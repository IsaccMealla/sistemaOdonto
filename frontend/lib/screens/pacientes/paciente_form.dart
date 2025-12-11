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

  // Controladores básicos del paciente
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
  }

  bool get isView => widget.viewOnly;

  // Método auxiliar para mostrar selector de fecha
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(Duration(days: 365 * 25)), // 25 años atrás
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        fechaNacimientoCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formContent = Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isView
                  ? 'Ver Paciente'
                  : widget.paciente == null
                      ? 'Nuevo Paciente'
                      : 'Editar Paciente',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            // Información básica del paciente
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nombresCtrl,
                            readOnly: isView,
                            decoration: InputDecoration(labelText: 'Nombres*'),
                            validator: (v) =>
                                v?.isEmpty == true ? 'Campo requerido' : null,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: apellidosCtrl,
                            readOnly: isView,
                            decoration:
                                InputDecoration(labelText: 'Apellidos*'),
                            validator: (v) =>
                                v?.isEmpty == true ? 'Campo requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: celularCtrl,
                            readOnly: isView,
                            decoration: InputDecoration(labelText: 'Celular'),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: edadCtrl,
                            readOnly: isView,
                            decoration: InputDecoration(labelText: 'Edad'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: sexoValue.isEmpty ? null : sexoValue,
                            decoration: InputDecoration(labelText: 'Sexo'),
                            items: ['M', 'F']
                                .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                        s == 'M' ? 'Masculino' : 'Femenino')))
                                .toList(),
                            onChanged: isView
                                ? null
                                : (v) => setState(() => sexoValue = v ?? ''),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: fechaNacimientoCtrl,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Fecha de Nacimiento',
                              hintText: 'Seleccionar fecha de nacimiento',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: isView ? null : _selectBirthDate,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: estadoCivilValue.isEmpty
                                ? null
                                : estadoCivilValue,
                            decoration:
                                InputDecoration(labelText: 'Estado Civil'),
                            items: ['Soltero', 'Casado', 'Divorciado', 'Viudo']
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: isView
                                ? null
                                : (v) =>
                                    setState(() => estadoCivilValue = v ?? ''),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: ocupacionCtrl,
                            readOnly: isView,
                            decoration: InputDecoration(labelText: 'Ocupación'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: direccionCtrl,
                      readOnly: isView,
                      decoration: InputDecoration(labelText: 'Dirección'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ultimaConsultaCtrl,
                            readOnly: isView,
                            decoration: InputDecoration(
                                labelText: 'Última Consulta (YYYY-MM-DD)'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: motivoUltimaConsultaCtrl,
                            readOnly: isView,
                            decoration: InputDecoration(
                                labelText: 'Motivo Última Consulta'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Botones de acción
            if (!isView)
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  try {
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
                      'ocupacion': ocupacionCtrl.text.isEmpty
                          ? null
                          : ocupacionCtrl.text,
                      'direccion': direccionCtrl.text.isEmpty
                          ? null
                          : direccionCtrl.text,
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

                    if (widget.paciente == null) {
                      await api.createPaciente(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Paciente creado exitosamente')),
                      );
                    } else {
                      await api.updatePaciente(widget.paciente!['id'], data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Paciente actualizado exitosamente')),
                      );
                    }

                    if (widget.embedded) {
                      context.read<MenuAppController>().setPage('pacientes');
                    } else {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
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
        child: Card(margin: EdgeInsets.all(16), child: formContent),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isView
            ? 'Ver Paciente'
            : widget.paciente == null
                ? 'Nuevo Paciente'
                : 'Editar Paciente'),
      ),
      body: SingleChildScrollView(child: formContent),
    );
  }
}
