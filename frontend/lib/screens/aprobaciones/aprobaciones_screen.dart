import 'package:flutter/material.dart';
import 'dart:convert';

import '../../constants.dart';
import '../../services/api_service.dart';
import '../../helpers/date_formatter.dart';

class AprobacionesScreen extends StatefulWidget {
  @override
  State<AprobacionesScreen> createState() => _AprobacionesScreenState();
}

class _AprobacionesScreenState extends State<AprobacionesScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _tratamientosPendientes = [];
  bool _cargando = true;
  String? _materiaFiltro;
  String? _estudianteFiltro;

  final List<Map<String, String>> _materias = [
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
    _cargarTratamientos();
  }

  Future<void> _cargarTratamientos() async {
    setState(() => _cargando = true);

    try {
      final tratamientos =
          await _apiService.fetchTratamientos(estado: 'solicitado');
      setState(() => _tratamientosPendientes =
          List<Map<String, dynamic>>.from(tratamientos));
    } catch (e) {
      print('Error al cargar tratamientos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar tratamientos: $e')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  List<Map<String, dynamic>> get _tratamientosFiltrados {
    var tratamientos = _tratamientosPendientes;

    if (_materiaFiltro != null) {
      tratamientos =
          tratamientos.where((t) => t['materia'] == _materiaFiltro).toList();
    }

    if (_estudianteFiltro != null && _estudianteFiltro!.isNotEmpty) {
      tratamientos = tratamientos.where((t) {
        final nombre = (t['estudiante_nombre'] ?? '').toString().toLowerCase();
        return nombre.contains(_estudianteFiltro!.toLowerCase());
      }).toList();
    }

    return tratamientos;
  }

  Future<void> _aprobarTratamiento(String id) async {
    // Mostrar diálogo para observaciones opcionales
    final observaciones = await _mostrarDialogoObservaciones(
      'Aprobar Tratamiento',
      'Observaciones (opcional):',
    );

    if (observaciones == null) return; // Usuario canceló

    try {
      await _apiService.aprobarTratamiento(id, observaciones: observaciones);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tratamiento aprobado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      await _cargarTratamientos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aprobar: $e')),
      );
    }
  }

  Future<void> _rechazarTratamiento(String id) async {
    // Mostrar diálogo para observaciones obligatorias
    final observaciones = await _mostrarDialogoObservaciones(
      'Rechazar Tratamiento',
      'Observaciones (obligatorias):',
      obligatorio: true,
    );

    if (observaciones == null || observaciones.isEmpty) return;

    try {
      await _apiService.rechazarTratamiento(id, observaciones);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tratamiento rechazado'),
          backgroundColor: Colors.orange,
        ),
      );
      await _cargarTratamientos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al rechazar: $e')),
      );
    }
  }

  Future<String?> _mostrarDialogoObservaciones(
    String titulo,
    String hint, {
    bool obligatorio = false,
  }) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (obligatorio && controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Las observaciones son obligatorias')),
                );
                return;
              }
              Navigator.pop(context, controller.text.trim());
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Aprobaciones Pendientes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: defaultPadding),

          // Filtros
          Wrap(
            spacing: defaultPadding,
            runSpacing: defaultPadding / 2,
            children: [
              // Filtro por materia
              SizedBox(
                width: 250,
                child: DropdownButtonFormField<String>(
                  value: _materiaFiltro,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por Materia',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: secondaryColor,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('Todas')),
                    ..._materias.map((m) => DropdownMenuItem(
                          value: m['value'],
                          child: Text(m['label']!),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => _materiaFiltro = value);
                  },
                ),
              ),

              // Filtro por estudiante
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar Estudiante',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: secondaryColor,
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => _estudianteFiltro = value);
                  },
                ),
              ),

              // Botón refrescar
              ElevatedButton.icon(
                onPressed: _cargarTratamientos,
                icon: Icon(Icons.refresh),
                label: Text('Actualizar'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),

          // Lista de tratamientos
          Expanded(
            child: _cargando
                ? Center(child: CircularProgressIndicator())
                : _tratamientosFiltrados.isEmpty
                    ? Center(
                        child: Text(
                          'No hay tratamientos pendientes de aprobación',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tratamientosFiltrados.length,
                        itemBuilder: (context, index) {
                          final tratamiento = _tratamientosFiltrados[index];
                          return _buildTratamientoCard(tratamiento);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTratamientoCard(Map<String, dynamic> tratamiento) {
    final materiaLabel = _materias.firstWhere(
      (m) => m['value'] == tratamiento['materia'],
      orElse: () => {'label': tratamiento['materia']},
    )['label'];

    return Card(
      color: secondaryColor,
      margin: EdgeInsets.only(bottom: defaultPadding),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.pending_actions, color: Colors.white),
        ),
        title: Text(
          materiaLabel ?? '',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Estudiante: ${tratamiento['estudiante_nombre'] ?? 'N/A'}'),
            Text('Paciente: ${tratamiento['paciente_nombre'] ?? 'N/A'}'),
            Text(
              'Solicitado: ${DateFormatter.formatDateTime(tratamiento['fecha_solicitud'])}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tratamiento['seguimiento'] != null)
                  Text(
                    'Seguimiento ID: ${tratamiento['seguimiento']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                SizedBox(height: defaultPadding),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _rechazarTratamiento(tratamiento['id']),
                      icon: Icon(Icons.close, color: Colors.red),
                      label:
                          Text('Rechazar', style: TextStyle(color: Colors.red)),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _aprobarTratamiento(tratamiento['id']),
                      icon: Icon(Icons.check),
                      label: Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
