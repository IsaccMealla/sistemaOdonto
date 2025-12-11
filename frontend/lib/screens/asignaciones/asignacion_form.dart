import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class AsignacionForm extends StatefulWidget {
  final Map<String, dynamic>? asignacion;
  final bool embedded;
  final bool viewOnly;
  AsignacionForm(
      {this.asignacion, this.embedded = false, this.viewOnly = false});

  @override
  _AsignacionFormState createState() => _AsignacionFormState();
}

class _AsignacionFormState extends State<AsignacionForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();

  final TextEditingController observacionesCtrl = TextEditingController();

  String? _selectedEstudianteId;
  String? _selectedPacienteId;
  String? _selectedDocenteId;
  String? _selectedMateria;
  String _selectedEstado = 'activa';

  List<dynamic> _estudiantes = [];
  List<dynamic> _pacientes = [];
  List<dynamic> _docentes = [];
  bool _loadingData = true;

  // Lista de materias basada en las especialidades mencionadas
  final List<String> _materias = [
    'Cirugía Bucal',
    'Operatoria y Endodoncia',
    'Periodoncia',
    'Prostodoncia Fija',
    'Prostodoncia Removible',
    'Odontopediatría',
    'Semiología',
  ];

  final List<Map<String, String>> _estados = [
    {'value': 'activa', 'label': 'Activa'},
    {'value': 'en_progreso', 'label': 'En Progreso'},
    {'value': 'completada', 'label': 'Completada'},
    {'value': 'cancelada', 'label': 'Cancelada'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    if (widget.asignacion != null) {
      observacionesCtrl.text = widget.asignacion!['observaciones'] ?? '';
      _selectedEstudianteId = widget.asignacion!['estudiante'];
      _selectedPacienteId = widget.asignacion!['paciente'];
      _selectedDocenteId = widget.asignacion!['docente'];
      _selectedMateria = widget.asignacion!['materia'];
      _selectedEstado = widget.asignacion!['estado'] ?? 'activa';
    }
  }

  Future<void> _cargarDatos() async {
    try {
      final usuarios = await api.fetchUsuarios();
      final pacientes = await api.fetchPacientes();

      // Filtrar estudiantes y docentes por rol
      final estudiantes =
          usuarios.where((u) => u['is_estudiante'] == true).toList();
      final docentes = usuarios.where((u) => u['is_docente'] == true).toList();

      // Ordenar pacientes por más recientes
      pacientes.sort((a, b) {
        final dateA = DateTime.tryParse(a['creado_en']?.toString() ?? '');
        final dateB = DateTime.tryParse(b['creado_en']?.toString() ?? '');
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      setState(() {
        _estudiantes = estudiantes;
        _pacientes = pacientes;
        _docentes = docentes;
        _loadingData = false;
      });
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  bool get isView => widget.viewOnly;
  bool get isEdit => widget.asignacion != null && !isView;
  bool get isCreate => widget.asignacion == null;

  @override
  Widget build(BuildContext context) {
    final formContent = Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isView
                    ? 'Ver Asignación'
                    : isCreate
                        ? 'Nueva Asignación'
                        : 'Editar Asignación',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),

              if (_loadingData)
                Center(child: CircularProgressIndicator())
              else ...[
                // Selección de Estudiante
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estudiante',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedEstudianteId,
                          decoration: InputDecoration(
                            labelText: 'Estudiante*',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _estudiantes.map<DropdownMenuItem<String>>((est) {
                            return DropdownMenuItem<String>(
                              value: est['id'],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(est['nombre_completo'] ??
                                      est['username']),
                                  if (est['codigo_estudiante'] != null)
                                    Text(
                                      'Código: ${est['codigo_estudiante']}',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: isView
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedEstudianteId = newValue;
                                  });
                                },
                          validator: (v) => v == null
                              ? 'Debe seleccionar un estudiante'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Selección de Paciente
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paciente',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPacienteId,
                          decoration: InputDecoration(
                            labelText: 'Paciente*',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _pacientes.map<DropdownMenuItem<String>>((pac) {
                            return DropdownMenuItem<String>(
                              value: pac['id'],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${pac['nombres']} ${pac['apellidos']}'),
                                  if (pac['celular'] != null)
                                    Text(
                                      'Cel: ${pac['celular']}',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: isView
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedPacienteId = newValue;
                                  });
                                },
                          validator: (v) =>
                              v == null ? 'Debe seleccionar un paciente' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Selección de Docente
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Docente Supervisor',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDocenteId,
                          decoration: InputDecoration(
                            labelText: 'Docente*',
                            border: OutlineInputBorder(),
                          ),
                          items: _docentes.map<DropdownMenuItem<String>>((doc) {
                            return DropdownMenuItem<String>(
                              value: doc['id'],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(doc['nombre_completo'] ??
                                      doc['username']),
                                  if (doc['especialidad'] != null)
                                    Text(
                                      'Esp: ${doc['especialidad']}',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: isView
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedDocenteId = newValue;
                                  });
                                },
                          validator: (v) =>
                              v == null ? 'Debe seleccionar un docente' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Materia y Estado
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles de la Asignación',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedMateria,
                          decoration: InputDecoration(
                            labelText: 'Materia*',
                            border: OutlineInputBorder(),
                          ),
                          items: _materias.map<DropdownMenuItem<String>>((mat) {
                            return DropdownMenuItem<String>(
                              value: mat,
                              child: Text(mat),
                            );
                          }).toList(),
                          onChanged: isView
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedMateria = newValue;
                                  });
                                },
                          validator: (v) =>
                              v == null ? 'Debe seleccionar una materia' : null,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedEstado,
                          decoration: InputDecoration(
                            labelText: 'Estado*',
                            border: OutlineInputBorder(),
                          ),
                          items: _estados.map<DropdownMenuItem<String>>((est) {
                            return DropdownMenuItem<String>(
                              value: est['value'],
                              child: Text(est['label']!),
                            );
                          }).toList(),
                          onChanged: isView
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedEstado = newValue!;
                                  });
                                },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: observacionesCtrl,
                          readOnly: isView,
                          decoration: InputDecoration(
                            labelText: 'Observaciones',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 24),

              // Botones
              if (!isView)
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      final data = {
                        'estudiante': _selectedEstudianteId,
                        'paciente': _selectedPacienteId,
                        'docente': _selectedDocenteId,
                        'materia': _selectedMateria,
                        'estado': _selectedEstado,
                        'observaciones': observacionesCtrl.text,
                      };

                      if (isCreate) {
                        await api.createAsignacion(data);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Asignación creada exitosamente')),
                        );
                      } else {
                        await api.updateAsignacion(
                            widget.asignacion!['id'], data);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Asignación actualizada exitosamente')),
                        );
                      }

                      if (widget.embedded) {
                        context
                            .read<MenuAppController>()
                            .setPage('asignaciones');
                      } else {
                        Navigator.pop(context, true);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text('Guardar'),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    if (widget.embedded) {
                      context.read<MenuAppController>().setPage('asignaciones');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Cerrar'),
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return Card(margin: EdgeInsets.all(16), child: formContent);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isView
            ? 'Ver Asignación'
            : isCreate
                ? 'Nueva Asignación'
                : 'Editar Asignación'),
      ),
      body: formContent,
    );
  }

  @override
  void dispose() {
    observacionesCtrl.dispose();
    super.dispose();
  }
}
