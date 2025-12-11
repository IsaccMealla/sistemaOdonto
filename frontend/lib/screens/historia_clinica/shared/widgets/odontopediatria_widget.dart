import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OdontopediatriaWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const OdontopediatriaWidget({
    Key? key,
    required this.data,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<OdontopediatriaWidget> createState() => _OdontopediatriaWidgetState();
}

class _OdontopediatriaWidgetState extends State<OdontopediatriaWidget> {
  // Controladores para Clínica Odontopediatría
  final TextEditingController _nombreCasaController = TextEditingController();
  final TextEditingController _hobbieController = TextEditingController();
  final TextEditingController _nombrePadreController = TextEditingController();
  final TextEditingController _telefonoPadreController = TextEditingController();
  final TextEditingController _nombreRepresentanteController = TextEditingController();
  final TextEditingController _telefonoRepresentanteController = TextEditingController();

  // Controladores para Antecedentes Personales
  final TextEditingController _duracionPartoController = TextEditingController();
  final TextEditingController _edadMadreController = TextEditingController();
  final TextEditingController _nroEmbarazoController = TextEditingController();
  bool _embarazoControlado = false;
  final TextEditingController _antecedentesEmbarazoController = TextEditingController();

  // Controladores para Perinatales y Neonatales
  bool _partoNormal = false;
  bool _cesarea = false;
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _tratamientoMedicoController = TextEditingController();

  // Controladores para Desarrollo Psicomotor
  final TextEditingController _edadSentoController = TextEditingController();
  final TextEditingController _edadGateoController = TextEditingController();
  final TextEditingController _edadParoController = TextEditingController();
  final TextEditingController _edadCaminoController = TextEditingController();
  final TextEditingController _edadPrimerDienteController = TextEditingController();
  final TextEditingController _edadPrimerPalabraController = TextEditingController();
  final TextEditingController _evolucionEscolarController = TextEditingController();
  final TextEditingController _vacunasController = TextEditingController();
  
  // Hábitos - Si/No con observaciones
  bool _biberon = false;
  final TextEditingController _biberonObsController = TextEditingController();
  bool _chupon = false;
  final TextEditingController _chuponObsController = TextEditingController();
  bool _succionDigital = false;
  final TextEditingController _succionDigitalObsController = TextEditingController();
  bool _enuresis = false;
  final TextEditingController _enuresisObsController = TextEditingController();
  bool _onicofagia = false;
  final TextEditingController _onicofagiaObsController = TextEditingController();
  bool _queilofagia = false;
  final TextEditingController _queilofagiaObsController = TextEditingController();
  bool _geofagia = false;
  final TextEditingController _geofagiaObsController = TextEditingController();
  bool _golosinas = false;
  final TextEditingController _golosinasObsController = TextEditingController();
  bool _otros = false;
  final TextEditingController _otrosObsController = TextEditingController();

  // Controladores para Hábitos de Higiene Bucal
  final TextEditingController _vecesCepilloController = TextEditingController();
  final TextEditingController _cuandoCepillaController = TextEditingController();
  bool _usaEnjuague = false;
  bool _usaHiloDental = false;
  final TextEditingController _higieneController = TextEditingController(); // solo o asistido
  final TextEditingController _pastaCepilloController = TextEditingController();
  bool _atencionPrevia = false;
  final TextEditingController _cuandoDondeController = TextEditingController();
  final TextEditingController _experienciaController = TextEditingController(); // positiva o negativa
  final TextEditingController _porQueController = TextEditingController();

  // Controladores para Alimentación Primer Año
  bool _lactanciaMaterna = false;
  final TextEditingController _lactanciaMaternaEdadController = TextEditingController();
  bool _lactanciaArtificial = false;
  final TextEditingController _lactanciaArtificialEdadController = TextEditingController();
  bool _lactanciaMixta = false;
  final TextEditingController _lactanciaMixtaEdadController = TextEditingController();
  final TextEditingController _alimentacionObsController = TextEditingController();

  // Controladores para Examen Físico
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _presionArterialController = TextEditingController();
  final TextEditingController _frecuenciaRespiratoriaController = TextEditingController();
  final TextEditingController _frecuenciaCardiacaController = TextEditingController();

  // Tipo de Dentición
  bool _temporal = false;
  bool _mixta = false;
  bool _permanente = false;

  // Odontograma Pediátrico - Dientes superiores (51-65)
  final Map<String, TextEditingController> _dientesSuperiores = {
    '55': TextEditingController(),
    '54': TextEditingController(),
    '53': TextEditingController(),
    '52': TextEditingController(),
    '51': TextEditingController(),
    '61': TextEditingController(),
    '62': TextEditingController(),
    '63': TextEditingController(),
    '64': TextEditingController(),
    '65': TextEditingController(),
  };

  // Odontograma Pediátrico - Dientes inferiores (71-85)
  final Map<String, TextEditingController> _dientesInferiores = {
    '85': TextEditingController(),
    '84': TextEditingController(),
    '83': TextEditingController(),
    '82': TextEditingController(),
    '81': TextEditingController(),
    '71': TextEditingController(),
    '72': TextEditingController(),
    '73': TextEditingController(),
    '74': TextEditingController(),
    '75': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final data = widget.data;

    // Clínica Odontopediatría
    _nombreCasaController.text = data['nombre_casa'] ?? '';
    _hobbieController.text = data['hobbie'] ?? '';
    _nombrePadreController.text = data['nombre_padre_madre'] ?? '';
    _telefonoPadreController.text = data['telefono_padre_madre'] ?? '';
    _nombreRepresentanteController.text = data['nombre_representante'] ?? '';
    _telefonoRepresentanteController.text = data['telefono_representante'] ?? '';

    // Antecedentes Personales
    _duracionPartoController.text = data['duracion_parto'] ?? '';
    _edadMadreController.text = data['edad_madre'] ?? '';
    _nroEmbarazoController.text = data['nro_embarazo'] ?? '';
    _embarazoControlado = data['embarazo_controlado'] ?? false;
    _antecedentesEmbarazoController.text = data['antecedentes_embarazo'] ?? '';

    // Perinatales y Neonatales
    _partoNormal = data['parto_normal'] ?? false;
    _cesarea = data['cesarea'] ?? false;
    _observacionesController.text = data['observaciones'] ?? '';
    _tratamientoMedicoController.text = data['tratamiento_medico_actual'] ?? '';

    // Desarrollo Psicomotor
    _edadSentoController.text = data['edad_sento'] ?? '';
    _edadGateoController.text = data['edad_gateo'] ?? '';
    _edadParoController.text = data['edad_paro'] ?? '';
    _edadCaminoController.text = data['edad_camino'] ?? '';
    _edadPrimerDienteController.text = data['edad_primer_diente'] ?? '';
    _edadPrimerPalabraController.text = data['edad_primer_palabra'] ?? '';
    _evolucionEscolarController.text = data['evolucion_escolar'] ?? '';
    _vacunasController.text = data['vacunas'] ?? '';
    _biberon = data['biberon'] ?? false;
    _biberonObsController.text = data['biberon_obs'] ?? '';
    _chupon = data['chupon'] ?? false;
    _chuponObsController.text = data['chupon_obs'] ?? '';
    _succionDigital = data['succion_digital'] ?? false;
    _succionDigitalObsController.text = data['succion_digital_obs'] ?? '';
    _enuresis = data['enuresis'] ?? false;
    _enuresisObsController.text = data['enuresis_obs'] ?? '';
    _onicofagia = data['onicofagia'] ?? false;
    _onicofagiaObsController.text = data['onicofagia_obs'] ?? '';
    _queilofagia = data['queilofagia'] ?? false;
    _queilofagiaObsController.text = data['queilofagia_obs'] ?? '';
    _geofagia = data['geofagia'] ?? false;
    _geofagiaObsController.text = data['geofagia_obs'] ?? '';
    _golosinas = data['golosinas'] ?? false;
    _golosinasObsController.text = data['golosinas_obs'] ?? '';
    _otros = data['otros'] ?? false;
    _otrosObsController.text = data['otros_obs'] ?? '';

    // Hábitos de Higiene Bucal
    _vecesCepilloController.text = data['veces_cepillo'] ?? '';
    _cuandoCepillaController.text = data['cuando_cepilla'] ?? '';
    _usaEnjuague = data['usa_enjuague'] ?? false;
    _usaHiloDental = data['usa_hilo_dental'] ?? false;
    _higieneController.text = data['higiene_solo_asistido'] ?? '';
    _pastaCepilloController.text = data['pasta_cepillo'] ?? '';
    _atencionPrevia = data['atencion_previa'] ?? false;
    _cuandoDondeController.text = data['cuando_donde'] ?? '';
    _experienciaController.text = data['experiencia'] ?? '';
    _porQueController.text = data['por_que'] ?? '';

    // Alimentación Primer Año
    _lactanciaMaterna = data['lactancia_materna'] ?? false;
    _lactanciaMaternaEdadController.text = data['lactancia_materna_edad'] ?? '';
    _lactanciaArtificial = data['lactancia_artificial'] ?? false;
    _lactanciaArtificialEdadController.text = data['lactancia_artificial_edad'] ?? '';
    _lactanciaMixta = data['lactancia_mixta'] ?? false;
    _lactanciaMixtaEdadController.text = data['lactancia_mixta_edad'] ?? '';
    _alimentacionObsController.text = data['alimentacion_obs'] ?? '';

    // Examen Físico
    _pesoController.text = data['peso'] ?? '';
    _tallaController.text = data['talla'] ?? '';
    _temperaturaController.text = data['temperatura'] ?? '';
    _presionArterialController.text = data['presion_arterial'] ?? '';
    _frecuenciaRespiratoriaController.text = data['frecuencia_respiratoria'] ?? '';
    _frecuenciaCardiacaController.text = data['frecuencia_cardiaca'] ?? '';

    // Tipo de Dentición
    _temporal = data['tipo_denticion_temporal'] ?? false;
    _mixta = data['tipo_denticion_mixta'] ?? false;
    _permanente = data['tipo_denticion_permanente'] ?? false;

    // Odontograma Pediátrico - Superiores
    final odontogramaSuperiores = data['odontograma_superiores'] ?? {};
    _dientesSuperiores.forEach((key, controller) {
      controller.text = odontogramaSuperiores[key] ?? '';
    });

    // Odontograma Pediátrico - Inferiores
    final odontogramaInferiores = data['odontograma_inferiores'] ?? {};
    _dientesInferiores.forEach((key, controller) {
      controller.text = odontogramaInferiores[key] ?? '';
    });
  }

  void _actualizarDatos() {
    widget.onDataChanged({
      // Clínica Odontopediatría
      'nombre_casa': _nombreCasaController.text,
      'hobbie': _hobbieController.text,
      'nombre_padre_madre': _nombrePadreController.text,
      'telefono_padre_madre': _telefonoPadreController.text,
      'nombre_representante': _nombreRepresentanteController.text,
      'telefono_representante': _telefonoRepresentanteController.text,

      // Antecedentes Personales
      'duracion_parto': _duracionPartoController.text,
      'edad_madre': _edadMadreController.text,
      'nro_embarazo': _nroEmbarazoController.text,
      'embarazo_controlado': _embarazoControlado,
      'antecedentes_embarazo': _antecedentesEmbarazoController.text,

      // Perinatales y Neonatales
      'parto_normal': _partoNormal,
      'cesarea': _cesarea,
      'observaciones': _observacionesController.text,
      'tratamiento_medico_actual': _tratamientoMedicoController.text,

      // Desarrollo Psicomotor
      'edad_sento': _edadSentoController.text,
      'edad_gateo': _edadGateoController.text,
      'edad_paro': _edadParoController.text,
      'edad_camino': _edadCaminoController.text,
      'edad_primer_diente': _edadPrimerDienteController.text,
      'edad_primer_palabra': _edadPrimerPalabraController.text,
      'evolucion_escolar': _evolucionEscolarController.text,
      'vacunas': _vacunasController.text,
      'biberon': _biberon,
      'biberon_obs': _biberonObsController.text,
      'chupon': _chupon,
      'chupon_obs': _chuponObsController.text,
      'succion_digital': _succionDigital,
      'succion_digital_obs': _succionDigitalObsController.text,
      'enuresis': _enuresis,
      'enuresis_obs': _enuresisObsController.text,
      'onicofagia': _onicofagia,
      'onicofagia_obs': _onicofagiaObsController.text,
      'queilofagia': _queilofagia,
      'queilofagia_obs': _queilofagiaObsController.text,
      'geofagia': _geofagia,
      'geofagia_obs': _geofagiaObsController.text,
      'golosinas': _golosinas,
      'golosinas_obs': _golosinasObsController.text,
      'otros': _otros,
      'otros_obs': _otrosObsController.text,

      // Hábitos de Higiene Bucal
      'veces_cepillo': _vecesCepilloController.text,
      'cuando_cepilla': _cuandoCepillaController.text,
      'usa_enjuague': _usaEnjuague,
      'usa_hilo_dental': _usaHiloDental,
      'higiene_solo_asistido': _higieneController.text,
      'pasta_cepillo': _pastaCepilloController.text,
      'atencion_previa': _atencionPrevia,
      'cuando_donde': _cuandoDondeController.text,
      'experiencia': _experienciaController.text,
      'por_que': _porQueController.text,

      // Alimentación Primer Año
      'lactancia_materna': _lactanciaMaterna,
      'lactancia_materna_edad': _lactanciaMaternaEdadController.text,
      'lactancia_artificial': _lactanciaArtificial,
      'lactancia_artificial_edad': _lactanciaArtificialEdadController.text,
      'lactancia_mixta': _lactanciaMixta,
      'lactancia_mixta_edad': _lactanciaMixtaEdadController.text,
      'alimentacion_obs': _alimentacionObsController.text,

      // Examen Físico
      'peso': _pesoController.text,
      'talla': _tallaController.text,
      'temperatura': _temperaturaController.text,
      'presion_arterial': _presionArterialController.text,
      'frecuencia_respiratoria': _frecuenciaRespiratoriaController.text,
      'frecuencia_cardiaca': _frecuenciaCardiacaController.text,
    });
  }

  @override
  void dispose() {
    _nombreCasaController.dispose();
    _hobbieController.dispose();
    _nombrePadreController.dispose();
    _telefonoPadreController.dispose();
    _nombreRepresentanteController.dispose();
    _telefonoRepresentanteController.dispose();
    _duracionPartoController.dispose();
    _edadMadreController.dispose();
    _nroEmbarazoController.dispose();
    _antecedentesEmbarazoController.dispose();
    _observacionesController.dispose();
    _tratamientoMedicoController.dispose();
    _edadSentoController.dispose();
    _edadGateoController.dispose();
    _edadParoController.dispose();
    _edadCaminoController.dispose();
    _edadPrimerDienteController.dispose();
    _edadPrimerPalabraController.dispose();
    _evolucionEscolarController.dispose();
    _vacunasController.dispose();
    _biberonObsController.dispose();
    _chuponObsController.dispose();
    _succionDigitalObsController.dispose();
    _enuresisObsController.dispose();
    _onicofagiaObsController.dispose();
    _queilofagiaObsController.dispose();
    _geofagiaObsController.dispose();
    _golosinasObsController.dispose();
    _otrosObsController.dispose();
    _vecesCepilloController.dispose();
    _cuandoCepillaController.dispose();
    _higieneController.dispose();
    _pastaCepilloController.dispose();
    _cuandoDondeController.dispose();
    _experienciaController.dispose();
    _porQueController.dispose();
    _lactanciaMaternaEdadController.dispose();
    _lactanciaArtificialEdadController.dispose();
    _lactanciaMixtaEdadController.dispose();
    _alimentacionObsController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _temperaturaController.dispose();
    _presionArterialController.dispose();
    _frecuenciaRespiratoriaController.dispose();
    _frecuenciaCardiacaController.dispose();
    super.dispose();
  }

  Widget _buildSeccionClinica() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clínica Odontopediatría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nombreCasaController,
              decoration: InputDecoration(
                labelText: '¿Cómo llaman al niño en casa?',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _hobbieController,
              decoration: InputDecoration(
                labelText: '¿Cuál es su hobbie?',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _nombrePadreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del padre o de la madre',
                      labelStyle: TextStyle(color: Colors.black),
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
                    controller: _telefonoPadreController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _nombreRepresentanteController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del representante o parentesco',
                      labelStyle: TextStyle(color: Colors.black),
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
                    controller: _telefonoRepresentanteController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.phone,
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

  Widget _buildSeccionAntecedentes() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antecedentes Personales',
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
                    controller: _duracionPartoController,
                    decoration: InputDecoration(
                      labelText: 'Duración del parto',
                      labelStyle: TextStyle(color: Colors.black),
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
                    controller: _edadMadreController,
                    decoration: InputDecoration(
                      labelText: 'Edad de la madre',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nroEmbarazoController,
                    decoration: InputDecoration(
                      labelText: 'Nro de embarazo',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            CheckboxListTile(
              title: Text(
                'Embarazo controlado',
                style: TextStyle(color: Colors.black),
              ),
              value: _embarazoControlado,
              onChanged: (value) {
                setState(() {
                  _embarazoControlado = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _antecedentesEmbarazoController,
              decoration: InputDecoration(
                labelText: 'Antecedentes durante el embarazo',
                labelStyle: TextStyle(color: Colors.black),
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

  Widget _buildSeccionPerinatales() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perinatales y Neonatales',
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
                  child: CheckboxListTile(
                    title: Text(
                      'Parto normal',
                      style: TextStyle(color: Colors.black),
                    ),
                    value: _partoNormal,
                    onChanged: (value) {
                      setState(() {
                        _partoNormal = value ?? false;
                        if (_partoNormal) _cesarea = false; // Solo uno puede estar marcado
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text(
                      'Cesárea',
                      style: TextStyle(color: Colors.black),
                    ),
                    value: _cesarea,
                    onChanged: (value) {
                      setState(() {
                        _cesarea = value ?? false;
                        if (_cesarea) _partoNormal = false; // Solo uno puede estar marcado
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
            
            TextFormField(
              controller: _observacionesController,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                labelStyle: TextStyle(color: Colors.black),
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
              controller: _tratamientoMedicoController,
              decoration: InputDecoration(
                labelText: 'Tratamiento médico actual',
                labelStyle: TextStyle(color: Colors.black),
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

  Widget _buildSeccionDesarrolloPsicomotor() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desarrollo Psicomotor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            // Preguntas de edad
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _edadSentoController,
                    decoration: InputDecoration(
                      labelText: '¿A qué edad se sentó?',
                      hintText: 'Ej: 6 meses',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
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
                    controller: _edadGateoController,
                    decoration: InputDecoration(
                      labelText: '¿A qué edad gateó?',
                      hintText: 'Ej: 8 meses',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
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
                    controller: _edadParoController,
                    decoration: InputDecoration(
                      labelText: '¿A qué edad se paró?',
                      hintText: 'Ej: 10 meses',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
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
                    controller: _edadCaminoController,
                    decoration: InputDecoration(
                      labelText: '¿A qué edad caminó?',
                      hintText: 'Ej: 12 meses',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
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
                    controller: _edadPrimerDienteController,
                    decoration: InputDecoration(
                      labelText: '¿A qué edad erupcionó el primer diente?',
                      hintText: 'Ej: 6-8 meses',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.child_care, color: Colors.blue),
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
                    controller: _edadPrimerPalabraController,
                    decoration: InputDecoration(
                      labelText: '¿A qué edad dijo su primer palabra?',
                      hintText: 'Ej: 12 meses',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.record_voice_over, color: Colors.blue),
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
            
            TextFormField(
              controller: _evolucionEscolarController,
              decoration: InputDecoration(
                labelText: '¿Cómo es su evolución escolar?',
                hintText: 'Describa el rendimiento académico y comportamiento',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.school, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 2,
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _vacunasController,
              decoration: InputDecoration(
                labelText: 'Vacunas',
                hintText: 'Indique las vacunas recibidas',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.medical_services, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 2,
              onChanged: (_) => _actualizarDatos(),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Hábitos (Sí/No con observaciones)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            
            // Hábitos con Checkbox y observaciones
            _buildHabitoCheckbox('Biberón', _biberon, _biberonObsController, (value) {
              setState(() {
                _biberon = value;
                _actualizarDatos();
              });
            }),
            _buildHabitoCheckbox('Chupón', _chupon, _chuponObsController, (value) {
              setState(() {
                _chupon = value;
                _actualizarDatos();
              });
            }),
            _buildHabitoCheckbox('Succión digital', _succionDigital, _succionDigitalObsController, (value) {
              setState(() {
                _succionDigital = value;
                _actualizarDatos();
              });
            }),
            _buildHabitoCheckbox('Enuresis', _enuresis, _enuresisObsController, (value) {
              setState(() {
                _enuresis = value;
                _actualizarDatos();
              });
            }),
            _buildHabitoCheckbox('Onicofagia', _onicofagia, _onicofagiaObsController, (value) {
              setState(() {
                _onicofagia = value;
                _actualizarDatos();
              });
            }),
            _buildHabitoCheckbox('Queilofagia', _queilofagia, _queilofagiaObsController, (value) {
              setState(() {
                _queilofagia = value;
                _actualizarDatos();
              });
            }),
            _buildHabitoCheckbox('Geofagia', _geofagia, _geofagiaObsController, (value) {
              setState(() {
                _geofagia = value;
                _actualizarDatos();
              });
            }),
            _buildHabitoCheckbox('Golosinas', _golosinas, _golosinasObsController, (value) {
              setState(() {
                _golosinas = value;
                _actualizarDatos();
              });
            }),
            _buildHabitoCheckbox('Otros', _otros, _otrosObsController, (value) {
              setState(() {
                _otros = value;
                _actualizarDatos();
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitoCheckbox(String label, bool value, TextEditingController controller, Function(bool) onChanged) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(label, style: TextStyle(color: Colors.black)),
          value: value,
          onChanged: (val) => onChanged(val ?? false),
          activeColor: Colors.blue,
          checkColor: Colors.white,
        ),
        if (value)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => _actualizarDatos(),
            ),
          ),
      ],
    );
  }

  Widget _buildSeccionHigieneBucal() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hábitos de Higiene Bucal',
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
                    controller: _vecesCepilloController,
                    decoration: InputDecoration(
                      labelText: '¿Cuántas veces se cepilla al día?',
                      hintText: '1-3 veces',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.looks_one, color: Colors.blue),
                      suffixText: 'veces/día',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 1 || num > 9) {
                          return 'Ingrese un número válido';
                        }
                      }
                      return null;
                    },
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cuandoCepillaController,
                    decoration: InputDecoration(
                      labelText: '¿Cuándo se cepilla?',
                      hintText: 'Ej: Mañana, noche, después de comer',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.access_time, color: Colors.blue),
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
                  child: CheckboxListTile(
                    title: Text('¿Utiliza enjuague bucal?', style: TextStyle(color: Colors.black)),
                    value: _usaEnjuague,
                    onChanged: (value) {
                      setState(() {
                        _usaEnjuague = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('¿Utiliza hilo dental?', style: TextStyle(color: Colors.black)),
                    value: _usaHiloDental,
                    onChanged: (value) {
                      setState(() {
                        _usaHiloDental = value ?? false;
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
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _higieneController,
                    decoration: InputDecoration(
                      labelText: '¿Realiza higiene bucal solo o asistido?',
                      hintText: 'Solo o Asistido',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
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
                    controller: _pastaCepilloController,
                    decoration: InputDecoration(
                      labelText: '¿Qué pasta dental y cepillo usa?',
                      hintText: 'Marca y tipo',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.brush, color: Colors.blue),
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
            
            CheckboxListTile(
              title: Text('¿Atención odontológica previa?', style: TextStyle(color: Colors.black)),
              value: _atencionPrevia,
              onChanged: (value) {
                setState(() {
                  _atencionPrevia = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            if (_atencionPrevia) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _cuandoDondeController,
                decoration: InputDecoration(
                  labelText: '¿Cuándo y dónde?',
                  hintText: 'Fecha y lugar de atención',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (_) => _actualizarDatos(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experienciaController,
                decoration: InputDecoration(
                  labelText: '¿Fue una experiencia positiva o negativa?',
                  hintText: 'Positiva o Negativa',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.sentiment_satisfied, color: Colors.blue),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (_) => _actualizarDatos(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _porQueController,
                decoration: InputDecoration(
                  labelText: '¿Por qué?',
                  hintText: 'Explique la razón',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.comment, color: Colors.blue),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.black),
                maxLines: 2,
                onChanged: (_) => _actualizarDatos(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionAlimentacion() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alimentación Primer Año',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              title: Text('Lactancia materna', style: TextStyle(color: Colors.black)),
              value: _lactanciaMaterna,
              onChanged: (value) {
                setState(() {
                  _lactanciaMaterna = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            if (_lactanciaMaterna)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: TextFormField(
                  controller: _lactanciaMaternaEdadController,
                  decoration: InputDecoration(
                    labelText: '¿Hasta qué edad?',
                    hintText: 'Ej: 6 meses, 1 año',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.timer, color: Colors.green),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (_) => _actualizarDatos(),
                ),
              ),
            
            CheckboxListTile(
              title: Text('Lactancia artificial', style: TextStyle(color: Colors.black)),
              value: _lactanciaArtificial,
              onChanged: (value) {
                setState(() {
                  _lactanciaArtificial = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            if (_lactanciaArtificial)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: TextFormField(
                  controller: _lactanciaArtificialEdadController,
                  decoration: InputDecoration(
                    labelText: '¿Hasta qué edad?',
                    hintText: 'Ej: 6 meses, 1 año',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.timer, color: Colors.orange),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (_) => _actualizarDatos(),
                ),
              ),
            
            CheckboxListTile(
              title: Text('Lactancia mixta', style: TextStyle(color: Colors.black)),
              value: _lactanciaMixta,
              onChanged: (value) {
                setState(() {
                  _lactanciaMixta = value ?? false;
                  _actualizarDatos();
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
            if (_lactanciaMixta)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: TextFormField(
                  controller: _lactanciaMixtaEdadController,
                  decoration: InputDecoration(
                    labelText: '¿Hasta qué edad?',
                    hintText: 'Ej: 6 meses, 1 año',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.timer, color: Colors.purple),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (_) => _actualizarDatos(),
                ),
              ),
            
            const SizedBox(height: 12),
            TextFormField(
              controller: _alimentacionObsController,
              decoration: InputDecoration(
                labelText: 'Observaciones generales de alimentación',
                hintText: 'Detalles adicionales sobre la alimentación',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionExamenFisico() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Examen Físico',
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
                    controller: _pesoController,
                    decoration: InputDecoration(
                      labelText: 'Peso',
                      hintText: '0.0',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.monitor_weight, color: Colors.blue),
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num <= 0 || num > 200) {
                          return 'Peso inválido (0-200 kg)';
                        }
                      }
                      return null;
                    },
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _tallaController,
                    decoration: InputDecoration(
                      labelText: 'Talla',
                      hintText: '0.0',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.height, color: Colors.blue),
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num <= 0 || num > 250) {
                          return 'Talla inválida (0-250 cm)';
                        }
                      }
                      return null;
                    },
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _temperaturaController,
                    decoration: InputDecoration(
                      labelText: 'Temperatura',
                      hintText: '36.5',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.thermostat, color: Colors.red),
                      suffixText: '°C',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num < 35 || num > 42) {
                          return 'Temperatura inválida (35-42°C)';
                        }
                      }
                      return null;
                    },
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
                    controller: _presionArterialController,
                    decoration: InputDecoration(
                      labelText: 'Presión arterial',
                      hintText: '120/80',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.favorite, color: Colors.red),
                      suffixText: 'mmHg',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    ],
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _frecuenciaRespiratoriaController,
                    decoration: InputDecoration(
                      labelText: 'Frec. respiratoria',
                      hintText: '12-20',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.air, color: Colors.lightBlue),
                      suffixText: 'rpm',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 8 || num > 40) {
                          return 'Rango: 8-40 rpm';
                        }
                      }
                      return null;
                    },
                    onChanged: (_) => _actualizarDatos(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _frecuenciaCardiacaController,
                    decoration: InputDecoration(
                      labelText: 'Frec. cardíaca',
                      hintText: '60-100',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.monitor_heart, color: Colors.pink),
                      suffixText: 'bpm',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 40 || num > 200) {
                          return 'Rango: 40-200 bpm';
                        }
                      }
                      return null;
                    },
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

  Widget _buildSeccionTipoDenticion() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Dentición',
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
                  child: CheckboxListTile(
                    title: Text('Temporal', style: TextStyle(color: Colors.black, fontSize: 16)),
                    value: _temporal,
                    onChanged: (value) {
                      setState(() {
                        _temporal = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Mixta', style: TextStyle(color: Colors.black, fontSize: 16)),
                    value: _mixta,
                    onChanged: (value) {
                      setState(() {
                        _mixta = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Permanente', style: TextStyle(color: Colors.black, fontSize: 16)),
                    value: _permanente,
                    onChanged: (value) {
                      setState(() {
                        _permanente = value ?? false;
                        _actualizarDatos();
                      });
                    },
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionOdontogramaPediatrico() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Odontograma Pediátrico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            // Área placeholder para imagen del odontograma
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.image, size: 48, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    'Imagen del odontograma pediátrico (se agregará después)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Dientes Superiores (55-51 y 61-65)
            Text(
              'Dientes Superiores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                // Lado izquierdo: 55-51
                Expanded(
                  child: Row(
                    children: [
                      _buildDienteField('55'),
                      _buildDienteField('54'),
                      _buildDienteField('53'),
                      _buildDienteField('52'),
                      _buildDienteField('51'),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Línea divisoria
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.black,
                ),
                SizedBox(width: 16),
                // Lado derecho: 61-65
                Expanded(
                  child: Row(
                    children: [
                      _buildDienteField('61'),
                      _buildDienteField('62'),
                      _buildDienteField('63'),
                      _buildDienteField('64'),
                      _buildDienteField('65'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Dientes Inferiores (85-81 y 71-75)
            Text(
              'Dientes Inferiores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                // Lado izquierdo: 85-81
                Expanded(
                  child: Row(
                    children: [
                      _buildDienteField('85'),
                      _buildDienteField('84'),
                      _buildDienteField('83'),
                      _buildDienteField('82'),
                      _buildDienteField('81'),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Línea divisoria
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.black,
                ),
                SizedBox(width: 16),
                // Lado derecho: 71-75
                Expanded(
                  child: Row(
                    children: [
                      _buildDienteField('71'),
                      _buildDienteField('72'),
                      _buildDienteField('73'),
                      _buildDienteField('74'),
                      _buildDienteField('75'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDienteField(String numeroDiente) {
    final controller = _dientesSuperiores[numeroDiente] ?? _dientesInferiores[numeroDiente];
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            Text(
              numeroDiente,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 50,
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '',
                  hintStyle: TextStyle(fontSize: 10),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(4),
                ),
                style: TextStyle(color: Colors.black, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 2,
                onChanged: (_) => _actualizarDatos(),
              ),
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
          _buildSeccionClinica(),
          const SizedBox(height: 16),
          _buildSeccionAntecedentes(),
          const SizedBox(height: 16),
          _buildSeccionPerinatales(),
          const SizedBox(height: 16),
          _buildSeccionDesarrolloPsicomotor(),
          const SizedBox(height: 16),
          _buildSeccionHigieneBucal(),
          const SizedBox(height: 16),
          _buildSeccionAlimentacion(),
          const SizedBox(height: 16),
          _buildSeccionExamenFisico(),
          const SizedBox(height: 16),
          _buildSeccionTipoDenticion(),
          const SizedBox(height: 16),
          _buildSeccionOdontogramaPediatrico(),
        ],
      ),
    );
  }
}
