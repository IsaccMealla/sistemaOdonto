import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PapeleraContactosScreen extends StatefulWidget {
  @override
  _PapeleraContactosScreenState createState() =>
      _PapeleraContactosScreenState();
}

class _PapeleraContactosScreenState extends State<PapeleraContactosScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = api.fetchContactosEliminados();
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
      _future = api.fetchContactosEliminados();
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
              'No hay contactos en la papelera',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los contactos eliminados aparecerán aquí',
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
      'Nombre',
      'Parentesco',
      'Teléfono',
      'Paciente',
      'Estado',
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
                return DataRow(
                  color: WidgetStateProperty.all(
                    Colors.red.withOpacity(0.05),
                  ),
                  cells: [
                    DataCell(Text(fmt(item['nombre']))),
                    DataCell(Text(fmt(item['parentesco']))),
                    DataCell(Text(fmt(item['telefono']))),
                    DataCell(Text(item['paciente_nombre'] ?? 'Sin asignar')),
                    DataCell(
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['estado'] ?? 'Eliminado',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDeletedAt(item['deleted_at']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Restaurar contacto',
                            child: IconButton(
                              icon: Icon(Icons.restore, color: Colors.green),
                              onPressed: () => _restaurarContacto(item),
                            ),
                          ),
                          SizedBox(width: 4),
                          Tooltip(
                            message: 'Eliminar permanentemente',
                            child: IconButton(
                              icon:
                                  Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () => _eliminarPermanentemente(item),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDeletedAt(dynamic deletedAt) {
    if (deletedAt == null) return 'Desconocido';
    try {
      final date = DateTime.parse(deletedAt.toString());
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0)
        return 'Hace ${diff.inDays} día${diff.inDays > 1 ? "s" : ""}';
      if (diff.inHours > 0)
        return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? "s" : ""}';
      if (diff.inMinutes > 0)
        return 'Hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? "s" : ""}';
      return 'Hace un momento';
    } catch (e) {
      return deletedAt.toString();
    }
  }

  Future<void> _restaurarContacto(Map<String, dynamic> contacto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.green),
            SizedBox(width: 8),
            Text('Restaurar Contacto'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Desea restaurar el contacto de emergencia?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${contacto['nombre']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  if (contacto['parentesco'] != null)
                    Text('Parentesco: ${contacto['parentesco']}'),
                  if (contacto['telefono'] != null)
                    Text('Teléfono: ${contacto['telefono']}'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            icon: Icon(Icons.restore),
            label: Text('Restaurar'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await api.restaurarContacto(contacto['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contacto restaurado exitosamente'),
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

  Future<void> _eliminarPermanentemente(Map<String, dynamic> contacto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Permanentemente'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ ADVERTENCIA: Esta acción no se puede deshacer',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text('Se eliminará permanentemente el contacto:'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: ${contacto['nombre']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  if (contacto['parentesco'] != null)
                    Text('Parentesco: ${contacto['parentesco']}'),
                  if (contacto['telefono'] != null)
                    Text('Teléfono: ${contacto['telefono']}'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: Icon(Icons.delete_forever),
            label: Text('Eliminar'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await api.hardDeleteContacto(contacto['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contacto eliminado permanentemente'),
            backgroundColor: Colors.red,
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
            Text('Papelera de Contactos'),
          ],
        ),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
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

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: _buildTable(allList),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
