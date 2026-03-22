import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../constants.dart';
import 'referencias_clinicas_widget.dart';

class CrearEvolucionScreen extends StatefulWidget {
  final String planId;
  final String pacienteId;
  final String pacienteNombre;
  final List<dynamic>? procedimientos;

  const CrearEvolucionScreen({
    Key? key,
    required this.planId,
    required this.pacienteId,
    required this.pacienteNombre,
    this.procedimientos,
  }) : super(key: key);

  @override
  State<CrearEvolucionScreen> createState() => _CrearEvolucionScreenState();
}

class _CrearEvolucionScreenState extends State<CrearEvolucionScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _tratamientoController = TextEditingController();
  final TextEditingController _hallazgosController = TextEditingController();
  final TextEditingController _complicacionesController =
      TextEditingController();
  final TextEditingController _materialesController = TextEditingController();
  final TextEditingController _indicacionesController = TextEditingController();

  // Variables
  DateTime fechaSesion = DateTime.now();
  DateTime? proximaCita;
  int numeroSesion = 1;
  String? procedimientoSeleccionado;
  List<Map<String, dynamic>> referencias = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cargarNumeroSesion();
  }

  @override
  void dispose() {
    _tratamientoController.dispose();
    _hallazgosController.dispose();
    _complicacionesController.dispose();
    _materialesController.dispose();
    _indicacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarNumeroSesion() async {
    try {
      final evoluciones = await _apiService.fetchEvolucionesClinicas(
        planId: widget.planId,
      );
      setState(() {
        numeroSesion = evoluciones.length + 1;
      });
    } catch (e) {
      print('Error al cargar número de sesión: $e');
    }
  }

  Future<void> _guardarEvolucion({bool firmarDirectamente = false}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_tratamientoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe describir el tratamiento realizado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Obtener estudiante_id del usuario autenticado
      final prefs = await SharedPreferences.getInstance();
      final usuarioStr = prefs.getString('usuario');
      String? estudianteId;

      if (usuarioStr != null) {
        final usuario = json.decode(usuarioStr);
        estudianteId = usuario['id']?.toString();
      }

      if (estudianteId == null) {
        throw Exception('No se pudo obtener el ID del estudiante');
      }

      // Crear evolución
      final evolucionData = {
        'plan': widget.planId,
        'estudiante': estudianteId,
        'procedimiento': procedimientoSeleccionado,
        'fecha_sesion': fechaSesion.toIso8601String(),
        'numero_sesion': numeroSesion,
        'tratamiento_realizado': _tratamientoController.text,
        'hallazgos_clinicos': _hallazgosController.text,
        'complicaciones': _complicacionesController.text,
        'materiales_usados': _materialesController.text,
        'referencias_clinicas': referencias,
        'proxima_cita': proximaCita != null
            ? '${proximaCita!.year}-${proximaCita!.month.toString().padLeft(2, '0')}-${proximaCita!.day.toString().padLeft(2, '0')}'
            : null,
        'indicaciones_proxima_cita': _indicacionesController.text,
      };

      final evolucionCreada =
          await _apiService.createEvolucionClinica(evolucionData);

      // Si se solicita firma directa
      if (firmarDirectamente) {
        await _apiService.firmarEvolucionEstudiante(evolucionCreada['id']);
      }

      // Si hay próxima cita, crear la cita médica automáticamente
      if (proximaCita != null) {
        try {
          await _crearCitaMedica(estudianteId);
        } catch (e) {
          print('Error al crear cita médica: $e');
          // No detenemos el proceso si falla la creación de la cita
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(firmarDirectamente
                ? 'Evolución registrada y firmada${proximaCita != null ? '. Cita creada automáticamente' : ''}'
                : 'Evolución registrada correctamente${proximaCita != null ? '. Cita creada automáticamente' : ''}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar evolución: ${e.toString()}'),
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

  Future<void> _crearCitaMedica(String estudianteId) async {
    if (proximaCita == null) return;

    try {
      // Obtener información del plan para sacar el docente
      final planData = await _apiService.getPlanTratamiento(widget.planId);

      final citaData = {
        'estudiante': estudianteId,
        'paciente': widget.pacienteId,
        'docente': planData['docente_supervisor'],
        'fecha':
            '${proximaCita!.year}-${proximaCita!.month.toString().padLeft(2, '0')}-${proximaCita!.day.toString().padLeft(2, '0')}',
        'hora':
            '09:00:00', // Hora por defecto - el estudiante puede modificarla después
        'motivo': _indicacionesController.text.isNotEmpty
            ? _indicacionesController.text
            : 'Continuación de tratamiento',
        'estado': 'programada',
      };

      await _apiService.createCita(citaData);
      print(
          'Cita médica creada automáticamente para ${proximaCita!.day}/${proximaCita!.month}/${proximaCita!.year}');
    } catch (e) {
      print('Error al crear cita médica automática: $e');
      rethrow;
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaSesion,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (fecha != null) {
      setState(() {
        fechaSesion = fecha;
      });
    }
  }

  Future<void> _seleccionarProximaCita() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (fecha != null) {
      setState(() {
        proximaCita = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        title: const Text('Registrar Evolución Clínica'),
        backgroundColor: primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Info del paciente
              Card(
                color: const Color(0xFF2C3E50),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Paciente',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              widget.pacienteNombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Sesión #$numeroSesion',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Fecha de la sesión
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fecha de la Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _seleccionarFecha,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF34495E),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  '${fechaSesion.day}/${fechaSesion.month}/${fechaSesion.year}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Procedimiento relacionado
                  if (widget.procedimientos != null &&
                      widget.procedimientos!.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Procedimiento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: procedimientoSeleccionado,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF34495E),
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white54),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white54),
                              ),
                              hintText: 'Opcional',
                              hintStyle: const TextStyle(color: Colors.white54),
                            ),
                            dropdownColor: const Color(0xFF34495E),
                            style: const TextStyle(color: Colors.white),
                            items: widget.procedimientos!.map((proc) {
                              return DropdownMenuItem<String>(
                                value: proc['id'],
                                child: Text(
                                  proc['descripcion'] ?? 'Procedimiento',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                procedimientoSeleccionado = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Tratamiento realizado
              const Text(
                'Tratamiento Realizado *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tratamientoController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF34495E),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  hintText: 'Describe detalladamente el tratamiento...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.medical_services, color: Colors.white),
                ),
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El tratamiento realizado es requerido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Hallazgos clínicos
              const Text(
                'Hallazgos Clínicos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hallazgosController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF34495E),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  hintText:
                      'Observaciones, hallazgos durante el procedimiento...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.visibility, color: Colors.white),
                ),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              // Complicaciones
              const Text(
                'Complicaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _complicacionesController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF34495E),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  hintText: 'Si hubo alguna complicación, descríbela aquí...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.warning, color: Colors.white),
                ),
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              // Materiales usados
              const Text(
                'Materiales Usados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _materialesController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF34495E),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  hintText: 'Lista de materiales utilizados...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.inventory_2, color: Colors.white),
                ),
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Referencias clínicas
              ReferenciasClinicasWidget(
                pacienteId: widget.pacienteId,
                referenciasActuales: referencias,
                onReferenciasChanged: (nuevasRefs) {
                  setState(() {
                    referencias = nuevasRefs;
                  });
                },
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Próxima cita
              const Text(
                'Próxima Cita',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _seleccionarProximaCita,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF34495E),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        proximaCita != null
                            ? '${proximaCita!.day}/${proximaCita!.month}/${proximaCita!.year}'
                            : 'Seleccionar fecha (opcional)',
                        style: TextStyle(
                          fontSize: 16,
                          color: proximaCita != null
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                      const Spacer(),
                      if (proximaCita != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            setState(() {
                              proximaCita = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Indicaciones para próxima cita
              TextFormField(
                controller: _indicacionesController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF34495E),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                  labelText: 'Indicaciones para Próxima Cita',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Plan para la siguiente sesión...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.assignment, color: Colors.white),
                ),
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          isSubmitting ? null : () => _guardarEvolucion(),
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () => _guardarEvolucion(firmarDirectamente: true),
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: const Text('Guardar y Firmar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
    );
  }
}
