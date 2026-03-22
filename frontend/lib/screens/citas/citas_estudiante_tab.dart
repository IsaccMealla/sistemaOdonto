import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'cita_form_dialog.dart';
import 'cita_model.dart';
import '../../services/api_service.dart';
import '../../helpers/date_formatter.dart';

class CitasEstudianteTab extends StatefulWidget {
  @override
  State<CitasEstudianteTab> createState() => _CitasEstudianteTabState();
}

class _CitasEstudianteTabState extends State<CitasEstudianteTab> {
  List<Map<String, dynamic>> _citas = [];
  List<Map<String, dynamic>> _pacientes = [];
  bool _loading = true;
  String? _estudianteId;
  String? _docenteId;

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
          _estudianteId = usuario['id'];
        });

        // Cargar pacientes asignados al estudiante
        await _fetchPacientes();
        await _fetchCitas();
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
      _showErrorSnackBar('Error al cargar datos del usuario');
    }
  }

  Future<void> _fetchPacientes() async {
    try {
      // El backend ya filtra los pacientes según el usuario autenticado
      // Si es estudiante, solo devuelve sus pacientes asignados
      final pacientes = await ApiService().fetchPacientes();
      setState(() {
        _pacientes = List<Map<String, dynamic>>.from(pacientes);
      });
    } catch (e) {
      print('Error al cargar pacientes: $e');
      _showErrorSnackBar('Error al cargar pacientes: $e');
    }
  }

  Future<void> _fetchCitas() async {
    setState(() => _loading = true);
    try {
      final citas = await ApiService().fetchCitas(estudianteId: _estudianteId);
      setState(() {
        _citas = List<Map<String, dynamic>>.from(citas);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showErrorSnackBar('Error al cargar las citas: $e');
    }
  }

  void _agendarCita() async {
    if (_pacientes.isEmpty) {
      _showErrorSnackBar(
          'No tienes pacientes asignados. Contacta a tu docente.');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => CitaFormDialog(
        pacientes: _pacientes,
        onSubmit: (pacienteId, fechaHora, motivo) async {
          try {
            final data = {
              'paciente': pacienteId,
              'estudiante': _estudianteId,
              'docente': _docenteId, // Puede ser null inicialmente
              'fecha_hora': fechaHora.toIso8601String(),
              'motivo': motivo,
              'estado': 'pendiente',
            };
            await ApiService().createCita(data);
            await _fetchCitas();
            _showSuccessSnackBar('Cita agendada exitosamente');
          } catch (e) {
            _showErrorSnackBar('Error al agendar la cita: $e');
          }
        },
      ),
    );
  }

  void _cancelarCita(int index) async {
    final cita = _citas[index];
    final confirmed = await _showConfirmationDialog(
      'Cancelar Cita',
      '¿Estás seguro de que deseas cancelar esta cita?',
    );

    if (confirmed) {
      try {
        final updated = Map<String, dynamic>.from(cita);
        updated['estado'] = 'cancelada';
        updated['motivo_cancelacion'] = 'Cancelada por el estudiante';
        await ApiService().updateCita(cita['id'], updated);
        await _fetchCitas();
        _showSuccessSnackBar('Cita cancelada');
      } catch (e) {
        _showErrorSnackBar('Error al cancelar la cita: $e');
      }
    }
  }

  void _reprogramarCita(int index) async {
    final cita = _citas[index];
    await showDialog(
      context: context,
      builder: (context) => CitaFormDialog(
        pacientes: _pacientes,
        pacienteIdInicial: cita['paciente'],
        onSubmit: (pacienteId, fechaHora, motivo) async {
          try {
            final updated = Map<String, dynamic>.from(cita);
            updated['paciente'] = pacienteId;
            updated['fecha_hora'] = fechaHora.toIso8601String();
            updated['motivo'] = motivo;
            updated['estado'] = 'pendiente';
            updated['motivo_cancelacion'] = null;
            await ApiService().updateCita(cita['id'], updated);
            await _fetchCitas();
            _showSuccessSnackBar('Cita reprogramada exitosamente');
          } catch (e) {
            _showErrorSnackBar('Error al reprogramar la cita:  $e');
          }
        },
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mis Citas Como Estudiante',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        ElevatedButton.icon(
                          onPressed: _agendarCita,
                          icon: const Icon(Icons.add),
                          label: const Text('Agendar Cita'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gestiona citas para tus pacientes asignados. Puedes programar, reprogramar y cancelar citas.',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _citas.isEmpty
                    ? const Center(
                        child: Text('No tienes citas agendadas.',
                            style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        itemCount: _citas.length,
                        itemBuilder: (context, index) {
                          final cita = _citas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                                      'Fecha: ${DateFormatter.formatDateTime(cita['fecha_hora'])}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text('Estado: ${cita['estado']}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  if (cita['observaciones_docente'] != null)
                                    Text(
                                      'Obs.  Docente: ${cita['observaciones_docente']}',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  if (cita['motivo_cancelacion'] != null)
                                    Text(
                                      'Motivo cancelación: ${cita['motivo_cancelacion']}',
                                      style: const TextStyle(
                                          color: Colors.redAccent),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (cita['estado'] != 'cancelada')
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Reprogramar',
                                      onPressed: () => _reprogramarCita(index),
                                    ),
                                  if (cita['estado'] != 'cancelada')
                                    IconButton(
                                      icon: const Icon(Icons.cancel),
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
