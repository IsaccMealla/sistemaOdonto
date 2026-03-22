import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'dart:typed_data';
import '../../constants.dart';
import '../../services/api_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({Key? key}) : super(key: key);

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String _tipoReporte =
      'pacientes'; // pacientes, tratamientos, academicas, seguimientos, planes_tratamiento

  // Datos de estadísticas
  Map<String, dynamic>? _estadisticas;

  // Filtros de fecha
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  // Filtros adicionales
  String? _estadoSeleccionado;
  String? _tipoTratamientoSeleccionado;
  String? _estudianteSeleccionado;
  String? _docenteSeleccionado;
  String? _generoSeleccionado;
  String? _rangoEdadSeleccionado;

  // Listas para dropdowns
  List<Map<String, dynamic>> _estudiantes = [];
  List<Map<String, dynamic>> _docentes = [];
  List<String> _tiposTratamiento = [];

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _cargarListas();
    _cargarEstadisticas();
  }

  Future<void> _cargarListas() async {
    try {
      // Cargar estudiantes
      final estudiantes =
          await _apiService.get('/api/reportes/lista_estudiantes/');
      setState(
          () => _estudiantes = List<Map<String, dynamic>>.from(estudiantes));

      // Cargar docentes
      final docentes = await _apiService.get('/api/reportes/lista_docentes/');
      setState(() => _docentes = List<Map<String, dynamic>>.from(docentes));

      // Cargar tipos de tratamiento
      final tipos = await _apiService.get('/api/reportes/tipos_tratamiento/');
      setState(() => _tiposTratamiento = List<String>.from(tipos));
    } catch (e) {
      print('Error al cargar listas: $e');
    }
  }

  Future<void> _cargarEstadisticas() async {
    setState(() => _isLoading = true);

    try {
      String url = '';
      Map<String, String> queryParams = {};

      if (_fechaInicio != null) {
        queryParams['fecha_inicio'] = _dateFormat.format(_fechaInicio!);
      }
      if (_fechaFin != null) {
        queryParams['fecha_fin'] = _dateFormat.format(_fechaFin!);
      }
      if (_estadoSeleccionado != null && _estadoSeleccionado!.isNotEmpty) {
        queryParams['estado'] = _estadoSeleccionado!;
      }
      if (_tipoTratamientoSeleccionado != null &&
          _tipoTratamientoSeleccionado!.isNotEmpty) {
        queryParams['tipo_registro'] = _tipoTratamientoSeleccionado!;
      }
      if (_estudianteSeleccionado != null &&
          _estudianteSeleccionado!.isNotEmpty) {
        queryParams['estudiante_id'] = _estudianteSeleccionado!;
      }
      if (_docenteSeleccionado != null && _docenteSeleccionado!.isNotEmpty) {
        queryParams['docente_id'] = _docenteSeleccionado!;
      }

      switch (_tipoReporte) {
        case 'pacientes':
          url = '/api/reportes/estadisticas_pacientes/';
          break;
        case 'tratamientos':
          url = '/api/reportes/estadisticas_tratamientos/';
          break;
        case 'academicas':
          url = '/api/reportes/estadisticas_academicas/';
          break;
        case 'seguimientos':
          url = '/api/reportes/estadisticas_seguimientos/';
          break;
        case 'planes_tratamiento':
          url = '/api/reportes/estadisticas_planes_tratamiento/';
          break;
      }

      final response = await _apiService.get(url, queryParameters: queryParams);

      setState(() {
        _estadisticas = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estadísticas: $e')),
        );
      }
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() => _fechaInicio = fecha);
      _cargarEstadisticas();
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() => _fechaFin = fecha);
      _cargarEstadisticas();
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
      _estadoSeleccionado = null;
      _tipoTratamientoSeleccionado = null;
      _estudianteSeleccionado = null;
      _docenteSeleccionado = null;
      _generoSeleccionado = null;
      _rangoEdadSeleccionado = null;
    });
    _cargarEstadisticas();
  }

  Future<void> _exportarExcel() async {
    if (_estadisticas == null) return;

    try {
      var excelFile = excel_lib.Excel.createExcel();
      var sheet = excelFile['Reporte'];

      // Título
      sheet.appendRow([
        excel_lib.TextCellValue('REPORTE DE ${_tipoReporte.toUpperCase()}')
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue(
            'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}')
      ]);
      sheet.appendRow([excel_lib.TextCellValue('')]);

      if (_tipoReporte == 'pacientes') {
        _exportarPacientesExcel(sheet);
      } else if (_tipoReporte == 'tratamientos') {
        _exportarTratamientosExcel(sheet);
      } else if (_tipoReporte == 'academicas') {
        _exportarAcademicasExcel(sheet);
      } else if (_tipoReporte == 'planes_tratamiento') {
        _exportarPlanesTratamientoExcel(sheet);
      }

      // Descargar archivo
      var bytes = excelFile.encode();
      if (bytes != null) {
        final blob = html.Blob([Uint8List.fromList(bytes)]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'reporte_$_tipoReporte.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reporte Excel descargado')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar Excel: $e')),
        );
      }
    }
  }

  void _exportarPacientesExcel(excel_lib.Sheet sheet) {
    sheet.appendRow([
      excel_lib.TextCellValue('Total de Pacientes'),
      excel_lib.IntCellValue(_estadisticas!['total_pacientes'])
    ]);
    sheet.appendRow([excel_lib.TextCellValue('')]);

    // Por género
    sheet.appendRow([excel_lib.TextCellValue('DISTRIBUCIÓN POR GÉNERO')]);
    sheet.appendRow([
      excel_lib.TextCellValue('Género'),
      excel_lib.TextCellValue('Cantidad')
    ]);

    final porGenero = _estadisticas!['por_genero'] as Map<String, dynamic>;
    porGenero.forEach((genero, cantidad) {
      sheet.appendRow(
          [excel_lib.TextCellValue(genero), excel_lib.IntCellValue(cantidad)]);
    });

    sheet.appendRow([excel_lib.TextCellValue('')]);

    // Por rango de edad
    sheet.appendRow([excel_lib.TextCellValue('DISTRIBUCIÓN POR EDAD')]);
    sheet.appendRow([
      excel_lib.TextCellValue('Rango'),
      excel_lib.TextCellValue('Cantidad')
    ]);

    final porEdad = _estadisticas!['por_rango_edad'] as Map<String, dynamic>;
    porEdad.forEach((rango, cantidad) {
      sheet.appendRow(
          [excel_lib.TextCellValue(rango), excel_lib.IntCellValue(cantidad)]);
    });

    sheet.appendRow([excel_lib.TextCellValue('')]);

    // Por mes
    sheet.appendRow([excel_lib.TextCellValue('PACIENTES POR MES')]);
    sheet.appendRow([
      excel_lib.TextCellValue('Mes'),
      excel_lib.TextCellValue('Nuevos Pacientes')
    ]);

    final porMes = _estadisticas!['por_mes'] as List<dynamic>;
    for (var item in porMes) {
      sheet.appendRow([
        excel_lib.TextCellValue(item['mes']),
        excel_lib.IntCellValue(item['total'])
      ]);
    }
  }

  void _exportarTratamientosExcel(excel_lib.Sheet sheet) {
    sheet.appendRow([
      excel_lib.TextCellValue('Total de Tratamientos'),
      excel_lib.IntCellValue(_estadisticas!['total_tratamientos'])
    ]);
    sheet.appendRow([excel_lib.TextCellValue('')]);

    // Por tipo
    sheet.appendRow([excel_lib.TextCellValue('TRATAMIENTOS POR TIPO')]);
    sheet.appendRow(
        [excel_lib.TextCellValue('Tipo'), excel_lib.TextCellValue('Cantidad')]);

    final porTipo = _estadisticas!['por_tipo'] as Map<String, dynamic>;
    porTipo.forEach((tipo, cantidad) {
      sheet.appendRow(
          [excel_lib.TextCellValue(tipo), excel_lib.IntCellValue(cantidad)]);
    });

    sheet.appendRow([excel_lib.TextCellValue('')]);

    // Por mes
    sheet.appendRow([excel_lib.TextCellValue('TRATAMIENTOS POR MES')]);
    sheet.appendRow(
        [excel_lib.TextCellValue('Mes'), excel_lib.TextCellValue('Cantidad')]);

    final porMes = _estadisticas!['por_mes'] as List<dynamic>;
    for (var item in porMes) {
      sheet.appendRow([
        excel_lib.TextCellValue(item['mes']),
        excel_lib.IntCellValue(item['total'])
      ]);
    }
  }

  void _exportarAcademicasExcel(excel_lib.Sheet sheet) {
    sheet.appendRow([
      excel_lib.TextCellValue('Total de Asignaciones'),
      excel_lib.IntCellValue(_estadisticas!['total_asignaciones'])
    ]);
    sheet.appendRow([excel_lib.TextCellValue('')]);

    // Top estudiantes
    sheet.appendRow([excel_lib.TextCellValue('TOP 10 ESTUDIANTES')]);
    sheet.appendRow([
      excel_lib.TextCellValue('Estudiante'),
      excel_lib.TextCellValue('Pacientes')
    ]);

    final topEstudiantes = _estadisticas!['top_estudiantes'] as List<dynamic>;
    for (var item in topEstudiantes) {
      sheet.appendRow([
        excel_lib.TextCellValue(item['nombre']),
        excel_lib.IntCellValue(item['pacientes'])
      ]);
    }

    sheet.appendRow([excel_lib.TextCellValue('')]);

    // Top docentes
    sheet.appendRow([excel_lib.TextCellValue('TOP 10 DOCENTES')]);
    sheet.appendRow([
      excel_lib.TextCellValue('Docente'),
      excel_lib.TextCellValue('Pacientes Supervisados')
    ]);

    final topDocentes = _estadisticas!['top_docentes'] as List<dynamic>;
    for (var item in topDocentes) {
      sheet.appendRow([
        excel_lib.TextCellValue(item['nombre']),
        excel_lib.IntCellValue(item['pacientes'])
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reportes y Estadísticas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _exportarExcel,
                    icon: const Icon(Icons.download),
                    label: const Text('Exportar Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),

          // Filtros
          Card(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_fechaInicio != null ||
                          _fechaFin != null ||
                          _estadoSeleccionado != null ||
                          _tipoTratamientoSeleccionado != null ||
                          _estudianteSeleccionado != null ||
                          _docenteSeleccionado != null)
                        TextButton.icon(
                          onPressed: _limpiarFiltros,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpiar Filtros'),
                        ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),

                  // Primera fila de filtros
                  Row(
                    children: [
                      // Tipo de reporte
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _tipoReporte,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Reporte',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'pacientes',
                              child: Text('Pacientes'),
                            ),
                            DropdownMenuItem(
                              value: 'tratamientos',
                              child: Text('Tratamientos'),
                            ),
                            DropdownMenuItem(
                              value: 'planes_tratamiento',
                              child: Text('Planes de Tratamiento'),
                            ),
                            DropdownMenuItem(
                              value: 'academicas',
                              child: Text('Académicas'),
                            ),
                            DropdownMenuItem(
                              value: 'seguimientos',
                              child: Text('Seguimientos'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _tipoReporte = value;
                                _limpiarFiltros();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: defaultPadding),

                      // Fecha inicio
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: _seleccionarFechaInicio,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha Inicio',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _fechaInicio != null
                                  ? _dateFormat.format(_fechaInicio!)
                                  : 'Seleccionar',
                              style: TextStyle(
                                color:
                                    _fechaInicio != null ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: defaultPadding),

                      // Fecha fin
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: _seleccionarFechaFin,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha Fin',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _fechaFin != null
                                  ? _dateFormat.format(_fechaFin!)
                                  : 'Seleccionar',
                              style: TextStyle(
                                color: _fechaFin != null ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Segunda fila de filtros (específicos por tipo)
                  if (_tipoReporte == 'tratamientos' ||
                      _tipoReporte == 'academicas' ||
                      _tipoReporte == 'seguimientos') ...[
                    const SizedBox(height: defaultPadding),
                    Row(
                      children: [
                        // Estado
                        if (_tipoReporte == 'academicas' ||
                            _tipoReporte == 'tratamientos')
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _estadoSeleccionado,
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text('Todos')),
                                if (_tipoReporte == 'academicas') ...[
                                  const DropdownMenuItem(
                                      value: 'activa', child: Text('Activa')),
                                  const DropdownMenuItem(
                                      value: 'en_progreso',
                                      child: Text('En Progreso')),
                                  const DropdownMenuItem(
                                      value: 'completada',
                                      child: Text('Completada')),
                                  const DropdownMenuItem(
                                      value: 'cancelada',
                                      child: Text('Cancelada')),
                                ],
                                if (_tipoReporte == 'tratamientos') ...[
                                  const DropdownMenuItem(
                                      value: 'completado',
                                      child: Text('Completado')),
                                  const DropdownMenuItem(
                                      value: 'en_progreso',
                                      child: Text('En Progreso')),
                                  const DropdownMenuItem(
                                      value: 'pendiente',
                                      child: Text('Pendiente')),
                                ],
                              ],
                              onChanged: (value) {
                                setState(() => _estadoSeleccionado = value);
                                _cargarEstadisticas();
                              },
                            ),
                          ),
                        if (_tipoReporte == 'academicas' ||
                            _tipoReporte == 'tratamientos')
                          const SizedBox(width: defaultPadding),

                        // Tipo de tratamiento
                        if (_tipoReporte == 'tratamientos')
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _tipoTratamientoSeleccionado,
                              decoration: const InputDecoration(
                                labelText: 'Tipo Tratamiento',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text('Todos')),
                                ..._tiposTratamiento.map((tipo) =>
                                    DropdownMenuItem(
                                        value: tipo, child: Text(tipo))),
                              ],
                              onChanged: (value) {
                                setState(
                                    () => _tipoTratamientoSeleccionado = value);
                                _cargarEstadisticas();
                              },
                            ),
                          ),
                        if (_tipoReporte == 'tratamientos')
                          const SizedBox(width: defaultPadding),

                        // Estudiante
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _estudianteSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Estudiante',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('Todos')),
                              ..._estudiantes.map((est) => DropdownMenuItem(
                                    value: est['id'],
                                    child: Text(est['nombre']),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() => _estudianteSeleccionado = value);
                              _cargarEstadisticas();
                            },
                          ),
                        ),
                        const SizedBox(width: defaultPadding),

                        // Docente
                        if (_tipoReporte == 'academicas')
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _docenteSeleccionado,
                              decoration: const InputDecoration(
                                labelText: 'Docente',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text('Todos')),
                                ..._docentes.map((doc) => DropdownMenuItem(
                                      value: doc['id'],
                                      child: Text(doc['nombre']),
                                    )),
                              ],
                              onChanged: (value) {
                                setState(() => _docenteSeleccionado = value);
                                _cargarEstadisticas();
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: defaultPadding),

          // Contenido
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _estadisticas == null
                    ? const Center(child: Text('No hay datos disponibles'))
                    : _construirContenido(),
          ),
        ],
      ),
    );
  }

  Widget _construirContenido() {
    switch (_tipoReporte) {
      case 'pacientes':
        return _construirReportePacientes();
      case 'tratamientos':
        return _construirReporteTratamientos();
      case 'planes_tratamiento':
        return _construirReportePlanesTratamiento();
      case 'academicas':
        return _construirReporteAcademicas();
      case 'seguimientos':
        return _construirReporteSeguimientos();
      default:
        return const Center(child: Text('Tipo de reporte no reconocido'));
    }
  }

  Widget _construirReportePacientes() {
    final totalPacientes = _estadisticas!['total_pacientes'] as int;
    final porGenero = _estadisticas!['por_genero'] as Map<String, dynamic>;
    final porMes = _estadisticas!['por_mes'] as List<dynamic>;
    final porEdad = _estadisticas!['por_rango_edad'] as Map<String, dynamic>;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Resumen
          Row(
            children: [
              Expanded(
                child: _construirTarjetaResumen(
                  'Total Pacientes',
                  totalPacientes.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: _construirTarjetaResumen(
                  'Hombres',
                  (porGenero['M'] ?? 0).toString(),
                  Icons.male,
                  Colors.indigo,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: _construirTarjetaResumen(
                  'Mujeres',
                  (porGenero['F'] ?? 0).toString(),
                  Icons.female,
                  Colors.pink,
                ),
              ),
            ],
          ),

          const SizedBox(height: defaultPadding),

          // Gráficas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico de líneas (pacientes por mes)
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pacientes Nuevos por Mes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: _construirGraficoLineas(porMes),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Gráfico de pie (género)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Distribución por Género',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: _construirGraficoPie(porGenero),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: defaultPadding),

          // Gráfico de barras (edad)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distribución por Rango de Edad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    height: 300,
                    child: _construirGraficoBarras(porEdad),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirReporteTratamientos() {
    final totalTratamientos =
        (_estadisticas!['total_tratamientos'] as int?) ?? 0;
    final porTipo = (_estadisticas!['por_tipo'] as Map<String, dynamic>?) ?? {};
    final porMes = (_estadisticas!['por_mes'] as List<dynamic>?) ?? [];
    final porEstado =
        (_estadisticas!['por_estado'] as Map<String, dynamic>?) ?? {};
    final topPacientes =
        (_estadisticas!['top_pacientes'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Resumen
          _construirTarjetaResumen(
            'Total Tratamientos',
            totalTratamientos.toString(),
            Icons.medical_services,
            Colors.green,
          ),

          const SizedBox(height: defaultPadding),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico de líneas (tratamientos por mes)
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tratamientos por Mes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: _construirGraficoLineas(porMes),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Gráfico de pie (tipo)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Por Tipo de Tratamiento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: _construirGraficoPie(porTipo),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: defaultPadding),

          // Segunda fila de gráficas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico de pie (estado)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tratamientos por Estado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: porEstado.isNotEmpty
                              ? _construirGraficoPie(porEstado)
                              : const Center(child: Text('Sin datos')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Top pacientes con más tratamientos
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top 10 Pacientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: topPacientes.isNotEmpty
                              ? _construirGraficoBarrasHorizontal(
                                  topPacientes
                                      .map((e) => {
                                            'nombre': e['nombre'] as String,
                                            'valor': e['tratamientos'] as int,
                                          })
                                      .toList(),
                                )
                              : const Center(child: Text('Sin datos')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirReporteAcademicas() {
    final totalAsignaciones =
        (_estadisticas!['total_asignaciones'] as int?) ?? 0;
    final topEstudiantes =
        (_estadisticas!['top_estudiantes'] as List<dynamic>?) ?? [];
    final topDocentes =
        (_estadisticas!['top_docentes'] as List<dynamic>?) ?? [];
    final porEstado =
        (_estadisticas!['por_estado'] as Map<String, dynamic>?) ?? {};
    final porMes = (_estadisticas!['por_mes'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Resumen
          _construirTarjetaResumen(
            'Total Asignaciones',
            totalAsignaciones.toString(),
            Icons.assignment,
            Colors.orange,
          ),

          const SizedBox(height: defaultPadding),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top estudiantes
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top 10 Estudiantes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 400,
                          child: _construirGraficoBarrasHorizontal(
                            topEstudiantes
                                .map((e) => {
                                      'nombre': e['nombre'] as String,
                                      'valor': e['pacientes'] as int,
                                    })
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Top docentes
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top 10 Docentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 400,
                          child: _construirGraficoBarrasHorizontal(
                            topDocentes
                                .map((e) => {
                                      'nombre': e['nombre'] as String,
                                      'valor': e['pacientes'] as int,
                                    })
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: defaultPadding),

          // Tercera fila - Gráficas adicionales
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asignaciones por mes
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Asignaciones por Mes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: porMes.isNotEmpty
                              ? _construirGraficoLineas(porMes)
                              : const Center(child: Text('Sin datos')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Asignaciones por estado
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Por Estado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: porEstado.isNotEmpty
                              ? _construirGraficoPie(porEstado)
                              : const Center(child: Text('Sin datos')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaResumen(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 32),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirGraficoLineas(List<dynamic> datos) {
    if (datos.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < datos.length; i++) {
      spots.add(FlSpot(i.toDouble(), (datos[i]['total'] as int).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < datos.length) {
                  final mes = datos[value.toInt()]['mes'] as String;
                  final partes = mes.split('-');
                  return Text(
                    '${partes[1]}/${partes[0].substring(2)}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirGraficoPie(Map<String, dynamic> datos) {
    if (datos.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final colors = [
      Colors.blue,
      Colors.pink,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    int index = 0;
    final sections = <PieChartSectionData>[];

    datos.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          value: (value as int).toDouble(),
          title: '$key\n$value',
          color: colors[index % colors.length],
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _construirGraficoBarras(Map<String, dynamic> datos) {
    if (datos.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final barGroups = <BarChartGroupData>[];
    int index = 0;

    datos.forEach((key, value) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: (value as int).toDouble(),
              color: Colors.blue,
              width: 20,
            ),
          ],
        ),
      );
      index++;
    });

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final keys = datos.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < keys.length) {
                  return Text(
                    keys[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _construirGraficoBarrasHorizontal(List<Map<String, dynamic>> datos) {
    if (datos.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < datos.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (datos[i]['valor'] as int).toDouble(),
              color: Colors.orange,
              width: 15,
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 150,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < datos.length) {
                  final nombre = datos[value.toInt()]['nombre'] as String;
                  return Text(
                    nombre,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.right,
                  );
                }
                return const Text('');
              },
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Widget _construirReporteSeguimientos() {
    final totalSeguimientos = _estadisticas!['total_seguimientos'] as int;
    final totalEntradas = _estadisticas!['total_entradas'] as int;
    final promedioEntradas = _estadisticas!['promedio_entradas'];
    final porEstado = _estadisticas!['por_estado'] as Map<String, dynamic>;
    final porMes = _estadisticas!['por_mes'] as List<dynamic>;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Resumen
          Row(
            children: [
              Expanded(
                child: _construirTarjetaResumen(
                  'Total Seguimientos',
                  totalSeguimientos.toString(),
                  Icons.track_changes,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: _construirTarjetaResumen(
                  'Total Entradas',
                  totalEntradas.toString(),
                  Icons.note_add,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: _construirTarjetaResumen(
                  'Promedio Entradas',
                  promedioEntradas.toString(),
                  Icons.analytics,
                  Colors.cyan,
                ),
              ),
            ],
          ),

          const SizedBox(height: defaultPadding),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico de líneas (seguimientos por mes)
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seguimientos por Mes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: _construirGraficoLineas(porMes),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Gráfico de pie (estado)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Por Estado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: _construirGraficoPie(porEstado),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirReportePlanesTratamiento() {
    final totalPlanes = _estadisticas!['total_planes'] as int;
    final porEstado = _estadisticas!['por_estado'] as Map<String, dynamic>;
    final porMateria = _estadisticas!['por_materia'] as Map<String, dynamic>;
    final porMes = _estadisticas!['por_mes'] as List<dynamic>;
    final progresoPromedio = _estadisticas!['progreso_promedio'] ?? 0.0;
    final totalProcedimientos = _estadisticas!['total_procedimientos'] ?? 0;
    final procedimientosCompletados = _estadisticas!['procedimientos_completados'] ?? 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Tarjetas de resumen
          Row(
            children: [
              Expanded(
                child: _construirTarjetaResumen(
                  'Total Planes',
                  totalPlanes.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: _construirTarjetaResumen(
                  'Progreso Promedio',
                  '${progresoPromedio.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: _construirTarjetaResumen(
                  'Procedimientos',
                  '$procedimientosCompletados / $totalProcedimientos',
                  Icons.medical_services,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: _construirTarjetaResumen(
                  'Tasa Completitud',
                  totalProcedimientos > 0
                      ? '${((procedimientosCompletados / totalProcedimientos) * 100).toStringAsFixed(1)}%'
                      : '0%',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: defaultPadding),

          // Fila con gráficos
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico de barras (planes por mes)
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Planes de Tratamiento por Mes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: _construirGraficoLineas(porMes),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Gráfico de pie (por estado)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Planes por Estado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        SizedBox(
                          height: 300,
                          child: _construirGraficoPie(porEstado),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: defaultPadding),

          // Gráfico de barras horizontales (por materia)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Planes por Materia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    height: 300,
                    child: _construirGraficoBarrasHorizontales(porMateria),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportarPlanesTratamientoExcel(excel_lib.Sheet sheet) {
    // Título principal con formato
    var cellTitulo = sheet.cell(excel_lib.CellIndex.indexByString('A1'));
    cellTitulo.value = excel_lib.TextCellValue('REPORTE DE PLANES DE TRATAMIENTO');
    cellTitulo.cellStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: excel_lib.HorizontalAlign.Center,
      backgroundColorHex: excel_lib.ExcelColor.blue,
      fontColorHex: excel_lib.ExcelColor.white,
    );
    sheet.merge(excel_lib.CellIndex.indexByString('A1'), excel_lib.CellIndex.indexByString('C1'));
    
    // Fecha
    var cellFecha = sheet.cell(excel_lib.CellIndex.indexByString('A2'));
    cellFecha.value = excel_lib.TextCellValue(
        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    cellFecha.cellStyle = excel_lib.CellStyle(italic: true, fontSize: 10);
    
    sheet.appendRow([excel_lib.TextCellValue('')]);

    // Sección: Resumen General
    var rowNum = 4;
    var cellResumen = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
    cellResumen.value = excel_lib.TextCellValue('RESUMEN GENERAL');
    cellResumen.cellStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: excel_lib.ExcelColor.fromHexString('#2C3E50'),
      fontColorHex: excel_lib.ExcelColor.white,
    );
    sheet.merge(
      excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1),
      excel_lib.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowNum - 1),
    );
    rowNum++;

    // Datos de resumen con estilo
    final resumenData = [
      ['Total de Planes', _estadisticas!['total_planes'].toString()],
      ['Progreso Promedio', '${(_estadisticas!['progreso_promedio'] ?? 0.0).toStringAsFixed(1)}%'],
      ['Total Procedimientos', (_estadisticas!['total_procedimientos'] ?? 0).toString()],
      ['Procedimientos Completados', (_estadisticas!['procedimientos_completados'] ?? 0).toString()],
      ['Costo Total', '\$${(_estadisticas!['costo_total'] ?? 0.0).toStringAsFixed(2)}'],
    ];

    for (var data in resumenData) {
      var cellLabel = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
      cellLabel.value = excel_lib.TextCellValue(data[0]);
      cellLabel.cellStyle = excel_lib.CellStyle(
        bold: true,
        backgroundColorHex: excel_lib.ExcelColor.fromHexString('#ECF0F1'),
      );
      
      var cellValue = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowNum - 1));
      cellValue.value = excel_lib.TextCellValue(data[1]);
      cellValue.cellStyle = excel_lib.CellStyle(
        horizontalAlign: excel_lib.HorizontalAlign.Right,
        bold: true,
        fontColorHex: excel_lib.ExcelColor.fromHexString('#2980B9'),
      );
      rowNum++;
    }

    rowNum++;

    // Sección: Planes por Estado
    var cellEstado = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
    cellEstado.value = excel_lib.TextCellValue('PLANES POR ESTADO');
    cellEstado.cellStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: excel_lib.ExcelColor.fromHexString('#27AE60'),
      fontColorHex: excel_lib.ExcelColor.white,
    );
    sheet.merge(
      excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1),
      excel_lib.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowNum - 1),
    );
    rowNum++;

    // Encabezados
    var headerStyle = excel_lib.CellStyle(
      bold: true,
      backgroundColorHex: excel_lib.ExcelColor.fromHexString('#34495E'),
      fontColorHex: excel_lib.ExcelColor.white,
      horizontalAlign: excel_lib.HorizontalAlign.Center,
    );

    for (var i = 0; i < 3; i++) {
      var cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowNum - 1));
      cell.value = excel_lib.TextCellValue(['Estado', 'Cantidad', 'Porcentaje'][i]);
      cell.cellStyle = headerStyle;
    }
    rowNum++;

    final porEstado = _estadisticas!['por_estado'] as Map<String, dynamic>;
    int totalEstados = porEstado.values.fold(0, (sum, val) => sum + (val as int));
    
    var isEven = false;
    porEstado.forEach((estado, cantidad) {
      int cantidadInt = cantidad as int;
      double porcentaje = totalEstados > 0 ? (cantidadInt / totalEstados * 100) : 0;
      
      var bgColor = isEven 
          ? excel_lib.ExcelColor.fromHexString('#F8F9FA')
          : excel_lib.ExcelColor.white;

      var cellEstado = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
      cellEstado.value = excel_lib.TextCellValue(estado);
      cellEstado.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
      );

      var cellCantidad = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowNum - 1));
      cellCantidad.value = excel_lib.IntCellValue(cantidadInt);
      cellCantidad.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
        horizontalAlign: excel_lib.HorizontalAlign.Center,
        bold: true,
      );

      var cellPorcentaje = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowNum - 1));
      cellPorcentaje.value = excel_lib.TextCellValue('${porcentaje.toStringAsFixed(1)}%');
      cellPorcentaje.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
        horizontalAlign: excel_lib.HorizontalAlign.Right,
        fontColorHex: excel_lib.ExcelColor.fromHexString('#27AE60'),
      );

      rowNum++;
      isEven = !isEven;
    });

    rowNum++;

    // Sección: Planes por Materia
    var cellMateria = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
    cellMateria.value = excel_lib.TextCellValue('PLANES POR MATERIA');
    cellMateria.cellStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: excel_lib.ExcelColor.fromHexString('#E67E22'),
      fontColorHex: excel_lib.ExcelColor.white,
    );
    sheet.merge(
      excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1),
      excel_lib.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowNum - 1),
    );
    rowNum++;

    // Encabezados
    for (var i = 0; i < 3; i++) {
      var cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowNum - 1));
      cell.value = excel_lib.TextCellValue(['Materia', 'Cantidad', 'Porcentaje'][i]);
      cell.cellStyle = headerStyle;
    }
    rowNum++;

    final porMateria = _estadisticas!['por_materia'] as Map<String, dynamic>;
    int totalMaterias = porMateria.values.fold(0, (sum, val) => sum + (val as int));
    
    isEven = false;
    porMateria.forEach((materia, cantidad) {
      int cantidadInt = cantidad as int;
      double porcentaje = totalMaterias > 0 ? (cantidadInt / totalMaterias * 100) : 0;
      
      var bgColor = isEven 
          ? excel_lib.ExcelColor.fromHexString('#F8F9FA')
          : excel_lib.ExcelColor.white;

      var cellMateria = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
      cellMateria.value = excel_lib.TextCellValue(materia);
      cellMateria.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
      );

      var cellCantidad = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowNum - 1));
      cellCantidad.value = excel_lib.IntCellValue(cantidadInt);
      cellCantidad.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
        horizontalAlign: excel_lib.HorizontalAlign.Center,
        bold: true,
      );

      var cellPorcentaje = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowNum - 1));
      cellPorcentaje.value = excel_lib.TextCellValue('${porcentaje.toStringAsFixed(1)}%');
      cellPorcentaje.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
        horizontalAlign: excel_lib.HorizontalAlign.Right,
        fontColorHex: excel_lib.ExcelColor.fromHexString('#E67E22'),
      );

      rowNum++;
      isEven = !isEven;
    });

    rowNum++;

    // Sección: Planes por Mes
    var cellMes = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
    cellMes.value = excel_lib.TextCellValue('PLANES POR MES');
    cellMes.cellStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: excel_lib.ExcelColor.fromHexString('#9B59B6'),
      fontColorHex: excel_lib.ExcelColor.white,
    );
    sheet.merge(
      excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1),
      excel_lib.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowNum - 1),
    );
    rowNum++;

    // Encabezados
    for (var i = 0; i < 3; i++) {
      var cell = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowNum - 1));
      cell.value = excel_lib.TextCellValue(['Mes', 'Nuevos Planes', 'Acumulado'][i]);
      cell.cellStyle = headerStyle;
    }
    rowNum++;

    final porMes = _estadisticas!['por_mes'] as List<dynamic>;
    int acumulado = 0;
    
    isEven = false;
    for (var item in porMes) {
      int total = item['total'] as int;
      acumulado += total;
      
      var bgColor = isEven 
          ? excel_lib.ExcelColor.fromHexString('#F8F9FA')
          : excel_lib.ExcelColor.white;

      var cellMes = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowNum - 1));
      cellMes.value = excel_lib.TextCellValue(item['mes']);
      cellMes.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
      );

      var cellTotal = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowNum - 1));
      cellTotal.value = excel_lib.IntCellValue(total);
      cellTotal.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
        horizontalAlign: excel_lib.HorizontalAlign.Center,
        bold: true,
        fontColorHex: excel_lib.ExcelColor.fromHexString('#2980B9'),
      );

      var cellAcumulado = sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowNum - 1));
      cellAcumulado.value = excel_lib.IntCellValue(acumulado);
      cellAcumulado.cellStyle = excel_lib.CellStyle(
        backgroundColorHex: bgColor,
        horizontalAlign: excel_lib.HorizontalAlign.Right,
        fontColorHex: excel_lib.ExcelColor.fromHexString('#8E44AD'),
      );

      rowNum++;
      isEven = !isEven;
    }

    // Ajustar ancho de columnas
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);
  }

  Widget _construirGraficoBarrasHorizontales(Map<String, dynamic> datos) {
    final entries = datos.entries.toList();
    final maxValue = entries.fold<double>(
        0, (max, e) => (e.value as num).toDouble() > max ? (e.value as num).toDouble() : max);

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final porcentaje = (entry.value as num).toDouble() / maxValue;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: porcentaje,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[700]!,
                            Colors.blue[400]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
