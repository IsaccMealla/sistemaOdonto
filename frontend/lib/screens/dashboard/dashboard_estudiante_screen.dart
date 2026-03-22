import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../constants.dart';
import '../../services/api_service.dart';
import 'components/header.dart';

class DashboardEstudianteScreen extends StatefulWidget {
  @override
  State<DashboardEstudianteScreen> createState() =>
      _DashboardEstudianteScreenState();
}

class _DashboardEstudianteScreenState extends State<DashboardEstudianteScreen> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _usuario;
  bool _cargando = true;

  // Estadísticas de tratamientos
  List<Map<String, dynamic>> _estadisticasPorMateria = [];
  Map<String, dynamic>? _resumenEstadisticas;

  // Pacientes asignados
  List<Map<String, dynamic>> _pacientesAsignados = [];
  Map<String, List<Map<String, dynamic>>> _pacientesPorEstado = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');
      if (usuarioJson != null) {
        final usuario = jsonDecode(usuarioJson);
        setState(() => _usuario = usuario);

        await Future.wait([
          _cargarEstadisticasTratamientos(),
          _cargarPacientesAsignados(),
        ]);
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cargarEstadisticasTratamientos() async {
    try {
      final stats = await _apiService.getEstadisticasTratamientos();
      setState(() {
        _estadisticasPorMateria =
            List<Map<String, dynamic>>.from(stats['por_materia'] ?? []);
        _resumenEstadisticas = stats['resumen'];
      });
    } catch (e) {
      print('Error al cargar estadísticas de tratamientos: $e');
    }
  }

  Future<void> _cargarPacientesAsignados() async {
    try {
      // Obtener ID del estudiante actual
      final estudianteId = _usuario?['id']?.toString();
      if (estudianteId == null) {
        print('No se pudo obtener el ID del estudiante');
        return;
      }

      print('Estudiante ID: $estudianteId');

      // Usar el método específico para obtener pacientes asignados al estudiante
      final pacientesData =
          await _apiService.fetchMisPacientesAsignados(estudianteId);
      print('Pacientes asignados encontrados: ${pacientesData.length}');

      // Los pacientes ya vienen con la información necesaria
      final pacientesAsignados =
          pacientesData.map((p) => Map<String, dynamic>.from(p)).toList();

      // Obtener tratamientos del estudiante para determinar estado
      final tratamientos =
          await _apiService.fetchTratamientos(estudianteId: estudianteId);
      print('Tratamientos encontrados: ${tratamientos.length}');

      final Map<String, List<Map<String, dynamic>>> porEstado = {
        'nuevo': [],
        'en_proceso': [],
        'pendiente_aprobacion': [],
        'terminado': [],
      };

      for (var paciente in pacientesAsignados) {
        final pacienteId =
            paciente['id']?.toString() ?? paciente['paciente_id']?.toString();
        if (pacienteId == null) continue;

        final tratamientosPaciente = tratamientos
            .where((t) => t['paciente']?.toString() == pacienteId)
            .toList();

        print(
            'Paciente ${paciente['nombres']} - Tratamientos: ${tratamientosPaciente.length}');

        if (tratamientosPaciente.isEmpty) {
          porEstado['nuevo']!.add(paciente);
        } else {
          final tieneAprobados =
              tratamientosPaciente.any((t) => t['estado'] == 'aprobado');
          final tieneSolicitados =
              tratamientosPaciente.any((t) => t['estado'] == 'solicitado');

          if (tieneSolicitados) {
            porEstado['pendiente_aprobacion']!.add(paciente);
          } else if (tieneAprobados) {
            porEstado['en_proceso']!.add(paciente);
          } else {
            porEstado['en_proceso']!.add(paciente);
          }
        }
      }

      setState(() {
        _pacientesAsignados = pacientesAsignados;
        _pacientesPorEstado = porEstado;
      });

      print(
          'Resumen - Total: ${_pacientesAsignados.length}, Nuevos: ${porEstado['nuevo']?.length}, En proceso: ${porEstado['en_proceso']?.length}');
    } catch (e) {
      print('Error al cargar pacientes asignados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            if (_cargando)
              Center(child: CircularProgressIndicator())
            else ...[
              // Título del dashboard
              Text(
                'MIS PACIENTES - SEMESTRE 2025-II',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: defaultPadding),

              // Resumen general
              _buildResumenGeneral(),
              SizedBox(height: defaultPadding),

              // Progreso por materia
              _buildProgresoMaterias(),
              SizedBox(height: defaultPadding),

              // Pacientes por estado
              _buildPacientesPorEstado(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumenGeneral() {
    final totalPacientes = _pacientesAsignados.length;
    final nuevos = _pacientesPorEstado['nuevo']?.length ?? 0;
    final enProceso = _pacientesPorEstado['en_proceso']?.length ?? 0;
    final pendientes = _pacientesPorEstado['pendiente_aprobacion']?.length ?? 0;
    final terminados = _pacientesPorEstado['terminado']?.length ?? 0;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Resumen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: defaultPadding / 2),
          Wrap(
            spacing: defaultPadding,
            runSpacing: 8,
            children: [
              _buildStatChip(
                  '$totalPacientes Pacientes Asignados', Colors.blue),
              _buildStatChip('$nuevos Nuevos', Colors.cyan),
              _buildStatChip('$enProceso En Proceso', Colors.green),
              _buildStatChip('$pendientes Pendiente Aprobación', Colors.orange),
              _buildStatChip('$terminados Terminados', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildProgresoMaterias() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROGRESO POR MATERIA',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: defaultPadding),
          if (_estadisticasPorMateria.isEmpty)
            Text('No hay tratamientos registrados aún')
          else
            ..._estadisticasPorMateria.map((materia) {
              final aprobados = materia['aprobados'] ?? 0;
              final meta = materia['meta'] ?? 10;
              final progreso = meta > 0 ? aprobados / meta : 0.0;
              final color = progreso >= 1.0
                  ? Colors.green
                  : progreso >= 0.7
                      ? Colors.blue
                      : progreso >= 0.4
                          ? Colors.orange
                          : Colors.red;

              return Padding(
                padding: EdgeInsets.only(bottom: defaultPadding / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            materia['materia_nombre'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '$aprobados/$meta',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progreso.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildPacientesPorEstado() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PACIENTES POR ESTADO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: defaultPadding),
          if (_pacientesAsignados.isEmpty)
            Text('No tienes pacientes asignados')
          else
            ..._buildListaPacientes(),
        ],
      ),
    );
  }

  List<Widget> _buildListaPacientes() {
    final List<Widget> widgets = [];

    // Nuevos
    if ((_pacientesPorEstado['nuevo']?.length ?? 0) > 0) {
      widgets.add(_buildEstadoHeader('🔵 NUEVOS', Colors.cyan));
      for (var paciente in _pacientesPorEstado['nuevo']!) {
        widgets.add(_buildPacienteCard(
            paciente, 'Sin tratamientos iniciados', Colors.cyan));
      }
    }

    // En proceso
    if ((_pacientesPorEstado['en_proceso']?.length ?? 0) > 0) {
      widgets.add(_buildEstadoHeader('🟢 EN PROCESO', Colors.green));
      for (var paciente in _pacientesPorEstado['en_proceso']!) {
        widgets.add(
            _buildPacienteCard(paciente, 'Tratamientos activos', Colors.green));
      }
    }

    // Pendiente aprobación
    if ((_pacientesPorEstado['pendiente_aprobacion']?.length ?? 0) > 0) {
      widgets.add(_buildEstadoHeader('🟡 PENDIENTE APROBACIÓN', Colors.orange));
      for (var paciente in _pacientesPorEstado['pendiente_aprobacion']!) {
        widgets.add(_buildPacienteCard(
            paciente, 'Esperando revisión docente', Colors.orange));
      }
    }

    // Terminados
    if ((_pacientesPorEstado['terminado']?.length ?? 0) > 0) {
      widgets.add(_buildEstadoHeader('✅ TERMINADOS', Colors.purple));
      for (var paciente in _pacientesPorEstado['terminado']!) {
        widgets.add(_buildPacienteCard(
            paciente, 'Tratamiento completo', Colors.purple));
      }
    }

    return widgets;
  }

  Widget _buildEstadoHeader(String titulo, Color color) {
    return Padding(
      padding: EdgeInsets.only(top: defaultPadding / 2, bottom: 8),
      child: Text(
        titulo,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPacienteCard(
      Map<String, dynamic> paciente, String estado, Color color) {
    return Card(
      color: bgColor,
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.person, color: color),
        ),
        title: Text(
          '${paciente['nombres']} ${paciente['apellidos']}',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(estado),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // TODO: Navegar a detalles del paciente
        },
      ),
    );
  }
}
