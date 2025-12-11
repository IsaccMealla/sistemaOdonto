import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class AntecedentePatologicoForm extends StatefulWidget {
  final Map<String, dynamic>? antecedente;
  final Map<String, dynamic>? paciente;
  final bool embedded;
  final bool viewOnly;
  AntecedentePatologicoForm(
      {this.antecedente,
      this.paciente,
      this.embedded = false,
      this.viewOnly = false});

  @override
  _AntecedentePatologicoFormState createState() =>
      _AntecedentePatologicoFormState();
}

class _AntecedentePatologicoFormState extends State<AntecedentePatologicoForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();
  final TextEditingController estadoCtrl = TextEditingController();
  final TextEditingController ultimoExamenCtrl = TextEditingController();
  final TextEditingController observacionesCtrl = TextEditingController();
  String? _pacienteId;
  String? _historialId;

  @override
  void initState() {
    super.initState();
    if (widget.antecedente != null) {
      estadoCtrl.text = widget.antecedente!['estado_salud'] ?? '';
      ultimoExamenCtrl.text =
          widget.antecedente!['ultimo_examen']?.toString() ?? '';
      observacionesCtrl.text = widget.antecedente!['observaciones'] ?? '';
      _historialId = widget.antecedente!['historial']?.toString();
      _pacienteId = widget.antecedente!['paciente']?.toString();
    } else if (widget.paciente != null) {
      _pacienteId = widget.paciente!['id']?.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isView = widget.viewOnly == true;
    return SingleChildScrollView(
        child: Card(
            margin: EdgeInsets.all(16),
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                          controller: estadoCtrl,
                          readOnly: isView,
                          decoration:
                              InputDecoration(labelText: 'Estado Salud')),
                      TextFormField(
                          controller: ultimoExamenCtrl,
                          readOnly: isView,
                          decoration:
                              InputDecoration(labelText: 'Último examen'),
                          onTap: isView
                              ? null
                              : () async {
                                  final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.tryParse(
                                              ultimoExamenCtrl.text) ??
                                          DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now());
                                  if (picked != null)
                                    ultimoExamenCtrl.text = picked
                                        .toIso8601String()
                                        .split('T')
                                        .first;
                                }),
                      TextFormField(
                          controller: observacionesCtrl,
                          readOnly: isView,
                          decoration:
                              InputDecoration(labelText: 'Observaciones')),
                      SizedBox(height: 12),
                      if (!isView)
                        ElevatedButton(
                            onPressed: () async {
                              String? historialId = _historialId;
                              if (historialId == null && _pacienteId != null) {
                                try {
                                  final historiales =
                                      await api.fetchHistoriales();
                                  final found = historiales.firstWhere(
                                      (h) =>
                                          h['paciente']?.toString() ==
                                          _pacienteId,
                                      orElse: () => null);
                                  if (found != null)
                                    historialId = found['id']?.toString();
                                  else {
                                    final created = await api.createHistorial(
                                        {'paciente': _pacienteId});
                                    historialId = created['id']?.toString();
                                  }
                                } catch (e) {}
                              }

                              final data = {
                                'historial': historialId,
                                'estado_salud': estadoCtrl.text.isEmpty
                                    ? null
                                    : estadoCtrl.text,
                                'ultimo_examen': ultimoExamenCtrl.text.isEmpty
                                    ? null
                                    : ultimoExamenCtrl.text,
                                'observaciones': observacionesCtrl.text.isEmpty
                                    ? null
                                    : observacionesCtrl.text,
                              };
                              try {
                                if (widget.antecedente != null)
                                  await api.updateAntecedentePatologico(
                                      widget.antecedente!['id'], data);
                                else
                                  await api.createAntecedentePatologico(data);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Guardado')));
                                if (widget.embedded)
                                  context
                                      .read<MenuAppController>()
                                      .setPage('antecedentes');
                                else
                                  Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')));
                              }
                            },
                            child: Text('Guardar'))
                      else
                        ElevatedButton(
                            onPressed: () {
                              if (widget.embedded)
                                context
                                    .read<MenuAppController>()
                                    .setPage('antecedentes');
                              else
                                Navigator.pop(context);
                            },
                            child: Text('Cerrar'))
                    ])))));
  }
}
