import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'cita_model.dart';
import 'cita_form_dialog.dart';
import 'cita_aprobacion_dialog.dart';
import '../../services/api_service.dart';
import '../../helpers/date_formatter.dart';

class CitasDocenteTab extends StatefulWidget {
  @override
  State<CitasDocenteTab> createState() => _CitasDocenteTabState();
}

class _CitasDocenteTabState extends State<CitasDocenteTab> {
  List<Map<String, dynamic>> _citas = [];
  List<Map<String, dynamic>> _estudiantes = [];
  List<Map<String, dynamic>> _pacientes = [];
  String? _selectedEstudianteId;
  String? _selectedPacienteId;
  DateTime? _selectedDate;
  String? _docenteId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');

      if (usuarioJson != null) {
        final usuario = json.decode(usuarioJson);
        setState(() {
          _docenteId = usuario['id'];
        });
        await _fetchData();
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      // Cargar TODOS los estudiantes (no solo asignados)
      final usuarios = await ApiService().fetchUsuarios();
      final estudiantesData = usuarios
          .where((u) =>
              u['roles'] != null &&
              (u['roles'] as List).any((r) => r['nombre'] == 'Estudiante'))
          .map((u) => {
                'id': u['id'],
                'nombre_completo': '${u['nombres']} ${u['apellidos']}'
              })
          .toList();

      // Cargar todos los pacientes para el filtro
      final todosPacientes = await ApiService().fetchPacientes();

      setState(() {
        _estudiantes = List<Map<String, dynamic>>.from(estudiantesData);
        _pacientes = List<Map<String, dynamic>>.from(todosPacientes);
        _selectedEstudianteId = null;
        _selectedPacienteId = null;
        _selectedDate = null;
      });

      await _fetchCitas();
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchCitas() async {
    try {
      // NO filtrar por docente, el docente ve TODAS las citas
      final citas = await ApiService().fetchCitas(
        estudianteId: _selectedEstudianteId,
        pacienteId: _selectedPacienteId,
      );

      // Filtrar por fecha localmente si está seleccionada
      List<Map<String, dynamic>> citasFiltradas =
          List<Map<String, dynamic>>.from(citas);
      if (_selectedDate != null) {
        citasFiltradas = citasFiltradas.where((cita) {
          try {
            final citaFecha = DateTime.parse(cita['fecha_hora']);
            return citaFecha.year == _selectedDate!.year &&
                citaFecha.month == _selectedDate!.month &&
                citaFecha.day == _selectedDate!.day;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      setState(() {
        _citas = citasFiltradas;
      });
    } catch (e) {
      print('Error al cargar citas: $e');
    }
  }

  void _onEstudianteChanged(String? estudianteId) async {
    setState(() {
      _selectedEstudianteId = estudianteId;
      _selectedPacienteId = null; // Limpiar filtro de paciente
      _selectedDate = null; // Limpiar filtro de fecha
    });
    await _fetchCitas();
  }

  void _onPacienteChanged(String? pacienteId) async {
    setState(() {
      _selectedPacienteId = pacienteId;
      _selectedEstudianteId = null; // Limpiar filtro de estudiante
      _selectedDate = null; // Limpiar filtro de fecha
    });
    await _fetchCitas();
  }

  void _onDateChanged(DateTime? date) async {
    setState(() {
      _selectedDate = date;
      _selectedEstudianteId = null; // Limpiar filtro de estudiante
      _selectedPacienteId = null; // Limpiar filtro de paciente
    });
    await _fetchCitas();
  }

  void _limpiarFiltros() async {
    setState(() {
      _selectedEstudianteId = null;
      _selectedPacienteId = null;
      _selectedDate = null;
    });
    await _fetchCitas();
  }

  void _aprobarORechazarCita(int index) async {
    final cita = _citas[index];
    await showDialog(
      context: context,
      builder: (context) => CitaAprobacionDialog(
        onSubmit: (aprobar, observaciones) async {
          final updated = Map<String, dynamic>.from(cita);
          updated['estado'] = aprobar ? 'aprobada' : 'rechazada';
          updated['observacionesDocente'] = observaciones;
          await ApiService().updateCita(cita['id'], updated);
          await _fetchCitas();
        },
      ),
    );
  }

  void _reprogramarCita(int index) async {
    final cita = _citas[index];

    // Crear lista con solo el paciente de la cita actual (el docente no cambia paciente)
    final pacienteActual =
        _pacientes.where((p) => p['id'] == cita['paciente']).toList();

    await showDialog(
      context: context,
      builder: (context) => CitaFormDialog(
        pacientes: pacienteActual.isEmpty ? _pacientes : pacienteActual,
        pacienteIdInicial: cita['paciente'],
        onSubmit: (pacienteId, fechaHora, motivo) async {
          try {
            final updated = Map<String, dynamic>.from(cita);
            updated['fecha_hora'] = fechaHora.toIso8601String();
            updated['motivo'] = motivo;
            updated['estado'] = 'pendiente';
            updated['observaciones_docente'] = null;
            updated['motivo_cancelacion'] = null;
            await ApiService().updateCita(cita['id'], updated);
            await _fetchCitas();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cita reprogramada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al reprogramar: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _cancelarCita(int index) async {
    final cita = _citas[index];

    // Solicitar motivo de cancelación
    final motivoController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Por qué deseas cancelar esta cita?'),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Ej: Estudiante no disponible, reagendamiento...',
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Regresar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Cita'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updated = Map<String, dynamic>.from(cita);
        updated['estado'] = 'cancelada';
        updated['motivo_cancelacion'] = motivoController.text.trim().isEmpty
            ? 'Cancelada por el docente'
            : motivoController.text.trim();
        await ApiService().updateCita(cita['id'], updated);
        await _fetchCitas();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar la cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Citas Como Docente',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gestión completa de citas: aprobar, rechazar, reprogramar y cancelar citas.',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),

                    // Filtros - Primera fila: Estudiante y Paciente
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedEstudianteId,
                            decoration: const InputDecoration(
                              labelText: 'Filtrar por estudiante',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Todos los estudiantes'),
                              ),
                              ..._estudiantes
                                  .map((e) => DropdownMenuItem<String>(
                                        value: e['id'],
                                        child: Text('${e['nombre_completo']}'),
                                      )),
                            ],
                            onChanged: _onEstudianteChanged,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPacienteId,
                            decoration: const InputDecoration(
                              labelText: 'Filtrar por paciente',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Todos los pacientes'),
                              ),
                              ..._pacientes.map((p) => DropdownMenuItem<String>(
                                    value: p['id'],
                                    child: Text(
                                        '${p['nombres']} ${p['apellidos']}'),
                                  )),
                            ],
                            onChanged: _onPacienteChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filtro de fecha
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                _onDateChanged(date);
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedDate == null
                                  ? 'Filtrar por fecha'
                                  : 'Fecha: ${DateFormatter.formatDate(_selectedDate!.toIso8601String())}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedEstudianteId != null ||
                            _selectedPacienteId != null ||
                            _selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Limpiar filtros',
                            onPressed: _limpiarFiltros,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _citas.isEmpty
                    ? const Center(
                        child: Text('No hay citas para mostrar.',
                            style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        itemCount: _citas.length,
                        itemBuilder: (context, index) {
                          final cita = _citas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text('${cita['motivo']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Paciente: ${cita['paciente_nombre'] ?? 'Sin especificar'}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text(
                                      'Estudiante: ${cita['estudiante_nombre'] ?? 'Sin especificar'}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text(
                                      'Fecha: ${DateFormatter.formatDateTime(cita['fecha_hora'])}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text('Estado: ${cita['estado']}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  if (cita['observaciones_docente'] != null)
                                    Text(
                                        'Obs. Docente: ${cita['observaciones_docente']}',
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                  if (cita['motivo_cancelacion'] != null)
                                    Text(
                                        'Motivo cancelación: ${cita['motivo_cancelacion']}',
                                        style: const TextStyle(
                                            color: Colors.redAccent)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (cita['estado'] == 'pendiente')
                                    IconButton(
                                      icon: const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      tooltip: 'Aprobar/Rechazar',
                                      onPressed: () =>
                                          _aprobarORechazarCita(index),
                                    ),
                                  if (cita['estado'] != 'cancelada')
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      tooltip: 'Reprogramar',
                                      onPressed: () => _reprogramarCita(index),
                                    ),
                                  if (cita['estado'] != 'cancelada')
                                    IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red),
                                      tooltip: 'Cancelar',
                                      onPressed: () => _cancelarCita(index),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
  }
}
