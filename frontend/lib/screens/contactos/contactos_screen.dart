import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class ContactosScreen extends StatefulWidget {
  @override
  _ContactosScreenState createState() => _ContactosScreenState();
}

class _ContactosScreenState extends State<ContactosScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = api.fetchContactos();
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
      _future = api.fetchContactos();
    });
  }

  List<dynamic> _filterList(List<dynamic> list) {
    if (_searchQuery.isEmpty) return list;

    return list.where((item) {
      final nombre = (item['nombre'] ?? '').toString().toLowerCase();
      final parentesco = (item['parentesco'] ?? '').toString().toLowerCase();
      final telefono = (item['telefono'] ?? '').toString().toLowerCase();
      final pacienteNombre =
          (item['paciente_nombre'] ?? '').toString().toLowerCase();

      return nombre.contains(_searchQuery) ||
          parentesco.contains(_searchQuery) ||
          telefono.contains(_searchQuery) ||
          pacienteNombre.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactos de Emergencia'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Papelera',
            onPressed: () {
              context.read<MenuAppController>().setPage('papelera_contactos');
            },
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
                hintText:
                    'Buscar por nombre, parentesco, teléfono o paciente...',
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

                if (allList.isEmpty)
                  return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(children: [
                        SizedBox(height: 40),
                        Center(child: Text('No hay contactos aún'))
                      ]));

                if (list.isEmpty)
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

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: Card(
                    margin: EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Parentesco')),
                          DataColumn(label: Text('Teléfono')),
                          DataColumn(label: Text('Paciente')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: list.map((item) {
                          String fmt(dynamic v) => (v ?? '').toString();
                          return DataRow(cells: [
                            DataCell(Text(fmt(item['nombre']))),
                            DataCell(Text(fmt(item['parentesco']))),
                            DataCell(Text(fmt(item['telefono']))),
                            DataCell(
                                Text(item['paciente_nombre'] ?? 'Sin asignar')),
                            DataCell(
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                icon: Icon(Icons.visibility,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                onPressed: () => context
                                    .read<MenuAppController>()
                                    .setPageWithArgs('contacto_form',
                                        {'contacto': item, 'viewOnly': true}),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                onPressed: () => context
                                    .read<MenuAppController>()
                                    .setPageWithArgs(
                                        'contacto_form', {'contacto': item}),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Confirmar'),
                                      content: Text('¿Eliminar contacto?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text('Cancelar')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text('Eliminar')),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    try {
                                      await api.softDeleteContacto(item['id']);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('Contacto eliminado')));
                                      _refresh();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text('Error: $e')));
                                    }
                                  }
                                },
                              ),
                            ])),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          context.read<MenuAppController>().setPage('contacto_form');
        },
      ),
    );
  }
}
