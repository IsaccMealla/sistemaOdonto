import 'package:flutter/material.dart';

/// Widget compartido para Examen Periodontal
/// Evalúa características de la encía: color, textura y consistencia
class ExamenPeriodontalWidget extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool readOnly;

  const ExamenPeriodontalWidget({
    Key? key,
    required this.initialData,
    required this.onDataChanged,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<ExamenPeriodontalWidget> createState() =>
      _ExamenPeriodontalWidgetState();
}

class _ExamenPeriodontalWidgetState extends State<ExamenPeriodontalWidget> {
  late Map<String, dynamic> _data;
  final TextEditingController _observacionesController =
      TextEditingController();

  // Opciones predefinidas
  final List<String> opcionesColor = [
    'Rosado coral',
    'Rosado pálido',
    'Rojo brillante',
    'Rojo oscuro',
    'Cianótico',
    'Otro'
  ];

  final List<String> opcionesTextura = [
    'Punteada (cáscara de naranja)',
    'Lisa',
    'Granular',
    'Nodular',
    'Otro'
  ];

  final List<String> opcionesConsistencia = [
    'Firme',
    'Edematosa',
    'Flácida',
    'Fibrosa',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(
        widget.initialData.isEmpty ? _getDefaultData() : widget.initialData);
    _loadControllers();
  }

  Map<String, dynamic> _getDefaultData() {
    return {
      'caracteristicas_encia': {
        'color': '',
        'textura': '',
        'consistencia': '',
      },
      'observaciones': '',
    };
  }

  void _loadControllers() {
    _observacionesController.text = _data['observaciones'] ?? '';
  }

  void _updateData() {
    widget.onDataChanged(_data);
  }

  void _updateCaracteristica(String tipo, String value) {
    setState(() {
      _data['caracteristicas_encia'][tipo] = value;
      _updateData();
    });
  }

  void _updateObservaciones(String value) {
    setState(() {
      _data['observaciones'] = value;
      _updateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(Icons.search, color: Colors.teal[700], size: 28),
              SizedBox(width: 12),
              Text(
                'EXAMEN PERIODONTAL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          Text(
            'Características de la encía',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),

          // Color
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.palette, color: Colors.pink[400], size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _data['caracteristicas_encia']['color']?.isEmpty ??
                                  true
                              ? null
                              : _data['caracteristicas_encia']['color'],
                      decoration: InputDecoration(
                        hintText: 'Seleccione el color',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: opcionesColor.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: widget.readOnly
                          ? null
                          : (value) => _updateCaracteristica('color', value!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Textura
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.texture, color: Colors.orange[400], size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Textura',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _data['caracteristicas_encia']['textura']?.isEmpty ??
                                  true
                              ? null
                              : _data['caracteristicas_encia']['textura'],
                      decoration: InputDecoration(
                        hintText: 'Seleccione la textura',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: opcionesTextura.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: widget.readOnly
                          ? null
                          : (value) => _updateCaracteristica('textura', value!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Consistencia
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.touch_app, color: Colors.blue[400], size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consistencia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _data['caracteristicas_encia']
                                      ['consistencia']
                                  ?.isEmpty ??
                              true
                          ? null
                          : _data['caracteristicas_encia']['consistencia'],
                      decoration: InputDecoration(
                        hintText: 'Seleccione la consistencia',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: opcionesConsistencia.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: widget.readOnly
                          ? null
                          : (value) =>
                              _updateCaracteristica('consistencia', value!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Observaciones adicionales
          TextFormField(
            controller: _observacionesController,
            enabled: !widget.readOnly,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Observaciones adicionales',
              hintText:
                  'Hallazgos adicionales, zonas específicas afectadas, etc.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_add),
            ),
            maxLines: 4,
            onChanged: _updateObservaciones,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }
}
