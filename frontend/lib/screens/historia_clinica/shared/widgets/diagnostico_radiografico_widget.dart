import 'package:flutter/material.dart';

/// Widget compartido para el módulo de Diagnóstico Radiográfico
class DiagnosticoRadiograficoWidget extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool readOnly;

  const DiagnosticoRadiograficoWidget({
    Key? key,
    required this.initialData,
    required this.onDataChanged,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<DiagnosticoRadiograficoWidget> createState() =>
      _DiagnosticoRadiograficoWidgetState();
}

class _DiagnosticoRadiograficoWidgetState
    extends State<DiagnosticoRadiograficoWidget> {
  late Map<String, dynamic> _data;
  final TextEditingController _examenesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(
        widget.initialData.isEmpty ? _getDefaultData() : widget.initialData);
    _loadControllers();
  }

  Map<String, dynamic> _getDefaultData() {
    return {
      'examenes_solicitados': '',
      'gingivitis': {
        'tipo':
            '', // leve_moderada, severa, marginal, papilar, marginopapilar, difusa, localizada, generalizada
        'clasificaciones': <String>[],
      },
      'periodontitis': {
        'tipo':
            '', // cronica, agresiva, incipiente, moderada, avanzada, localizada, generalizada
        'clasificaciones': <String>[],
      },
    };
  }

  void _loadControllers() {
    _examenesController.text = _data['examenes_solicitados'] ?? '';
  }

  @override
  void dispose() {
    _examenesController.dispose();
    super.dispose();
  }

  void _updateExamenesSolicitados(String value) {
    setState(() {
      _data['examenes_solicitados'] = value;
    });
    widget.onDataChanged(_data);
  }

  void _toggleGingivitis(String tipo, bool? value) {
    setState(() {
      List<String> clasificaciones =
          List<String>.from(_data['gingivitis']['clasificaciones'] ?? []);
      if (value == true) {
        if (!clasificaciones.contains(tipo)) {
          clasificaciones.add(tipo);
        }
      } else {
        clasificaciones.remove(tipo);
      }
      _data['gingivitis']['clasificaciones'] = clasificaciones;
    });
    widget.onDataChanged(_data);
  }

  void _togglePeriodontitis(String tipo, bool? value) {
    setState(() {
      List<String> clasificaciones =
          List<String>.from(_data['periodontitis']['clasificaciones'] ?? []);
      if (value == true) {
        if (!clasificaciones.contains(tipo)) {
          clasificaciones.add(tipo);
        }
      } else {
        clasificaciones.remove(tipo);
      }
      _data['periodontitis']['clasificaciones'] = clasificaciones;
    });
    widget.onDataChanged(_data);
  }

  bool _isGingivitisSelected(String tipo) {
    List<String> clasificaciones =
        List<String>.from(_data['gingivitis']['clasificaciones'] ?? []);
    return clasificaciones.contains(tipo);
  }

  bool _isPeriodontitisSelected(String tipo) {
    List<String> clasificaciones =
        List<String>.from(_data['periodontitis']['clasificaciones'] ?? []);
    return clasificaciones.contains(tipo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.purple[700], size: 28),
              SizedBox(width: 12),
              Text(
                'DIAGNÓSTICO RADIOGRÁFICO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Exámenes solicitados
          Text(
            'Exámenes solicitados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _examenesController,
            enabled: !widget.readOnly,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Diagnóstico',
              hintText: 'Ej: Radiografía panorámica, periapicales, etc.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            onChanged: _updateExamenesSolicitados,
          ),

          SizedBox(height: 24),

          // Gingivitis
          Text(
            'Gingivitis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCheckboxChip('Leve moderada', 'leve_moderada', true),
              _buildCheckboxChip('Severa', 'severa', true),
              _buildCheckboxChip('Marginal', 'marginal', true),
              _buildCheckboxChip('Papilar', 'papilar', true),
              _buildCheckboxChip('Marginopapilar', 'marginopapilar', true),
              _buildCheckboxChip('Difusa', 'difusa', true),
              _buildCheckboxChip('Localizada', 'localizada', true),
              _buildCheckboxChip('Generalizada', 'generalizada', true),
            ],
          ),

          SizedBox(height: 24),

          // Periodontitis
          Text(
            'Periodontitis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCheckboxChip('Crónica', 'cronica', false),
              _buildCheckboxChip('Agresiva', 'agresiva', false),
              _buildCheckboxChip('Incipiente', 'incipiente', false),
              _buildCheckboxChip('Moderada', 'moderada', false),
              _buildCheckboxChip('Avanzada', 'avanzada', false),
              _buildCheckboxChip('Localizada', 'localizada_p', false),
              _buildCheckboxChip('Generalizada', 'generalizada_p', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxChip(String label, String value, bool isGingivitis) {
    bool isSelected = isGingivitis
        ? _isGingivitisSelected(value)
        : _isPeriodontitisSelected(value);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      onSelected: widget.readOnly
          ? null
          : (selected) {
              if (isGingivitis) {
                _toggleGingivitis(value, selected);
              } else {
                _togglePeriodontitis(value, selected);
              }
            },
      selectedColor: Colors.purple[700],
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[200],
      elevation: 2,
      pressElevation: 4,
    );
  }
}
