import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../constants.dart';

class CrearPlanTratamientoScreen extends StatefulWidget {
  final String pacienteId;
  final String pacienteNombre;

  const CrearPlanTratamientoScreen({
    Key? key,
    required this.pacienteId,
    required this.pacienteNombre,
  }) : super(key: key);

  @override
  State<CrearPlanTratamientoScreen> createState() =>
      _CrearPlanTratamientoScreenState();
}

class _CrearPlanTratamientoScreenState
    extends State<CrearPlanTratamientoScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Campos del plan
  String materiaSeleccionada = 'operatoria_endodoncia';
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  // Lista de procedimientos
  List<Map<String, dynamic>> procedimientos = [];

  // Controllers para nuevo procedimiento
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _piezaDentalController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  String prioridadSeleccionada = 'media';

  bool isSubmitting = false;

  @override
  void dispose() {
    _diagnosticoController.dispose();
    _observacionesController.dispose();
    _descripcionController.dispose();
    _piezaDentalController.dispose();
    _costoController.dispose();
    super.dispose();
  }

  void _agregarProcedimiento() {
    if (_descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La descripción del procedimiento es requerida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nuevoProcedimiento = {
      'secuencia': procedimientos.length + 1,
      'descripcion': _descripcionController.text,
      'pieza_dental': _piezaDentalController.text.isEmpty
          ? null
          : _piezaDentalController.text,
      'prioridad': prioridadSeleccionada,
      'costo_estimado': double.tryParse(_costoController.text) ?? 0.0,
    };

    setState(() {
      procedimientos.add(nuevoProcedimiento);
      // Limpiar campos
      _descripcionController.clear();
      _piezaDentalController.clear();
      _costoController.clear();
      prioridadSeleccionada = 'media';
    });
  }

  void _eliminarProcedimiento(int index) {
    setState(() {
      procedimientos.removeAt(index);
      // Reordenar secuencias
      for (int i = 0; i < procedimientos.length; i++) {
        procedimientos[i]['secuencia'] = i + 1;
      }
    });
  }

  void _reordenarProcedimiento(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = procedimientos.removeAt(oldIndex);
      procedimientos.insert(newIndex, item);
      // Actualizar secuencias
      for (int i = 0; i < procedimientos.length; i++) {
        procedimientos[i]['secuencia'] = i + 1;
      }
    });
  }

  Future<void> _guardarPlan({bool solicitarAprobacion = false}) async {
    if (!_formKey.currentState!.validate()) return;

    if (procedimientos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un procedimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Obtener ID del usuario actual (estudiante)
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');
      if (usuarioJson == null) {
        throw Exception('No se pudo obtener información del usuario');
      }
      final usuario = json.decode(usuarioJson);
      final estudianteId = usuario['id'];

      // Crear plan de tratamiento
      final planData = {
        'paciente': widget.pacienteId,
        'estudiante': estudianteId,
        'materia': materiaSeleccionada,
        'observaciones_generales':
            'Diagnóstico: ${_diagnosticoController.text}\n\n${_observacionesController.text}',
        'estado': 'borrador',
      };

      final planCreado = await _apiService.createPlanTratamiento(planData);
      final planId = planCreado['id'];

      // Crear procedimientos
      for (var proc in procedimientos) {
        final procData = {
          'plan': planId,
          'secuencia': proc['secuencia'],
          'descripcion': proc['descripcion'],
          'pieza_dental': proc['pieza_dental'],
          'prioridad': proc['prioridad'],
          'costo_estimado': proc['costo_estimado'],
          'estado': 'pendiente',
        };
        await _apiService.createProcedimientoPlan(procData);
      }

      // Si se solicita aprobación, aprobar el plan
      if (solicitarAprobacion) {
        await _apiService.aprobarPlanTratamiento(planId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(solicitarAprobacion
                ? 'Plan creado y enviado para aprobación'
                : 'Plan guardado como borrador'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retornar true para recargar
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar plan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Plan de Tratamiento'),
        backgroundColor: primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna izquierda - Formulario principal
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info del paciente
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: primaryColor, size: 32),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Paciente',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF616161),
                                  ),
                                ),
                                Text(
                                  widget.pacienteNombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Materia clínica
                    const Text(
                      'Materia Clínica',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: materiaSeleccionada,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'operatoria_endodoncia',
                            child: Text('Operatoria y Endodoncia')),
                        DropdownMenuItem(
                            value: 'periodoncia', child: Text('Periodoncia')),
                        DropdownMenuItem(
                            value: 'cirugia_bucal',
                            child: Text('Cirugía Bucal')),
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
                            value: 'semiologia', child: Text('Semiología')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            materiaSeleccionada = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Diagnóstico/Motivo
                    const Text(
                      'Diagnóstico / Motivo del Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _diagnosticoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'Ej: Caries múltiples en molares superiores, necesidad de rehabilitación...',
                        hintStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.medical_information,
                            color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El diagnóstico es requerido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Observaciones adicionales
                    const Text(
                      'Observaciones Adicionales',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _observacionesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'Notas adicionales, consideraciones especiales...',
                        hintStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.note, color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),

                    // Agregar procedimiento
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agregar Procedimiento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción del Procedimiento *',
                              hintText:
                                  'Ej: Resina compuesta clase II, Endodoncia...',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(color: Color(0xFF212121)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _piezaDentalController,
                                  decoration: const InputDecoration(
                                    labelText: 'Pieza Dental',
                                    hintText: 'Ej: 16, 26, 36...',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  style:
                                      const TextStyle(color: Color(0xFF212121)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: prioridadSeleccionada,
                                  decoration: const InputDecoration(
                                    labelText: 'Prioridad',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  style:
                                      const TextStyle(color: Color(0xFF212121)),
                                  dropdownColor: Colors.white,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'alta', child: Text('Alta')),
                                    DropdownMenuItem(
                                        value: 'media', child: Text('Media')),
                                    DropdownMenuItem(
                                        value: 'baja', child: Text('Baja')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        prioridadSeleccionada = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _costoController,
                            decoration: const InputDecoration(
                              labelText: 'Costo Estimado',
                              hintText: '50000',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              prefixText: '\$ ',
                            ),
                            style: const TextStyle(color: Color(0xFF212121)),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _agregarProcedimiento,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar Procedimiento'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Columna derecha - Lista de procedimientos
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list_alt, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Procedimientos (${procedimientos.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: procedimientos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay procedimientos agregados',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ReorderableListView.builder(
                              itemCount: procedimientos.length,
                              onReorder: _reordenarProcedimiento,
                              itemBuilder: (context, index) {
                                final proc = procedimientos[index];
                                return _buildProcedimientoCard(proc, index);
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Botones de acción
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () => _guardarPlan(solicitarAprobacion: true),
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: const Text('Guardar y Enviar a Aprobación'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                isSubmitting ? null : () => _guardarPlan(),
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar como Borrador'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedimientoCard(Map<String, dynamic> proc, int index) {
    final prioridad = proc['prioridad'] ?? 'media';
    Color prioridadColor;
    IconData prioridadIcon;

    switch (prioridad) {
      case 'alta':
        prioridadColor = Colors.red;
        prioridadIcon = Icons.arrow_upward;
        break;
      case 'baja':
        prioridadColor = Colors.blue;
        prioridadIcon = Icons.arrow_downward;
        break;
      default:
        prioridadColor = Colors.orange;
        prioridadIcon = Icons.remove;
    }

    return Card(
      key: ValueKey(proc['secuencia']),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: Text(
            '${proc['secuencia']}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          proc['descripcion'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (proc['pieza_dental'] != null)
              Text('Pieza: ${proc['pieza_dental']}'),
            Row(
              children: [
                Icon(prioridadIcon, size: 14, color: prioridadColor),
                const SizedBox(width: 4),
                Text(
                  prioridad.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: prioridadColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text('\$${proc['costo_estimado']}'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _eliminarProcedimiento(index),
        ),
      ),
    );
  }
}
