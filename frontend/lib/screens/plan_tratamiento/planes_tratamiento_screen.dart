import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/plan_tratamiento.dart';
import '../../constants.dart';
import 'crear_plan_screen.dart';
import 'detalle_plan_screen.dart';

class PlanesTratamientoScreen extends StatefulWidget {
  const PlanesTratamientoScreen({Key? key}) : super(key: key);

  @override
  State<PlanesTratamientoScreen> createState() =>
      _PlanesTratamientoScreenState();
}

class _PlanesTratamientoScreenState extends State<PlanesTratamientoScreen> {
  final ApiService _apiService = ApiService();
  List<PlanTratamiento> planes = [];
  bool isLoading = true;
  String? errorMessage;
  String materiaFiltro = 'todos';

  @override
  void initState() {
    super.initState();
    _cargarPlanes();
  }

  Future<void> _cargarPlanes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _apiService.fetchPlanesTratamiento(
        materia: materiaFiltro != 'todos' ? materiaFiltro : null,
      );
      setState(() {
        planes = data.map((json) => PlanTratamiento.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar planes: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'borrador':
        return Colors.grey;
      case 'aprobado':
        return Colors.blue;
      case 'en_ejecucion':
        return Colors.orange;
      case 'completado':
        return Colors.green;
      case 'suspendido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'borrador':
        return Icons.edit_note;
      case 'aprobado':
        return Icons.check_circle_outline;
      case 'en_ejecucion':
        return Icons.play_circle_outline;
      case 'completado':
        return Icons.done_all;
      case 'suspendido':
        return Icons.pause_circle_outline;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Tratamiento'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarPlanes,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: materiaFiltro,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por Materia',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todas')),
                      DropdownMenuItem(
                          value: 'operatoria', child: Text('Operatoria')),
                      DropdownMenuItem(
                          value: 'endodoncia', child: Text('Endodoncia')),
                      DropdownMenuItem(
                          value: 'periodoncia', child: Text('Periodoncia')),
                      DropdownMenuItem(
                          value: 'cirugia', child: Text('Cirugía')),
                      DropdownMenuItem(
                          value: 'prostodoncia_fija',
                          child: Text('Prostodoncia Fija')),
                      DropdownMenuItem(
                          value: 'prostodoncia_removible',
                          child: Text('Prostodoncia Removible')),
                      DropdownMenuItem(
                          value: 'odontopediatria',
                          child: Text('Odontopediatría')),
                      DropdownMenuItem(
                          value: 'ortodoncia', child: Text('Ortodoncia')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          materiaFiltro = value;
                        });
                        _cargarPlanes();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lista de planes
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(errorMessage!,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _cargarPlanes,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : planes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay planes de tratamiento',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Navegar a crear plan
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Función de crear plan próximamente'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crear Primer Plan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: planes.length,
                            itemBuilder: (context, index) {
                              final plan = planes[index];
                              return _buildPlanCard(plan);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Mostrar diálogo para seleccionar paciente
          await _mostrarSeleccionPaciente();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Plan'),
        backgroundColor: primaryColor,
      ),
    );
  }

  Widget _buildPlanCard(PlanTratamiento plan) {
    final progressPercentage = plan.progresoPorcentaje;
    final estadoColor = _getEstadoColor(plan.estado);
    final estadoIcon = _getEstadoIcon(plan.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navegar a detalle del plan
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetallePlanScreen(planId: plan.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(estadoIcon, color: estadoColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.pacienteNombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.materiaNombre,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: estadoColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plan.estado.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progreso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso: ${plan.procedimientosCompletados}/${plan.totalProcedimientos} procedimientos',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '${progressPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressPercentage == 100 ? Colors.green : Colors.blue,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Información adicional
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.person,
                    plan.estudianteNombre,
                    Colors.blue,
                  ),
                  _buildInfoChip(
                    Icons.calendar_today,
                    _formatDate(plan.fechaCreacion),
                    Colors.grey,
                  ),
                  if (plan.docenteAutorizaNombre != null)
                    _buildInfoChip(
                      Icons.verified,
                      plan.docenteAutorizaNombre!,
                      Colors.green,
                    ),
                ],
              ),

              if (plan.observaciones != null &&
                  plan.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan.observaciones!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _mostrarSeleccionPaciente() async {
    try {
      // Obtener ID del usuario actual
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');
      if (usuarioJson == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener información del usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      final usuario = json.decode(usuarioJson);
      final estudianteId = usuario['id'];

      // Obtener pacientes asignados al usuario actual
      final asignaciones =
          await _apiService.fetchMisPacientesAsignados(estudianteId);

      if (!mounted) return;

      if (asignaciones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes pacientes asignados activos'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Mostrar diálogo de selección
      final pacienteSeleccionado = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Seleccionar Paciente'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: asignaciones.length,
                itemBuilder: (context, index) {
                  final paciente = asignaciones[index];

                  // Validar que paciente tenga los campos necesarios
                  if (paciente == null || paciente['id'] == null) {
                    return const SizedBox.shrink();
                  }

                  final nombres = paciente['nombres'] ?? '';
                  final apellidos = paciente['apellidos'] ?? '';
                  final nombreCompleto = '$nombres $apellidos'.trim();

                  if (nombreCompleto.isEmpty) return const SizedBox.shrink();

                  // Información de asignación
                  final asignacion = paciente['asignacion'];
                  final materia =
                      asignacion != null ? asignacion['materia'] ?? '' : '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(
                        nombres.isNotEmpty ? nombres[0].toUpperCase() : 'P',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(nombreCompleto),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Doc: ${paciente['ci'] ?? paciente['documento'] ?? 'N/A'}'),
                        if (materia.isNotEmpty)
                          Text(
                            'Materia: $materia',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                    isThreeLine: materia.isNotEmpty,
                    onTap: () {
                      Navigator.of(context).pop({
                        'id': paciente['id'],
                        'nombres': nombres,
                        'apellidos': apellidos,
                        'nombre_completo': nombreCompleto,
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );

      if (pacienteSeleccionado != null && mounted) {
        // Navegar a crear plan
        final resultado = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CrearPlanTratamientoScreen(
              pacienteId: pacienteSeleccionado['id'],
              pacienteNombre: pacienteSeleccionado['nombre_completo'] ??
                  '${pacienteSeleccionado['nombres'] ?? ''} ${pacienteSeleccionado['apellidos'] ?? ''}'
                      .trim(),
            ),
          ),
        );

        // Si se creó el plan, recargar lista
        if (resultado == true) {
          _cargarPlanes();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pacientes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
