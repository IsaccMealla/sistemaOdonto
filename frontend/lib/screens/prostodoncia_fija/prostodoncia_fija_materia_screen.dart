import 'package:flutter/material.dart';
import '../historia_clinica/shared/widgets/clinica_prostodoncia_fija_widget.dart';

class ProstodonciaFijaMateriaScreen extends StatelessWidget {
  final String? pacienteId;
  final String? historialId;
  final String? estudianteId;
  const ProstodonciaFijaMateriaScreen(
      {Key? key, this.pacienteId, this.historialId, this.estudianteId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROSTODONCIA FIJA')),
      body: ClinicaProstodonciaFijaWidget(),
    );
  }
}
