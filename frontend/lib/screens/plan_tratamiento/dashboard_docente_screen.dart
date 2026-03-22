import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../constants.dart';
import 'detalle_plan_screen.dart';

class DashboardDocenteScreen extends StatefulWidget {
  const DashboardDocenteScreen({Key? key}) : super(key: key);

  @override
  State<DashboardDocenteScreen> createState() => _DashboardDocenteScreenState();
}

class _DashboardDocenteScreenState extends State<DashboardDocenteScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<dynamic> planesPendientes = [];
  List<dynamic> planesAprobados = [];
  List<dynamic> planesEnEjecucion = [];
  List<dynamic> evolucionesPendientes = [];
  List<dynamic> estudiantes = [];
  Map<String, dynamic> todosUsuarios = {}; // Cache de usuarios por ID

  List<dynamic> planesFiltrados = [];
  List<dynamic> evolucionesFiltradas = [];

  bool isLoading = true;
  String? estudianteSeleccionado;
  String? materiaSeleccionada;
  String searchQuery = '';

  final materias = [
    {'value': 'cirugia_bucal', 'label': 'Cirugía Bucal'},
    {'value': 'operatoria_endodoncia', 'label': 'Operatoria y Endodoncia'},
    {'value': 'periodoncia', 'label': 'Periodoncia'},
    {'value': 'prostodoncia_fija', 'label': 'Prostodoncia Fija'},
    {'value': 'prostodoncia_removible', 'label': 'Prostodoncia Removible'},
    {'value': 'odontopediatria', 'label': 'Odontopediatría'},
    {'value': 'semiologia', 'label': 'Semiología'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_aplicarFiltros);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.removeListener(_aplicarFiltros);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtener docente ID del usuario autenticado
      final prefs = await SharedPreferences.getInstance();
      final usuarioStr = prefs.getString('usuario');
      String? docenteId;

      if (usuarioStr != null) {
        final usuario = json.decode(usuarioStr);
        docenteId = usuario['id']?.toString();
      }

      print('🔄 Cargando planes de tratamiento...');

      // Cargar planes por estado
      final pendientes =
          await _apiService.fetchPlanesTratamiento(estado: 'borrador');
      final aprobados =
          await _apiService.fetchPlanesTratamiento(estado: 'aprobado');
      final enEjecucion =
          await _apiService.fetchPlanesTratamiento(estado: 'en_ejecucion');

      print('📦 Planes cargados: ${pendientes.length + aprobados.length + enEjecucion.length}');

      // Cargar evoluciones sin firma de docente
      final evoluciones = await _apiService.fetchEvolucionesSinFirmaDocente();
      print('📋 Evoluciones cargadas: ${evoluciones.length}');

      // Procesar planes y extraer estudiantes
      final todosPlanes = [...pendientes, ...aprobados, ...enEjecucion];
      final estudiantesMap = <String, Map<String, dynamic>>{};

      // Procesar evoluciones para cargar datos de planes
      for (var evol in evoluciones) {
        try {
          final plan = evol['plan'];
          if (plan != null && plan is Map) {
            // Procesar paciente del plan
            final paciente = plan['paciente'];
            if (paciente != null && paciente is String) {
              try {
                final pacienteData = await _apiService.getPaciente(paciente);
                if (pacienteData != null) {
                  plan['paciente'] = pacienteData;
                }
              } catch (e) {
                print('Error al cargar paciente en evolución: $e');
              }
            }
            
            // Procesar estudiante del plan
            final estudiante = plan['estudiante'];
            if (estudiante != null && estudiante is Map) {
              final id = estudiante['id']?.toString();
              if (id != null && !estudiantesMap.containsKey(id)) {
                estudiantesMap[id] = Map<String, dynamic>.from(estudiante);
              }
            }
          }
        } catch (e) {
          print('Error procesando evolución: $e');
        }
      }

      for (var plan in todosPlanes) {
        try {
          // Procesar estudiante
          final estudiante = plan['estudiante'];
          if (estudiante != null && estudiante is Map) {
            final id = estudiante['id']?.toString();
            if (id != null && id.isNotEmpty) {
              // Guardar el estudiante tal como viene del plan
              final estudianteData = Map<String, dynamic>.from(estudiante);
              estudiantesMap[id] = estudianteData;
              print('✅ Estudiante extraído: $id - ${_getNombreFromMap(estudianteData)}');
            }
          } else if (estudiante is String && estudiante.isNotEmpty) {
            print('⚠️ Estudiante viene como ID: $estudiante (no se puede resolver)');
          }

          // Procesar paciente - cargar datos completos si solo tenemos ID
          final paciente = plan['paciente'];
          if (paciente != null && paciente is String) {
            try {
              final pacienteData = await _apiService.getPaciente(paciente);
              if (pacienteData != null) {
                plan['paciente'] = pacienteData; // Reemplazar ID con datos completos
              }
            } catch (e) {
              print('Error al cargar paciente $paciente: $e');
            }
          }
        } catch (e) {
          print('Error procesando plan: $e');
        }
      }

      setState(() {
        planesPendientes = pendientes;
        planesAprobados = aprobados;
        planesEnEjecucion = enEjecucion;
        evolucionesPendientes = evoluciones;
        estudiantes = estudiantesMap.values.toList();
        isLoading = false;
      });

      // Debug: verificar estudiantes cargados
      print('📊 Estudiantes únicos encontrados: ${estudiantes.length}');
      for (var est in estudiantes) {
        print('  - ${est['id']}: ${_getNombre(est)}');
      }

      _aplicarFiltros();
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        isLoading = false;
        estudiantes = []; // Asegurar que la lista no sea null
      });
    }
  }

  void _aplicarFiltros() {
    setState(() {
      // Obtener planes según el tab actual
      List<dynamic> planesActuales;
      switch (_tabController.index) {
        case 0:
          planesActuales = planesPendientes;
          break;
        case 1:
          planesActuales = planesAprobados;
          break;
        case 2:
          planesActuales = planesEnEjecucion;
          break;
        default:
          planesActuales = [];
      }

      // Aplicar filtros a planes
      planesFiltrados = planesActuales.where((plan) {
        bool coincideEstudiante = true;
        bool coincideMateria = true;
        bool coincideBusqueda = true;

        // Filtro por estudiante
        if (estudianteSeleccionado != null) {
          final estudiante = plan['estudiante'];
          if (estudiante is Map) {
            coincideEstudiante =
                estudiante['id']?.toString() == estudianteSeleccionado;
          } else if (estudiante is String) {
            coincideEstudiante = estudiante == estudianteSeleccionado;
          }
        }

        // Filtro por materia
        if (materiaSeleccionada != null) {
          coincideMateria = plan['materia'] == materiaSeleccionada;
        }

        // Búsqueda por nombre de paciente
        if (searchQuery.isNotEmpty) {
          final nombrePaciente = _getNombre(plan['paciente']).toLowerCase();
          coincideBusqueda = nombrePaciente.contains(searchQuery.toLowerCase());
        }

        return coincideEstudiante && coincideMateria && coincideBusqueda;
      }).toList();

      // Aplicar filtros a evoluciones
      evolucionesFiltradas = evolucionesPendientes.where((evol) {
        bool coincideBusqueda = true;

        if (searchQuery.isNotEmpty) {
          final tratamiento =
              (evol['tratamiento_realizado'] ?? '').toLowerCase();
          coincideBusqueda = tratamiento.contains(searchQuery.toLowerCase());
        }

        return coincideBusqueda;
      }).toList();
    });
  }

  Future<void> _aprobarPlan(String planId) async {
    try {
      await _apiService.aprobarPlanTratamiento(planId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan aprobado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al aprobar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _firmarEvolucion(String evolucionId) async {
    try {
      await _apiService.firmarEvolucionDocente(evolucionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evolución firmada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al firmar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Docente'),
        backgroundColor: primaryColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Filtros
              Container(
                color: primaryColor.withOpacity(0.9),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Filtro por estudiante
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: estudianteSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Estudiante',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        dropdownColor: const Color(0xFF2C3E50),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ...estudiantes.map((est) {
                            return DropdownMenuItem<String>(
                              value: est['id']?.toString(),
                              child: Text(
                                _getNombre(est),
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            estudianteSeleccionado = value;
                          });
                          _aplicarFiltros();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filtro por materia
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: materiaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Materia',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.school, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        dropdownColor: const Color(0xFF2C3E50),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todas',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ...materias.map((mat) {
                            return DropdownMenuItem(
                              value: mat['value'],
                              child: Text(
                                mat['label']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            materiaSeleccionada = value;
                          });
                          _aplicarFiltros();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Buscador
              Container(
                color: primaryColor.withOpacity(0.9),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por paciente...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                              });
                              _aplicarFiltros();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _aplicarFiltros();
                  },
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(
                    child: _buildTabWithBadge(
                        'Pendientes', planesPendientes.length, Colors.orange),
                  ),
                  Tab(
                    child: _buildTabWithBadge(
                        'Aprobados', planesAprobados.length, Colors.green),
                  ),
                  Tab(
                    child: _buildTabWithBadge(
                        'En Ejecución', planesEnEjecucion.length, Colors.blue),
                  ),
                  Tab(
                    child: _buildTabWithBadge('Evoluciones',
                        evolucionesPendientes.length, Colors.purple),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPlanesTab('pendientes'),
                _buildPlanesTab('aprobados'),
                _buildPlanesTab('en_ejecucion'),
                _buildEvolucionesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarDatos,
        backgroundColor: primaryColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlanesTab(String tipo) {
    if (planesFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay planes en esta categoría',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (estudianteSeleccionado != null ||
                materiaSeleccionada != null ||
                searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    estudianteSeleccionado = null;
                    materiaSeleccionada = null;
                    searchQuery = '';
                  });
                  _aplicarFiltros();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: planesFiltrados.length,
      itemBuilder: (context, index) {
        final plan = planesFiltrados[index];
        final progreso = plan['progreso_porcentaje'] ?? 0.0;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetallePlanScreen(planId: plan['id']),
                ),
              );
              _cargarDatos();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con estado
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    size: 18, color: Colors.white70),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _getNombre(plan['paciente']),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.school,
                                    size: 14, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  plan['materia_display'] ?? 'Materia',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildEstadoBadge(tipo),
                    ],
                  ),

                  const Divider(height: 24),

                  // Información del estudiante
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF2196F3),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estudiante',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white54),
                            ),
                            Text(
                              _getNombre(plan['estudiante']),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Estadísticas
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          Icons.medical_services,
                          'Procedimientos',
                          '${plan['procedimientos_completados'] ?? 0}/${plan['total_procedimientos'] ?? 0}',
                        ),
                        Container(
                            width: 1, height: 40, color: Colors.grey[300]),
                        _buildStat(
                          Icons.trending_up,
                          'Progreso',
                          '${progreso.toInt()}%',
                        ),
                        Container(
                            width: 1, height: 40, color: Colors.grey[300]),
                        _buildStat(
                          Icons.attach_money,
                          'Costo Est.',
                          '\$${plan['costo_estimado'] ?? 0}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Barra de progreso
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso del plan',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progreso / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progreso < 50
                              ? Colors.red
                              : progreso < 100
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetallePlanScreen(planId: plan['id']),
                              ),
                            );
                            _cargarDatos();
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('Ver Detalle'),
                        ),
                      ),
                      if (tipo == 'pendientes') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _aprobarPlan(plan['id']),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Aprobar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstadoBadge(String tipo) {
    Color color;
    String label;

    switch (tipo) {
      case 'pendientes':
        color = Colors.orange;
        label = 'PENDIENTE';
        break;
      case 'aprobados':
        color = Colors.green;
        label = 'APROBADO';
        break;
      case 'en_ejecucion':
        color = Colors.blue;
        label = 'EN EJECUCIÓN';
        break;
      default:
        color = Colors.grey;
        label = 'DESCONOCIDO';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget _buildEvolucionesTab() {
    final evoluciones = evolucionesFiltradas;

    if (evoluciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay evoluciones pendientes de firma',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: evoluciones.length,
      itemBuilder: (context, index) {
        final evol = evoluciones[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple,
                      radius: 24,
                      child: Text(
                        '#${evol['numero_sesion']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sesión ${evol['numero_sesion']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 12, color: Color(0xFF757575)),
                              const SizedBox(width: 4),
                              Text(
                                evol['fecha_sesion'] ?? '',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF757575)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (evol['firmado_estudiante'])
                      const Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Firmado Est.'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 11),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                  ],
                ),

                const Divider(height: 24),

                // Información del plan
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services,
                              size: 16, color: Color(0xFF2196F3)),
                          const SizedBox(width: 8),
                          const Text(
                            'Plan de Tratamiento',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paciente: ${_getNombre(evol['plan']?['paciente'])}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Estudiante: ${_getNombre(evol['plan']?['estudiante'])}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tratamiento realizado
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description,
                            size: 16, color: Color(0xFF616161)),
                        SizedBox(width: 4),
                        Text(
                          'Tratamiento Realizado:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        evol['tratamiento_realizado'] ?? 'Sin descripción',
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Hallazgos clínicos
                if (evol['hallazgos_clinicos'] != null &&
                    evol['hallazgos_clinicos'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.search,
                              size: 16, color: Color(0xFF616161)),
                          SizedBox(width: 4),
                          Text(
                            'Hallazgos:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF616161),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        evol['hallazgos_clinicos'],
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Botón firmar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _firmarEvolucion(evol['id']),
                    icon: const Icon(Icons.draw),
                    label: const Text('Firmar como Docente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getNombre(dynamic objeto) {
    if (objeto == null) return 'N/A';
    if (objeto is Map) {
      return _getNombreFromMap(Map<String, dynamic>.from(objeto));
    }
    // Si es String (ID), no mostrarlo, devolver mensaje
    if (objeto is String) return 'Cargando...';
    return 'N/A';
  }

  String _getNombreFromMap(Map<String, dynamic> objeto) {
    if (objeto['nombre_completo'] != null) {
      return objeto['nombre_completo'].toString();
    }
    final nombres = objeto['nombres']?.toString() ?? '';
    final apellidos = objeto['apellidos']?.toString() ?? '';
    final nombreCompleto = '$nombres $apellidos'.trim();
    if (nombreCompleto.isNotEmpty) return nombreCompleto;
    return 'N/A';
  }
}
