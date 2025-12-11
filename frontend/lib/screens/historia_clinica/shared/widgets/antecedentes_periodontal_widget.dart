import 'package:flutter/material.dart';

/// Widget compartido para Antecedentes de Enfermedad Periodontal
/// Reutilizable en diferentes contextos
class AntecedentesPeriodontalWidget extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool readOnly;

  const AntecedentesPeriodontalWidget({
    Key? key,
    required this.initialData,
    required this.onDataChanged,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<AntecedentesPeriodontalWidget> createState() =>
      _AntecedentesPeriodontalWidgetState();
}

class _AntecedentesPeriodontalWidgetState
    extends State<AntecedentesPeriodontalWidget> {
  late Map<String, dynamic> _data;
  final TextEditingController _detallesFamiliaresController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(
        widget.initialData.isEmpty ? _getDefaultData() : widget.initialData);
    _loadControllers();
  }

  Map<String, dynamic> _getDefaultData() {
    return {
      'sangramiento_espontaneo': false,
      'sangramiento_provocado': false,
      'movilidad': false,
      'dientes_separados': false,
      'dientes_elongados': false,
      'halitosis': false,
      'antecedentes_familiares': <String>[],
      'detalles_familiares': '',
    };
  }

  void _loadControllers() {
    _detallesFamiliaresController.text = _data['detalles_familiares'] ?? '';
  }

  void _updateData() {
    widget.onDataChanged(_data);
  }

  void _toggleBoolean(String key, bool? value) {
    setState(() {
      _data[key] = value ?? false;
      _updateData();
    });
  }

  void _toggleAntecedenteFamiliar(String familiar) {
    setState(() {
      List<String> antecedentes =
          List<String>.from(_data['antecedentes_familiares'] ?? []);
      if (antecedentes.contains(familiar)) {
        antecedentes.remove(familiar);
      } else {
        antecedentes.add(familiar);
      }
      _data['antecedentes_familiares'] = antecedentes;
      _updateData();
    });
  }

  void _updateDetallesFamiliares(String value) {
    setState(() {
      _data['detalles_familiares'] = value;
      _updateData();
    });
  }

  bool _isAntecedenteSelected(String familiar) {
    List<String> antecedentes =
        List<String>.from(_data['antecedentes_familiares'] ?? []);
    return antecedentes.contains(familiar);
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
              Icon(Icons.history, color: Colors.orange[700], size: 28),
              SizedBox(width: 12),
              Text(
                'ANTECEDENTES DE ENFERMEDAD PERIODONTAL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Signos y síntomas
          Text(
            'Signos y síntomas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSwitchTile(
                  'Sangramiento espontáneo',
                  'sangramiento_espontaneo',
                  Icons.water_drop,
                  Colors.red,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSwitchTile(
                  'Sangramiento provocado',
                  'sangramiento_provocado',
                  Icons.water_drop_outlined,
                  Colors.red[300]!,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSwitchTile(
                  'Movilidad',
                  'movilidad',
                  Icons.swap_horiz,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSwitchTile(
                  'Se han separado',
                  'dientes_separados',
                  Icons.trending_flat,
                  Colors.purple,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSwitchTile(
                  'Se han elongado',
                  'dientes_elongados',
                  Icons.height,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSwitchTile(
                  'Halitosis',
                  'halitosis',
                  Icons.air,
                  Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Antecedentes familiares
          Text(
            'Antecedentes familiares',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildFamiliarCheckbox('Padre', 'padre'),
              _buildFamiliarCheckbox('Madre', 'madre'),
              _buildFamiliarCheckbox('Hermanos', 'hermanos'),
              _buildFamiliarCheckbox('Otros', 'otros'),
            ],
          ),

          SizedBox(height: 16),

          TextFormField(
            controller: _detallesFamiliaresController,
            enabled: !widget.readOnly,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Detalles de antecedentes familiares',
              hintText:
                  'Especificar qué familiar y qué tipo de enfermedad periodontal...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.family_restroom),
            ),
            maxLines: 3,
            onChanged: _updateDetallesFamiliares,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String key, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        ),
        value: _data[key] ?? false,
        onChanged:
            widget.readOnly ? null : (value) => _toggleBoolean(key, value),
        dense: true,
      ),
    );
  }

  Widget _buildFamiliarCheckbox(String label, String key) {
    return SizedBox(
      width: 150,
      child: CheckboxListTile(
        title: Text(label, style: TextStyle(fontSize: 14, color: Colors.black)),
        value: _isAntecedenteSelected(key),
        enabled: !widget.readOnly,
        onChanged: (value) => _toggleAntecedenteFamiliar(key),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  @override
  void dispose() {
    _detallesFamiliaresController.dispose();
    super.dispose();
  }
}
