import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'seguimiento_widget.dart';

class SeguimientoScreen extends StatefulWidget {
  const SeguimientoScreen({Key? key}) : super(key: key);

  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  final ApiService _apiService = ApiService();

  String? _pacienteSeleccionado;
  List<dynamic> _pacientes = [];
  Map<String, dynamic>? _seguimiento;
  bool _cargando = false;
  String? _estudianteId;
  bool _esDocente = false;

  // Para vista de docente
  String? _docenteId;
  List<dynamic> _estudiantes = [];
  String? _estudianteSeleccionado;
  String? _pacienteSeleccionadoDocente;
  List<dynamic> _todosSeguimientos = []; // Todos los seguimientos para filtrar
  String? _filtroEstudiante;
  String? _filtroPaciente;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioActual();
  }

  Future<void> _cargarUsuarioActual() async {
    try {
      final usuario = await _apiService.getCurrentUser();

      // Verificar si el usuario es docente
      final roles = usuario['roles'] as List<dynamic>? ?? [];
      final esDocente = roles
          .any((rol) => rol['nombre']?.toString().toLowerCase() == 'docente');

      setState(() {
        _estudianteId = usuario['id'].toString();
        _esDocente = esDocente;
        if (esDocente) {
          _docenteId = usuario['id'].toString();
        }
      });

      if (!esDocente) {
        await _cargarPacientes();
      } else {
        await _cargarEstudiantes();
        await _cargarTodosSeguimientos();
      }
    } catch (e) {
      _mostrarError('Error al cargar usuario: $e');
    }
  }

  Future<void> _cargarPacientes() async {
    if (_estudianteId == null) return;

    try {
      // Cargar solo pacientes asignados al estudiante
      final pacientes =
          await _apiService.fetchMisPacientesAsignados(_estudianteId!);
      setState(() {
        _pacientes = pacientes;
      });

      if (pacientes.isEmpty) {
        _mostrarError(
            'No tienes pacientes asignados aún. Contacta con tu docente.');
      }
    } catch (e) {
      _mostrarError('Error al cargar pacientes: $e');
    }
  }

  Future<void> _cargarEstudiantes() async {
    try {
      // Cargar TODOS los usuarios con rol Estudiante
      final usuarios = await _apiService.fetchUsuarios();
      final estudiantesFiltrados = usuarios.where((u) {
        final roles = u['roles'] as List<dynamic>? ?? [];
        return roles.any((r) => r['nombre'] == 'Estudiante');
      }).toList();

      setState(() {
        _estudiantes = estudiantesFiltrados;
      });

      // Cargar todos los pacientes
      await _cargarTodosPacientesDocente();
    } catch (e) {
      _mostrarError('Error al cargar estudiantes: $e');
    }
  }

  Future<void> _cargarTodosPacientesDocente() async {
    try {
      final pacientes = await _apiService.fetchPacientes();
      setState(() {
        _pacientes = pacientes;
      });
    } catch (e) {
      _mostrarError('Error al cargar pacientes: $e');
    }
  }

  Future<void> _cargarTodosSeguimientos() async {
    try {
      // Cargar TODOS los seguimientos sin filtro
      final seguimientos = await _apiService.fetchSeguimientos();
      setState(() {
        _todosSeguimientos = seguimientos;
      });
    } catch (e) {
      _mostrarError('Error al cargar seguimientos: $e');
    }
  }

  List<dynamic> get _seguimientosFiltrados {
    var seguimientos = List.from(_todosSeguimientos);

    if (_filtroEstudiante != null) {
      seguimientos = seguimientos
          .where((s) => s['estudiante'] == _filtroEstudiante)
          .toList();
    }

    if (_filtroPaciente != null) {
      seguimientos =
          seguimientos.where((s) => s['paciente'] == _filtroPaciente).toList();
    }

    return seguimientos;
  }

  Future<void> _cargarSeguimiento(String pacienteId) async {
    if (_estudianteId == null) {
      _mostrarError('Error: No se pudo obtener el ID del usuario');
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      // Buscar si ya existe un seguimiento para este estudiante-paciente
      final seguimientos = await _apiService.fetchSeguimientos(
        estudianteId: _estudianteId!,
        pacienteId: pacienteId,
      );

      if (seguimientos.isNotEmpty) {
        setState(() {
          _seguimiento = seguimientos.first;
        });
      } else {
        // Crear nuevo seguimiento
        final nuevoSeguimiento = await _apiService.createSeguimiento({
          'estudiante': _estudianteId!,
          'paciente': pacienteId,
          'activo': true,
        });
        setState(() {
          _seguimiento = nuevoSeguimiento;
        });
      }
    } catch (e) {
      _mostrarError('Error al cargar seguimiento: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _cargarSeguimientoDocente(
      String estudianteId, String pacienteId) async {
    setState(() {
      _cargando = true;
    });

    try {
      // Buscar seguimiento específico
      final seguimientos = await _apiService.fetchSeguimientos(
        estudianteId: estudianteId,
        pacienteId: pacienteId,
      );

      if (seguimientos.isNotEmpty) {
        setState(() {
          _seguimiento = seguimientos.first;
          _estudianteSeleccionado = estudianteId;
          _pacienteSeleccionadoDocente = pacienteId;
        });
      } else {
        _mostrarError('No se encontró el seguimiento');
      }
    } catch (e) {
      _mostrarError('Error al cargar seguimiento: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  String _getEstudianteNombreById(String estudianteId) {
    try {
      final estudiante =
          _estudiantes.firstWhere((e) => e['id'] == estudianteId);
      return '${estudiante['nombres']} ${estudiante['apellidos']}';
    } catch (e) {
      return 'Desconocido';
    }
  }

  String _getPacienteNombreById(String pacienteId) {
    try {
      final paciente = _pacientes.firstWhere((p) => p['id'] == pacienteId);
      return '${paciente['nombres']} ${paciente['apellidos']}';
    } catch (e) {
      return 'Desconocido';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguimiento Clínico'),
        backgroundColor: Colors.teal,
      ),
      body: _esDocente ? _buildVistaDocente() : _buildVistaEstudiante(),
    );
  }

  Widget _buildVistaDocente() {
    if (_seguimiento != null &&
        _pacienteSeleccionadoDocente != null &&
        _estudianteSeleccionado != null) {
      // Mostrar seguimiento específico para revisar
      return Column(
        children: [
          // Header con info y botón volver
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.teal[50],
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _seguimiento = null;
                      _pacienteSeleccionadoDocente = null;
                      _estudianteSeleccionado = null;
                    });
                    _cargarTodosSeguimientos();
                  },
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revisando Seguimiento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Estudiante: ${_getEstudianteNombre(_estudianteSeleccionado!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Paciente: ${_getPacienteNombre(_pacienteSeleccionadoDocente!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('Modo Revisión',
                      style: TextStyle(color: Colors.black87)),
                  backgroundColor: Colors.orange[100],
                  avatar: Icon(Icons.visibility,
                      size: 18, color: Colors.orange[700]),
                ),
              ],
            ),
          ),
          Expanded(
            child: SeguimientoWidget(
              seguimiento: _seguimiento!,
              modoSoloLectura: false,
              onActualizar: () async {
                await _cargarSeguimientoDocente(
                  _estudianteSeleccionado!,
                  _pacienteSeleccionadoDocente!,
                );
              },
            ),
          ),
        ],
      );
    }

    // Vista principal del docente: lista de todos los seguimientos
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 32, color: Colors.teal),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supervisión de Seguimientos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Revisa y aprueba los seguimientos de los estudiantes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Filtros
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroEstudiante,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por estudiante',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos los estudiantes'),
                    ),
                    ..._estudiantes.map((e) => DropdownMenuItem<String>(
                          value: e['id'],
                          child: Text('${e['nombres']} ${e['apellidos']}'),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filtroEstudiante = value;
                      _filtroPaciente = null; // Limpiar otro filtro
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroPaciente,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por paciente',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos los pacientes'),
                    ),
                    ..._pacientes.map((p) => DropdownMenuItem<String>(
                          value: p['id'],
                          child: Text('${p['nombres']} ${p['apellidos']}'),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filtroPaciente = value;
                      _filtroEstudiante = null; // Limpiar otro filtro
                    });
                  },
                ),
              ),
              if (_filtroEstudiante != null || _filtroPaciente != null)
                IconButton(
                  icon: Icon(Icons.clear),
                  tooltip: 'Limpiar filtros',
                  onPressed: () {
                    setState(() {
                      _filtroEstudiante = null;
                      _filtroPaciente = null;
                    });
                  },
                ),
            ],
          ),
          SizedBox(height: 24),

          // Lista de seguimientos
          Expanded(
            child: _cargando
                ? Center(child: CircularProgressIndicator())
                : _seguimientosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 80, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'No hay seguimientos para mostrar',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _seguimientosFiltrados.length,
                        itemBuilder: (context, index) {
                          final seguimiento = _seguimientosFiltrados[index];
                          final estudianteNombre = _getEstudianteNombreById(
                              seguimiento['estudiante']);
                          final pacienteNombre =
                              _getPacienteNombreById(seguimiento['paciente']);
                          final entradas =
                              seguimiento['entradas'] as List<dynamic>? ?? [];
                          final entradasFirmadas = entradas
                              .where((e) => e['firmado'] == true)
                              .length;

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal,
                                child:
                                    Icon(Icons.assignment, color: Colors.white),
                              ),
                              title: Text(
                                'Seguimiento: $estudianteNombre',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Paciente: $pacienteNombre'),
                                  Text(
                                      'Entradas: ${entradas.length} | Firmadas: $entradasFirmadas'),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () async {
                                await _cargarSeguimientoDocente(
                                  seguimiento['estudiante'],
                                  seguimiento['paciente'],
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadistica(String titulo, String valor, IconData icono) {
    return Column(
      children: [
        Icon(icono, color: Colors.teal[700], size: 32),
        SizedBox(height: 8),
        Text(
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  String _getEstudianteNombre(String estudianteId) {
    return _getEstudianteNombreById(estudianteId);
  }

  String _getPacienteNombre(String pacienteId) {
    return _getPacienteNombreById(pacienteId);
  }

  Widget _buildVistaEstudiante() {
    // Agrupar pacientes por materia para mostrar resumen
    Map<String, int> pacientesPorMateria = {};
    for (var paciente in _pacientes) {
      final materia = paciente['asignacion']?['materia'] ?? 'Sin materia';
      pacientesPorMateria[materia] = (pacientesPorMateria[materia] ?? 0) + 1;
    }

    return Column(
      children: [
        // Resumen de asignaciones
        if (_pacientes.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.teal[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tus Asignaciones',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: pacientesPorMateria.entries.map((entry) {
                    return Chip(
                      label: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      backgroundColor: Colors.teal[100],
                      padding: EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        // Selector de paciente
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Seleccionar Paciente',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.person, color: Colors.teal),
            ),
            dropdownColor: Colors.white,
            style: TextStyle(color: Colors.black87, fontSize: 14),
            value: _pacienteSeleccionado,
            selectedItemBuilder: (BuildContext context) {
              return _pacientes.map((paciente) {
                final asignacion = paciente['asignacion'] ?? {};
                final materia = asignacion['materia'] ?? 'Sin materia';
                final docenteNombre =
                    asignacion['docente_nombre'] ?? 'Sin docente';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${paciente['nombres']} ${paciente['apellidos']} - CI: ${paciente['ci']}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '📚 $materia | 👨‍🏫 $docenteNombre',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }).toList();
            },
            items: _pacientes.map((paciente) {
              final asignacion = paciente['asignacion'] ?? {};
              final materia = asignacion['materia'] ?? 'Sin materia';
              final docenteNombre =
                  asignacion['docente_nombre'] ?? 'Sin docente';

              return DropdownMenuItem<String>(
                value: paciente['id'].toString(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${paciente['nombres']} ${paciente['apellidos']} - CI: ${paciente['ci']}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '📚 $materia | 👨‍🏫 $docenteNombre',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _pacienteSeleccionado = value;
                _seguimiento = null;
                if (value != null) {
                  _cargarSeguimiento(value);
                }
              });
            },
          ),
        ),

        // Contenido principal
        Expanded(
          child: _cargando
              ? Center(child: CircularProgressIndicator())
              : _seguimiento == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Selecciona un paciente para ver su seguimiento',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SeguimientoWidget(
                      seguimiento: _seguimiento!,
                      onActualizar: () {
                        // Recargar el seguimiento
                        if (_pacienteSeleccionado != null) {
                          _cargarSeguimiento(_pacienteSeleccionado!);
                        }
                      },
                    ),
        ),
      ],
    );
  }
}
