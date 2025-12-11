import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class PacienteForm extends StatefulWidget {
  final Map<String, dynamic>? paciente;
  final bool embedded;
  final bool viewOnly;
  PacienteForm({this.paciente, this.embedded = false, this.viewOnly = false});

  @override
  _PacienteFormState createState() => _PacienteFormState();
}

class _PacienteFormState extends State<PacienteForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();

  final TextEditingController nombresCtrl = TextEditingController();
  final TextEditingController apellidosCtrl = TextEditingController();
  final TextEditingController celularCtrl = TextEditingController();
  final TextEditingController edadCtrl = TextEditingController();
  String sexoValue = '';
  final TextEditingController fechaNacimientoCtrl = TextEditingController();
  String estadoCivilValue = '';
  final TextEditingController ocupacionCtrl = TextEditingController();
  final TextEditingController direccionCtrl = TextEditingController();
  final TextEditingController ultimaConsultaCtrl = TextEditingController();
  final TextEditingController motivoUltimaConsultaCtrl =
      TextEditingController();
  // Antecedentes buffers (for new paciente or additions before save)
  final List<Map<String, dynamic>> _afBuffer = [];
  final List<Map<String, dynamic>> _agBuffer = [];
  final List<Map<String, dynamic>> _anpBuffer = [];
  final List<Map<String, dynamic>> _apBuffer = [];

  // controllers for quick-add antecedente inputs
  final TextEditingController afCondicionCtrl = TextEditingController();
  bool afPresente = false;
  final TextEditingController afObservCtrl = TextEditingController();
  // additional familiares flags + observations (not in DB but sent in payload)
  bool famAlergia = false;
  final TextEditingController famAlergiaObsCtrl = TextEditingController();
  bool famAsma = false;
  final TextEditingController famAsmaObsCtrl = TextEditingController();
  bool famCardio = false;
  final TextEditingController famCardioObsCtrl = TextEditingController();
  bool famOnco = false;
  final TextEditingController famOncoObsCtrl = TextEditingController();
  bool famDiscrasia = false;
  final TextEditingController famDiscrasiaObsCtrl = TextEditingController();
  bool famDiabetes = false;
  final TextEditingController famDiabetesObsCtrl = TextEditingController();
  bool famHipertension = false;
  final TextEditingController famHipertensionObsCtrl = TextEditingController();
  bool famRenales = false;
  final TextEditingController famRenalesObsCtrl = TextEditingController();

  bool agEmbarazada = false;
  final TextEditingController agMesesCtrl = TextEditingController();
  bool agAnticon = false;
  final TextEditingController agObservCtrl = TextEditingController();

  bool anpRespira = false;
  bool anpAlimentosCitricos = false;
  bool anpMuerdeUnas = false;
  bool anpMuerdeObjetos = false;
  bool anpFuma = false;
  bool anpApretamiento = false;
  final TextEditingController anpObservCtrl = TextEditingController();
  final TextEditingController anpCantidadCigarrosCtrl = TextEditingController();

  final TextEditingController apEstadoCtrl = TextEditingController();
  final TextEditingController apUltimoExCtrl = TextEditingController();
  final TextEditingController apObservCtrl = TextEditingController();
  bool apCirugia = false;
  bool apMedicActuales = false;
  bool apTratamientoMed = false;
  final TextEditingController apProblemasSangCtrl = TextEditingController();
  bool apOncologicos = false;
  bool apLeucemia = false;
  bool apProblemasRenales = false;
  bool apHemofilia = false;
  bool apTransfusion = false;
  bool apDefVitK = false;
  bool apDrogas = false;
  bool apProblemasCorazon = false;
  bool apAlerPenic = false;
  bool apAlerAnest = false;
  bool apAlerAspiYodo = false;
  bool apHepatitis = false;
  bool apFiebreReuma = false;
  bool apAsma = false;
  bool apDiabetes = false;
  bool apUlcer = false;
  bool apTensionAlta = false;
  bool apTensionBaja = false;
  bool apEnfVener = false;
  bool apHerpesAftas = false;
  bool apVih = false;

  // existing antecedentes (when editing)
  List<Map<String, dynamic>> _afExisting = [];
  List<Map<String, dynamic>> _agExisting = [];
  List<Map<String, dynamic>> _anpExisting = [];
  List<Map<String, dynamic>> _apExisting = [];

  // Función para recopilar antecedentes automáticamente
  void _recopilarAntecedentesAutomaticamente() {
    // Limpiar buffers existentes de datos automáticos
    _afBuffer.removeWhere((item) => item['auto_added'] == true);
    _agBuffer.removeWhere((item) => item['auto_added'] == true);
    _anpBuffer.removeWhere((item) => item['auto_added'] == true);
    _apBuffer.removeWhere((item) => item['auto_added'] == true);

    // SIEMPRE agregar antecedentes familiares (incluso si todos son "No")
    _afBuffer.add({
      'auto_added': true,
      'alergia': famAlergia ? 1 : 0,
      'asma_bronquial': famAsma ? 1 : 0,
      'cardiologicos': famCardio ? 1 : 0,
      'oncologicos': famOnco ? 1 : 0,
      'discrasias_sanguineas': famDiscrasia ? 1 : 0,
      'diabetes': famDiabetes ? 1 : 0,
      'hipertension_arterial': famHipertension ? 1 : 0,
      'renales': famRenales ? 1 : 0,
      'observaciones': afObservCtrl.text.isNotEmpty
          ? afObservCtrl.text
          : 'Antecedentes familiares evaluados',
    });

    // SIEMPRE agregar antecedentes ginecológicos (incluso si todos son "No")
    _agBuffer.add({
      'auto_added': true,
      'embarazada': agEmbarazada ? 1 : 0,
      'meses_embarazo':
          agMesesCtrl.text.isNotEmpty ? int.tryParse(agMesesCtrl.text) : null,
      'anticonceptivos': agAnticon ? 1 : 0,
      'observaciones': agObservCtrl.text.isNotEmpty
          ? agObservCtrl.text
          : 'Antecedentes ginecologicos evaluados',
    });

    // SIEMPRE agregar antecedentes no patológicos (incluso si todos son "No")
    _anpBuffer.add({
      'auto_added': true,
      'respira_boca': anpRespira ? 1 : 0,
      'alimentos_citricos': anpAlimentosCitricos ? 1 : 0,
      'muerde_unas': anpMuerdeUnas ? 1 : 0,
      'muerde_objetos': anpMuerdeObjetos ? 1 : 0,
      'fuma': anpFuma ? 1 : 0,
      'cantidad_cigarros': anpCantidadCigarrosCtrl.text.isNotEmpty
          ? int.tryParse(anpCantidadCigarrosCtrl.text)
          : null,
      'apretamiento_dentario': anpApretamiento ? 1 : 0,
      'observaciones': anpObservCtrl.text.isNotEmpty
          ? anpObservCtrl.text
          : 'Antecedentes no patologicos evaluados',
    });

    // SIEMPRE agregar antecedentes patológicos (incluso si todos son "No")
    _apBuffer.add({
      'auto_added': true,
      'bajo_tratamiento_medico': apTratamientoMed ? 1 : 0,
      'toma_medicamentos': apMedicActuales ? 1 : 0,
      'intervencion_quirurgica': apCirugia ? 1 : 0,
      'problemas_oncologicos': apOncologicos ? 1 : 0,
      'leucemia': apLeucemia ? 1 : 0,
      'problemas_renales': apProblemasRenales ? 1 : 0,
      'hemofilia': apHemofilia ? 1 : 0,
      'transfusion_sanguinea': apTransfusion ? 1 : 0,
      'deficit_vitamina_k': apDefVitK ? 1 : 0,
      'consume_drogas': apDrogas ? 1 : 0,
      'problemas_corazon': apProblemasCorazon ? 1 : 0,
      'alergia_penicilina': apAlerPenic ? 1 : 0,
      'alergia_anestesia': apAlerAnest ? 1 : 0,
      'alergia_aspirina': apAlerAspiYodo ? 1 : 0,
      'alergia_yodo': false, // Agregar campo faltante
      'fiebre_reumatica': apFiebreReuma ? 1 : 0,
      'asma': apAsma ? 1 : 0,
      'diabetes': apDiabetes ? 1 : 0,
      'ulcera_gastrica': apUlcer ? 1 : 0,
      'enfermedades_venereas': apEnfVener ? 1 : 0,
      'herpes_aftas_recurrentes': apHerpesAftas ? 1 : 0,
      'vih_positivo': apVih ? 1 : 0,
      'sangra_excesivamente': false, // Campo requerido del modelo
      'problema_sanguineo': false, // Campo requerido del modelo
      'anemia': false, // Campo requerido del modelo
      'estado_salud':
          apEstadoCtrl.text.isNotEmpty ? apEstadoCtrl.text : 'buena',
      'fecha_ultimo_examen':
          apUltimoExCtrl.text.isNotEmpty ? apUltimoExCtrl.text : null,
      'tension_arterial': _obtenerTensionArterial(),
      'observaciones': apObservCtrl.text.isNotEmpty
          ? apObservCtrl.text
          : 'Antecedentes patologicos evaluados',
    });
  }

  // Función helper para obtener tensión arterial
  String? _obtenerTensionArterial() {
    if (apTensionAlta) return 'alta';
    if (apTensionBaja) return 'baja';
    return 'normal';
  }

  @override
  void initState() {
    super.initState();
    if (widget.paciente != null) {
      nombresCtrl.text = widget.paciente!['nombres'] ?? '';
      apellidosCtrl.text = widget.paciente!['apellidos'] ?? '';
      celularCtrl.text = widget.paciente!['celular'] ?? '';
      edadCtrl.text = widget.paciente!['edad']?.toString() ?? '';
      sexoValue = widget.paciente!['sexo'] ?? '';
      fechaNacimientoCtrl.text = widget.paciente!['fecha_nacimiento'] ?? '';
      estadoCivilValue = widget.paciente!['estado_civil'] ?? '';
      ocupacionCtrl.text = widget.paciente!['ocupacion'] ?? '';
      direccionCtrl.text = widget.paciente!['direccion'] ?? '';
      ultimaConsultaCtrl.text = widget.paciente!['ultima_consulta'] ?? '';
      motivoUltimaConsultaCtrl.text =
          widget.paciente!['motivo_ultima_consulta'] ?? '';
    }
    // if editing, load existing antecedentes for this paciente
    if (widget.paciente != null) {
      _loadAntecedentes();
    }
  }

  void _loadAntecedentes() async {
    try {
      final id = widget.paciente!['id']?.toString();
      if (id == null) return;
      // find historiales for this paciente, then filter antecedentes by historial id
      final historiales = await api.fetchHistoriales();
      final myHistIds = historiales
          .where((h) => h['paciente']?.toString() == id)
          .map((h) => h['id']?.toString())
          .where((x) => x != null)
          .map((x) => x!)
          .toSet();
      // Usar la nueva API consolidada
      final antecedentesConsolidados =
          await api.fetchAntecedentesConsolidados();

      // Filtrar antecedentes para este paciente usando la nueva estructura
      final antecedentesDelPaciente = antecedentesConsolidados
          .where((ant) =>
              ant['historial'] != null &&
              myHistIds.contains(ant['historial'].toString()))
          .toList();

      setState(() {
        _afExisting = antecedentesDelPaciente
            .where((ant) => ant['tipo'] == 'familiar')
            .map((ant) {
              final detalles = ant['detalles'] as Map<String, dynamic>? ?? {};
              return {
                'id': ant['id'],
                'alergia': detalles['alergia'] ?? false,
                'diabetes': detalles['diabetes'] ?? false,
                'hipertension_arterial':
                    detalles['hipertension_arterial'] ?? false,
                'asma_bronquial': detalles['asma_bronquial'] ?? false,
                'cardiologicos': detalles['cardiologicos'] ?? false,
                'oncologicos': detalles['oncologicos'] ?? false,
                'discrasias_sanguineas':
                    detalles['discrasias_sanguineas'] ?? false,
                'renales': detalles['renales'] ?? false,
                'observaciones': ant['observaciones'] ?? '',
                'historial': ant['historial'],
              };
            })
            .cast<Map<String, dynamic>>()
            .toList();

        _agExisting = antecedentesDelPaciente
            .where((ant) => ant['tipo'] == 'ginecologico')
            .map((ant) {
              final detalles = ant['detalles'] as Map<String, dynamic>? ?? {};
              return {
                'id': ant['id'],
                'embarazada': detalles['embarazada'] ?? false,
                'meses_embarazo': detalles['meses_embarazo'],
                'anticonceptivos': detalles['anticonceptivos'] ?? false,
                'observaciones': ant['observaciones'] ?? '',
                'historial': ant['historial'],
              };
            })
            .cast<Map<String, dynamic>>()
            .toList();

        _anpExisting = antecedentesDelPaciente
            .where((ant) => ant['tipo'] == 'no_patologico')
            .map((ant) {
              final detalles = ant['detalles'] as Map<String, dynamic>? ?? {};
              return {
                'id': ant['id'],
                'respira_boca': detalles['respira_boca'] ?? false,
                'alimentos_citricos': detalles['alimentos_citricos'] ?? false,
                'muerde_unas': detalles['muerde_unas'] ?? false,
                'muerde_objetos': detalles['muerde_objetos'] ?? false,
                'fuma': detalles['fuma'] ?? false,
                'cantidad_cigarros': detalles['cantidad_cigarros'],
                'apretamiento_dentario':
                    detalles['apretamiento_dentario'] ?? false,
                'observaciones': ant['observaciones'] ?? '',
                'historial': ant['historial'],
              };
            })
            .cast<Map<String, dynamic>>()
            .toList();

        _apExisting = antecedentesDelPaciente
            .where((ant) => ant['tipo'] == 'patologico')
            .map((ant) {
              final detalles = ant['detalles'] as Map<String, dynamic>? ?? {};
              return {
                'id': ant['id'],
                'estado_salud': detalles['estado_salud'],
                'fecha_ultimo_examen': detalles['fecha_ultimo_examen'],
                'bajo_tratamiento_medico':
                    detalles['bajo_tratamiento_medico'] ?? false,
                'toma_medicamentos': detalles['toma_medicamentos'] ?? false,
                'intervencion_quirurgica':
                    detalles['intervencion_quirurgica'] ?? false,
                'sangra_excesivamente':
                    detalles['sangra_excesivamente'] ?? false,
                'problema_sanguineo': detalles['problema_sanguineo'] ?? false,
                'anemia': detalles['anemia'] ?? false,
                'tension_arterial': detalles['tension_arterial'],
                'observaciones': ant['observaciones'] ?? '',
                'historial': ant['historial'],
              };
            })
            .cast<Map<String, dynamic>>()
            .toList();
      });
    } catch (e) {
      // ignore silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.paciente != null;
    final isView = widget.viewOnly == true;

    final formContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nombresCtrl,
              decoration: InputDecoration(labelText: 'Nombres'),
              readOnly: isView,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            TextFormField(
                controller: apellidosCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Apellidos')),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: edadCtrl,
                    readOnly: isView,
                    decoration: InputDecoration(labelText: 'Edad'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: sexoValue.isEmpty ? null : sexoValue,
                    decoration: InputDecoration(labelText: 'Sexo'),
                    items: ['M', 'F', 'Otro']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: isView
                        ? null
                        : (v) => setState(() => sexoValue = v ?? ''),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: fechaNacimientoCtrl,
              decoration: InputDecoration(labelText: 'Fecha de Nacimiento'),
              readOnly: true,
              onTap: isView
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.tryParse(fechaNacimientoCtrl.text) ??
                                DateTime(1990),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null)
                        fechaNacimientoCtrl.text =
                            picked.toIso8601String().split('T').first;
                    },
            ),
            TextFormField(
                controller: ocupacionCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Ocupacion')),
            TextFormField(
                controller: direccionCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Direccion')),
            TextFormField(
                controller: celularCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Celular')),
            TextFormField(
              controller: ultimaConsultaCtrl,
              decoration: InputDecoration(labelText: 'Ultima Consulta'),
              readOnly: true,
              onTap: isView
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.tryParse(ultimaConsultaCtrl.text) ??
                                DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null)
                        ultimaConsultaCtrl.text =
                            picked.toIso8601String().split('T').first;
                    },
            ),
            TextFormField(
                controller: motivoUltimaConsultaCtrl,
                readOnly: isView,
                decoration:
                    InputDecoration(labelText: 'Motivo Ultima Consulta')),
            DropdownButtonFormField<String>(
              initialValue: estadoCivilValue.isEmpty ? null : estadoCivilValue,
              decoration: InputDecoration(labelText: 'Estado civil'),
              items: ['Soltero', 'Casado', 'Divorciado', 'Viudo', 'Otro']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: isView
                  ? null
                  : (v) => setState(() => estadoCivilValue = v ?? ''),
            ),
            SizedBox(height: 20),
            // --- Antecedentes sections (shown inline) ---
            Divider(),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Antecedentes',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            // Familiares
            ExpansionTile(
              title: Text('Familiares'),
              children: [
                if (isEdit) ...[
                  ..._afExisting.map((a) => ListTile(
                        title: Text(a['condicion']?.toString() ?? ''),
                        subtitle: Text(a['observaciones']?.toString() ?? ''),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () => context
                                      .read<MenuAppController>()
                                      .setPageWithArgs(
                                          'antecedente_familiar_form', {
                                    'antecedente': a,
                                    'paciente': widget.paciente
                                  })),
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => context
                                      .read<MenuAppController>()
                                      .setPageWithArgs(
                                          'antecedente_familiar_form', {
                                    'antecedente': a,
                                    'paciente': widget.paciente
                                  })),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                try {
                                  await api.deleteAntecedenteFamiliar(
                                      a['id'].toString());
                                  _loadAntecedentes();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              }),
                        ]),
                      ))
                ] else ...[
                  // quick-add inputs for new paciente (with checkboxes for yes/no)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(children: [
                        TextFormField(
                            controller: afCondicionCtrl,
                            decoration: InputDecoration(
                                labelText: 'Condicion familiar')),
                        Row(
                          children: [
                            Checkbox(
                                value: afPresente,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => afPresente = v ?? false);
                                }),
                            SizedBox(width: 8),
                            Text('Presente'),
                            SizedBox(width: 12),
                            Expanded(
                                child: TextFormField(
                                    controller: afObservCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Observaciones'))),
                          ],
                        ),
                        // Additional family flags + observations
                        Divider(),
                        // each flag with a small observation field
                        Row(
                          children: [
                            Checkbox(
                                value: famAlergia,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => famAlergia = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Alergia'),
                            SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: famAlergiaObsCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Obs Alergia')))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: famAsma,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => famAsma = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Asma bronquial'),
                            SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: famAsmaObsCtrl,
                                    decoration:
                                        InputDecoration(labelText: 'Obs Asma')))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: famCardio,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => famCardio = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Cardiologicos'),
                            SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: famCardioObsCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Obs Cardio')))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: famOnco,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => famOnco = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Oncologicos'),
                            SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: famOncoObsCtrl,
                                    decoration:
                                        InputDecoration(labelText: 'Obs Onco')))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: famDiscrasia,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => famDiscrasia = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Discrasias sanguineas'),
                            SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: famDiscrasiaObsCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Obs Discrasia')))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: famDiabetes,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => famDiabetes = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Diabetes'),
                            SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: famDiabetesObsCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Obs Diabetes')))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: famHipertension,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(
                                        () => famHipertension = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Hipertension arterial'),
                            SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: famHipertensionObsCtrl,
                                    decoration:
                                        InputDecoration(labelText: 'Obs HTA')))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: famRenales,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => famRenales = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Renales'),
                            SizedBox(width: 8),
                            Expanded(
                                child: TextFormField(
                                    controller: famRenalesObsCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Obs Renales')))
                          ],
                        ),
                        // Los antecedentes se guardaran automaticamente al guardar el paciente
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Los antecedentes familiares se guardaran automaticamente al guardar el paciente',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        ..._afBuffer.map((b) => ListTile(
                            title: Text(b['condicion']?.toString() ?? ''),
                            subtitle:
                                Text(b['observaciones']?.toString() ?? ''),
                            trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    setState(() => _afBuffer.remove(b)))))
                      ]))
                ]
              ],
            ),
            // Ginecologicos
            ExpansionTile(
              title: Text('Ginecologicos'),
              children: [
                if (isEdit) ...[
                  ..._agExisting.map((a) => ListTile(
                        title: Text(
                            'Embarazada: ${a['embarazada']?.toString() ?? ''}'),
                        subtitle: Text(a['observaciones']?.toString() ?? ''),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () => context
                                      .read<MenuAppController>()
                                      .setPageWithArgs(
                                          'antecedente_ginecologico_form', {
                                    'antecedente': a,
                                    'paciente': widget.paciente
                                  })),
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => context
                                      .read<MenuAppController>()
                                      .setPageWithArgs(
                                          'antecedente_ginecologico_form', {
                                    'antecedente': a,
                                    'paciente': widget.paciente
                                  })),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                try {
                                  await api.deleteAntecedenteGinecologico(
                                      a['id'].toString());
                                  _loadAntecedentes();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              }),
                        ]),
                      ))
                ] else ...[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(children: [
                        Row(
                          children: [
                            Checkbox(
                                value: agEmbarazada,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => agEmbarazada = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Embarazada'),
                            SizedBox(width: 12),
                            Expanded(
                                child: TextFormField(
                                    controller: agMesesCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Meses embarazo'),
                                    keyboardType: TextInputType.number))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: agAnticon,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => agAnticon = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Anticonceptivos'),
                            SizedBox(width: 12),
                            Expanded(
                                child: TextFormField(
                                    controller: agObservCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Observaciones')))
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Los antecedentes ginecológicos se guardaran automaticamente al guardar el paciente',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        ..._agBuffer.map((b) => ListTile(
                            title: Text('Embarazada: ${b['embarazada']}'),
                            subtitle:
                                Text(b['observaciones']?.toString() ?? ''),
                            trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    setState(() => _agBuffer.remove(b)))))
                      ]))
                ]
              ],
            ),
            // No Patologicos
            ExpansionTile(
              title: Text('No Patologicos'),
              children: [
                if (isEdit) ...[
                  ..._anpExisting.map((a) => ListTile(
                        title: Text('Fuma: ${a['fuma']?.toString() ?? ''}'),
                        subtitle: Text(a['observaciones']?.toString() ?? ''),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () => context
                                      .read<MenuAppController>()
                                      .setPageWithArgs(
                                          'antecedente_no_patologico_form', {
                                    'antecedente': a,
                                    'paciente': widget.paciente
                                  })),
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => context
                                      .read<MenuAppController>()
                                      .setPageWithArgs(
                                          'antecedente_no_patologico_form', {
                                    'antecedente': a,
                                    'paciente': widget.paciente
                                  })),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                try {
                                  await api.deleteAntecedenteNoPatologico(
                                      a['id'].toString());
                                  _loadAntecedentes();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              }),
                        ]),
                      ))
                ] else ...[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(children: [
                        Row(
                          children: [
                            Checkbox(
                                value: anpRespira,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => anpRespira = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Respira boca'),
                            SizedBox(width: 12),
                            Checkbox(
                                value: anpAlimentosCitricos,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() =>
                                        anpAlimentosCitricos = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Alimentos citricos')
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: anpMuerdeUnas,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => anpMuerdeUnas = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Muerde unas'),
                            SizedBox(width: 12),
                            Checkbox(
                                value: anpMuerdeObjetos,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(
                                        () => anpMuerdeObjetos = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Muerde objetos')
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: anpFuma,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => anpFuma = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Fuma'),
                            SizedBox(width: 12),
                            Expanded(
                                child: TextFormField(
                                    controller: anpCantidadCigarrosCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Cantidad cigarros (num)'),
                                    keyboardType: TextInputType.number))
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: anpApretamiento,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(
                                        () => anpApretamiento = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Apretamiento dentario')
                          ],
                        ),
                        TextFormField(
                            controller: anpObservCtrl,
                            decoration:
                                InputDecoration(labelText: 'Observaciones')),
                        Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                                onPressed: null, // Deshabilitado
                                child: Text('Se guardara automaticamente'))),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Todos los antecedentes no patologicos se guardaran al presionar "Guardar"',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        ..._anpBuffer.map((b) => ListTile(
                            title: Text(
                                'Fuma: ${b['fuma']} — Respira: ${b['respira_boca']}'),
                            subtitle:
                                Text(b['observaciones']?.toString() ?? ''),
                            trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    setState(() => _anpBuffer.remove(b)))))
                      ]))
                ]
              ],
            ),
            // Patologicos
            ExpansionTile(
              title: Text('Patologicos Personales'),
              children: [
                if (isEdit) ...[
                  ..._apExisting.map((a) => ListTile(
                        title: Text(a['estado_salud']?.toString() ?? ''),
                        subtitle: Text(a['observaciones']?.toString() ?? ''),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () => context
                                      .read<MenuAppController>()
                                      .setPageWithArgs(
                                          'antecedente_patologico_form', {
                                    'antecedente': a,
                                    'paciente': widget.paciente
                                  })),
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => context
                                      .read<MenuAppController>()
                                      .setPageWithArgs(
                                          'antecedente_patologico_form', {
                                    'antecedente': a,
                                    'paciente': widget.paciente
                                  })),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                try {
                                  await api.deleteAntecedentePatologico(
                                      a['id'].toString());
                                  _loadAntecedentes();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              }),
                        ]),
                      ))
                ] else ...[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(children: [
                        Row(
                          children: [
                            Checkbox(
                                value: apCirugia,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(() => apCirugia = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Cirugia'),
                            SizedBox(width: 12),
                            Checkbox(
                                value: apMedicActuales,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(
                                        () => apMedicActuales = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Medicamentos actuales')
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: apTratamientoMed,
                                onChanged: (v) {
                                  if (!isView)
                                    setState(
                                        () => apTratamientoMed = v ?? false);
                                }),
                            SizedBox(width: 6),
                            Text('Tratamiento medico'),
                            SizedBox(width: 12),
                            Expanded(
                                child: TextFormField(
                                    controller: apEstadoCtrl,
                                    decoration: InputDecoration(
                                        labelText: 'Estado salud')))
                          ],
                        ),
                        TextFormField(
                            controller: apUltimoExCtrl,
                            decoration:
                                InputDecoration(labelText: 'Ultimo examen'),
                            readOnly: false,
                            onTap: () async {
                              final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now());
                              if (picked != null)
                                apUltimoExCtrl.text =
                                    picked.toIso8601String().split('T').first;
                            }),
                        TextFormField(
                            controller: apProblemasSangCtrl,
                            decoration: InputDecoration(
                                labelText: 'Problemas sanguineos (texto)')),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apOncologicos,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(
                                          () => apOncologicos = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Oncologicos')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apLeucemia,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apLeucemia = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Leucemia')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apProblemasRenales,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() =>
                                          apProblemasRenales = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Problemas renales')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apHemofilia,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apHemofilia = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Hemofilia')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apTransfusion,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(
                                          () => apTransfusion = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Transfusion')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apDefVitK,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apDefVitK = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Deficit Vit K')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apDrogas,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apDrogas = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Drogas')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apProblemasCorazon,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() =>
                                          apProblemasCorazon = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Problemas corazon')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apAlerPenic,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apAlerPenic = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Alergia penicilina')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apAlerAnest,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apAlerAnest = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Alergia anestesia')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apAlerAspiYodo,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(
                                          () => apAlerAspiYodo = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Alergia aspirina/yodo')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apHepatitis,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apHepatitis = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Hepatitis')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apFiebreReuma,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(
                                          () => apFiebreReuma = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Fiebre reumática')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apAsma,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apAsma = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Asma')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apDiabetes,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apDiabetes = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Diabetes')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apUlcer,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apUlcer = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Úlcera gástrica')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apTensionAlta,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(
                                          () => apTensionAlta = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Tensión alta')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apTensionBaja,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(
                                          () => apTensionBaja = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Tensión baja')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apEnfVener,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apEnfVener = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Enf. venéreas')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apHerpesAftas,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(
                                          () => apHerpesAftas = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('Herpes / aftas')
                            ]),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  value: apVih,
                                  onChanged: (v) {
                                    if (!isView)
                                      setState(() => apVih = v ?? false);
                                  }),
                              SizedBox(width: 6),
                              Text('VIH')
                            ]),
                          ],
                        ),
                        TextFormField(
                            controller: apObservCtrl,
                            decoration:
                                InputDecoration(labelText: 'Observaciones')),
                        Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                                onPressed:
                                    null, // Deshabilitado - se guarda automaticamente
                                child: Text('Se guardara automaticamente'))),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Todos los antecedentes patologicos se guardaran al presionar "Guardar"',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        ..._apBuffer.map((b) => ListTile(
                            title: Text(b['estado_salud']?.toString() ?? ''),
                            subtitle:
                                Text(b['observaciones']?.toString() ?? ''),
                            trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    setState(() => _apBuffer.remove(b)))))
                      ]))
                ]
              ],
            ),
            if (!isView)
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    'nombres': nombresCtrl.text,
                    'apellidos': apellidosCtrl.text,
                    'edad': int.tryParse(edadCtrl.text) ?? null,
                    'sexo': sexoValue.isEmpty ? null : sexoValue,
                    'fecha_nacimiento': fechaNacimientoCtrl.text.isEmpty
                        ? null
                        : fechaNacimientoCtrl.text,
                    'estado_civil':
                        estadoCivilValue.isEmpty ? null : estadoCivilValue,
                    'ocupacion':
                        ocupacionCtrl.text.isEmpty ? null : ocupacionCtrl.text,
                    'direccion':
                        direccionCtrl.text.isEmpty ? null : direccionCtrl.text,
                    'celular':
                        celularCtrl.text.isEmpty ? null : celularCtrl.text,
                    'ultima_consulta': ultimaConsultaCtrl.text.isEmpty
                        ? null
                        : ultimaConsultaCtrl.text,
                    'motivo_ultima_consulta':
                        motivoUltimaConsultaCtrl.text.isEmpty
                            ? null
                            : motivoUltimaConsultaCtrl.text,
                  };
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  try {
                    // Recopilar antecedentes automáticamente antes de guardar
                    _recopilarAntecedentesAutomaticamente();

                    Map<String, dynamic> created;
                    if (isEdit) {
                      created = await api.updatePaciente(
                          widget.paciente!['id'], data);
                    } else {
                      created = await api.createPaciente(data);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Guardado correctamente')));
                    final pacienteId = created['id']?.toString();
                    if (pacienteId != null) {
                      // Get the historial that was automatically created
                      String? historialId;
                      try {
                        // Wait a bit for the historial to be created
                        await Future.delayed(Duration(milliseconds: 500));
                        final historiales = await api.fetchHistoriales();
                        final found = historiales.firstWhere(
                            (h) => h['paciente']?.toString() == pacienteId,
                            orElse: () => null);
                        if (found != null) {
                          historialId = found['id']?.toString();
                        }
                      } catch (e) {
                        print('Error finding historial: $e');
                        historialId = null;
                      }

                      if (historialId != null) {
                        // Crear antecedentes usando la nueva API consolidada
                        for (final b in _afBuffer) {
                          final payload = {
                            'historial': historialId,
                            'tipo': 'familiar',
                            'observaciones': b['observaciones'] ?? '',
                            'detalles_familiares': {
                              'alergia': (b['alergia'] ?? 0) == 1,
                              'asma_bronquial': (b['asma_bronquial'] ?? 0) == 1,
                              'cardiologicos': (b['cardiologicos'] ?? 0) == 1,
                              'oncologicos': (b['oncologicos'] ?? 0) == 1,
                              'discrasias_sanguineas':
                                  (b['discrasias_sanguineas'] ?? 0) == 1,
                              'diabetes': (b['diabetes'] ?? 0) == 1,
                              'hipertension_arterial':
                                  (b['hipertension_arterial'] ?? 0) == 1,
                              'renales': (b['renales'] ?? 0) == 1,
                            }
                          };
                          try {
                            await api.createAntecedenteConsolidado(payload);
                          } catch (e) {
                            print('Error creating antecedente familiar: $e');
                          }
                        }
                        for (final b in _agBuffer) {
                          final payload = {
                            'historial': historialId,
                            'tipo': 'ginecologico',
                            'observaciones': b['observaciones'] ?? '',
                            'detalles_ginecologicos': {
                              'embarazada': (b['embarazada'] ?? 0) == 1,
                              'meses_embarazo': b['meses_embarazo'],
                              'anticonceptivos':
                                  (b['anticonceptivos'] ?? 0) == 1,
                            }
                          };
                          try {
                            await api.createAntecedenteConsolidado(payload);
                          } catch (e) {
                            print(
                                'Error creating antecedente ginecológico: $e');
                          }
                        }
                        for (final b in _anpBuffer) {
                          final payload = {
                            'historial': historialId,
                            'tipo': 'no_patologico',
                            'observaciones': b['observaciones'] ?? '',
                            'detalles_no_patologicos': {
                              'respira_boca': (b['respira_boca'] ?? 0) == 1,
                              'alimentos_citricos':
                                  (b['alimentos_citricos'] ?? 0) == 1,
                              'muerde_unas': (b['muerde_unas'] ?? 0) == 1,
                              'muerde_objetos': (b['muerde_objetos'] ?? 0) == 1,
                              'fuma': (b['fuma'] ?? 0) == 1,
                              'cantidad_cigarros': b['cantidad_cigarros'],
                              'apretamiento_dentario':
                                  (b['apretamiento_dentario'] ?? 0) == 1,
                            }
                          };
                          try {
                            await api.createAntecedenteConsolidado(payload);
                          } catch (e) {
                            print(
                                'Error creating antecedente no patológico: $e');
                          }
                        }
                        for (final b in _apBuffer) {
                          final payload = {
                            'historial': historialId,
                            'tipo': 'patologico',
                            'observaciones': b['observaciones'] ?? '',
                            'detalles_patologicos': {
                              'estado_salud': b['estado_salud'],
                              'fecha_ultimo_examen': b['fecha_ultimo_examen'],
                              'bajo_tratamiento_medico':
                                  (b['bajo_tratamiento_medico'] ?? 0) == 1,
                              'toma_medicamentos':
                                  (b['toma_medicamentos'] ?? 0) == 1,
                              'intervencion_quirurgica':
                                  (b['intervencion_quirurgica'] ?? 0) == 1,
                              'sangra_excesivamente':
                                  (b['sangra_excesivamente'] ?? 0) == 1,
                              'problema_sanguineo':
                                  (b['problema_sanguineo'] ?? 0) == 1,
                              'anemia': (b['anemia'] ?? 0) == 1,
                              'tension_arterial': b['tension_arterial'],
                            }
                          };
                          try {
                            await api.createAntecedenteConsolidado(payload);
                          } catch (e) {
                            print('Error creating antecedente patológico: $e');
                          }
                        }
                      }
                    }
                    // after save, if embedded go back to pacientes list, else pop
                    if (widget.embedded) {
                      context.read<MenuAppController>().setPage('pacientes');
                    } else {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: Text('Guardar'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  if (widget.embedded) {
                    context.read<MenuAppController>().setPage('pacientes');
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text('Cerrar'),
              ),
          ],
        ),
      ),
    );

    if (widget.embedded) {
      return SingleChildScrollView(
          child: Card(margin: EdgeInsets.all(16), child: formContent));
    }

    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? 'Editar Paciente' : 'Nuevo Paciente')),
      body: formContent,
    );
  }
}
