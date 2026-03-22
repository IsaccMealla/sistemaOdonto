import 'package:flutter/material.dart';
import '../historia_clinica/shared/widgets/habitos_widget.dart';
import '../historia_clinica/shared/widgets/antecedentes_periodontal_widget.dart';
import '../historia_clinica/shared/widgets/examen_periodontal_widget.dart';
import 'widgets/periodontograma_widget.dart';

class PeriodonciaMateriaScreen extends StatefulWidget {
  final String? pacienteId;
  final String? historialId;
  final String? estudianteId;
  const PeriodonciaMateriaScreen(
      {Key? key, this.pacienteId, this.historialId, this.estudianteId})
      : super(key: key);

  @override
  State<PeriodonciaMateriaScreen> createState() =>
      _PeriodonciaMateriaScreenState();
}

class _PeriodonciaMateriaScreenState extends State<PeriodonciaMateriaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPacienteId;
  String? _selectedHistorialId;
  Map<String, dynamic>? _pacienteSeleccionado;
  Map<String, dynamic> _habitosData = {};
  Map<String, dynamic> _antecedentesData = {};
  Map<String, dynamic> _examenData = {};
  Map<String, dynamic> _periodontogramaData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedPacienteId = widget.pacienteId;
    _selectedHistorialId = widget.historialId;
    // TODO: cargar datos del paciente si ya está seleccionado
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPacienteSeleccionado(
      String pacienteId, String historialId, Map<String, dynamic> paciente) {
    setState(() {
      _selectedPacienteId = pacienteId;
      _selectedHistorialId = historialId;
      _pacienteSeleccionado = paciente;
      // TODO: cargar datos de todos los formularios para ese paciente
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PERIODONCIA'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hábitos'),
            Tab(text: 'Antecedentes'),
            Tab(text: 'Examen'),
            Tab(text: 'Periodontograma'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSelectorPaciente(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      HabitosWidget(
                        initialData: _habitosData,
                        onDataChanged: (data) {
                          setState(() {
                            _habitosData = data;
                          });
                        },
                      ),
                      AntecedentesPeriodontalWidget(
                        initialData: _antecedentesData,
                        onDataChanged: (data) {
                          setState(() {
                            _antecedentesData = data;
                          });
                        },
                      ),
                      ExamenPeriodontalWidget(
                        initialData: _examenData,
                        onDataChanged: (data) {
                          setState(() {
                            _examenData = data;
                          });
                        },
                      ),
                      PeriodontogramaWidget(
                        titulo: 'PERIODONTOGRAMA PERIODONCIA',
                        readOnly: false,
                        initialData: _periodontogramaData,
                        onDataChanged: (data) {
                          setState(() {
                            _periodontogramaData = data;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSelectorPaciente() {
    // TODO: Implementar selector de paciente reutilizable (puedes usar el de periodoncia_screen.dart)
    // Al seleccionar, llamar _onPacienteSeleccionado
    return Container();
  }
}
