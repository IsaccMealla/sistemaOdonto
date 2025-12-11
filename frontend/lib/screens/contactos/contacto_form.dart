import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class ContactoForm extends StatefulWidget {
  final Map<String, dynamic>? contacto;
  final bool embedded;
  final bool viewOnly;
  ContactoForm({this.contacto, this.embedded = false, this.viewOnly = false});

  @override
  _ContactoFormState createState() => _ContactoFormState();
}

class _ContactoFormState extends State<ContactoForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController parentescoCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();

  List<dynamic> _pacientes = [];
  String? _pacienteSeleccionado;
  bool _loadingPacientes = true;

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
    if (widget.contacto != null) {
      nombreCtrl.text = widget.contacto!['nombre'] ?? '';
      parentescoCtrl.text = widget.contacto!['parentesco'] ?? '';
      telefonoCtrl.text = widget.contacto!['telefono'] ?? '';
      _pacienteSeleccionado = widget.contacto!['paciente']?.toString();
    }
  }

  Future<void> _cargarPacientes() async {
    try {
      final pacientes = await api.fetchPacientes();
      setState(() {
        // Ordenar por más reciente (creado_en descendente)
        _pacientes = List.from(pacientes);
        _pacientes.sort((a, b) {
          final aDate = a['creado_en'] ?? '';
          final bDate = b['creado_en'] ?? '';
          return bDate.toString().compareTo(aDate.toString());
        });
        _loadingPacientes = false;
      });
    } catch (e) {
      setState(() {
        _loadingPacientes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar pacientes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contacto != null;
    final isView = widget.viewOnly == true;

    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                controller: nombreCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null),
            TextFormField(
                controller: parentescoCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Parentesco')),
            TextFormField(
                controller: telefonoCtrl,
                readOnly: isView,
                decoration: InputDecoration(labelText: 'Teléfono')),
            SizedBox(height: 16),
            if (!isView && _loadingPacientes)
              Center(child: CircularProgressIndicator())
            else if (!isView)
              DropdownButtonFormField<String>(
                initialValue: _pacienteSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Paciente',
                  hintText: 'Seleccione un paciente (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('-- Sin asignar --'),
                  ),
                  ..._pacientes.map((paciente) {
                    final nombreCompleto =
                        '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}'
                            .trim();
                    final celular = paciente['celular'] ?? '';
                    return DropdownMenuItem<String>(
                      value: paciente['id'].toString(),
                      child: Text(
                        '$nombreCompleto${celular.isNotEmpty ? " - $celular" : ""}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _pacienteSeleccionado = value;
                  });
                },
              )
            else if (isView)
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(labelText: 'Paciente'),
                initialValue: _obtenerNombrePaciente(),
              ),
            SizedBox(height: 20),
            if (!isView)
              ElevatedButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final data = {
                    'nombre': nombreCtrl.text,
                    'parentesco': parentescoCtrl.text,
                    'telefono': telefonoCtrl.text,
                    'paciente': _pacienteSeleccionado,
                  };
                  try {
                    if (widget.contacto != null) {
                      await api.updateContacto(widget.contacto!['id'], data);
                    } else {
                      await api.createContacto(data);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Contacto guardado exitosamente')));
                    if (widget.embedded) {
                      context.read<MenuAppController>().setPage('contactos');
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
                    context.read<MenuAppController>().setPage('contactos');
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
        appBar:
            AppBar(title: Text(isEdit ? 'Editar Contacto' : 'Nuevo Contacto')),
        body: content);
  }

  String _obtenerNombrePaciente() {
    if (_pacienteSeleccionado == null) return 'Sin asignar';
    try {
      final paciente = _pacientes.firstWhere(
        (p) => p['id'].toString() == _pacienteSeleccionado,
        orElse: () => null,
      );
      if (paciente == null) return 'Paciente no encontrado';
      return '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}'
          .trim();
    } catch (e) {
      return 'Sin asignar';
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    parentescoCtrl.dispose();
    telefonoCtrl.dispose();
    super.dispose();
  }
}
