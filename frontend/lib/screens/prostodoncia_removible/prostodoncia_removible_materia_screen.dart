import 'package:flutter/material.dart';
import '../historia_clinica/shared/widgets/clinica_prostodoncia_removible_widget.dart';

class ProstodonciaRemovibleMateriaScreen extends StatelessWidget {
  final String? pacienteId;
  final String? historialId;
  final String? estudianteId;
  const ProstodonciaRemovibleMateriaScreen(
      {Key? key, this.pacienteId, this.historialId, this.estudianteId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROSTODONCIA REMOVIBLE')),
      body: ClinicaProstodonciaRemovibleWidget(),
    );
  }
}
