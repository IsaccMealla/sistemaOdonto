import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';

class AsignacionesScreen extends StatefulWidget {
  @override
  _AsignacionesScreenState createState() => _AsignacionesScreenState();
}

class _AsignacionesScreenState extends State<AsignacionesScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  bool _vistaEstudiante = true; // true = por estudiante, false = por paciente
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtros avanzados
  String? _estadoSeleccionado;
  String? _materiaSeleccionada;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  void initState() {
    super.initState();
    _future = api.fetchAsignaciones();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = api.fetchAsignaciones();
    });
  }

  List<dynamic> _filterList(List<dynamic> list) {
    var filtered = list;

    // Filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final estudianteNombre =
            (item['estudiante_nombre'] ?? '').toString().toLowerCase();
        final estudianteCodigo =
            (item['estudiante_codigo'] ?? '').toString().toLowerCase();
        final pacienteNombre =
            (item['paciente_nombre'] ?? '').toString().toLowerCase();
        final pacienteCelular =
            (item['paciente_celular'] ?? '').toString().toLowerCase();
        final docenteNombre =
            (item['docente_nombre'] ?? '').toString().toLowerCase();
        final materia = (item['materia'] ?? '').toString().toLowerCase();
        final estado = (item['estado'] ?? '').toString().toLowerCase();

        return estudianteNombre.contains(_searchQuery) ||
            estudianteCodigo.contains(_searchQuery) ||
            pacienteNombre.contains(_searchQuery) ||
            pacienteCelular.contains(_searchQuery) ||
            docenteNombre.contains(_searchQuery) ||
            materia.contains(_searchQuery) ||
            estado.contains(_searchQuery);
      }).toList();
    }

    // Filtro por estado
    if (_estadoSeleccionado != null && _estadoSeleccionado!.isNotEmpty) {
      filtered = filtered
          .where((item) => item['estado'] == _estadoSeleccionado)
          .toList();
    }

    // Filtro por materia
    if (_materiaSeleccionada != null && _materiaSeleccionada!.isNotEmpty) {
      filtered = filtered
          .where((item) => item['materia'] == _materiaSeleccionada)
          .toList();
    }

    // Filtro por rango de fechas
    if (_fechaDesde != null || _fechaHasta != null) {
      filtered = filtered.where((item) {
        final fechaAsignacion = item['fecha_asignacion'];
        if (fechaAsignacion == null) return false;
        try {
          final fecha = DateTime.parse(fechaAsignacion);
          if (_fechaDesde != null && fecha.isBefore(_fechaDesde!)) return false;
          if (_fechaHasta != null &&
              fecha.isAfter(_fechaHasta!.add(Duration(days: 1)))) return false;
          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return filtered;
  }

  /// Limpiar todos los filtros
  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _estadoSeleccionado = null;
      _materiaSeleccionada = null;
      _fechaDesde = null;
      _fechaHasta = null;
    });
  }

  /// Contar filtros activos
  int _contarFiltrosActivos() {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_estadoSeleccionado != null && _estadoSeleccionado!.isNotEmpty) count++;
    if (_materiaSeleccionada != null && _materiaSeleccionada!.isNotEmpty)
      count++;
    if (_fechaDesde != null || _fechaHasta != null) count++;
    return count;
  }

  /// Exportar a Excel
  Future<void> _exportarExcel(List<dynamic> asignaciones) async {
    try {
      var excel = excel_lib.Excel.createExcel();
      excel_lib.Sheet sheet = excel['Asignaciones'];

      // Estilos
      final headerStyle = excel_lib.CellStyle(
        bold: true,
        backgroundColorHex: excel_lib.ExcelColor.blue,
        fontColorHex: excel_lib.ExcelColor.white,
      );

      // Encabezados
      final headers = [
        'Estudiante',
        'Código Estudiante',
        'Paciente',
        'Celular Paciente',
        'Docente',
        'Materia',
        'Estado',
        'Fecha Asignación',
        'Fecha Inicio',
        'Fecha Fin',
      ];

      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(
          excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = excel_lib.TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Datos
      for (int i = 0; i < asignaciones.length; i++) {
        final a = asignaciones[i];
        final rowIndex = i + 1;

        final valores = [
          a['estudiante_nombre'] ?? '',
          a['estudiante_codigo'] ?? '',
          a['paciente_nombre'] ?? '',
          a['paciente_celular'] ?? '',
          a['docente_nombre'] ?? '',
          a['materia'] ?? '',
          _getEstadoLabel(a['estado'] ?? ''),
          a['fecha_asignacion'] != null
              ? DateFormat('dd/MM/yyyy')
                  .format(DateTime.parse(a['fecha_asignacion']))
              : '',
          a['fecha_inicio'] != null
              ? DateFormat('dd/MM/yyyy')
                  .format(DateTime.parse(a['fecha_inicio']))
              : '',
          a['fecha_fin'] != null
              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(a['fecha_fin']))
              : '',
        ];

        for (int j = 0; j < valores.length; j++) {
          var cell = sheet.cell(
            excel_lib.CellIndex.indexByColumnRow(
                columnIndex: j, rowIndex: rowIndex),
          );
          cell.value = excel_lib.TextCellValue(valores[j].toString());
        }
      }

      // Ajustar ancho de columnas
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Guardar y descargar
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final blob = html.Blob([
          fileBytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download',
              'asignaciones_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel exportado exitosamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al exportar Excel: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  /// Exportar a PDF
  Future<void> _exportarPDF(List<dynamic> asignaciones) async {
    try {
      final pdf = pw.Document();

      // Dividir en páginas si hay muchos registros
      final itemsPerPage = 18;
      final totalPages = (asignaciones.length / itemsPerPage).ceil();

      for (int page = 0; page < totalPages; page++) {
        final startIndex = page * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage < asignaciones.length)
            ? startIndex + itemsPerPage
            : asignaciones.length;
        final pageData = asignaciones.sublist(startIndex, endIndex);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Listado de Asignaciones',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Total de registros: ${asignaciones.length} | Página ${page + 1} de $totalPages',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Table.fromTextArray(
                    border: pw.TableBorder.all(),
                    headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 7),
                    cellStyle: pw.TextStyle(fontSize: 6),
                    cellHeight: 18,
                    headerDecoration:
                        pw.BoxDecoration(color: PdfColors.grey300),
                    headers: [
                      'Estudiante',
                      'Paciente',
                      'Docente',
                      'Materia',
                      'Estado',
                      'Fecha Asig.'
                    ],
                    data: pageData.map((a) {
                      return [
                        a['estudiante_nombre'] ?? '',
                        a['paciente_nombre'] ?? '',
                        a['docente_nombre'] ?? '',
                        a['materia'] ?? '',
                        _getEstadoLabel(a['estado'] ?? ''),
                        a['fecha_asignacion'] != null
                            ? DateFormat('dd/MM/yy')
                                .format(DateTime.parse(a['fecha_asignacion']))
                            : '',
                      ];
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Mostrar diálogo de impresión/guardado
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'asignaciones_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _toggleVista() {
    setState(() {
      _vistaEstudiante = !_vistaEstudiante;
    });
  }

  Map<String, List<dynamic>> _agruparPorPaciente(List<dynamic> asignaciones) {
    Map<String, List<dynamic>> agrupadas = {};

    for (var asignacion in asignaciones) {
      String pacienteId = asignacion['paciente'] ?? '';
      if (pacienteId.isEmpty) continue;

      if (!agrupadas.containsKey(pacienteId)) {
        agrupadas[pacienteId] = [];
      }
      agrupadas[pacienteId]!.add(asignacion);
    }

    return agrupadas;
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'activa':
        return Colors.blue;
      case 'en_progreso':
        return Colors.orange;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'activa':
        return 'Activa';
      case 'en_progreso':
        return 'En Progreso';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vistaEstudiante
            ? 'Asignaciones por Estudiante'
            : 'Asignaciones por Paciente'),
        actions: [
          IconButton(
            icon: Icon(_vistaEstudiante ? Icons.person : Icons.school),
            tooltip:
                _vistaEstudiante ? 'Ver por Paciente' : 'Ver por Estudiante',
            onPressed: _toggleVista,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Papelera',
            onPressed: () {
              context
                  .read<MenuAppController>()
                  .setPage('papelera_asignaciones');
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Barra de búsqueda y exportación
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText:
                                    'Buscar por estudiante, paciente, docente, materia o estado...',
                                prefixIcon: Icon(Icons.search),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () =>
                                            _searchController.clear(),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              _future.then((allList) {
                                final list = _filterList(allList);
                                _exportarExcel(list);
                              });
                            },
                            icon: Icon(Icons.file_download),
                            label: Text('Excel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              _future.then((allList) {
                                final list = _filterList(allList);
                                _exportarPDF(list);
                              });
                            },
                            icon: Icon(Icons.picture_as_pdf),
                            label: Text('PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Filtros avanzados
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.filter_list, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Filtros',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Spacer(),
                                  if (_contarFiltrosActivos() > 0)
                                    Chip(
                                      label: Text(
                                          '${_contarFiltrosActivos()} activos'),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                  SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: _limpiarFiltros,
                                    icon: Icon(Icons.clear_all, size: 18),
                                    label: Text('Limpiar'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _estadoSeleccionado,
                                      decoration: InputDecoration(
                                        labelText: 'Estado',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                            value: null, child: Text('Todos')),
                                        DropdownMenuItem(
                                            value: 'activa',
                                            child: Text('Activa')),
                                        DropdownMenuItem(
                                            value: 'en_progreso',
                                            child: Text('En Progreso')),
                                        DropdownMenuItem(
                                            value: 'completada',
                                            child: Text('Completada')),
                                        DropdownMenuItem(
                                            value: 'cancelada',
                                            child: Text('Cancelada')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _estadoSeleccionado = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _materiaSeleccionada,
                                      decoration: InputDecoration(
                                        labelText: 'Materia',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                            value: null, child: Text('Todas')),
                                        DropdownMenuItem(
                                            value: 'Operatoria Dental',
                                            child: Text('Operatoria Dental')),
                                        DropdownMenuItem(
                                            value: 'Cirugía Oral',
                                            child: Text('Cirugía Oral')),
                                        DropdownMenuItem(
                                            value: 'Endodoncia',
                                            child: Text('Endodoncia')),
                                        DropdownMenuItem(
                                            value: 'Periodoncia',
                                            child: Text('Periodoncia')),
                                        DropdownMenuItem(
                                            value: 'Prótesis',
                                            child: Text('Prótesis')),
                                        DropdownMenuItem(
                                            value: 'Ortodoncia',
                                            child: Text('Ortodoncia')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _materiaSeleccionada = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final fecha = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _fechaDesde ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        );
                                        if (fecha != null) {
                                          setState(() {
                                            _fechaDesde = fecha;
                                          });
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Fecha Desde',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          suffixIcon: _fechaDesde != null
                                              ? IconButton(
                                                  icon: Icon(Icons.clear,
                                                      size: 18),
                                                  onPressed: () {
                                                    setState(() {
                                                      _fechaDesde = null;
                                                    });
                                                  },
                                                )
                                              : Icon(Icons.calendar_today),
                                        ),
                                        child: Text(
                                          _fechaDesde != null
                                              ? DateFormat('dd/MM/yyyy')
                                                  .format(_fechaDesde!)
                                              : 'Seleccionar',
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final fecha = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _fechaHasta ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        );
                                        if (fecha != null) {
                                          setState(() {
                                            _fechaHasta = fecha;
                                          });
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Fecha Hasta',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          suffixIcon: _fechaHasta != null
                                              ? IconButton(
                                                  icon: Icon(Icons.clear,
                                                      size: 18),
                                                  onPressed: () {
                                                    setState(() {
                                                      _fechaHasta = null;
                                                    });
                                                  },
                                                )
                                              : Icon(Icons.calendar_today),
                                        ),
                                        child: Text(
                                          _fechaHasta != null
                                              ? DateFormat('dd/MM/yyyy')
                                                  .format(_fechaHasta!)
                                              : 'Seleccionar',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: _future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Center(child: CircularProgressIndicator());
                          if (snapshot.hasError)
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          final allList = snapshot.data ?? [];
                          final list = _filterList(allList);
                          if (allList.isEmpty)
                            return RefreshIndicator(
                                onRefresh: _refresh,
                                child: ListView(children: [
                                  SizedBox(height: 40),
                                  Center(child: Text('No hay asignaciones aún'))
                                ]));

                          if (list.isEmpty)
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No se encontraron resultados',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Intenta con otros términos de búsqueda',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );

                          return _vistaEstudiante
                              ? _buildVistaEstudiante(list)
                              : _buildVistaPaciente(list);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          context.read<MenuAppController>().setPage('asignacion_form');
        },
      ),
    );
  }

  // Vista por Estudiante (tabla)
  Widget _buildVistaEstudiante(List<dynamic> list) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Card(
        margin: EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Estudiante')),
              DataColumn(label: Text('Paciente')),
              DataColumn(label: Text('Docente')),
              DataColumn(label: Text('Materia')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Fecha Asignación')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: list.map((item) {
              String fmt(dynamic v) => (v ?? '').toString();
              String estado = item['estado'] ?? 'activa';

              return DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt(item['estudiante_nombre']),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item['estudiante_codigo'] != null)
                      Text(
                        fmt(item['estudiante_codigo']),
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt(item['paciente_nombre']),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item['paciente_celular'] != null)
                      Text(
                        fmt(item['paciente_celular']),
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt(item['docente_nombre']),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item['docente_especialidad'] != null)
                      Text(
                        fmt(item['docente_especialidad']),
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                )),
                DataCell(Text(
                  fmt(item['materia']),
                  style: TextStyle(fontWeight: FontWeight.w500),
                )),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(estado),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getEstadoLabel(estado),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(fmt(item['fecha_asignacion']).split('T')[0])),
                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: Icon(Icons.visibility,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: () => context
                        .read<MenuAppController>()
                        .setPageWithArgs('asignacion_form',
                            {'asignacion': item, 'viewOnly': true}),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: Theme.of(context).colorScheme.secondary),
                    onPressed: () => context
                        .read<MenuAppController>()
                        .setPageWithArgs(
                            'asignacion_form', {'asignacion': item}),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _eliminarAsignacion(item),
                  ),
                ])),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Vista por Paciente (agrupada)
  Widget _buildVistaPaciente(List<dynamic> list) {
    final agrupadas = _agruparPorPaciente(list);
    final pacientes = agrupadas.entries.toList();

    pacientes.sort((a, b) {
      final nombreA = a.value.first['paciente_nombre'] ?? '';
      final nombreB = b.value.first['paciente_nombre'] ?? '';
      return nombreA.compareTo(nombreB);
    });

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: pacientes.length,
        itemBuilder: (context, index) {
          final asignaciones = pacientes[index].value;
          final primerAsignacion = asignaciones.first;

          final pacienteNombre =
              primerAsignacion['paciente_nombre'] ?? 'Sin nombre';
          final pacienteCelular = primerAsignacion['paciente_celular'] ?? '';

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  pacienteNombre.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                pacienteNombre,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pacienteCelular.isNotEmpty)
                    Text('Tel: $pacienteCelular',
                        style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text(
                    '${asignaciones.length} asignación${asignaciones.length != 1 ? 'es' : ''}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              children: [
                Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: asignaciones.length,
                  itemBuilder: (context, idx) {
                    final asig = asignaciones[idx];
                    final estado = asig['estado'] ?? 'activa';

                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getEstadoColor(estado).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.medical_services,
                            color: _getEstadoColor(estado),
                            size: 20,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              asig['materia'] ?? 'Sin materia',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getEstadoColor(estado),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getEstadoLabel(estado),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.school, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Estudiante: ${asig['estudiante_nombre'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          if (asig['estudiante_codigo'] != null) ...[
                            SizedBox(height: 2),
                            Text(
                              '  Código: ${asig['estudiante_codigo']}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Docente: ${asig['docente_nombre'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'Asignado: ${asig['fecha_asignacion']?.toString().split('T')[0] ?? 'N/A'}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'ver') {
                            context.read<MenuAppController>().setPageWithArgs(
                              'asignacion_form',
                              {'asignacion': asig, 'viewOnly': true},
                            );
                          } else if (value == 'editar') {
                            context.read<MenuAppController>().setPageWithArgs(
                              'asignacion_form',
                              {'asignacion': asig},
                            );
                          } else if (value == 'eliminar') {
                            _eliminarAsignacion(asig);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'ver',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18),
                                SizedBox(width: 8),
                                Text('Ver'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _eliminarAsignacion(Map<String, dynamic> asignacion) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('¿Eliminar esta asignación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await api.softDeleteAsignacion(asignacion['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asignación eliminada')),
        );
        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
