import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AntecedentesScreen extends StatefulWidget {
  @override
  _AntecedentesScreenState createState() => _AntecedentesScreenState();
}

class _AntecedentesScreenState extends State<AntecedentesScreen> {
  final ApiService api = ApiService();
  late Future<Map<String, List<dynamic>>> _antecedentesAgrupados;

  @override
  void initState() {
    super.initState();
    _loadAntecedentes();
  }

  void _loadAntecedentes() {
    _antecedentesAgrupados = _fetchAntecedentesAgrupados();
  }

  Future<Map<String, List<dynamic>>> _fetchAntecedentesAgrupados() async {
    try {
      final antecedentes = await api.fetchAntecedentesConsolidados();
      Map<String, List<dynamic>> agrupados = {};

      for (var antecedente in antecedentes) {
        String pacienteNombre =
            antecedente['paciente_nombre_completo'] ?? 'N/A';
        if (!agrupados.containsKey(pacienteNombre)) {
          agrupados[pacienteNombre] = [];
        }
        agrupados[pacienteNombre]!.add(antecedente);
      }

      return agrupados;
    } catch (e) {
      print('Error fetching antecedentes: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Antecedentes')),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _antecedentesAgrupados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final antecedentesAgrupados = snapshot.data ?? {};

          if (antecedentesAgrupados.isEmpty) {
            return Center(child: Text('No hay antecedentes registrados'));
          }

          return SingleChildScrollView(
            child: Column(children: [
              Card(
                margin: EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                      columns: [
                        DataColumn(label: Text('Paciente')),
                        DataColumn(label: Text('Tipos de Antecedentes')),
                        DataColumn(label: Text('Cantidad')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: antecedentesAgrupados.entries.map<DataRow>((entry) {
                        String pacienteNombre = entry.key;
                        List<dynamic> antecedentes = entry.value;
                        String tiposResumen = _getTiposResumen(antecedentes);

                        return DataRow(cells: [
                          DataCell(Text(pacienteNombre)),
                          DataCell(Text(tiposResumen)),
                          DataCell(
                              Text('${antecedentes.length} antecedente(s)')),
                          DataCell(
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                icon: Icon(Icons.visibility),
                                onPressed: () {
                                  _showPacienteAntecedentes(
                                      pacienteNombre, antecedentes);
                                }),
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _editarAntecedentes(
                                      pacienteNombre, antecedentes);
                                }),
                          ])),
                        ]);
                      }).toList()),
                ),
              ),
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _crearNuevoAntecedente();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _getTiposResumen(List<dynamic> antecedentes) {
    Set<String> tipos = {};
    for (var antecedente in antecedentes) {
      String tipoDisplay = _getNombreTipoSinTildes(antecedente['tipo'] ?? '');
      tipos.add(tipoDisplay);
    }
    return tipos.join(', ');
  }

  String _getNombreTipoSinTildes(String tipo) {
    switch (tipo) {
      case 'familiar':
        return 'Familiares';
      case 'ginecologico':
        return 'Ginecologicos';
      case 'no_patologico':
        return 'No Patologicos';
      case 'patologico':
        return 'Patologicos Personales';
      default:
        return 'Desconocido';
    }
  }

  void _showPacienteAntecedentes(
      String pacienteNombre, List<dynamic> antecedentes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Antecedentes de $pacienteNombre'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total de antecedentes: ${antecedentes.length}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ...antecedentes
                    .map((antecedente) => Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildAntecedenteDetails(antecedente),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _editarAntecedentes(String pacienteNombre, List<dynamic> antecedentes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcion de editar antecedentes en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _crearNuevoAntecedente() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcion de crear antecedente en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  List<Widget> _buildAntecedenteDetails(Map<String, dynamic> antecedente) {
    List<Widget> details = [];
    final detalles = antecedente['detalles'] as Map<String, dynamic>? ?? {};
    final tipo = antecedente['tipo'] ?? '';
    final tipoDisplay = _getNombreTipoSinTildes(tipo);

    details.add(Text('Tipo: $tipoDisplay',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)));
    details.add(SizedBox(height: 8));

    if (antecedente['observaciones'] != null &&
        antecedente['observaciones'].toString().isNotEmpty) {
      details.add(Text('Observaciones: ${antecedente['observaciones']}'));
      details.add(SizedBox(height: 8));
    }

    if (detalles.isNotEmpty) {
      details.add(Text('Detalles especificos:',
          style: TextStyle(fontWeight: FontWeight.bold)));
      detalles.forEach((key, value) {
        if (value != null) {
          String displayKey = key
              .replaceAll('_', ' ')
              .split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ');

          // Convertir booleanos a Si/No
          String displayValue;
          if (value is bool) {
            displayValue = value ? 'Si' : 'No';
          } else if (value.toString().toLowerCase() == 'true') {
            displayValue = 'Si';
          } else if (value.toString().toLowerCase() == 'false') {
            displayValue = 'No';
          } else {
            displayValue = value.toString();
          }

          details.add(Text('$displayKey: $displayValue'));
        }
      });
    } else {
      details.add(Text('Sin detalles especificos disponibles'));
    }

    return details;
  }
}
