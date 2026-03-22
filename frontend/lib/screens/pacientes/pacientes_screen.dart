import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/permission_service.dart';
import '../../controllers/menu_app_controller.dart';
import 'papelera_pacientes_screen.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';

class PacientesScreen extends StatefulWidget {
  @override
  _PacientesScreenState createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtros avanzados
  String? _sexoSeleccionado;
  String? _estadoCivilSeleccionado;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  int? _edadMin;
  int? _edadMax;

  @override
  void initState() {
    super.initState();
    _future = api.fetchPacientes();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    // Escuchar cambios en permisos
    PermissionService.permissionsChanged.addListener(_onPermissionsChanged);
  }

  void _onPermissionsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    PermissionService.permissionsChanged.removeListener(_onPermissionsChanged);
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = api.fetchPacientes();
    });
  }

  List<dynamic> _filterList(List<dynamic> list) {
    var filtered = list;

    // Filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final nombres = (item['nombres'] ?? '').toString().toLowerCase();
        final apellidos = (item['apellidos'] ?? '').toString().toLowerCase();
        final ci = (item['ci'] ?? '').toString().toLowerCase();
        final celular = (item['celular'] ?? '').toString().toLowerCase();
        final email = (item['email'] ?? '').toString().toLowerCase();
        final direccion = (item['direccion'] ?? '').toString().toLowerCase();
        return nombres.contains(_searchQuery) ||
            apellidos.contains(_searchQuery) ||
            ci.contains(_searchQuery) ||
            celular.contains(_searchQuery) ||
            email.contains(_searchQuery) ||
            direccion.contains(_searchQuery);
      }).toList();
    }

    // Filtro por sexo
    if (_sexoSeleccionado != null && _sexoSeleccionado!.isNotEmpty) {
      filtered =
          filtered.where((item) => item['sexo'] == _sexoSeleccionado).toList();
    }

    // Filtro por estado civil
    if (_estadoCivilSeleccionado != null &&
        _estadoCivilSeleccionado!.isNotEmpty) {
      filtered = filtered
          .where((item) => item['estado_civil'] == _estadoCivilSeleccionado)
          .toList();
    }

    // Filtro por edad
    if (_edadMin != null || _edadMax != null) {
      filtered = filtered.where((item) {
        final edad = item['edad'];
        if (edad == null) return false;
        if (_edadMin != null && edad < _edadMin!) return false;
        if (_edadMax != null && edad > _edadMax!) return false;
        return true;
      }).toList();
    }

    // Filtro por rango de fechas
    if (_fechaDesde != null || _fechaHasta != null) {
      filtered = filtered.where((item) {
        final creadoEn = item['creado_en'];
        if (creadoEn == null) return false;
        try {
          final fecha = DateTime.parse(creadoEn);
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
      _sexoSeleccionado = null;
      _estadoCivilSeleccionado = null;
      _fechaDesde = null;
      _fechaHasta = null;
      _edadMin = null;
      _edadMax = null;
    });
  }

  /// Contar filtros activos
  int _contarFiltrosActivos() {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_sexoSeleccionado != null && _sexoSeleccionado!.isNotEmpty) count++;
    if (_estadoCivilSeleccionado != null &&
        _estadoCivilSeleccionado!.isNotEmpty) count++;
    if (_fechaDesde != null || _fechaHasta != null) count++;
    if (_edadMin != null || _edadMax != null) count++;
    return count;
  }

  /// Exportar a Excel
  Future<void> _exportarExcel(List<dynamic> pacientes) async {
    try {
      var excel = excel_lib.Excel.createExcel();
      excel_lib.Sheet sheet = excel['Pacientes'];

      // Estilos
      final headerStyle = excel_lib.CellStyle(
        bold: true,
        backgroundColorHex: excel_lib.ExcelColor.blue,
        fontColorHex: excel_lib.ExcelColor.white,
      );

      // Encabezados
      final headers = [
        'Nombres',
        'Apellidos',
        'CI',
        'Sexo',
        'Edad',
        'Fecha Nacimiento',
        'Estado Civil',
        'Email',
        'Celular',
        'Teléfono',
        'Dirección',
        'Ocupación',
        'Fecha Registro',
      ];

      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(
          excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = excel_lib.TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Datos
      for (int i = 0; i < pacientes.length; i++) {
        final p = pacientes[i];
        final rowIndex = i + 1;

        final valores = [
          p['nombres'] ?? '',
          p['apellidos'] ?? '',
          p['ci'] ?? '',
          p['sexo'] ?? '',
          p['edad']?.toString() ?? '',
          p['fecha_nacimiento'] ?? '',
          p['estado_civil'] ?? '',
          p['email'] ?? '',
          p['celular'] ?? '',
          p['telefono'] ?? '',
          p['direccion'] ?? '',
          p['ocupacion'] ?? '',
          p['creado_en'] != null
              ? DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(p['creado_en']))
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
              'pacientes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx')
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
  Future<void> _exportarPDF(List<dynamic> pacientes) async {
    try {
      final pdf = pw.Document();

      // Dividir en páginas si hay muchos registros
      final itemsPerPage = 20;
      final totalPages = (pacientes.length / itemsPerPage).ceil();

      for (int page = 0; page < totalPages; page++) {
        final startIndex = page * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage < pacientes.length)
            ? startIndex + itemsPerPage
            : pacientes.length;
        final pageData = pacientes.sublist(startIndex, endIndex);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Listado de Pacientes',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Total de registros: ${pacientes.length} | Página ${page + 1} de $totalPages',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Table.fromTextArray(
                    border: pw.TableBorder.all(),
                    headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 8),
                    cellStyle: pw.TextStyle(fontSize: 7),
                    cellHeight: 20,
                    headerDecoration:
                        pw.BoxDecoration(color: PdfColors.grey300),
                    headers: [
                      'Nombres',
                      'Apellidos',
                      'CI',
                      'Sexo',
                      'Edad',
                      'Celular',
                      'Email',
                      'Dirección'
                    ],
                    data: pageData.map((p) {
                      return [
                        p['nombres'] ?? '',
                        p['apellidos'] ?? '',
                        p['ci'] ?? '',
                        p['sexo'] ?? '',
                        p['edad']?.toString() ?? '',
                        p['celular'] ?? '',
                        p['email'] ?? '',
                        (p['direccion'] ?? '').toString().substring(
                            0,
                            (p['direccion'] ?? '').toString().length > 30
                                ? 30
                                : (p['direccion'] ?? '').toString().length),
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
            'pacientes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTable(List<dynamic> list) {
    final columns = [
      'Nombres',
      'Apellidos',
      'CI',
      'Edad',
      'Celular',
      'Ultima Consulta',
      'Antecedentes',
      'Acciones'
    ];

    return Card(
      margin: EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.6),
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary.withOpacity(0.12)),
              columns: columns
                  .map((c) => DataColumn(
                      label: Text(c,
                          style: TextStyle(fontWeight: FontWeight.w600))))
                  .toList(),
              rows: list.map((item) {
                String fmt(dynamic v) => (v ?? '').toString();
                return DataRow(cells: [
                  DataCell(Text(fmt(item['nombres']))),
                  DataCell(Text(fmt(item['apellidos']))),
                  DataCell(Text(fmt(item['ci']))),
                  DataCell(Text(fmt(item['edad']))),
                  DataCell(Text(fmt(item['celular']))),
                  DataCell(Text(fmt(item['ultima_consulta']))),
                  DataCell(
                    ElevatedButton.icon(
                      icon: Icon(Icons.medical_information, size: 16),
                      label: Text('Antecedentes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        // Navegar al módulo de antecedentes con el paciente seleccionado
                        context
                            .read<MenuAppController>()
                            .setPageWithArgs('antecedentes', {
                          'paciente_id': item['id'],
                          'paciente_nombre':
                              '${item['nombres']} ${item['apellidos']}',
                          'ver_antecedentes':
                              false // Ir directo a crear antecedentes
                        });
                      },
                    ),
                  ),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility,
                            color: Theme.of(context).colorScheme.primary),
                        tooltip: 'Ver',
                        onPressed: () {
                          context.read<MenuAppController>().setPageWithArgs(
                              'paciente_form',
                              {'paciente': item, 'viewOnly': true});
                        },
                      ),
                      if (PermissionService.checkPermissionSync(
                          'pacientes.editar'))
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Theme.of(context).colorScheme.secondary),
                          tooltip: 'Editar',
                          onPressed: () {
                            context.read<MenuAppController>().setPageWithArgs(
                                'paciente_form', {'paciente': item});
                          },
                        ),
                      if (PermissionService.checkPermissionSync(
                          'pacientes.eliminar'))
                        IconButton(
                          icon:
                              Icon(Icons.delete_outline, color: Colors.orange),
                          tooltip: 'Mover a papelera',
                          onPressed: () => _eliminarPaciente(item),
                        ),
                    ],
                  ))
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pacientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Ver papelera',
            onPressed: () => _navegarAPapelera(),
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
                                    'Buscar por nombres, apellidos, CI, celular, email...',
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
                                      value: _sexoSeleccionado,
                                      decoration: InputDecoration(
                                        labelText: 'Sexo',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                            value: null, child: Text('Todos')),
                                        DropdownMenuItem(
                                            value: 'M',
                                            child: Text('Masculino')),
                                        DropdownMenuItem(
                                            value: 'F',
                                            child: Text('Femenino')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _sexoSeleccionado = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _estadoCivilSeleccionado,
                                      decoration: InputDecoration(
                                        labelText: 'Estado Civil',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                            value: null, child: Text('Todos')),
                                        DropdownMenuItem(
                                            value: 'Soltero/a',
                                            child: Text('Soltero/a')),
                                        DropdownMenuItem(
                                            value: 'Casado/a',
                                            child: Text('Casado/a')),
                                        DropdownMenuItem(
                                            value: 'Divorciado/a',
                                            child: Text('Divorciado/a')),
                                        DropdownMenuItem(
                                            value: 'Viudo/a',
                                            child: Text('Viudo/a')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _estadoCivilSeleccionado = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Edad Mínima',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _edadMin = value.isEmpty
                                              ? null
                                              : int.tryParse(value);
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Edad Máxima',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _edadMax = value.isEmpty
                                              ? null
                                              : int.tryParse(value);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
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
                                  Spacer(),
                                  Spacer(),
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

                          if (allList.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: _refresh,
                              child: ListView(
                                children: [
                                  SizedBox(height: 40),
                                  Center(
                                      child: Text('No hay pacientes aún',
                                          style: TextStyle(fontSize: 16))),
                                ],
                              ),
                            );
                          }

                          if (list.isEmpty) {
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
                          }

                          return RefreshIndicator(
                              onRefresh: _refresh, child: _buildTable(list));
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
      floatingActionButton:
          PermissionService.checkPermissionSync('pacientes.crear')
              ? FloatingActionButton(
                  heroTag: 'addPaciente',
                  child: Icon(Icons.add),
                  onPressed: () async {
                    context.read<MenuAppController>().setPage('paciente_form');
                  },
                )
              : null,
    );
  }

  /// Eliminar paciente (eliminación lógica)
  Future<void> _eliminarPaciente(Map<String, dynamic> paciente) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mover a papelera'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Mover a la papelera el paciente:'),
            SizedBox(height: 8),
            Text(
              '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'El paciente se moverá a la papelera y podrá ser restaurado posteriormente.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Mover a papelera'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final resultado = await api.softDeletePaciente(paciente['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message'] ?? 'Paciente movido a papelera'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Ver papelera',
              textColor: Colors.white,
              onPressed: () => _navegarAPapelera(),
            ),
          ),
        );

        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al mover paciente: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navegar a la pantalla de papelera
  void _navegarAPapelera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PapeleraPacientesScreen(),
      ),
    ).then((_) => _refresh()); // Refrescar al volver
  }
}
