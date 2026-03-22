import 'package:flutter/material.dart';

class CitaAprobacionDialog extends StatefulWidget {
  final void Function(bool aprobar, String? observaciones) onSubmit;
  const CitaAprobacionDialog({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  State<CitaAprobacionDialog> createState() => _CitaAprobacionDialogState();
}

class _CitaAprobacionDialogState extends State<CitaAprobacionDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _observaciones;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aprobar o Rechazar Cita'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration:
              const InputDecoration(labelText: 'Observaciones (opcional)'),
          onChanged: (v) => _observaciones = v,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(false, _observaciones);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Rechazar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(true, _observaciones);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Aprobar'),
        ),
      ],
    );
  }
}
