import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../responsive.dart';
import '../shared/widgets/examen_periodontal_widget.dart';

class ExamenPeriodontalScreen extends StatefulWidget {
  final String? pacienteId;
  final String? historialId;
  final String? estudianteId;
  final String? registroId;

  const ExamenPeriodontalScreen({
    Key? key,
    this.pacienteId,
    this.historialId,
    this.estudianteId,
    this.registroId,
  }) : super(key: key);

  @override
  State<ExamenPeriodontalScreen> createState() =>
      _ExamenPeriodontalScreenState();
}

class _ExamenPeriodontalScreenState extends State<ExamenPeriodontalScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isSaving = false;

  String? _selectedPacienteId;
  String? _selectedHistorialId;
  Map<String, dynamic>? _pacienteSeleccionado;
  List<dynamic> _pacientes = [];
  final TextEditingController _searchPacienteController =
      TextEditingController();
  bool _showPacienteSelector = true;

  Map<String, dynamic> _examenData = {};

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    if (widget.pacienteId != null && widget.historialId != null) {
      setState(() {
        _selectedPacienteId = widget.pacienteId;
        _selectedHistorialId = widget.historialId;
        _showPacienteSelector = false;
      });
      await _cargarDatosPaciente(widget.pacienteId!);
    } else {
      await _cargarPacientes();
    }

    if (widget.registroId != null) {
      await _cargarRegistro();
    }
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
      // TODO: Implementar endpoint en backend para examen
      // final response = await _apiService.fetchExamenById(widget.registroId!);
      // setState(() {
      //   _examenData = Map<String, dynamic>.from(response['datos']);
      // });
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
        'tipo_registro': 'examen_periodontal',
        'datos': _examenData,
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
              title: Text('Examen Periodontal'),
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
                        'Examen Periodontal',
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
                      ExamenPeriodontalWidget(
                        initialData: _examenData,
                        onDataChanged: (data) {
                          setState(() => _examenData = data);
                        },
                        readOnly: false,
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancelar'),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : _guardar,
                            icon: _isSaving
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.save),
                            label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[700],
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
    final pacientesFiltrados = _pacientes.where((p) {
      final searchTerm = _searchPacienteController.text.toLowerCase();
      final nombres = (p['nombres'] ?? '').toString().toLowerCase();
      final apellidos = (p['apellidos'] ?? '').toString().toLowerCase();
      final ci = (p['ci'] ?? '').toString().toLowerCase();
      return nombres.contains(searchTerm) ||
          apellidos.contains(searchTerm) ||
          ci.contains(searchTerm);
    }).toList();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccionar Paciente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _searchPacienteController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, apellido o CI...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
          ),
          SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              itemCount: pacientesFiltrados.length,
              itemBuilder: (context, index) {
                final paciente = pacientesFiltrados[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      paciente['nombres']?[0]?.toUpperCase() ?? 'P',
                    ),
                  ),
                  title: Text(
                    '${paciente['nombres']} ${paciente['apellidos']}',
                  ),
                  subtitle: Text('CI: ${paciente['ci']}'),
                  selected: _selectedPacienteId == paciente['id'].toString(),
                  onTap: () => _seleccionarPaciente(paciente),
                );
              },
            ),
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
        tipoRegistro: 'examen_periodontal',
      );

      if (registros.isNotEmpty) {
        // Cargar el registro más reciente
        final registro = registros.first;
        setState(() {
          _examenData = Map<String, dynamic>.from(registro['datos']);
          _selectedHistorialId = registro['historial'];
        });
      } else {
        // Limpiar los datos si no hay registro
        setState(() {
          _examenData = {};
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

  @override
  void dispose() {
    _searchPacienteController.dispose();
    super.dispose();
  }
}
