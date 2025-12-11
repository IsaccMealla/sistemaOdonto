import 'package:flutter/material.dart';

class ProstodonciaFijaWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const ProstodonciaFijaWidget({
    Key? key,
    required this.data,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<ProstodonciaFijaWidget> createState() => _ProstodonciaFijaWidgetState();
}

class _ProstodonciaFijaWidgetState extends State<ProstodonciaFijaWidget> {
  // Controladores para Oclusión
  final TextEditingController _tipoOclusiOnController = TextEditingController();
  final TextEditingController _apinamientoDentalController = TextEditingController();
  final TextEditingController _rotacionController = TextEditingController();
  final TextEditingController _sobreerupcionController = TextEditingController();
  final TextEditingController _diastemasController = TextEditingController();
  final TextEditingController _relacionCentricaController = TextEditingController();

  // Controladores para Exploración Radiológica
  final TextEditingController _nivelHuesoAlveolarController = TextEditingController();
  final TextEditingController _proporcionCoronariaController = TextEditingController();
  final TextEditingController _leyAnteController = TextEditingController();
  final TextEditingController _raizLongitudController = TextEditingController();
  final TextEditingController _raizConfiguracionController = TextEditingController();
  final TextEditingController _raizDireccionController = TextEditingController();
  final TextEditingController _crestaAlveolarAlturaController = TextEditingController();
  
  bool _traumaOclusion = false;
  bool _espaciosEdentulos = false;
  
  final TextEditingController _pilaresController = TextEditingController();
  final TextEditingController _curvaSpeeController = TextEditingController();
  final TextEditingController _diagnosticoRadiologicoController = TextEditingController();
  final TextEditingController _diagnosticoClinicoController = TextEditingController();
  final TextEditingController _planTratamientoController = TextEditingController();
  final TextEditingController _tomaImpresionesController = TextEditingController();
  final TextEditingController _cementadoController = TextEditingController();
  final TextEditingController _pruebasInicialesController = TextEditingController();
  final TextEditingController _controlPruebaFinalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final data = widget.data;

    // Oclusión
    _tipoOclusiOnController.text = data['tipo_oclusion'] ?? '';
    _apinamientoDentalController.text = data['apinamiento_dental'] ?? '';
    _rotacionController.text = data['rotacion'] ?? '';
    _sobreerupcionController.text = data['sobreerupcion'] ?? '';
    _diastemasController.text = data['diastemas'] ?? '';
    _relacionCentricaController.text = data['relacion_centrica'] ?? '';

    // Exploración Radiológica
    _nivelHuesoAlveolarController.text = data['nivel_hueso_alveolar'] ?? '';
    _proporcionCoronariaController.text = data['proporcion_coronaria'] ?? '';
    _leyAnteController.text = data['ley_ante'] ?? '';
    _raizLongitudController.text = data['raiz_longitud'] ?? '';
    _raizConfiguracionController.text = data['raiz_configuracion'] ?? '';
    _raizDireccionController.text = data['raiz_direccion'] ?? '';
    _crestaAlveolarAlturaController.text = data['cresta_alveolar_altura'] ?? '';
    
    _traumaOclusion = data['trauma_oclusion'] ?? false;
    _espaciosEdentulos = data['espacios_edentulos'] ?? false;
    
    _pilaresController.text = data['pilares'] ?? '';
    _curvaSpeeController.text = data['curva_spee'] ?? '';
    _diagnosticoRadiologicoController.text = data['diagnostico_radiologico'] ?? '';
    _diagnosticoClinicoController.text = data['diagnostico_clinico'] ?? '';
    _planTratamientoController.text = data['plan_tratamiento'] ?? '';
    _tomaImpresionesController.text = data['toma_impresiones'] ?? '';
    _cementadoController.text = data['cementado'] ?? '';
    _pruebasInicialesController.text = data['pruebas_iniciales'] ?? '';
    _controlPruebaFinalController.text = data['control_prueba_final'] ?? '';
  }

  void _actualizarDatos() {
    final datosActualizados = {
      // Oclusión
      'tipo_oclusion': _tipoOclusiOnController.text,
      'apinamiento_dental': _apinamientoDentalController.text,
      'rotacion': _rotacionController.text,
      'sobreerupcion': _sobreerupcionController.text,
      'diastemas': _diastemasController.text,
      'relacion_centrica': _relacionCentricaController.text,

      // Exploración Radiológica
      'nivel_hueso_alveolar': _nivelHuesoAlveolarController.text,
      'proporcion_coronaria': _proporcionCoronariaController.text,
      'ley_ante': _leyAnteController.text,
      'raiz_longitud': _raizLongitudController.text,
      'raiz_configuracion': _raizConfiguracionController.text,
      'raiz_direccion': _raizDireccionController.text,
      'cresta_alveolar_altura': _crestaAlveolarAlturaController.text,
      
      'trauma_oclusion': _traumaOclusion,
      'espacios_edentulos': _espaciosEdentulos,
      
      'pilares': _pilaresController.text,
      'curva_spee': _curvaSpeeController.text,
      'diagnostico_radiologico': _diagnosticoRadiologicoController.text,
      'diagnostico_clinico': _diagnosticoClinicoController.text,
      'plan_tratamiento': _planTratamientoController.text,
      'toma_impresiones': _tomaImpresionesController.text,
      'cementado': _cementadoController.text,
      'pruebas_iniciales': _pruebasInicialesController.text,
      'control_prueba_final': _controlPruebaFinalController.text,
    };

    widget.onDataChanged(datosActualizados);
  }

  @override
  void dispose() {
    _tipoOclusiOnController.dispose();
    _apinamientoDentalController.dispose();
    _rotacionController.dispose();
    _sobreerupcionController.dispose();
    _diastemasController.dispose();
    _relacionCentricaController.dispose();
    _nivelHuesoAlveolarController.dispose();
    _proporcionCoronariaController.dispose();
    _leyAnteController.dispose();
    _raizLongitudController.dispose();
    _raizConfiguracionController.dispose();
    _raizDireccionController.dispose();
    _crestaAlveolarAlturaController.dispose();
    _pilaresController.dispose();
    _curvaSpeeController.dispose();
    _diagnosticoRadiologicoController.dispose();
    _diagnosticoClinicoController.dispose();
    _planTratamientoController.dispose();
    _tomaImpresionesController.dispose();
    _cementadoController.dispose();
    _pruebasInicialesController.dispose();
    _controlPruebaFinalController.dispose();

    super.dispose();
  }

  Widget _buildSeccionOclusion() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oclusión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tipoOclusiOnController,
                    decoration: InputDecoration(
                      labelText: 'Tipo de oclusión',
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
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _apinamientoDentalController,
                    decoration: InputDecoration(
                      labelText: 'Apiñamiento dental',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.compress, color: Colors.blue),
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

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rotacionController,
                    decoration: InputDecoration(
                      labelText: 'Rotación',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.rotate_90_degrees_ccw, color: Colors.blue),
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
                    controller: _sobreerupcionController,
                    decoration: InputDecoration(
                      labelText: 'Sobreerupción',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.arrow_upward, color: Colors.blue),
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

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _diastemasController,
                    decoration: InputDecoration(
                      labelText: 'Diastemas',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.space_bar, color: Colors.blue),
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
                    controller: _relacionCentricaController,
                    decoration: InputDecoration(
                      labelText: 'Relación céntrica',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.center_focus_strong, color: Colors.blue),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionExploracionRadiologica() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exploración Radiológica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Primera fila
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nivelHuesoAlveolarController,
                    decoration: InputDecoration(
                      labelText: 'Nivel de hueso alveolar',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.layers, color: Colors.blue),
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
                    controller: _proporcionCoronariaController,
                    decoration: InputDecoration(
                      labelText: 'Proporción coronaria',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.aspect_ratio, color: Colors.blue),
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
            TextFormField(
              controller: _leyAnteController,
              decoration: InputDecoration(
                labelText: 'Ley de Ante',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.gavel, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 16),

            // Sección Raíz
            Text(
              'Raíz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _raizLongitudController,
                    decoration: InputDecoration(
                      labelText: 'Longitud',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.straighten, color: Colors.orange),
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
                    controller: _raizConfiguracionController,
                    decoration: InputDecoration(
                      labelText: 'Configuración',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.settings, color: Colors.orange),
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
                    controller: _raizDireccionController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.navigation, color: Colors.orange),
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

            // Cresta alveolar ósea altura coronaria
            TextFormField(
              controller: _crestaAlveolarAlturaController,
              decoration: InputDecoration(
                labelText: 'Cresta alveolar ósea altura coronaria',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.terrain, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 16),

            // Checkboxes Sí/No
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Trauma de oclusión', style: TextStyle(color: Colors.black)),
                    value: _traumaOclusion,
                    onChanged: (value) {
                      setState(() {
                        _traumaOclusion = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.red,
                    checkColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Espacios edéntulos', style: TextStyle(color: Colors.black)),
                    value: _espaciosEdentulos,
                    onChanged: (value) {
                      setState(() {
                        _espaciosEdentulos = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pilares y Curva de Spee
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pilaresController,
                    decoration: InputDecoration(
                      labelText: 'Pilares',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.view_column, color: Colors.blue),
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
                    controller: _curvaSpeeController,
                    decoration: InputDecoration(
                      labelText: 'Curva de Spee',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.show_chart, color: Colors.blue),
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

            // Diagnósticos
            TextFormField(
              controller: _diagnosticoRadiologicoController,
              decoration: InputDecoration(
                labelText: 'Diagnóstico radiológico',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.medical_services, color: Colors.green),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _diagnosticoClinicoController,
              decoration: InputDecoration(
                labelText: 'Diagnóstico clínico',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.assignment, color: Colors.green),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            // Plan de tratamiento
            TextFormField(
              controller: _planTratamientoController,
              decoration: InputDecoration(
                labelText: 'Plan de tratamiento',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.playlist_add_check, color: Colors.purple),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            // Procedimientos
            TextFormField(
              controller: _tomaImpresionesController,
              decoration: InputDecoration(
                labelText: 'Toma de impresiones',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.fingerprint, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _cementadoController,
              decoration: InputDecoration(
                labelText: 'Cementado',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.construction, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _pruebasInicialesController,
              decoration: InputDecoration(
                labelText: 'Pruebas iniciales',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.science, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _controlPruebaFinalController,
              decoration: InputDecoration(
                labelText: 'Control y prueba final',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.check_circle, color: Colors.green),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeccionOclusion(),
          const SizedBox(height: 16),
          _buildSeccionExploracionRadiologica(),
        ],
      ),
    );
  }
}
