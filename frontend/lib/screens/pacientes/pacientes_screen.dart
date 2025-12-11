import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';
import 'papelera_pacientes_screen.dart';

class PacientesScreen extends StatefulWidget {
  @override
  _PacientesScreenState createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = api.fetchPacientes();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = api.fetchPacientes();
    });
  }

  List<dynamic> _filterList(List<dynamic> list) {
    if (_searchQuery.isEmpty) return list;

    return list.where((item) {
      final nombres = (item['nombres'] ?? '').toString().toLowerCase();
      final apellidos = (item['apellidos'] ?? '').toString().toLowerCase();
      final ci = (item['ci'] ?? '').toString().toLowerCase();
      final celular = (item['celular'] ?? '').toString().toLowerCase();

      return nombres.contains(_searchQuery) ||
          apellidos.contains(_searchQuery) ||
          ci.contains(_searchQuery) ||
          celular.contains(_searchQuery);
    }).toList();
  }

  Widget _buildTable(List<dynamic> list) {
    final columns = [
      'Nombres',
      'Apellidos',
      'Edad',
      'Celular',
      'Ultima Consulta',
      'Antecedentes',
      'Acciones'
    ];

    return Card(
      margin: EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.6),
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary.withOpacity(0.12)),
              columns: columns
                  .map((c) => DataColumn(
                      label: Text(c,
                          style: TextStyle(fontWeight: FontWeight.w600))))
                  .toList(),
              rows: list.map((item) {
                String fmt(dynamic v) => (v ?? '').toString();
                return DataRow(cells: [
                  DataCell(Text(fmt(item['nombres']))),
                  DataCell(Text(fmt(item['apellidos']))),
                  DataCell(Text(fmt(item['edad']))),
                  DataCell(Text(fmt(item['celular']))),
                  DataCell(Text(fmt(item['ultima_consulta']))),
                  DataCell(
                    ElevatedButton.icon(
                      icon: Icon(Icons.medical_information, size: 16),
                      label: Text('Antecedentes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        // Navegar al módulo de antecedentes con el paciente seleccionado
                        context
                            .read<MenuAppController>()
                            .setPageWithArgs('antecedentes', {
                          'paciente_id': item['id'],
                          'paciente_nombre':
                              '${item['nombres']} ${item['apellidos']}',
                          'ver_antecedentes':
                              false // Ir directo a crear antecedentes
                        });
                      },
                    ),
                  ),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility,
                            color: Theme.of(context).colorScheme.primary),
                        tooltip: 'Ver',
                        onPressed: () {
                          context.read<MenuAppController>().setPageWithArgs(
                              'paciente_form',
                              {'paciente': item, 'viewOnly': true});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Theme.of(context).colorScheme.secondary),
                        tooltip: 'Editar',
                        onPressed: () {
                          context.read<MenuAppController>().setPageWithArgs(
                              'paciente_form', {'paciente': item});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.orange),
                        tooltip: 'Mover a papelera',
                        onPressed: () => _eliminarPaciente(item),
                      ),
                    ],
                  ))
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pacientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Ver papelera',
            onPressed: () => _navegarAPapelera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombres, apellidos, CI o celular...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                final allList = snapshot.data ?? [];
                final list = _filterList(allList);

                if (allList.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      children: [
                        SizedBox(height: 40),
                        Center(
                            child: Text('No hay pacientes aún',
                                style: TextStyle(fontSize: 16))),
                      ],
                    ),
                  );
                }

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Intenta con otros términos de búsqueda',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                    onRefresh: _refresh, child: _buildTable(list));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addPaciente',
        child: Icon(Icons.add),
        onPressed: () async {
          context.read<MenuAppController>().setPage('paciente_form');
        },
      ),
    );
  }

  /// Eliminar paciente (eliminación lógica)
  Future<void> _eliminarPaciente(Map<String, dynamic> paciente) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mover a papelera'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Mover a la papelera el paciente:'),
            SizedBox(height: 8),
            Text(
              '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'El paciente se moverá a la papelera y podrá ser restaurado posteriormente.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Mover a papelera'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final resultado = await api.softDeletePaciente(paciente['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message'] ?? 'Paciente movido a papelera'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Ver papelera',
              textColor: Colors.white,
              onPressed: () => _navegarAPapelera(),
            ),
          ),
        );

        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al mover paciente: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navegar a la pantalla de papelera
  void _navegarAPapelera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PapeleraPacientesScreen(),
      ),
    ).then((_) => _refresh()); // Refrescar al volver
  }
}
