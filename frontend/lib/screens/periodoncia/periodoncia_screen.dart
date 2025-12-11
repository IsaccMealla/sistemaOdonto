import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'widgets/periodontograma_widget.dart';
import '../historia_clinica/shared/widgets/habitos_widget.dart';
import '../historia_clinica/shared/widgets/antecedentes_periodontal_widget.dart';
import '../historia_clinica/shared/widgets/examen_periodontal_widget.dart';

class PeridonciaScreen extends StatefulWidget {
  final String? pacienteId;
  final String? historialId;
  final String? estudianteId;
  final String? registroId; // Para editar un registro existente

  const PeridonciaScreen({
    Key? key,
    this.pacienteId,
    this.historialId,
    this.estudianteId,
    this.registroId,
  }) : super(key: key);

  @override
  State<PeridonciaScreen> createState() => _PeridonciaScreenState();
}

class _PeridonciaScreenState extends State<PeridonciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isSaving = false;

  // Selector de paciente
  String? _selectedPacienteId;
  String? _selectedHistorialId;
  Map<String, dynamic>? _pacienteSeleccionado;
  List<dynamic> _pacientes = [];
  final TextEditingController _searchPacienteController =
      TextEditingController();
  bool _showPacienteSelector = true;

  // Datos de los módulos
  Map<String, dynamic> _habitosData = {};
  Map<String, dynamic> _antecedentesData = {};
  Map<String, dynamic> _examenData = {};
  Map<String, dynamic> _periodontogramaData = {};

  // Observaciones
  final TextEditingController _observacionesController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    // Si vienen datos pre-cargados (desde asignaciones), ocultar selector
    if (widget.pacienteId != null && widget.historialId != null) {
      setState(() {
        _selectedPacienteId = widget.pacienteId;
        _selectedHistorialId = widget.historialId;
        _showPacienteSelector = false;
      });
      await _cargarDatosPaciente(widget.pacienteId!);
    } else {
      // Mostrar selector de paciente
      await _cargarPacientes();
    }

    // Si hay un registro existente, cargarlo
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
      // Buscar el paciente en la lista
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

      // Cargar historial del paciente
      await _cargarHistorialPaciente(pacienteId);
    } catch (e) {
      _showError('Error al cargar datos del paciente: $e');
    }
  }

  Future<void> _cargarHistorialPaciente(String pacienteId) async {
    try {
      final historiales = await _apiService.fetchHistoriales();
      final historialesDelPaciente = historiales
          .where((h) => h['paciente'].toString() == pacienteId)
          .toList();

      if (historialesDelPaciente.isNotEmpty) {
        setState(() {
          _selectedHistorialId = historialesDelPaciente[0]['id'].toString();
        });
      } else {
        // Si no tiene historial, crear uno automáticamente
        final nuevoHistorial = await _apiService.createHistorial({
          'paciente': pacienteId,
        });
        setState(() {
          _selectedHistorialId = nuevoHistorial['id'].toString();
        });
      }
    } catch (e) {
      _showError('Error al cargar historial: $e');
    }
  }

  void _seleccionarPaciente(Map<String, dynamic> paciente) async {
    setState(() {
      _selectedPacienteId = paciente['id'];
      _pacienteSeleccionado = paciente;
      _showPacienteSelector = false;
      _isLoading = true;
    });

    await _cargarHistorialPaciente(paciente['id']);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _cargarRegistro() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _apiService.fetchPeriodonciaById(widget.registroId!);
      if (response['periodontograma_datos'] != null) {
        setState(() {
          // Cargar datos de todos los módulos
          _habitosData =
              Map<String, dynamic>.from(response['habitos_datos'] ?? {});
          _antecedentesData =
              Map<String, dynamic>.from(response['antecedentes_datos'] ?? {});
          _examenData =
              Map<String, dynamic>.from(response['examen_datos'] ?? {});
          _periodontogramaData =
              Map<String, dynamic>.from(response['periodontograma_datos']);
          _observacionesController.text =
              response['observaciones_docente'] ?? '';
        });
      }
    } catch (e) {
      _showError('Error al cargar registro: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que se haya seleccionado un paciente
    if (_selectedPacienteId == null || _selectedHistorialId == null) {
      _showError('Debe seleccionar un paciente antes de guardar');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'historial': _selectedHistorialId,
        'estudiante': widget.estudianteId,
        'paciente': _selectedPacienteId,
        'materia': 'periodoncia',
        'habitos_datos': _habitosData,
        'antecedentes_datos': _antecedentesData,
        'examen_datos': _examenData,
        'periodontograma_datos': _periodontogramaData,
        'observaciones_docente': _observacionesController.text,
        'estado': 'pendiente',
      };

      if (widget.registroId != null) {
        // Actualizar registro existente
        await _apiService.updatePeriodoncia(widget.registroId!, data);
        _showSuccess('Registro actualizado exitosamente');
      } else {
        // Crear nuevo registro
        await _apiService.createPeriodoncia(data);
        _showSuccess('Registro creado exitosamente');
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showError('Error al guardar: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.registroId != null
              ? 'Editar Registro de Periodoncia'
              : 'Nuevo Registro de Periodoncia',
        ),
        backgroundColor: Colors.blue[700],
        actions: [
          if (!_isSaving)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _guardarRegistro,
              tooltip: 'Guardar registro',
            ),
          if (_isSaving)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            ),
        ],
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
                    // Título principal
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[700]!, Colors.blue[500]!],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REGISTRO DE PERIODONCIA',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Evaluación periodontal completa',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // SELECTOR DE PACIENTE (si no viene pre-cargado)
                    if (_showPacienteSelector) _buildSelectorPaciente(),

                    // INFORMACIÓN DEL PACIENTE (si ya está seleccionado)
                    if (_pacienteSeleccionado != null) _buildInfoPaciente(),

                    SizedBox(height: 24),

                    // HÁBITOS
                    HabitosWidget(
                      initialData: _habitosData,
                      onDataChanged: (data) {
                        setState(() {
                          _habitosData = data;
                        });
                      },
                      readOnly: false,
                    ),

                    SizedBox(height: 32),

                    // ANTECEDENTES DE ENFERMEDAD PERIODONTAL
                    AntecedentesPeriodontalWidget(
                      initialData: _antecedentesData,
                      onDataChanged: (data) {
                        setState(() {
                          _antecedentesData = data;
                        });
                      },
                      readOnly: false,
                    ),

                    SizedBox(height: 32),

                    // EXAMEN PERIODONTAL
                    ExamenPeriodontalWidget(
                      initialData: _examenData,
                      onDataChanged: (data) {
                        setState(() {
                          _examenData = data;
                        });
                      },
                      readOnly: false,
                    ),

                    SizedBox(height: 32),

                    // PERIODONTOGRAMA VESTIBULAR
                    PeriodontogramaWidget(
                      titulo: 'PERIODONTOGRAMA PERIODONCIA VESTIBULAR',
                      initialData: _periodontogramaData,
                      onDataChanged: (data) {
                        setState(() {
                          _periodontogramaData = data;
                        });
                      },
                      readOnly: false,
                    ),

                    SizedBox(height: 32),

                    // PERIODONTOGRAMA LINGUAL/PALATINO
                    PeriodontogramaWidget(
                      titulo: 'PERIODONTOGRAMA PERIODONCIA LINGUAL/PALATINO',
                      initialData: _periodontogramaData,
                      onDataChanged: (data) {
                        setState(() {
                          _periodontogramaData = data;
                        });
                      },
                      readOnly: false,
                    ),

                    SizedBox(height: 32),

                    // OBSERVACIONES
                    _buildSeccionObservaciones(),

                    SizedBox(height: 32),

                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed:
                              _isSaving ? null : () => Navigator.pop(context),
                          child: Text('Cancelar'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _guardarRegistro,
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
                          label: Text(
                              _isSaving ? 'Guardando...' : 'Guardar Registro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_search, color: Colors.orange[700], size: 28),
              SizedBox(width: 12),
              Text(
                'SELECCIONAR PACIENTE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Buscador de paciente
          TextField(
            controller: _searchPacienteController,
            decoration: InputDecoration(
              labelText: 'Buscar paciente',
              hintText: 'Nombre, apellido o CI',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              setState(() {
                // Filtrar pacientes en tiempo real
              });
            },
          ),

          SizedBox(height: 16),

          // Lista de pacientes filtrados
          if (_pacientes.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay pacientes disponibles',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: _pacientes.where((p) {
                  final searchLower =
                      _searchPacienteController.text.toLowerCase();
                  if (searchLower.isEmpty) return true;

                  final nombres = (p['nombres'] ?? '').toString().toLowerCase();
                  final apellidos =
                      (p['apellidos'] ?? '').toString().toLowerCase();
                  final ci = (p['ci'] ?? '').toString().toLowerCase();

                  return nombres.contains(searchLower) ||
                      apellidos.contains(searchLower) ||
                      ci.contains(searchLower);
                }).length,
                itemBuilder: (context, index) {
                  final pacientesFiltrados = _pacientes.where((p) {
                    final searchLower =
                        _searchPacienteController.text.toLowerCase();
                    if (searchLower.isEmpty) return true;

                    final nombres =
                        (p['nombres'] ?? '').toString().toLowerCase();
                    final apellidos =
                        (p['apellidos'] ?? '').toString().toLowerCase();
                    final ci = (p['ci'] ?? '').toString().toLowerCase();

                    return nombres.contains(searchLower) ||
                        apellidos.contains(searchLower) ||
                        ci.contains(searchLower);
                  }).toList();

                  final paciente = pacientesFiltrados[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[700],
                      child: Text(
                        (paciente['nombres']?.toString()[0] ?? 'P')
                            .toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('CI: ${paciente['ci']}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _seleccionarPaciente(paciente),
                    hoverColor: Colors.orange[50],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoPaciente() {
    if (_pacienteSeleccionado == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 28),
              SizedBox(width: 12),
              Text(
                'PACIENTE SELECCIONADO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre completo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_pacienteSeleccionado!['nombres'] ?? ''} ${_pacienteSeleccionado!['apellidos'] ?? ''}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cédula de Identidad',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _pacienteSeleccionado!['ci'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_showPacienteSelector == false)
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue[700]),
                  onPressed: () {
                    setState(() {
                      _showPacienteSelector = true;
                      _pacienteSeleccionado = null;
                      _selectedPacienteId = null;
                      _selectedHistorialId = null;
                    });
                  },
                  tooltip: 'Cambiar paciente',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionObservaciones() {
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
          Row(
            children: [
              Icon(Icons.note_alt, color: Colors.orange[700], size: 28),
              SizedBox(width: 12),
              Text(
                'OBSERVACIONES Y NOTAS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _observacionesController,
            decoration: InputDecoration(
              labelText: 'Observaciones del docente',
              hintText: 'Hallazgos clínicos, recomendaciones, pronóstico...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }
}
