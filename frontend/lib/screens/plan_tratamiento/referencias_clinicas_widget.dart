import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../constants.dart';

class ReferenciasClinicasWidget extends StatefulWidget {
  final String pacienteId;
  final List<Map<String, dynamic>> referenciasActuales;
  final Function(List<Map<String, dynamic>>) onReferenciasChanged;

  const ReferenciasClinicasWidget({
    Key? key,
    required this.pacienteId,
    required this.referenciasActuales,
    required this.onReferenciasChanged,
  }) : super(key: key);

  @override
  State<ReferenciasClinicasWidget> createState() =>
      _ReferenciasClinicasWidgetState();
}

class _ReferenciasClinicasWidgetState extends State<ReferenciasClinicasWidget> {
  final ApiService _apiService = ApiService();
  bool _isLoadingRegistros = false;

  Map<String, IconData> _getTipoIcon(String tipo) {
    const iconos = {
      'periodontograma': Icons.grid_on,
      'examen_dental': Icons.sick,
      'protocolo_quirurgico': Icons.medical_services,
      'operatoria': Icons.healing,
      'endodoncia': Icons.local_hospital,
      'cirugia_bucal': Icons.cut,
      'prostodoncia_fija': Icons.architecture,
      'prostodoncia_removible': Icons.playlist_add_check,
      'odontopediatria': Icons.child_care,
      'semiologia': Icons.science,
      'antecedentes': Icons.history,
    };
    return {tipo: iconos[tipo] ?? Icons.description};
  }

  Color _getTipoColor(String tipo) {
    const colores = {
      'periodontograma': Color(0xFF1976D2), // Azul oscuro
      'examen_dental': Color(0xFF388E3C), // Verde oscuro
      'protocolo_quirurgico': Color(0xFFD32F2F), // Rojo oscuro
      'operatoria': Color(0xFF7B1FA2), // Púrpura oscuro
      'endodoncia': Color(0xFFC2185B), // Rosa oscuro
      'cirugia_bucal': Color(0xFFE64A19), // Naranja oscuro
      'prostodoncia_fija': Color(0xFF0288D1), // Cyan oscuro
      'prostodoncia_removible': Color(0xFF0097A7), // Teal oscuro
      'odontopediatria': Color(0xFFFBC02D), // Amarillo oscuro
      'semiologia': Color(0xFF5D4037), // Marrón oscuro
      'antecedentes': Color(0xFF455A64), // Gris azulado oscuro
    };
    return colores[tipo] ?? const Color(0xFF424242); // Gris oscuro por defecto
  }

  String _getTipoNombre(String tipo) {
    const nombres = {
      'periodontograma': 'Periodontograma',
      'examen_dental': 'Examen Dental',
      'protocolo_quirurgico': 'Protocolo Quirúrgico',
      'operatoria': 'Operatoria',
      'endodoncia': 'Endodoncia',
      'cirugia_bucal': 'Cirugía Bucal',
      'prostodoncia_fija': 'Prostodoncia Fija',
      'prostodoncia_removible': 'Prostodoncia Removible',
      'odontopediatria': 'Odontopediatría',
      'semiologia': 'Semiología',
      'antecedentes': 'Antecedentes',
    };
    return nombres[tipo] ?? tipo;
  }

