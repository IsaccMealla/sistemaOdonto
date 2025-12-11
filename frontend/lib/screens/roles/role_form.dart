import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class RoleForm extends StatefulWidget {
  final Map<String, dynamic>? role;
  final bool embedded;
  final bool viewOnly;
  RoleForm({this.role, this.embedded = false, this.viewOnly = false});

  @override
  _RoleFormState createState() => _RoleFormState();
}

class _RoleFormState extends State<RoleForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();
  final TextEditingController nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      nameCtrl.text = widget.role!['name'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.role != null;
    final isView = widget.viewOnly == true;
    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                controller: nameCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null),
            SizedBox(height: 20),
            if (!isView)
              ElevatedButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final data = {'name': nameCtrl.text};
                  try {
                    if (isEdit) {
                      await api.updateRole(widget.role!['id'], data);
                    } else {
                      await api.createRole(data);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Guardado correctamente')));
                    if (widget.embedded) {
                      context.read<MenuAppController>().setPage('roles');
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
                    context.read<MenuAppController>().setPage('roles');
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
        appBar: AppBar(title: Text(isEdit ? 'Editar Rol' : 'Nuevo Rol')),
        body: content);
  }
}
