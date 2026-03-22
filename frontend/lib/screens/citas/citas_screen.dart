import 'package:flutter/material.dart';
import 'citas_estudiante_tab.dart';
import 'citas_paciente_tab.dart';
import 'citas_docente_tab.dart';

class CitasScreen extends StatelessWidget {
  final String
      userRole; // 'estudiante', 'docente', 'paciente', 'Administrador', etc.
  const CitasScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🔍 CitasScreen - userRole recibido: "$userRole"'); // DEBUG

    // Normalizar el rol a minúsculas para comparación
    final roleNormalized = userRole.toLowerCase();

    // Determinar qué tabs mostrar según el rol
    final List<Widget> tabs = [];
    final List<Widget> tabViews = [];

    // Administrador ve todas las tabs
    final isAdmin = roleNormalized.contains('admin');

    // Estudiante
    if (isAdmin || roleNormalized.contains('estudiante')) {
      tabs.add(const Tab(text: 'Como Estudiante'));
      tabViews.add(CitasEstudianteTab());
    }

    // Paciente
    if (isAdmin || roleNormalized.contains('paciente')) {
      tabs.add(const Tab(text: 'Como Paciente'));
      tabViews.add(CitasPacienteTab());
    }

    // Docente
    if (isAdmin || roleNormalized.contains('docente')) {
      tabs.add(const Tab(text: 'Como Docente'));
      tabViews.add(CitasDocenteTab());
    }

    // Si no hay tabs (no debería pasar), mostrar mensaje
    if (tabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Citas Médicas')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'No tienes permisos para ver citas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Rol actual: $userRole',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // Si solo hay una tab, mostrar directamente sin tabs
    if (tabs.length == 1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Citas Médicas'),
        ),
        body: tabViews[0],
      );
    }

    // Si hay múltiples tabs, mostrar TabBar
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Citas Médicas'),
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: tabViews,
        ),
      ),
    );
  }
}
