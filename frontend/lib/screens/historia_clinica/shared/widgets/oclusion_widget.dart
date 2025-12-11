import 'package:flutter/material.dart';

class OclusiOnWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const OclusiOnWidget({
    Key? key,
    required this.data,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<OclusiOnWidget> createState() => _OclusiOnWidgetState();
}

class _OclusiOnWidgetState extends State<OclusiOnWidget> {
  // Controladores para Análisis Facial
  final TextEditingController _competenciaLabialController = TextEditingController();
  final TextEditingController _tipoPerfilController = TextEditingController();
  final TextEditingController _lineaMediaController = TextEditingController();
  final TextEditingController _relacionMolarBaumeController = TextEditingController();
  final TextEditingController _tipoArcoBaumeController = TextEditingController();
  final TextEditingController _relacionMolarAngleController = TextEditingController();
  final TextEditingController _relacionCaninaController = TextEditingController();

  // Campos de Sí/No
  bool _mordidaAbierta = false;
  bool _apinamiento = false;
  bool _mordidaCubierta = false;
  bool _diastemas = false;
  bool _mordidaBordeABorde = false;
  bool _transposicion = false;
  bool _mordidaCruzadaAnterior = false;
  bool _versionRotacion = false;
  bool _mordidaCruzadaUnilateralDerecha = false;
  bool _mordidaCruzadaUnilateralIzquierda = false;
  bool _mordidaCruzadaBilateral = false;

  final TextEditingController _observacionesAnalisisFacialController = TextEditingController();
  final TextEditingController _anomaliasFormacionDentalController = TextEditingController();

  // Controladores para Análisis Conductual
  // Tipo Escobar
  bool _colaborador = false;
  bool _noColaborador = false;
  bool _colaboradorEnPotencia = false;

  // Rasgos de personalidad
  bool _timido = false;
  bool _agresivo = false;
  bool _mimado = false;
  bool _miedoso = false;
  bool _desafiante = false;
  bool _lloroso = false;

  // Rasgos del padre y madre
  bool _cooperador = false;
  bool _despreocupado = false;
  bool _sobreprotector = false;
  bool _reganon = false;
  bool _debil = false;

  final TextEditingController _observacionesConductualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final data = widget.data;

    // Análisis Facial
    _competenciaLabialController.text = data['competencia_labial'] ?? '';
    _tipoPerfilController.text = data['tipo_perfil'] ?? '';
    _lineaMediaController.text = data['linea_media'] ?? '';
    _relacionMolarBaumeController.text = data['relacion_molar_baume'] ?? '';
    _tipoArcoBaumeController.text = data['tipo_arco_baume'] ?? '';
    _relacionMolarAngleController.text = data['relacion_molar_angle'] ?? '';
    _relacionCaninaController.text = data['relacion_canina'] ?? '';

    _mordidaAbierta = data['mordida_abierta'] ?? false;
    _apinamiento = data['apinamiento'] ?? false;
    _mordidaCubierta = data['mordida_cubierta'] ?? false;
    _diastemas = data['diastemas'] ?? false;
    _mordidaBordeABorde = data['mordida_borde_a_borde'] ?? false;
    _transposicion = data['transposicion'] ?? false;
    _mordidaCruzadaAnterior = data['mordida_cruzada_anterior'] ?? false;
    _versionRotacion = data['version_rotacion'] ?? false;
    _mordidaCruzadaUnilateralDerecha = data['mordida_cruzada_unilateral_derecha'] ?? false;
    _mordidaCruzadaUnilateralIzquierda = data['mordida_cruzada_unilateral_izquierda'] ?? false;
    _mordidaCruzadaBilateral = data['mordida_cruzada_bilateral'] ?? false;

    _observacionesAnalisisFacialController.text = data['observaciones_analisis_facial'] ?? '';
    _anomaliasFormacionDentalController.text = data['anomalias_formacion_dental'] ?? '';

    // Análisis Conductual
    _colaborador = data['tipo_colaborador'] ?? false;
    _noColaborador = data['tipo_no_colaborador'] ?? false;
    _colaboradorEnPotencia = data['tipo_colaborador_potencia'] ?? false;

    _timido = data['rasgo_timido'] ?? false;
    _agresivo = data['rasgo_agresivo'] ?? false;
    _mimado = data['rasgo_mimado'] ?? false;
    _miedoso = data['rasgo_miedoso'] ?? false;
    _desafiante = data['rasgo_desafiante'] ?? false;
    _lloroso = data['rasgo_lloroso'] ?? false;

    _cooperador = data['padre_cooperador'] ?? false;
    _despreocupado = data['padre_despreocupado'] ?? false;
    _sobreprotector = data['padre_sobreprotector'] ?? false;
    _reganon = data['padre_reganon'] ?? false;
    _debil = data['padre_debil'] ?? false;

    _observacionesConductualController.text = data['observaciones_conductual'] ?? '';
  }

  void _actualizarDatos() {
    final datosActualizados = {
      // Análisis Facial
      'competencia_labial': _competenciaLabialController.text,
      'tipo_perfil': _tipoPerfilController.text,
      'linea_media': _lineaMediaController.text,
      'relacion_molar_baume': _relacionMolarBaumeController.text,
      'tipo_arco_baume': _tipoArcoBaumeController.text,
      'relacion_molar_angle': _relacionMolarAngleController.text,
      'relacion_canina': _relacionCaninaController.text,

      'mordida_abierta': _mordidaAbierta,
      'apinamiento': _apinamiento,
      'mordida_cubierta': _mordidaCubierta,
      'diastemas': _diastemas,
      'mordida_borde_a_borde': _mordidaBordeABorde,
      'transposicion': _transposicion,
      'mordida_cruzada_anterior': _mordidaCruzadaAnterior,
      'version_rotacion': _versionRotacion,
      'mordida_cruzada_unilateral_derecha': _mordidaCruzadaUnilateralDerecha,
      'mordida_cruzada_unilateral_izquierda': _mordidaCruzadaUnilateralIzquierda,
      'mordida_cruzada_bilateral': _mordidaCruzadaBilateral,

      'observaciones_analisis_facial': _observacionesAnalisisFacialController.text,
      'anomalias_formacion_dental': _anomaliasFormacionDentalController.text,

      // Análisis Conductual
      'tipo_colaborador': _colaborador,
      'tipo_no_colaborador': _noColaborador,
      'tipo_colaborador_potencia': _colaboradorEnPotencia,

      'rasgo_timido': _timido,
      'rasgo_agresivo': _agresivo,
      'rasgo_mimado': _mimado,
      'rasgo_miedoso': _miedoso,
      'rasgo_desafiante': _desafiante,
      'rasgo_lloroso': _lloroso,

      'padre_cooperador': _cooperador,
      'padre_despreocupado': _despreocupado,
      'padre_sobreprotector': _sobreprotector,
      'padre_reganon': _reganon,
      'padre_debil': _debil,

      'observaciones_conductual': _observacionesConductualController.text,
    };

    widget.onDataChanged(datosActualizados);
  }

  @override
  void dispose() {
    _competenciaLabialController.dispose();
    _tipoPerfilController.dispose();
    _lineaMediaController.dispose();
    _relacionMolarBaumeController.dispose();
    _tipoArcoBaumeController.dispose();
    _relacionMolarAngleController.dispose();
    _relacionCaninaController.dispose();
    _observacionesAnalisisFacialController.dispose();
    _anomaliasFormacionDentalController.dispose();
    _observacionesConductualController.dispose();

    super.dispose();
  }

  Widget _buildSeccionAnalisisFacial() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis Facial',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Primera fila de campos
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _competenciaLabialController,
                    decoration: InputDecoration(
                      labelText: 'Competencia labial',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.face, color: Colors.blue),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _tipoPerfilController,
                    decoration: InputDecoration(
                      labelText: 'Tipo de perfil',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segunda fila
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lineaMediaController,
                    decoration: InputDecoration(
                      labelText: 'Línea media',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.linear_scale, color: Colors.blue),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _relacionMolarBaumeController,
                    decoration: InputDecoration(
                      labelText: 'Relación molar de Baume',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.category, color: Colors.blue),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tercera fila
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tipoArcoBaumeController,
                    decoration: InputDecoration(
                      labelText: 'Tipo de arco de Baume',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.architecture, color: Colors.blue),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _relacionMolarAngleController,
                    decoration: InputDecoration(
                      labelText: 'Relación molar Angle',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.straighten, color: Colors.blue),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cuarta fila
            TextFormField(
              controller: _relacionCaninaController,
              decoration: InputDecoration(
                labelText: 'Relación canina',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.arrow_forward, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 20),

            // Campos de Sí/No
            Text(
              'Características oclusales (Sí/No)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildCheckboxGrid([
              {'label': 'Mordida abierta', 'value': _mordidaAbierta, 'onChanged': (v) => setState(() { _mordidaAbierta = v; _actualizarDatos(); })},
              {'label': 'Apiñamiento', 'value': _apinamiento, 'onChanged': (v) => setState(() { _apinamiento = v; _actualizarDatos(); })},
              {'label': 'Mordida cubierta', 'value': _mordidaCubierta, 'onChanged': (v) => setState(() { _mordidaCubierta = v; _actualizarDatos(); })},
              {'label': 'Diastemas', 'value': _diastemas, 'onChanged': (v) => setState(() { _diastemas = v; _actualizarDatos(); })},
              {'label': 'Mordida borde a borde', 'value': _mordidaBordeABorde, 'onChanged': (v) => setState(() { _mordidaBordeABorde = v; _actualizarDatos(); })},
              {'label': 'Transposición', 'value': _transposicion, 'onChanged': (v) => setState(() { _transposicion = v; _actualizarDatos(); })},
              {'label': 'Mordida cruzada anterior', 'value': _mordidaCruzadaAnterior, 'onChanged': (v) => setState(() { _mordidaCruzadaAnterior = v; _actualizarDatos(); })},
              {'label': 'Versión rotación', 'value': _versionRotacion, 'onChanged': (v) => setState(() { _versionRotacion = v; _actualizarDatos(); })},
              {'label': 'Mordida cruzada unilateral derecha', 'value': _mordidaCruzadaUnilateralDerecha, 'onChanged': (v) => setState(() { _mordidaCruzadaUnilateralDerecha = v; _actualizarDatos(); })},
              {'label': 'Mordida cruzada unilateral izquierda', 'value': _mordidaCruzadaUnilateralIzquierda, 'onChanged': (v) => setState(() { _mordidaCruzadaUnilateralIzquierda = v; _actualizarDatos(); })},
              {'label': 'Mordida cruzada bilateral', 'value': _mordidaCruzadaBilateral, 'onChanged': (v) => setState(() { _mordidaCruzadaBilateral = v; _actualizarDatos(); })},
            ]),
            const SizedBox(height: 16),

            // Observaciones
            TextFormField(
              controller: _observacionesAnalisisFacialController,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.notes, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            // Anomalías de formación dental
            TextFormField(
              controller: _anomaliasFormacionDentalController,
              decoration: InputDecoration(
                labelText: 'Anomalías de formación dental',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.warning, color: Colors.orange),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
              onChanged: (_) => _actualizarDatos(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionAnalisisConductual() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis Conductual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Tipo Escobar
            Text(
              'Tipo Escobar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Colaborador', style: TextStyle(color: Colors.black)),
                    value: _colaborador,
                    onChanged: (value) {
                      setState(() {
                        _colaborador = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('No colaborador', style: TextStyle(color: Colors.black)),
                    value: _noColaborador,
                    onChanged: (value) {
                      setState(() {
                        _noColaborador = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.red,
                    checkColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Colaborador en potencia', style: TextStyle(color: Colors.black)),
                    value: _colaboradorEnPotencia,
                    onChanged: (value) {
                      setState(() {
                        _colaboradorEnPotencia = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.orange,
                    checkColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rasgos de personalidad
            Text(
              'Rasgos de personalidad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            _buildCheckboxGrid([
              {'label': 'Tímido', 'value': _timido, 'onChanged': (v) => setState(() { _timido = v; _actualizarDatos(); })},
              {'label': 'Agresivo', 'value': _agresivo, 'onChanged': (v) => setState(() { _agresivo = v; _actualizarDatos(); })},
              {'label': 'Mimado', 'value': _mimado, 'onChanged': (v) => setState(() { _mimado = v; _actualizarDatos(); })},
              {'label': 'Miedoso', 'value': _miedoso, 'onChanged': (v) => setState(() { _miedoso = v; _actualizarDatos(); })},
              {'label': 'Desafiante', 'value': _desafiante, 'onChanged': (v) => setState(() { _desafiante = v; _actualizarDatos(); })},
              {'label': 'Lloroso', 'value': _lloroso, 'onChanged': (v) => setState(() { _lloroso = v; _actualizarDatos(); })},
            ]),
            const SizedBox(height: 16),

            // Rasgos del padre y madre
            Text(
              'Rasgos del padre y madre',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            _buildCheckboxGrid([
              {'label': 'Cooperador', 'value': _cooperador, 'onChanged': (v) => setState(() { _cooperador = v; _actualizarDatos(); })},
              {'label': 'Despreocupado', 'value': _despreocupado, 'onChanged': (v) => setState(() { _despreocupado = v; _actualizarDatos(); })},
              {'label': 'Sobreprotector', 'value': _sobreprotector, 'onChanged': (v) => setState(() { _sobreprotector = v; _actualizarDatos(); })},
              {'label': 'Regañón', 'value': _reganon, 'onChanged': (v) => setState(() { _reganon = v; _actualizarDatos(); })},
              {'label': 'Débil', 'value': _debil, 'onChanged': (v) => setState(() { _debil = v; _actualizarDatos(); })},
            ]),
            const SizedBox(height: 16),

            // Observaciones
            TextFormField(
              controller: _observacionesConductualController,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.psychology, color: Colors.purple),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
              onChanged: (_) => _actualizarDatos(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxGrid(List<Map<String, dynamic>> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          width: MediaQuery.of(context).size.width / 3 - 32,
          child: CheckboxListTile(
            title: Text(
              item['label'],
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            value: item['value'],
            onChanged: (value) => item['onChanged'](value ?? false),
            activeColor: Colors.blue,
            checkColor: Colors.white,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeccionAnalisisFacial(),
          const SizedBox(height: 16),
          _buildSeccionAnalisisConductual(),
        ],
      ),
    );
  }
}
