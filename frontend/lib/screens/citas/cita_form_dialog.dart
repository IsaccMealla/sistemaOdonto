import 'package:flutter/material.dart';

class CitaFormDialog extends StatefulWidget {
  final void Function(String pacienteId, DateTime fechaHora, String motivo)
      onSubmit;
  final List<Map<String, dynamic>> pacientes;
  final String? pacienteIdInicial;

  const CitaFormDialog({
    Key? key,
    required this.onSubmit,
    required this.pacientes,
    this.pacienteIdInicial,
  }) : super(key: key);

  @override
  State<CitaFormDialog> createState() => _CitaFormDialogState();
}

class _CitaFormDialogState extends State<CitaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fechaHora;
  String _motivo = '';
  String? _pacienteId;

  @override
  void initState() {
    super.initState();
    _pacienteId = widget.pacienteIdInicial;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agendar/Reprogramar Cita'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector de paciente
              DropdownButtonFormField<String>(
                value: _pacienteId,
                decoration: const InputDecoration(
                  labelText: 'Paciente',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Seleccione un paciente' : null,
                items: widget.pacientes.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['id'],
                    child: Text('${p['nombres']} ${p['apellidos']}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _pacienteId = v),
              ),
              const SizedBox(height: 16),

              // Selector de fecha y hora
              ListTile(
                title: Text(_fechaHora == null
                    ? 'Seleccionar fecha y hora'
                    : '${_fechaHora!.day}/${_fechaHora!.month}/${_fechaHora!.year} ${_fechaHora!.hour}:${_fechaHora!.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                onTap: () async {
                  final now = DateTime.now();
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (fecha != null) {
                    final hora = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (hora != null) {
                      setState(() {
                        _fechaHora = DateTime(
                          fecha.year,
                          fecha.month,
                          fecha.day,
                          hora.hour,
                          hora.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Campo de motivo
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Motivo de la cita',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Limpieza dental, extracción...',
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese un motivo' : null,
                onChanged: (v) => _motivo = v,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _fechaHora != null) {
              widget.onSubmit(_pacienteId!, _fechaHora!, _motivo);
              Navigator.pop(context);
            } else if (_fechaHora == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor seleccione fecha y hora'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
