import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class AntecedenteNoPatologicoForm extends StatefulWidget {
  final Map<String, dynamic>? antecedente;
  final Map<String, dynamic>? paciente;
  final bool embedded;
  final bool viewOnly;
  AntecedenteNoPatologicoForm(
      {this.antecedente,
      this.paciente,
      this.embedded = false,
      this.viewOnly = false});

  @override
  _AntecedenteNoPatologicoFormState createState() =>
      _AntecedenteNoPatologicoFormState();
}

class _AntecedenteNoPatologicoFormState
    extends State<AntecedenteNoPatologicoForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();
  final TextEditingController respiraCtrl = TextEditingController();
  final TextEditingController fumaCtrl = TextEditingController();
  final TextEditingController observacionesCtrl = TextEditingController();
  String? _pacienteId;
  String? _historialId;

  @override
  void initState() {
    super.initState();
    if (widget.antecedente != null) {
      respiraCtrl.text = widget.antecedente!['respira_boca']?.toString() ?? '';
      fumaCtrl.text = widget.antecedente!['fuma']?.toString() ?? '';
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
                          controller: respiraCtrl,
                          readOnly: isView,
                          decoration:
                              InputDecoration(labelText: 'Respira boca (0/1)'),
                          keyboardType: TextInputType.number),
                      TextFormField(
                          controller: fumaCtrl,
                          readOnly: isView,
                          decoration: InputDecoration(labelText: 'Fuma (0/1)'),
                          keyboardType: TextInputType.number),
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
                                'respira_boca':
                                    int.tryParse(respiraCtrl.text) ?? 0,
                                'fuma': int.tryParse(fumaCtrl.text) ?? 0,
                                'observaciones': observacionesCtrl.text.isEmpty
                                    ? null
                                    : observacionesCtrl.text,
                              };
                              try {
                                if (widget.antecedente != null)
                                  await api.updateAntecedenteNoPatologico(
                                      widget.antecedente!['id'], data);
                                else
                                  await api.createAntecedenteNoPatologico(data);
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
