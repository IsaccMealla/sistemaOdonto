import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class CuposEstudianteScreen extends StatefulWidget {
  const CuposEstudianteScreen({Key? key}) : super(key: key);

  @override
  State<CuposEstudianteScreen> createState() => _CuposEstudianteScreenState();
}

class _CuposEstudianteScreenState extends State<CuposEstudianteScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _cupos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCupos();
  }

  Future<void> _cargarCupos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioStr = prefs.getString('usuario');
      if (usuarioStr == null) {
        throw Exception('No hay usuario autenticado');
      }

      final usuario =
          Map<String, dynamic>.from(Map.from(Uri.splitQueryString(usuarioStr)));
      final estudianteId = usuario['id'];

      final cupos = await _apiService.fetchCuposEstudiante(estudianteId);
      setState(() {
        _cupos = cupos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar cupos: $e';
        _isLoading = false;
      });
    }
  }

  Color _getColorPorProgreso(int completados, int requeridos) {
    if (requeridos == 0) return Colors.grey;
    final porcentaje = (completados / requeridos) * 100;
    if (porcentaje < 50) return Colors.red;
    if (porcentaje < 80) return Colors.orange;
    return Colors.green;
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Nunca';
    try {
      final dt = DateTime.parse(fecha.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cupos Clínicos'),
        backgroundColor: const Color(0xFF2C3E50),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarCupos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _cargarCupos,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarCupos,
                  child: _cupos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.inbox_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Aún no has completado procedimientos',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Los cupos se actualizan automáticamente al completar procedimientos',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _cupos.length,
                          itemBuilder: (context, index) {
                            final cupo = _cupos[index];
                            final materiaDisplay =
                                cupo['materia_display'] ?? 'N/A';
                            final completados =
                                cupo['procedimientos_completados'] ?? 0;
                            final ultimaFecha =
                                cupo['ultimo_procedimiento_fecha'];

                            // Requisitos estimados por materia (esto puede venir de configuración)
                            final requeridos =
                                10; // Por defecto, puede configurarse
                            final color =
                                _getColorPorProgreso(completados, requeridos);
                            final porcentaje = requeridos > 0
                                ? ((completados / requeridos) * 100).toInt()
                                : 0;

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      color.withOpacity(0.1),
                                      color.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icono y título
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.medical_services_outlined,
                                              color: color,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              materiaDisplay,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF212121),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      // Progreso
                                      Text(
                                        '$completados / $requeridos',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: requeridos > 0
                                            ? completados / requeridos
                                            : 0,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                color),
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$porcentaje%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: color,
                                            ),
                                          ),
                                          if (ultimaFecha != null)
                                            Text(
                                              _formatearFecha(ultimaFecha),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
