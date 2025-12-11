import 'package:flutter/material.dart';

class ProstodonciaRemovibleWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const ProstodonciaRemovibleWidget({
    Key? key,
    required this.data,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<ProstodonciaRemovibleWidget> createState() => _ProstodonciaRemovibleWidgetState();
}

class _ProstodonciaRemovibleWidgetState extends State<ProstodonciaRemovibleWidget> {
  // Controladores para Antecedentes Protésicos
  String _portadorProtesis = ''; // parcial o total
  String _experienciaProtesica = ''; // favorable o desfavorable
  final TextEditingController _tiempoPortaProtesisController = TextEditingController();

  // Controladores para Relación Alveolar
  String _labio = ''; // largo, mediano, corto
  String _lengua = ''; // grande, mediana, pequeña
  final TextEditingController _examenRadiograficoController = TextEditingController();
  final TextEditingController _diagnosticoProtesisController = TextEditingController();
  final TextEditingController _pronosticoController = TextEditingController();

  // Procedimiento - Sí/No
  bool _impresionesIniciales = false;
  bool _impresionesFinales = false;
  bool _relacionesIntermaxilares = false;
  bool _enfiladoArticulado = false;
  bool _terminado = false;
  final TextEditingController _observacionesProcedimientoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final data = widget.data;

    // Antecedentes Protésicos
    _portadorProtesis = data['portador_protesis'] ?? '';
    _experienciaProtesica = data['experiencia_protesica'] ?? '';
    _tiempoPortaProtesisController.text = data['tiempo_porta_protesis'] ?? '';

    // Relación Alveolar
    _labio = data['labio'] ?? '';
    _lengua = data['lengua'] ?? '';
    _examenRadiograficoController.text = data['examen_radiografico'] ?? '';
    _diagnosticoProtesisController.text = data['diagnostico_protesis_removible'] ?? '';
    _pronosticoController.text = data['pronostico'] ?? '';

    // Procedimiento
    _impresionesIniciales = data['impresiones_iniciales'] ?? false;
    _impresionesFinales = data['impresiones_finales'] ?? false;
    _relacionesIntermaxilares = data['relaciones_intermaxilares'] ?? false;
    _enfiladoArticulado = data['enfilado_articulado'] ?? false;
    _terminado = data['terminado'] ?? false;
    _observacionesProcedimientoController.text = data['observaciones_procedimiento'] ?? '';
  }

  void _actualizarDatos() {
    final datosActualizados = {
      // Antecedentes Protésicos
      'portador_protesis': _portadorProtesis,
      'experiencia_protesica': _experienciaProtesica,
      'tiempo_porta_protesis': _tiempoPortaProtesisController.text,

      // Relación Alveolar
      'labio': _labio,
      'lengua': _lengua,
      'examen_radiografico': _examenRadiograficoController.text,
      'diagnostico_protesis_removible': _diagnosticoProtesisController.text,
      'pronostico': _pronosticoController.text,

      // Procedimiento
      'impresiones_iniciales': _impresionesIniciales,
      'impresiones_finales': _impresionesFinales,
      'relaciones_intermaxilares': _relacionesIntermaxilares,
      'enfilado_articulado': _enfiladoArticulado,
      'terminado': _terminado,
      'observaciones_procedimiento': _observacionesProcedimientoController.text,
    };

    widget.onDataChanged(datosActualizados);
  }

  @override
  void dispose() {
    _tiempoPortaProtesisController.dispose();
    _examenRadiograficoController.dispose();
    _diagnosticoProtesisController.dispose();
    _pronosticoController.dispose();
    _observacionesProcedimientoController.dispose();

    super.dispose();
  }

  Widget _buildSeccionAntecedentesProtesicos() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antecedentes Protésicos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Portador de prótesis
            Text(
              'Portador de prótesis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Parcial', style: TextStyle(color: Colors.black)),
                    value: 'parcial',
                    groupValue: _portadorProtesis,
                    onChanged: (value) {
                      setState(() {
                        _portadorProtesis = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Total', style: TextStyle(color: Colors.black)),
                    value: 'total',
                    groupValue: _portadorProtesis,
                    onChanged: (value) {
                      setState(() {
                        _portadorProtesis = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Experiencia protésica
            Text(
              'Experiencia protésica',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Favorable', style: TextStyle(color: Colors.black)),
                    value: 'favorable',
                    groupValue: _experienciaProtesica,
                    onChanged: (value) {
                      setState(() {
                        _experienciaProtesica = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Desfavorable', style: TextStyle(color: Colors.black)),
                    value: 'desfavorable',
                    groupValue: _experienciaProtesica,
                    onChanged: (value) {
                      setState(() {
                        _experienciaProtesica = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tiempo que porta la prótesis
            TextFormField(
              controller: _tiempoPortaProtesisController,
              decoration: InputDecoration(
                labelText: 'Tiempo que porta la prótesis',
                hintText: 'Ej: 5 años, 2 meses',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.access_time, color: Colors.blue),
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

  Widget _buildSeccionRelacionAlveolar() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relación Alveolar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Labio
            Text(
              'Labio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Largo', style: TextStyle(color: Colors.black, fontSize: 14)),
                    value: 'largo',
                    groupValue: _labio,
                    onChanged: (value) {
                      setState(() {
                        _labio = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Mediano', style: TextStyle(color: Colors.black, fontSize: 14)),
                    value: 'mediano',
                    groupValue: _labio,
                    onChanged: (value) {
                      setState(() {
                        _labio = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Corto', style: TextStyle(color: Colors.black, fontSize: 14)),
                    value: 'corto',
                    groupValue: _labio,
                    onChanged: (value) {
                      setState(() {
                        _labio = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lengua
            Text(
              'Lengua',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Grande', style: TextStyle(color: Colors.black, fontSize: 14)),
                    value: 'grande',
                    groupValue: _lengua,
                    onChanged: (value) {
                      setState(() {
                        _lengua = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Mediana', style: TextStyle(color: Colors.black, fontSize: 14)),
                    value: 'mediana',
                    groupValue: _lengua,
                    onChanged: (value) {
                      setState(() {
                        _lengua = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Pequeña', style: TextStyle(color: Colors.black, fontSize: 14)),
                    value: 'pequeña',
                    groupValue: _lengua,
                    onChanged: (value) {
                      setState(() {
                        _lengua = value ?? '';
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Examen radiográfico
            TextFormField(
              controller: _examenRadiograficoController,
              decoration: InputDecoration(
                labelText: 'Examen radiográfico',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.medical_information, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            // Diagnóstico prótesis removible
            TextFormField(
              controller: _diagnosticoProtesisController,
              decoration: InputDecoration(
                labelText: 'Diagnóstico prótesis removible',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.assignment, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),

            // Pronóstico
            TextFormField(
              controller: _pronosticoController,
              decoration: InputDecoration(
                labelText: 'Pronóstico',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.trending_up, color: Colors.green),
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

  Widget _buildSeccionProcedimiento() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Procedimiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Checkboxes de procedimientos
            CheckboxListTile(
              title: Text('Impresiones iniciales', style: TextStyle(color: Colors.black)),
              value: _impresionesIniciales,
              onChanged: (value) {
                setState(() {
                  _impresionesIniciales = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            CheckboxListTile(
              title: Text('Impresiones finales', style: TextStyle(color: Colors.black)),
              value: _impresionesFinales,
              onChanged: (value) {
                setState(() {
                  _impresionesFinales = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            CheckboxListTile(
              title: Text('Relaciones intermaxilares', style: TextStyle(color: Colors.black)),
              value: _relacionesIntermaxilares,
              onChanged: (value) {
                setState(() {
                  _relacionesIntermaxilares = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            CheckboxListTile(
              title: Text('Enfilado y articulado', style: TextStyle(color: Colors.black)),
              value: _enfiladoArticulado,
              onChanged: (value) {
                setState(() {
                  _enfiladoArticulado = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            CheckboxListTile(
              title: Text('Terminado', style: TextStyle(color: Colors.black)),
              value: _terminado,
              onChanged: (value) {
                setState(() {
                  _terminado = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            const SizedBox(height: 16),

            // Observaciones
            TextFormField(
              controller: _observacionesProcedimientoController,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.notes, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 4,
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
          _buildSeccionAntecedentesProtesicos(),
          const SizedBox(height: 16),
          _buildSeccionRelacionAlveolar(),
          const SizedBox(height: 16),
          _buildSeccionProcedimiento(),
        ],
      ),
    );
  }
}
