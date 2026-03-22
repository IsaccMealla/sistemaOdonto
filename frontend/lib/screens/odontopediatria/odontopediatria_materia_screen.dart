import 'package:flutter/material.dart';
import '../historia_clinica/shared/widgets/clinica_odontopediatria_widget.dart';

class OdontopediatriaMateriaScreen extends StatelessWidget {
  final String? pacienteId;
  final String? historialId;
  final String? estudianteId;
  const OdontopediatriaMateriaScreen(
      {Key? key, this.pacienteId, this.historialId, this.estudianteId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ODONTOPEDIATRÍA')),
      body: ClinicaOdontopediatriaWidget(),
    );
  }
}
