import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../constants.dart';
import 'crear_evolucion_screen.dart';
import 'package:intl/intl.dart';

class DetallePlanScreen extends StatefulWidget {
  final String planId;

  const DetallePlanScreen({
    Key? key,
    required this.planId,
  }) : super(key: key);

  @override
  State<DetallePlanScreen> createState() => _DetallePlanScreenState();
}

class _DetallePlanScreenState extends State<DetallePlanScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  Map<String, dynamic>? plan;
  List<dynamic> procedimientos = [];
  List<dynamic> evoluciones = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final planData = await _apiService.getPlanTratamiento(widget.planId);
      final procsData =
          await _apiService.fetchProcedimientosPlan(planId: widget.planId);
      final evolsData =
          await _apiService.fetchEvolucionesClinicas(planId: widget.planId);

      // Cargar datos completos del paciente si solo tenemos el ID
      if (planData['paciente'] is String) {
        try {
          final pacienteData =
              await _apiService.getPaciente(planData['paciente']);
          planData['paciente'] = pacienteData;
        } catch (e) {
          print('Error al cargar datos del paciente: $e');
        }
      }

      setState(() {
        plan = planData;
        procedimientos = procsData;
        evoluciones = evolsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar plan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      default:
        return Colors.grey;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'borrador':
        return 'Borrador';
      case 'aprobado':
        return 'Aprobado';
      case 'en_ejecucion':
        return 'En Ejecución';
      case 'completado':
        return 'Completado';
      default:
        return estado;
    }
  }

  Future<void> _completarProcedimiento(Map<String, dynamic> proc) async {
    print('Intentando completar procedimiento: ${proc['id']}');

    // Verificar si el plan está aprobado
    if (plan!['estado'] != 'aprobado' && plan!['estado'] != 'en_ejecucion') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('El plan debe estar aprobado para completar procedimientos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Solicitar costo real
    final costoController = TextEditingController(
      text: proc['costo_estimado']?.toString() ?? '0',
    );

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Completar Procedimiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              proc['descripcion'] ?? 'Procedimiento',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costoController,
              decoration: const InputDecoration(
                labelText: 'Costo Real',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Completar'),
          ),
        ],
      ),
    );

    print('Usuario confirmó: $confirm');

    if (confirm == true) {
      try {
        final costoReal = double.tryParse(costoController.text) ?? 0.0;
        print('Llamando API con costo: $costoReal');

        await _apiService.completarProcedimiento(proc['id'], costoReal);

        print('Procedimiento completado exitosamente');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Procedimiento completado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          await _cargarDatos(); // Recargar datos
        }
      } catch (e) {
        print('Error al completar: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getNombreSeguro(dynamic objeto, [String fallback = 'N/A']) {
    if (objeto == null) return fallback;
    if (objeto is String) return objeto;
    if (objeto is Map) {
      if (objeto['nombre_completo'] != null) {
        return objeto['nombre_completo'].toString();
      }
      final nombres = objeto['nombres']?.toString() ?? '';
      final apellidos = objeto['apellidos']?.toString() ?? '';
      final nombreCompleto = '$nombres $apellidos'.trim();
      return nombreCompleto.isNotEmpty ? nombreCompleto : fallback;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
          backgroundColor: primaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: primaryColor,
        ),
        body: const Center(
          child: Text('No se pudo cargar el plan de tratamiento'),
        ),
      );
    }

    final progreso = plan!['progreso'] ?? {};
    final completados = progreso['completados'] ?? 0;
    final total = progreso['total'] ?? 1;
    final porcentaje = (completados / total * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de Tratamiento'),
        backgroundColor: primaryColor,
        actions: [
          if (plan!['estado'] == 'aprobado' ||
              plan!['estado'] == 'en_ejecucion')
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CrearEvolucionScreen(
                      planId: widget.planId,
                      pacienteId: plan!['paciente'] is Map
                          ? plan!['paciente']['id']
                          : plan!['paciente'],
                      pacienteNombre: _getNombreSeguro(plan!['paciente']),
                      procedimientos: procedimientos,
                    ),
                  ),
                );
                if (result == true) {
                  _cargarDatos();
                }
              },
              tooltip: 'Registrar Evolución',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header con info del plan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getNombreSeguro(plan!['paciente'], 'Paciente'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan!['materia_display'] ?? 'Materia',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(plan!['estado']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getEstadoLabel(plan!['estado']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Estudiante: ${_getNombreSeguro(plan!['estudiante'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (plan!['docente_supervisor'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Supervisor: ${_getNombreSeguro(plan!['docente_supervisor'])}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Barra de progreso
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso: $completados/$total procedimientos',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF424242),
                          ),
                        ),
                        Text(
                          '$porcentaje%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getEstadoColor(plan!['estado']),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: porcentaje / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getEstadoColor(plan!['estado']),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
            tabs: const [
              Tab(text: 'Procedimientos'),
              Tab(text: 'Evoluciones'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Procedimientos
                _buildProcedimientosTab(),

                // Tab Evoluciones
                _buildEvolucionesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcedimientosTab() {
    if (procedimientos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay procedimientos registrados',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: procedimientos.length,
      itemBuilder: (context, index) {
        final proc = procedimientos[index];
        final estado = proc['estado'] ?? 'pendiente';
        final completado = estado == 'completado';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: completado,
              onChanged: completado
                  ? null
                  : (value) async {
                      if (value == true) {
                        await _completarProcedimiento(proc);
                      }
                    },
              activeColor: Colors.green,
            ),
            title: Text(
              proc['descripcion'] ?? 'Procedimiento',
              style: TextStyle(
                color: const Color(0xFF212121),
                decoration: completado ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (proc['pieza_dental'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Pieza: ${proc['pieza_dental']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
                if (proc['costo_estimado'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Costo estimado: \$${proc['costo_estimado']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getPrioridadColor(proc['prioridad'] ?? 'media')
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (proc['prioridad'] ?? 'media').toUpperCase(),
                style: TextStyle(
                  color: _getPrioridadColor(proc['prioridad'] ?? 'media'),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEvolucionesTab() {
    if (evoluciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay evoluciones registradas',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (plan!['estado'] == 'aprobado' ||
                plan!['estado'] == 'en_ejecucion')
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CrearEvolucionScreen(
                        planId: widget.planId,
                        pacienteId: plan!['paciente'] is Map
                            ? plan!['paciente']['id']
                            : plan!['paciente'],
                        pacienteNombre: _getNombreSeguro(plan!['paciente']),
                        procedimientos: procedimientos,
                      ),
                    ),
                  );
                  if (result == true) {
                    _cargarDatos();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Registrar Primera Evolución'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
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
        final fechaSesion = DateTime.parse(evol['fecha_sesion']);
        final dateFormat = DateFormat('dd/MM/yyyy');

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor,
              child: Text(
                '${evol['numero_sesion']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Sesión ${evol['numero_sesion']} - ${dateFormat.format(fechaSesion)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            subtitle: Text(
              evol['procedimiento_descripcion'] ?? 'Sin procedimiento asociado',
              style: TextStyle(color: Colors.grey[700]),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Tratamiento Realizado',
                        evol['tratamiento_realizado'] ?? 'N/A'),
                    if (evol['hallazgos_clinicos'] != null &&
                        evol['hallazgos_clinicos'].isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          'Hallazgos Clínicos', evol['hallazgos_clinicos']),
                    ],
                    if (evol['complicaciones'] != null &&
                        evol['complicaciones'].isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow('Complicaciones', evol['complicaciones']),
                    ],
                    if (evol['materiales_usados'] != null &&
                        evol['materiales_usados'].isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          'Materiales Usados', evol['materiales_usados']),
                    ],
                    if (evol['referencias_clinicas'] != null &&
                        (evol['referencias_clinicas'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Referencias Clínicas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (evol['referencias_clinicas'] as List)
                            .map((ref) => Chip(
                                  label: Text(
                                    ref['tipo'] ?? 'Registro',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: primaryColor,
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (evol['firmado_estudiante'])
                          const Chip(
                            label: Text('✓ Firmado Estudiante'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        if (evol['firmado_docente']) const SizedBox(width: 8),
                        if (evol['firmado_docente'])
                          const Chip(
                            label: Text('✓ Firmado Docente'),
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }
}
