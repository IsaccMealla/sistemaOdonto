import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PapeleraPacientesScreen extends StatefulWidget {
  @override
  _PapeleraPacientesScreenState createState() =>
      _PapeleraPacientesScreenState();
}

class _PapeleraPacientesScreenState extends State<PapeleraPacientesScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = api.fetchPacientesEliminados();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = api.fetchPacientesEliminados();
    });
  }

  Widget _buildTable(List<dynamic> list) {
    if (list.isEmpty) {
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
              'No hay pacientes en la papelera',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los pacientes eliminados aparecerán aquí',
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
      'Nombres',
      'Apellidos',
      'Celular',
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
                    DataCell(Text(fmt(item['nombres']))),
                    DataCell(Text(fmt(item['apellidos']))),
                    DataCell(Text(fmt(item['celular']))),
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
                        item['eliminado_hace'] ?? 'Tiempo desconocido',
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
                            message: 'Restaurar paciente',
                            child: IconButton(
                              icon: Icon(Icons.restore, color: Colors.green),
                              onPressed: () => _restaurarPaciente(item),
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

  /// Restaurar paciente desde la papelera
  Future<void> _restaurarPaciente(Map<String, dynamic> paciente) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restaurar paciente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Restaurar el paciente:'),
            SizedBox(height: 8),
            Text(
              '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'El paciente volverá a aparecer en la lista principal.',
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
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final resultado = await api.restaurarPaciente(paciente['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                resultado['message'] ?? 'Paciente restaurado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al restaurar paciente: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Eliminar paciente permanentemente
  Future<void> _eliminarPermanentemente(Map<String, dynamic> paciente) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('¡PELIGRO!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Eliminar PERMANENTEMENTE el paciente:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️ ESTA ACCIÓN NO SE PUEDE DESHACER\n'
                'El paciente y todos sus registros asociados se perderán para siempre.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[800],
                  fontWeight: FontWeight.w500,
                ),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar para siempre'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final resultado = await api.hardDeletePaciente(paciente['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                resultado['message'] ?? 'Paciente eliminado permanentemente'),
            backgroundColor: Colors.red,
          ),
        );

        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar permanentemente: $e'),
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
        title: Text('Papelera de Pacientes'),
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red[800],
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Información de la Papelera'),
                  content: Text(
                    'Aquí se muestran los pacientes eliminados temporalmente.\n\n'
                    '• Restaurar: Devuelve el paciente a la lista principal\n'
                    '• Eliminar permanentemente: Borra el paciente para siempre',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
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
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final list = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildTable(list),
          );
        },
      ),
    );
  }
}
