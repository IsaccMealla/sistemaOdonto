import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class HistorialesScreen extends StatefulWidget {
  @override
  _HistorialesScreenState createState() => _HistorialesScreenState();
}

class _HistorialesScreenState extends State<HistorialesScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = api.fetchHistoriales();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = api.fetchHistoriales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historiales Clínicos')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          final list = snapshot.data ?? [];
          if (list.isEmpty)
            return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(children: [
                  SizedBox(height: 40),
                  Center(child: Text('No hay historiales aún'))
                ]));
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Card(
              margin: EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Paciente')),
                    DataColumn(label: Text('Creado')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: list.map((item) {
                    String fmt(dynamic v) => (v ?? '').toString();
                    return DataRow(cells: [
                      DataCell(Text(fmt(item['paciente']))),
                      DataCell(Text(fmt(item['creado_en']))),
                      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: Icon(Icons.visibility,
                              color: Theme.of(context).colorScheme.primary),
                          onPressed: () => context
                              .read<MenuAppController>()
                              .setPageWithArgs('historial_form',
                                  {'historial': item, 'viewOnly': true}),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Theme.of(context).colorScheme.secondary),
                          onPressed: () => context
                              .read<MenuAppController>()
                              .setPageWithArgs(
                                  'historial_form', {'historial': item}),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Confirmar'),
                                content: Text('¿Eliminar historial?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text('Cancelar')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text('Eliminar')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              try {
                                await api.deleteHistorial(item['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Historial eliminado')));
                                _refresh();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')));
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          context.read<MenuAppController>().setPage('historial_form');
        },
      ),
    );
  }
}
