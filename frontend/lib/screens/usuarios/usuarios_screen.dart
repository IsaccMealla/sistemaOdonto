import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/permission_service.dart';
import '../../controllers/menu_app_controller.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';

class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtros avanzados
  String? _rolSeleccionado;
  bool? _activoSeleccionado;
  String? _semestreSeleccionado;

  @override
  void initState() {
    super.initState();
    _future = api.fetchUsuarios();
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
      _future = api.fetchUsuarios();
    });
  }

  List<dynamic> _filterList(List<dynamic> list) {
    var filtered = list;

    // Filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final username = (item['username'] ?? '').toString().toLowerCase();
        final email = (item['email'] ?? '').toString().toLowerCase();
        final rol = (item['rol_principal'] ?? '').toString().toLowerCase();
        final codigo =
            (item['codigo_estudiante'] ?? '').toString().toLowerCase();
        final nombres = (item['nombres'] ?? '').toString().toLowerCase();
        final apellidos = (item['apellidos'] ?? '').toString().toLowerCase();

        return username.contains(_searchQuery) ||
            email.contains(_searchQuery) ||
            rol.contains(_searchQuery) ||
            codigo.contains(_searchQuery) ||
            nombres.contains(_searchQuery) ||
            apellidos.contains(_searchQuery);
      }).toList();
    }

    // Filtro por rol
    if (_rolSeleccionado != null && _rolSeleccionado!.isNotEmpty) {
      filtered = filtered
          .where((item) => item['rol_principal'] == _rolSeleccionado)
          .toList();
    }

    // Filtro por activo
    if (_activoSeleccionado != null) {
      filtered = filtered
          .where((item) => item['activo'] == _activoSeleccionado)
          .toList();
    }

    // Filtro por semestre (solo para estudiantes)
    if (_semestreSeleccionado != null && _semestreSeleccionado!.isNotEmpty) {
      filtered = filtered.where((item) {
        if (item['rol_principal'] == 'Estudiante') {
          return item['semestre']?.toString() == _semestreSeleccionado;
        }
        return false;
      }).toList();
    }

    return filtered;
  }

  /// Limpiar todos los filtros
  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _rolSeleccionado = null;
      _activoSeleccionado = null;
      _semestreSeleccionado = null;
    });
  }

  /// Contar filtros activos
  int _contarFiltrosActivos() {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_rolSeleccionado != null && _rolSeleccionado!.isNotEmpty) count++;
    if (_activoSeleccionado != null) count++;
    if (_semestreSeleccionado != null && _semestreSeleccionado!.isNotEmpty)
      count++;
    return count;
  }

  /// Exportar a Excel
  Future<void> _exportarExcel(List<dynamic> usuarios) async {
    try {
      var excel = excel_lib.Excel.createExcel();
      excel_lib.Sheet sheet = excel['Usuarios'];

      // Estilos
      final headerStyle = excel_lib.CellStyle(
        bold: true,
        backgroundColorHex: excel_lib.ExcelColor.blue,
        fontColorHex: excel_lib.ExcelColor.white,
      );

      // Encabezados
      final headers = [
        'Usuario',
        'Email',
        'Nombres',
        'Apellidos',
        'Rol Principal',
        'Código Estudiante',
        'Semestre',
        'Especialidad',
        'Activo',
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
      for (int i = 0; i < usuarios.length; i++) {
        final u = usuarios[i];
        final rowIndex = i + 1;

        final valores = [
          u['username'] ?? '',
          u['email'] ?? '',
          u['nombres'] ?? '',
          u['apellidos'] ?? '',
          u['rol_principal'] ?? '',
          u['codigo_estudiante'] ?? '',
          u['semestre']?.toString() ?? '',
          u['especialidad'] ?? '',
          (u['activo'] == true) ? 'Sí' : 'No',
          u['creado_en'] != null
              ? DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(u['creado_en']))
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
              'usuarios_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx')
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
  Future<void> _exportarPDF(List<dynamic> usuarios) async {
    try {
      final pdf = pw.Document();

      // Dividir en páginas si hay muchos registros
      final itemsPerPage = 20;
      final totalPages = (usuarios.length / itemsPerPage).ceil();

      for (int page = 0; page < totalPages; page++) {
        final startIndex = page * itemsPerPage;
        final endIndex = (startIndex + itemsPerPage < usuarios.length)
            ? startIndex + itemsPerPage
            : usuarios.length;
        final pageData = usuarios.sublist(startIndex, endIndex);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Listado de Usuarios',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Total de registros: ${usuarios.length} | Página ${page + 1} de $totalPages',
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
                      'Usuario',
                      'Email',
                      'Nombres',
                      'Apellidos',
                      'Rol',
                      'Código',
                      'Activo'
                    ],
                    data: pageData.map((u) {
                      return [
                        u['username'] ?? '',
                        u['email'] ?? '',
                        u['nombres'] ?? '',
                        u['apellidos'] ?? '',
                        u['rol_principal'] ?? '',
                        u['codigo_estudiante'] ?? '',
                        (u['activo'] == true) ? 'Sí' : 'No',
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
            'usuarios_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al exportar PDF: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'Administrador':
        return Colors.deepPurple;
      case 'Docente':
        return Colors.blue;
      case 'Estudiante':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Papelera',
            onPressed: () {
              context.read<MenuAppController>().setPage('papelera_usuarios');
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
                                    'Buscar por usuario, email, nombres, apellidos, rol o código...',
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
                                      value: _rolSeleccionado,
                                      decoration: InputDecoration(
                                        labelText: 'Rol',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                            value: null, child: Text('Todos')),
                                        DropdownMenuItem(
                                            value: 'Administrador',
                                            child: Text('Administrador')),
                                        DropdownMenuItem(
                                            value: 'Docente',
                                            child: Text('Docente')),
                                        DropdownMenuItem(
                                            value: 'Estudiante',
                                            child: Text('Estudiante')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _rolSeleccionado = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<bool>(
                                      value: _activoSeleccionado,
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
                                            value: true,
                                            child: Text('Activos')),
                                        DropdownMenuItem(
                                            value: false,
                                            child: Text('Inactivos')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _activoSeleccionado = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _semestreSeleccionado,
                                      decoration: InputDecoration(
                                        labelText: 'Semestre (Estudiantes)',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                            value: null, child: Text('Todos')),
                                        for (int i = 1; i <= 10; i++)
                                          DropdownMenuItem(
                                              value: i.toString(),
                                              child: Text('$i° Semestre')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _semestreSeleccionado = value;
                                        });
                                      },
                                    ),
                                  ),
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

                          if (allList.isEmpty)
                            return RefreshIndicator(
                                onRefresh: _refresh,
                                child: ListView(children: [
                                  SizedBox(height: 40),
                                  Center(child: Text('No hay usuarios aún'))
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

                          return RefreshIndicator(
                            onRefresh: _refresh,
                            child: Card(
                              margin: EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('Usuario')),
                                    DataColumn(label: Text('Email')),
                                    DataColumn(label: Text('Rol')),
                                    DataColumn(label: Text('Creado')),
                                    DataColumn(label: Text('Acciones')),
                                  ],
                                  rows: list.map((item) {
                                    String fmt(dynamic v) =>
                                        (v ?? '').toString();
                                    String rolDisplay =
                                        item['rol_principal'] ?? '';
                                    bool tieneRol = rolDisplay.isNotEmpty;

                                    return DataRow(cells: [
                                      DataCell(Text(fmt(item['username']))),
                                      DataCell(Text(fmt(item['email']))),
                                      DataCell(
                                        tieneRol
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      _getRolColor(rolDisplay),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  rolDisplay,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                'Sin asignar',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                      ),
                                      DataCell(Text(fmt(item['creado_en']))),
                                      DataCell(Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.visibility,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                              onPressed: () => context
                                                  .read<MenuAppController>()
                                                  .setPageWithArgs(
                                                      'usuario_form', {
                                                'usuario': item,
                                                'viewOnly': true
                                              }),
                                            ),
                                            if (PermissionService
                                                .checkPermissionSync(
                                                    'usuarios.editar'))
                                              IconButton(
                                                icon: Icon(Icons.edit,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                                onPressed: () => context
                                                    .read<MenuAppController>()
                                                    .setPageWithArgs(
                                                        'usuario_form',
                                                        {'usuario': item}),
                                              ),
                                            if (PermissionService
                                                .checkPermissionSync(
                                                    'usuarios.eliminar'))
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.redAccent),
                                                onPressed: () async {
                                                  final ok =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) =>
                                                        AlertDialog(
                                                      title: Text('Confirmar'),
                                                      content: Text(
                                                          '¿Eliminar usuario?'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    ctx, false),
                                                            child: Text(
                                                                'Cancelar')),
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    ctx, true),
                                                            child: Text(
                                                                'Eliminar')),
                                                      ],
                                                    ),
                                                  );
                                                  if (ok == true) {
                                                    try {
                                                      await api
                                                          .softDeleteUsuario(
                                                              item['id']
                                                                  .toString());
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Usuario eliminado')));
                                                      _refresh();
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Error: $e')));
                                                    }
                                                  }
                                                },
                                              ),
                                          ])),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
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
          PermissionService.checkPermissionSync('usuarios.crear')
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () async {
                    context.read<MenuAppController>().setPage('usuario_form');
                  },
                )
              : null,
    );
  }
}
