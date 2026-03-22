import 'package:flutter/material.dart';
import '../historia_clinica/shared/widgets/examen_dental_widget.dart';
import '../historia_clinica/shared/widgets/diagnostico_radiografico_widget.dart';

class OperatoriaEndodonciaMateriaScreen extends StatefulWidget {
  final String? pacienteId;
  final String? historialId;
  final String? estudianteId;
  const OperatoriaEndodonciaMateriaScreen(
      {Key? key, this.pacienteId, this.historialId, this.estudianteId})
      : super(key: key);

  @override
  State<OperatoriaEndodonciaMateriaScreen> createState() =>
      _OperatoriaEndodonciaMateriaScreenState();
}

class _OperatoriaEndodonciaMateriaScreenState
    extends State<OperatoriaEndodonciaMateriaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OPERATORIA Y ENDODONCIA'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Examen Dental'),
            Tab(text: 'Diagnóstico Radiográfico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ExamenDentalWidget(
            data: const {}, // TODO: Replace empty map with actual data
            onDataChanged: (newData) {
              // TODO: Handle data change
            },
          ),
          DiagnosticoRadiograficoWidget(
            initialData: const {}, // TODO: Replace with actual initial data
            onDataChanged: (newData) {
              // TODO: Handle data change
            },
          ),
        ],
      ),
    );
  }
}
