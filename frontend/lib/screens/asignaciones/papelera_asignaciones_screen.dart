import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_app_controller.dart';

class PapeleraAsignacionesScreen extends StatefulWidget {
  @override
  _PapeleraAsignacionesScreenState createState() =>
      _PapeleraAsignacionesScreenState();
}

class _PapeleraAsignacionesScreenState
    extends State<PapeleraAsignacionesScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = api.fetchAsignacionesEliminadas();
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
      _future = api.fetchAsignacionesEliminadas();
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

  Widget _buildTable(List<dynamic> allList) {
    final list = _filterList(allList);
    
    if (allList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No hay asignaciones en la papelera',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Las asignaciones eliminadas aparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final columns = [
      'Estudiante',
      'Paciente',
      'Docente',
      'Materia',
      'Estado',
      'Fecha Asignación',
      'Eliminado',
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
              headingRowColor:
                  WidgetStateProperty.all(Colors.red.withOpacity(0.1)),
              columns: columns
                  .map((c) => DataColumn(
                      label: Text(c,
                          style: TextStyle(fontWeight: FontWeight.w600))))
                  .toList(),
              rows: list.map<DataRow>((item) {
                String fmt(dynamic v) => (v ?? '').toString();
                String estado = item['estado'] ?? 'activa';

                return DataRow(
                  color: WidgetStateProperty.all(
                    Colors.red.withOpacity(0.05),
                  ),
                  cells: [
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fmt(item['deleted_at']).split('T')[0],
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'Por: ${fmt(item['deleted_by'])}',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    )),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'Restaurar',
                          child: IconButton(
                            icon: Icon(Icons.restore, color: Colors.green),
                            onPressed: () => _restaurarAsignacion(item),
                          ),
                        ),
                        Tooltip(
                          message: 'Eliminar permanentemente',
                          child: IconButton(
                            icon: Icon(Icons.delete_forever, color: Colors.red),
                            onPressed: () => _eliminarPermanente(item),
                          ),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _restaurarAsignacion(Map<String, dynamic> asignacion) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.green),
            SizedBox(width: 8),
            Text('Restaurar Asignación'),
          ],
        ),
        content: Text(
            '¿Restaurar la asignación de ${asignacion['estudiante_nombre']} con ${asignacion['paciente_nombre']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.restore),
            label: Text('Restaurar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await api.restaurarAsignacion(asignacion['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asignación restaurada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al restaurar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarPermanente(Map<String, dynamic> asignacion) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('⚠️ Eliminar Permanentemente'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de eliminar permanentemente esta asignación?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Estudiante: ${asignacion['estudiante_nombre']}'),
            Text('Paciente: ${asignacion['paciente_nombre']}'),
            Text('Materia: ${asignacion['materia']}'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción no se puede deshacer',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.delete_forever),
            label: Text('Eliminar Permanentemente'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await api.hardDeleteAsignacion(asignacion['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asignación eliminada permanentemente'),
            backgroundColor: Colors.orange,
          ),
        );
        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.delete_outline),
            SizedBox(width: 8),
            Text('Papelera de Asignaciones'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Volver a Asignaciones',
            onPressed: () {
              context.read<MenuAppController>().setPage('asignaciones');
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
            child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text('Reintentar'),
                      onPressed: _refresh,
                    ),
                  ],
                ),
              );
            }
            final allList = snapshot.data ?? [];
            final list = _filterList(allList);
            
            if (list.isEmpty && allList.isNotEmpty) {
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
            
            return _buildTable(allList);
          },
        ),
      ),
          ),
        ],
      ),
    );
  }
}
