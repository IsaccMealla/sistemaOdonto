import 'package:flutter/material.dart';
import 'dart:convert';

import 'cita_model.dart';
import '../../services/api_service.dart';
import '../../helpers/date_formatter.dart';

class CitasPacienteTab extends StatefulWidget {
  @override
  State<CitasPacienteTab> createState() => _CitasPacienteTabState();
}

class _CitasPacienteTabState extends State<CitasPacienteTab> {
  List<Map<String, dynamic>> _citas = [];
  bool _loading = true;
  // TODO:  Reemplazar por el pacienteId real del usuario logueado
  final String _pacienteId = 'p1';

  @override
  void initState() {
    super.initState();
    _fetchCitas();
  }

  Future<void> _fetchCitas() async {
    setState(() => _loading = true);
    try {
      final citas = await ApiService().fetchCitas(pacienteId: _pacienteId);
      setState(() {
        _citas = List<Map<String, dynamic>>.from(citas);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showErrorSnackBar('Error al cargar las citas: $e');
    }
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
                labelText: 'Motivo de cancelación',
                border: OutlineInputBorder(),
                hintText: 'Ej: Conflicto de horario, problema personal...',
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
            onPressed: () {
              if (motivoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes proporcionar un motivo'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Cita'),
          ),
        ],
      ),
    );

    if (confirmed == true && motivoController.text.trim().isNotEmpty) {
      try {
        final updated = Map<String, dynamic>.from(cita);
        updated['estado'] = 'cancelada';
        updated['motivo_cancelacion'] = motivoController.text.trim();
        await ApiService().updateCita(cita['id'], updated);
        await _fetchCitas();
        _showSuccessSnackBar('Cita cancelada exitosamente');
      } catch (e) {
        _showErrorSnackBar('Error al cancelar la cita: $e');
      }
    }
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
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
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
                    const Text(
                      'Mis Citas Como Paciente',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Consulta tus citas programadas. Solo puedes cancelar citas proporcionando un motivo.',
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
                                      'Estudiante: ${cita['estudiante_nombre'] ?? 'Sin asignar'}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  if (cita['docente_nombre'] != null)
                                    Text('Docente: ${cita['docente_nombre']}',
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
                              trailing: cita['estado'] != 'cancelada'
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel),
                                      tooltip: 'Cancelar',
                                      onPressed: () => _cancelarCita(index),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
  }
}
