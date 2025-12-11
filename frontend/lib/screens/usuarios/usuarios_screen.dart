import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = api.fetchUsuarios();
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
      _future = api.fetchUsuarios();
    });
  }

  List<dynamic> _filterList(List<dynamic> list) {
    if (_searchQuery.isEmpty) return list;

    return list.where((item) {
      final username = (item['username'] ?? '').toString().toLowerCase();
      final email = (item['email'] ?? '').toString().toLowerCase();
      final rol = (item['rol_principal'] ?? '').toString().toLowerCase();
      final codigo = (item['codigo_estudiante'] ?? '').toString().toLowerCase();

      return username.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          rol.contains(_searchQuery) ||
          codigo.contains(_searchQuery);
    }).toList();
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'Administrador':
        return Colors.deepPurple;
      case 'Docente':
        return Colors.blue;
      case 'Estudiante':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Papelera',
            onPressed: () {
              context.read<MenuAppController>().setPage('papelera_usuarios');
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
                hintText: 'Buscar por usuario, email, rol o código...',
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
                        Center(child: Text('No hay usuarios aún'))
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
                          DataColumn(label: Text('Usuario')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Rol')),
                          DataColumn(label: Text('Creado')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: list.map((item) {
                          String fmt(dynamic v) => (v ?? '').toString();
                          String rolDisplay = item['rol_principal'] ?? '';
                          bool tieneRol = rolDisplay.isNotEmpty;

                          return DataRow(cells: [
                            DataCell(Text(fmt(item['username']))),
                            DataCell(Text(fmt(item['email']))),
                            DataCell(
                              tieneRol
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getRolColor(rolDisplay),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        rolDisplay,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Sin asignar',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                            ),
                            DataCell(Text(fmt(item['creado_en']))),
                            DataCell(
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                icon: Icon(Icons.visibility,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                onPressed: () => context
                                    .read<MenuAppController>()
                                    .setPageWithArgs('usuario_form',
                                        {'usuario': item, 'viewOnly': true}),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                onPressed: () => context
                                    .read<MenuAppController>()
                                    .setPageWithArgs(
                                        'usuario_form', {'usuario': item}),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Confirmar'),
                                      content: Text('¿Eliminar usuario?'),
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
                                      await api.softDeleteUsuario(
                                          item['id'].toString());
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('Usuario eliminado')));
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
          context.read<MenuAppController>().setPage('usuario_form');
        },
      ),
    );
  }
}
