import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../responsive.dart';
import '../shared/widgets/diagnostico_radiografico_widget.dart';

class DiagnosticoRadiograficoScreen extends StatefulWidget {
  final String? pacienteId;
  final String? historialId;
  final String? estudianteId;
  final String? registroId;

  const DiagnosticoRadiograficoScreen({
    Key? key,
    this.pacienteId,
    this.historialId,
    this.estudianteId,
    this.registroId,
  }) : super(key: key);

  @override
  State<DiagnosticoRadiograficoScreen> createState() =>
      _DiagnosticoRadiograficoScreenState();
}

class _DiagnosticoRadiograficoScreenState
    extends State<DiagnosticoRadiograficoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _selectedPacienteId;
  String? _selectedHistorialId;
  Map<String, dynamic>? _pacienteSeleccionado;
  Map<String, dynamic> _diagnosticoData = {};
  List<dynamic> _pacientes = [];
  bool _showPacienteSelector = true;

  @override
  void initState() {
    super.initState();
    _selectedPacienteId = widget.pacienteId;
    _selectedHistorialId = widget.historialId;
    _showPacienteSelector = widget.pacienteId == null;

    if (widget.pacienteId != null) {
      _cargarDatosPaciente(widget.pacienteId!);
    }

    if (widget.registroId != null) {
      _cargarRegistro();
    }

    _cargarPacientes();
  }

  Future<void> _cargarPacientes() async {
    try {
      final pacientes = await _apiService.fetchPacientes();
      setState(() {
        _pacientes = pacientes;
      });
    } catch (e) {
      _showError('Error al cargar pacientes: $e');
    }
  }

  Future<void> _cargarDatosPaciente(String pacienteId) async {
    try {
      final pacientes = await _apiService.fetchPacientes();
      final paciente = pacientes.firstWhere(
        (p) => p['id'].toString() == pacienteId,
        orElse: () => <String, dynamic>{},
      );

      if (paciente.isEmpty) {
        throw Exception('Paciente no encontrado');
      }

      setState(() {
        _pacienteSeleccionado = paciente;
      });
    } catch (e) {
      _showError('Error al cargar datos del paciente: $e');
    }
  }

  Future<void> _cargarRegistro() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _apiService.fetchRegistroHistoriaClinica(widget.registroId!);
      setState(() {
        _diagnosticoData = Map<String, dynamic>.from(response['datos']);
      });
    } catch (e) {
      _showError('Error al cargar registro: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPacienteId == null) {
      _showError('Debe seleccionar un paciente');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'historial': _selectedHistorialId,
        'estudiante': widget.estudianteId,
        'paciente': _selectedPacienteId,
        'materia': 'periodoncia',
        'tipo_registro': 'diagnostico_radiografico',
        'datos': _diagnosticoData,
        'estado': 'pendiente',
      };

      if (widget.registroId != null) {
        await _apiService.updateRegistroHistoriaClinica(
            widget.registroId!, data);
        _showSuccess('Registro actualizado exitosamente');
      } else {
        await _apiService.createRegistroHistoriaClinica(data);
        _showSuccess('Registro creado exitosamente');
      }
    } catch (e) {
      _showError('Error al guardar: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Responsive.isDesktop(context)
          ? null
          : AppBar(
              title: Text('Diagnóstico Radiográfico'),
              backgroundColor: Colors.purple[700],
            ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!Responsive.isDesktop(context)) ...[
                      Text(
                        'Diagnóstico Radiográfico',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    if (_showPacienteSelector) _buildSelectorPaciente(),
                    if (_pacienteSeleccionado != null) ...[
                      SizedBox(height: 16),
                      _buildDatosPaciente(),
                    ],
                    if (_selectedPacienteId != null) ...[
                      SizedBox(height: 24),
                      DiagnosticoRadiograficoWidget(
                        initialData: _diagnosticoData,
                        onDataChanged: (data) {
                          setState(() {
                            _diagnosticoData = data;
                          });
                        },
                        readOnly: false,
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                _isSaving ? null : () => Navigator.pop(context),
                            icon: Icon(Icons.cancel),
                            label: Text('Cancelar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _guardar,
                            icon: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Icon(Icons.save),
                            label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[700],
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSelectorPaciente() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
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
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedPacienteId,
            decoration: InputDecoration(
              labelText: 'Paciente',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              filled: true,
              fillColor: Colors.white,
            ),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Debe seleccionar un paciente';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatosPaciente() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.blue[700], size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_pacienteSeleccionado!['nombres']} ${_pacienteSeleccionado!['apellidos']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'CI: ${_pacienteSeleccionado!['ci']}',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _seleccionarPaciente(Map<String, dynamic> paciente) async {
    setState(() {
      _selectedPacienteId = paciente['id'].toString();
      _pacienteSeleccionado = paciente;
      _isLoading = true;
    });

    // Cargar registro existente si hay
    try {
      final registros = await _apiService.fetchRegistrosHistoriaClinica(
        pacienteId: _selectedPacienteId,
        materia: 'periodoncia',
        tipoRegistro: 'diagnostico_radiografico',
      );

      if (registros.isNotEmpty) {
        // Cargar el registro más reciente
        final registro = registros.first;
        setState(() {
          _diagnosticoData = Map<String, dynamic>.from(registro['datos']);
          _selectedHistorialId = registro['historial'];
        });
      } else {
        // Limpiar los datos si no hay registro
        setState(() {
          _diagnosticoData = {};
        });
      }
    } catch (e) {
      _showError('Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
