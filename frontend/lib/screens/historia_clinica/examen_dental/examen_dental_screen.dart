import 'package:flutter/material.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/screens/historia_clinica/shared/widgets/examen_dental_widget.dart';

class ExamenDentalScreen extends StatefulWidget {
  const ExamenDentalScreen({Key? key}) : super(key: key);

  @override
  State<ExamenDentalScreen> createState() => _ExamenDentalScreenState();
}

class _ExamenDentalScreenState extends State<ExamenDentalScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _selectedPacienteId;
  Map<String, dynamic>? _pacienteSeleccionado;
  List<dynamic> _pacientes = [];
  String? _registroId;

  // Datos del examen dental
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  Future<void> _cargarPacientes() async {
    setState(() => _isLoading = true);
    try {
      final pacientes = await _apiService.fetchPacientes();
      setState(() {
        _pacientes = pacientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Error al cargar pacientes: $e');
    }
  }

  Future<void> _seleccionarPaciente(Map<String, dynamic> paciente) async {
    setState(() {
      _selectedPacienteId = paciente['id'].toString();
      _pacienteSeleccionado = paciente;
      _isLoading = true;
    });

    try {
      // Buscar registros existentes de este tipo para este paciente
      final registros = await _apiService.fetchRegistrosHistoriaClinica(
        pacienteId: _selectedPacienteId!,
        materia: 'periodoncia',
        tipoRegistro: 'examen_dental',
      );

      if (registros.isNotEmpty) {
        // Cargar el registro más reciente
        final registro = registros.first;
        setState(() {
          _registroId = registro['id'].toString();
          _data = Map<String, dynamic>.from(registro['datos'] ?? {});
        });
      } else {
        // Limpiar el formulario
        setState(() {
          _registroId = null;
          _data = {};
        });
      }
    } catch (e) {
      _mostrarError('Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardar() async {
    if (_selectedPacienteId == null) {
      _mostrarError('Por favor selecciona un paciente');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dataToSave = {
        'paciente_id': _selectedPacienteId,
        'materia': 'periodoncia',
        'tipo_registro': 'examen_dental',
        'datos': _data,
        'estado': 'pendiente',
      };

      if (_registroId != null) {
        // Actualizar registro existente
        await _apiService.updateRegistroHistoriaClinica(
            _registroId!, dataToSave);
        _mostrarExito('Examen dental actualizado correctamente');
      } else {
        // Crear nuevo registro
        final nuevoRegistro =
            await _apiService.createRegistroHistoriaClinica(dataToSave);
        setState(() {
          _registroId = nuevoRegistro['id'].toString();
        });
        _mostrarExito('Examen dental guardado correctamente');
      }
    } catch (e) {
      _mostrarError('Error al guardar: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSelectorPaciente() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Paciente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedPacienteId,
              decoration: InputDecoration(
                labelText: 'Paciente',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
              items: _pacientes.map((paciente) {
                return DropdownMenuItem<String>(
                  value: paciente['id'].toString(),
                  child: Text(
                    '${paciente['nombres']} ${paciente['apellidos']} - CI: ${paciente['ci']}',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final paciente = _pacientes.firstWhere(
                    (p) => p['id'].toString() == value,
                  );
                  _seleccionarPaciente(paciente);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade100,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        'Examen Dental',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Odontograma - Evaluación del estado de cada diente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Selector de paciente
                      _buildSelectorPaciente(),
                      const SizedBox(height: 16),

                      // Widget del examen dental
                      if (_selectedPacienteId != null)
                        ExamenDentalWidget(
                          data: _data,
                          onDataChanged: (newData) {
                            setState(() {
                              _data = newData;
                            });
                          },
                        ),

                      const SizedBox(height: 24),

                      // Botones de acción
                      if (_selectedPacienteId != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isSaving
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedPacienteId = null;
                                        _pacienteSeleccionado = null;
                                        _registroId = null;
                                        _data = {};
                                      });
                                    },
                              icon: Icon(Icons.cancel),
                              label: Text('Cancelar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _isSaving ? null : _guardar,
                              icon: _isSaving
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(Icons.save),
                              label:
                                  Text(_isSaving ? 'Guardando...' : 'Guardar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