  Future<void> _mostrarSelectorReferencias() async {
    setState(() => _isLoadingRegistros = true);

    try {
      final registrosDisponibles =
          await _apiService.obtenerRegistrosDisponiblesParaReferencia(
        widget.pacienteId,
      );

      if (!mounted) return;

      setState(() => _isLoadingRegistros = false);

      if (registrosDisponibles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No hay registros clínicos disponibles para referenciar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Mostrar diálogo de selección
      final seleccionados = await showDialog<List<Map<String, dynamic>>>(
        context: context,
        builder: (context) => _DialogoSeleccionRegistros(
          registrosDisponibles: registrosDisponibles,
          referenciasActuales: widget.referenciasActuales,
        ),
      );

      if (seleccionados != null) {
        widget.onReferenciasChanged(seleccionados);
      }
    } catch (e) {
      setState(() => _isLoadingRegistros = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar registros: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _eliminarReferencia(int index) {
    final nuevasReferencias = List<Map<String, dynamic>>.from(
      widget.referenciasActuales,
    );
    nuevasReferencias.removeAt(index);
    widget.onReferenciasChanged(nuevasReferencias);
  }

  Future<void> _verDetalleReferencia(Map<String, dynamic> referencia) async {
    try {
      final detalle = await _apiService.obtenerRegistroClinico(
        referencia['tipo'],
        referencia['registro_id'],
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => _DialogoDetalleRegistro(detalle: detalle),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar detalle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y botón agregar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Referencias Clínicas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed:
                  _isLoadingRegistros ? null : _mostrarSelectorReferencias,
              icon: _isLoadingRegistros
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.add_link, size: 18),
              label: const Text('Agregar Referencia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Lista de referencias
        if (widget.referenciasActuales.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF34495E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay referencias agregadas. Vincula registros clínicos relacionados.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.referenciasActuales.asMap().entries.map((entry) {
              final index = entry.key;
              final ref = entry.value;
              final tipo = ref['tipo'] ?? 'desconocido';
              final color = _getTipoColor(tipo);
              final icono = _getTipoIcon(tipo).values.first;

              return InkWell(
                onTap: () => _verDetalleReferencia(ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icono, size: 16, color: color),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getTipoNombre(tipo),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (ref['descripcion'] != null)
                            Text(
                              ref['descripcion'],
                              style: TextStyle(
                                fontSize: 10,
                                color: color.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _eliminarReferencia(index),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _DialogoSeleccionRegistros extends StatefulWidget {
  final List<dynamic> registrosDisponibles;
  final List<Map<String, dynamic>> referenciasActuales;

  const _DialogoSeleccionRegistros({
    required this.registrosDisponibles,
    required this.referenciasActuales,
  });

  @override
  State<_DialogoSeleccionRegistros> createState() =>
      __DialogoSeleccionRegistrosState();
}

class __DialogoSeleccionRegistrosState
    extends State<_DialogoSeleccionRegistros> {
  late List<Map<String, dynamic>> _seleccionados;

  @override
  void initState() {
    super.initState();
    _seleccionados = List.from(widget.referenciasActuales);
  }

  bool _estaSeleccionado(String registroId) {
    return _seleccionados.any((ref) => ref['registro_id'] == registroId);
  }

  void _toggleSeleccion(Map<String, dynamic> registro) {
    setState(() {
      final registroId = registro['registro_id'];
      if (_estaSeleccionado(registroId)) {
        _seleccionados.removeWhere((ref) => ref['registro_id'] == registroId);
      } else {
        _seleccionados.add(registro);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C3E50),
      title: const Text(
        'Seleccionar Referencias',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: widget.registrosDisponibles.length,
          itemBuilder: (context, index) {
            final registro = widget.registrosDisponibles[index];
            final seleccionado = _estaSeleccionado(registro['registro_id']);

            return CheckboxListTile(
              value: seleccionado,
              onChanged: (value) => _toggleSeleccion(registro),
              title: Text(
                registro['descripcion'] ?? 'Registro',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              subtitle: Text(
                '${registro['tipo']} - ${registro['fecha']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              secondary: Icon(
                Icons.description,
                color: primaryColor,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_seleccionados),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: Text('Aceptar (${_seleccionados.length})'),
        ),
      ],
    );
  }
}

class _DialogoDetalleRegistro extends StatelessWidget {
  final Map<String, dynamic> detalle;

  const _DialogoDetalleRegistro({required this.detalle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C3E50),
      title: Row(
        children: [
          const Icon(Icons.description, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              detalle['tipo'] ?? 'Registro Clínico',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Paciente', detalle['paciente_nombre']),
            _buildInfoRow('Fecha', detalle['fecha']),
            const Divider(height: 24),
            if (detalle['observaciones'] != null &&
                detalle['observaciones'].isNotEmpty) ...[
              const Text(
                'Observaciones',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detalle['observaciones'],
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
            ],
            if (detalle['datos'] != null) ...[
              const Text(
                'Datos del Registro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF34495E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: _buildDatosFormatted(detalle['datos']),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatosFormatted(dynamic datos) {
    if (datos == null) {
      return const Text('No hay datos disponibles',
          style: TextStyle(color: Colors.white70));
    }

    // Si es un mapa, mostrarlo de forma legible
    if (datos is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: datos.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value?.toString() ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Si es una lista
    if (datos is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: datos.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${entry.key + 1}. ${entry.value.toString()}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      );
    }

    // Fallback para otros tipos
    return Text(
      datos.toString(),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
      ),
    );
  }
}
