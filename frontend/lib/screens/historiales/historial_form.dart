import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class HistorialForm extends StatefulWidget {
  final Map<String, dynamic>? historial;
  final Map<String, dynamic>? paciente;
  final bool embedded;
  final bool viewOnly;
  HistorialForm(
      {this.historial,
      this.paciente,
      this.embedded = false,
      this.viewOnly = false});

  @override
  _HistorialFormState createState() => _HistorialFormState();
}

class _HistorialFormState extends State<HistorialForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();
  final TextEditingController pacienteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.historial != null) {
      pacienteCtrl.text = widget.historial!['paciente']?.toString() ?? '';
    } else if (widget.paciente != null) {
      pacienteCtrl.text = widget.paciente!['id']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.historial != null;
    final isView = widget.viewOnly == true;

    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                controller: pacienteCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Paciente ID'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null),
            SizedBox(height: 20),
            if (!isView)
              ElevatedButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final data = {'paciente': pacienteCtrl.text};
                  try {
                    if (isEdit) {
                      await api.updateHistorial(widget.historial!['id'], data);
                    } else {
                      await api.createHistorial(data);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Guardado correctamente')));
                    if (widget.embedded) {
                      context.read<MenuAppController>().setPage('historiales');
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
                    context.read<MenuAppController>().setPage('historiales');
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text('Cerrar'),
              )
          ],
        ),
      ),
    );

    if (widget.embedded)
      return SingleChildScrollView(
          child: Card(margin: EdgeInsets.all(16), child: content));
    return Scaffold(
        appBar: AppBar(
            title: Text(isEdit ? 'Editar Historial' : 'Nuevo Historial')),
        body: content);
  }
}
