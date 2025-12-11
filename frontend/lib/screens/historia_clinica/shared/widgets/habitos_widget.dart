import 'package:flutter/material.dart';

/// Widget compartido para el módulo de Hábitos
/// Reutilizable en diferentes contextos (materia, vista paciente, etc.)
class HabitosWidget extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool readOnly;

  const HabitosWidget({
    Key? key,
    required this.initialData,
    required this.onDataChanged,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<HabitosWidget> createState() => _HabitosWidgetState();
}

class _HabitosWidgetState extends State<HabitosWidget> {
  late Map<String, dynamic> _data;
  final TextEditingController _tecnicaCepilladoController =
      TextEditingController();
  final TextEditingController _otrosElementosController =
      TextEditingController();
  final TextEditingController _otrosHabitosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(
        widget.initialData.isEmpty ? _getDefaultData() : widget.initialData);
    _loadControllers();
  }

  Map<String, dynamic> _getDefaultData() {
    return {
      'tecnica_cepillado': '',
      'elementos_higiene': {
        'enjuagues': false,
        'hilo_dental': false,
        'palillo_dental': false,
        'otros': '',
      },
      'habitos_parafuncionales': {
        'onicofagia': false,
        'interposicion_lingual': false,
        'bruxismo': false,
        'bruxomania': false,
        'succiona_citricos': false,
        'respirador_bucal': false,
        'fuma': false,
        'bebe': false,
        'interposicion_objetos': false,
        'otros': '',
      }
    };
  }

  void _loadControllers() {
    _tecnicaCepilladoController.text = _data['tecnica_cepillado'] ?? '';
    _otrosElementosController.text = _data['elementos_higiene']?['otros'] ?? '';
    _otrosHabitosController.text =
        _data['habitos_parafuncionales']?['otros'] ?? '';
  }

  void _updateData() {
    widget.onDataChanged(_data);
  }

  void _updateTecnicaCepillado(String value) {
    setState(() {
      _data['tecnica_cepillado'] = value;
      _updateData();
    });
  }

  void _toggleElementoHigiene(String key, bool? value) {
    setState(() {
      _data['elementos_higiene'][key] = value ?? false;
      _updateData();
    });
  }

  void _updateOtrosElementos(String value) {
    setState(() {
      _data['elementos_higiene']['otros'] = value;
      _updateData();
    });
  }

  void _toggleHabitoParafuncional(String key, bool? value) {
    setState(() {
      _data['habitos_parafuncionales'][key] = value ?? false;
      _updateData();
    });
  }

  void _updateOtrosHabitos(String value) {
    setState(() {
      _data['habitos_parafuncionales']['otros'] = value;
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
              Icon(Icons.psychology, color: Colors.purple[700], size: 28),
              SizedBox(width: 12),
              Text(
                'HÁBITOS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Técnica de cepillado
          TextFormField(
            controller: _tecnicaCepilladoController,
            enabled: !widget.readOnly,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Técnica de cepillado',
              hintText: 'Ej: Bass modificada, horizontal, circular, etc.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.brush),
            ),
            onChanged: _updateTecnicaCepillado,
          ),

          SizedBox(height: 24),

          // Elementos utilizados en la higiene bucal
          Text(
            'Elementos utilizados en la higiene bucal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          CheckboxListTile(
            title: Text('Enjuagues', style: TextStyle(color: Colors.black)),
            value: _data['elementos_higiene']['enjuagues'] ?? false,
            enabled: !widget.readOnly,
            onChanged: (value) => _toggleElementoHigiene('enjuagues', value),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Hilo dental', style: TextStyle(color: Colors.black)),
            value: _data['elementos_higiene']['hilo_dental'] ?? false,
            enabled: !widget.readOnly,
            onChanged: (value) => _toggleElementoHigiene('hilo_dental', value),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title:
                Text('Palillo dental', style: TextStyle(color: Colors.black)),
            value: _data['elementos_higiene']['palillo_dental'] ?? false,
            enabled: !widget.readOnly,
            onChanged: (value) =>
                _toggleElementoHigiene('palillo_dental', value),
            controlAffinity: ListTileControlAffinity.leading,
          ),

          SizedBox(height: 8),
          TextFormField(
            controller: _otrosElementosController,
            enabled: !widget.readOnly,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Otros elementos',
              hintText: 'Especificar otros elementos...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.add_circle_outline),
            ),
            onChanged: _updateOtrosElementos,
          ),

          SizedBox(height: 24),

          // Hábitos parafuncionales
          Text(
            'Hábitos parafuncionales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildHabitoCheckbox('Onicofagia', 'onicofagia'),
              _buildHabitoCheckbox(
                  'Interposición lingual', 'interposicion_lingual'),
              _buildHabitoCheckbox('Bruxismo', 'bruxismo'),
              _buildHabitoCheckbox('Bruxomanía', 'bruxomania'),
              _buildHabitoCheckbox('Succiona cítricos', 'succiona_citricos'),
              _buildHabitoCheckbox('Respirador bucal', 'respirador_bucal'),
              _buildHabitoCheckbox('Fuma', 'fuma'),
              _buildHabitoCheckbox('Bebe', 'bebe'),
              _buildHabitoCheckbox(
                  'Interposición de objetos', 'interposicion_objetos'),
            ],
          ),

          SizedBox(height: 16),
          TextFormField(
            controller: _otrosHabitosController,
            enabled: !widget.readOnly,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Otros hábitos',
              hintText: 'Especificar otros hábitos parafuncionales...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.add_circle_outline),
            ),
            maxLines: 2,
            onChanged: _updateOtrosHabitos,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitoCheckbox(String label, String key) {
    return SizedBox(
      width: 200,
      child: CheckboxListTile(
        title: Text(label, style: TextStyle(fontSize: 14, color: Colors.black)),
        value: _data['habitos_parafuncionales'][key] ?? false,
        enabled: !widget.readOnly,
        onChanged: (value) => _toggleHabitoParafuncional(key, value),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  @override
  void dispose() {
    _tecnicaCepilladoController.dispose();
    _otrosElementosController.dispose();
    _otrosHabitosController.dispose();
    super.dispose();
  }
}
