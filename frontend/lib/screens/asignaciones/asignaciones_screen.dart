import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../controllers/menu_app_controller.dart';

class AsignacionesScreen extends StatefulWidget {
  @override
  _AsignacionesScreenState createState() => _AsignacionesScreenState();
}

class _AsignacionesScreenState extends State<AsignacionesScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  bool _vistaEstudiante = true; // true = por estudiante, false = por paciente
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = api.fetchAsignaciones();
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
      _future = api.fetchAsignaciones();
    });
  }

  List<dynamic> _filterList(List<dynamic> list) {
    if (_searchQuery.isEmpty) return list;
    
    return list.where((item) {
      final estudianteNombre = (item['estudiante_nombre'] ?? '').toString().toLowerCase();
      final estudianteCodigo = (item['estudiante_codigo'] ?? '').toString().toLowerCase();
      final pacienteNombre = (item['paciente_nombre'] ?? '').toString().toLowerCase();
      final pacienteCelular = (item['paciente_celular'] ?? '').toString().toLowerCase();
      final docenteNombre = (item['docente_nombre'] ?? '').toString().toLowerCase();
      final materia = (item['materia'] ?? '').toString().toLowerCase();
      final estado = (item['estado'] ?? '').toString().toLowerCase();
      
      return estudianteNombre.contains(_searchQuery) ||
             estudianteCodigo.contains(_searchQuery) ||
             pacienteNombre.contains(_searchQuery) ||
             pacienteCelular.contains(_searchQuery) ||
             docenteNombre.contains(_searchQuery) ||
             materia.contains(_searchQuery) ||
             estado.contains(_searchQuery);
    }).toList();
  }

  void _toggleVista() {
    setState(() {
      _vistaEstudiante = !_vistaEstudiante;
    });
  }

  Map<String, List<dynamic>> _agruparPorPaciente(List<dynamic> asignaciones) {
    Map<String, List<dynamic>> agrupadas = {};

    for (var asignacion in asignaciones) {
      String pacienteId = asignacion['paciente'] ?? '';
      if (pacienteId.isEmpty) continue;

      if (!agrupadas.containsKey(pacienteId)) {
        agrupadas[pacienteId] = [];
      }
      agrupadas[pacienteId]!.add(asignacion);
    }

    return agrupadas;
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'activa':
        return Colors.blue;
      case 'en_progreso':
        return Colors.orange;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'activa':
        return 'Activa';
      case 'en_progreso':
        return 'En Progreso';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vistaEstudiante
            ? 'Asignaciones por Estudiante'
            : 'Asignaciones por Paciente'),
        actions: [
          IconButton(
            icon: Icon(_vistaEstudiante ? Icons.person : Icons.school),
            tooltip:
                _vistaEstudiante ? 'Ver por Paciente' : 'Ver por Estudiante',
            onPressed: _toggleVista,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Papelera',
            onPressed: () {
              context
                  .read<MenuAppController>()
                  .setPage('papelera_asignaciones');
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
                hintText: 'Buscar por estudiante, paciente, docente, materia o estado...',
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
                  Center(child: Text('No hay asignaciones aún'))
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

          return _vistaEstudiante
              ? _buildVistaEstudiante(list)
              : _buildVistaPaciente(list);
        },
      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          context.read<MenuAppController>().setPage('asignacion_form');
        },
      ),
    );
  }

  // Vista por Estudiante (tabla)
  Widget _buildVistaEstudiante(List<dynamic> list) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Card(
        margin: EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Estudiante')),
              DataColumn(label: Text('Paciente')),
              DataColumn(label: Text('Docente')),
              DataColumn(label: Text('Materia')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Fecha Asignación')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: list.map((item) {
              String fmt(dynamic v) => (v ?? '').toString();
              String estado = item['estado'] ?? 'activa';

              return DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt(item['estudiante_nombre']),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item['estudiante_codigo'] != null)
                      Text(
                        fmt(item['estudiante_codigo']),
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt(item['paciente_nombre']),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item['paciente_celular'] != null)
                      Text(
                        fmt(item['paciente_celular']),
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt(item['docente_nombre']),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item['docente_especialidad'] != null)
                      Text(
                        fmt(item['docente_especialidad']),
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                )),
                DataCell(Text(
                  fmt(item['materia']),
                  style: TextStyle(fontWeight: FontWeight.w500),
                )),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(estado),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getEstadoLabel(estado),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(fmt(item['fecha_asignacion']).split('T')[0])),
                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: Icon(Icons.visibility,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: () => context
                        .read<MenuAppController>()
                        .setPageWithArgs('asignacion_form',
                            {'asignacion': item, 'viewOnly': true}),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: Theme.of(context).colorScheme.secondary),
                    onPressed: () => context
                        .read<MenuAppController>()
                        .setPageWithArgs(
                            'asignacion_form', {'asignacion': item}),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _eliminarAsignacion(item),
                  ),
                ])),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Vista por Paciente (agrupada)
  Widget _buildVistaPaciente(List<dynamic> list) {
    final agrupadas = _agruparPorPaciente(list);
    final pacientes = agrupadas.entries.toList();

    pacientes.sort((a, b) {
      final nombreA = a.value.first['paciente_nombre'] ?? '';
      final nombreB = b.value.first['paciente_nombre'] ?? '';
      return nombreA.compareTo(nombreB);
    });

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: pacientes.length,
        itemBuilder: (context, index) {
          final asignaciones = pacientes[index].value;
          final primerAsignacion = asignaciones.first;

          final pacienteNombre =
              primerAsignacion['paciente_nombre'] ?? 'Sin nombre';
          final pacienteCelular = primerAsignacion['paciente_celular'] ?? '';

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  pacienteNombre.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                pacienteNombre,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pacienteCelular.isNotEmpty)
                    Text('Tel: $pacienteCelular',
                        style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text(
                    '${asignaciones.length} asignación${asignaciones.length != 1 ? 'es' : ''}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              children: [
                Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: asignaciones.length,
                  itemBuilder: (context, idx) {
                    final asig = asignaciones[idx];
                    final estado = asig['estado'] ?? 'activa';

                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getEstadoColor(estado).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.medical_services,
                            color: _getEstadoColor(estado),
                            size: 20,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              asig['materia'] ?? 'Sin materia',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getEstadoColor(estado),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getEstadoLabel(estado),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.school, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Estudiante: ${asig['estudiante_nombre'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          if (asig['estudiante_codigo'] != null) ...[
                            SizedBox(height: 2),
                            Text(
                              '  Código: ${asig['estudiante_codigo']}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Docente: ${asig['docente_nombre'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'Asignado: ${asig['fecha_asignacion']?.toString().split('T')[0] ?? 'N/A'}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'ver') {
                            context.read<MenuAppController>().setPageWithArgs(
                              'asignacion_form',
                              {'asignacion': asig, 'viewOnly': true},
                            );
                          } else if (value == 'editar') {
                            context.read<MenuAppController>().setPageWithArgs(
                              'asignacion_form',
                              {'asignacion': asig},
                            );
                          } else if (value == 'eliminar') {
                            _eliminarAsignacion(asig);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'ver',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18),
                                SizedBox(width: 8),
                                Text('Ver'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _eliminarAsignacion(Map<String, dynamic> asignacion) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('¿Eliminar esta asignación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await api.softDeleteAsignacion(asignacion['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asignación eliminada')),
        );
        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
