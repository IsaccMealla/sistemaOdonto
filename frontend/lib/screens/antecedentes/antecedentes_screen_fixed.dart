import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AntecedentesScreen extends StatefulWidget {
  @override
  _AntecedentesScreenState createState() => _AntecedentesScreenState();
}

class _AntecedentesScreenState extends State<AntecedentesScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _antecedentesConsolidados;

  @override
  void initState() {
    super.initState();
    _loadAntecedentes();
  }

  void _loadAntecedentes() {
    _antecedentesConsolidados = _fetchAntecedentesConsolidados();
  }

  Future<List<dynamic>> _fetchAntecedentesConsolidados() async {
    try {
      return await api.fetchAntecedentesConsolidados();
    } catch (e) {
      print('Error fetching antecedentes: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Antecedentes')),
      body: FutureBuilder<List<dynamic>>(
        future: _antecedentesConsolidados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final antecedentes = snapshot.data ?? [];

          if (antecedentes.isEmpty) {
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
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Información')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: antecedentes.map<DataRow>((antecedente) {
                        return DataRow(cells: [
                          DataCell(Text(
                              antecedente['paciente_nombre_completo'] ??
                                  'N/A')),
                          DataCell(Text(_getTipoAntecedente(antecedente))),
                          DataCell(Text(_getInformacionResumen(antecedente))),
                          DataCell(
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                icon: Icon(Icons.visibility),
                                onPressed: () {
                                  _showAntecedenteDetail(antecedente);
                                }),
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // TODO: Implementar edición
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
          // TODO: Implementar creación de antecedente
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _getTipoAntecedente(Map<String, dynamic> antecedente) {
    if (antecedente['familiares'] != null) return 'Familiares';
    if (antecedente['ginecologicos'] != null) return 'Ginecológicos';
    if (antecedente['no_patologicos'] != null) return 'No Patológicos';
    if (antecedente['patologicos_personales'] != null)
      return 'Patológicos Personales';
    return 'Desconocido';
  }

  String _getInformacionResumen(Map<String, dynamic> antecedente) {
    if (antecedente['familiares'] != null) {
      final fam = antecedente['familiares'];
      return 'Condición: ${fam['condicion'] ?? 'N/A'}';
    }
    if (antecedente['ginecologicos'] != null) {
      final gine = antecedente['ginecologicos'];
      return 'Embarazada: ${gine['embarazada'] ?? 'N/A'}';
    }
    if (antecedente['no_patologicos'] != null) {
      final np = antecedente['no_patologicos'];
      return 'Fuma: ${np['fuma'] ?? 'N/A'}, Bebe: ${np['bebe'] ?? 'N/A'}';
    }
    if (antecedente['patologicos_personales'] != null) {
      final pp = antecedente['patologicos_personales'];
      return 'Estado de salud: ${pp['estado_salud'] ?? 'N/A'}';
    }
    return 'N/A';
  }

  void _showAntecedenteDetail(Map<String, dynamic> antecedente) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detalles del Antecedente'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paciente: ${antecedente['paciente_nombre_completo'] ?? 'N/A'}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ..._buildAntecedenteDetails(antecedente),
            ],
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

  List<Widget> _buildAntecedenteDetails(Map<String, dynamic> antecedente) {
    List<Widget> details = [];

    if (antecedente['familiares'] != null) {
      final fam = antecedente['familiares'];
      details.addAll([
        Text('Tipo: Antecedentes Familiares',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Condición: ${fam['condicion'] ?? 'N/A'}'),
        Text('Observaciones: ${fam['observaciones'] ?? 'N/A'}'),
      ]);
    }

    if (antecedente['ginecologicos'] != null) {
      final gine = antecedente['ginecologicos'];
      details.addAll([
        Text('Tipo: Antecedentes Ginecológicos',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Embarazada: ${gine['embarazada'] ?? 'N/A'}'),
        Text('Observaciones: ${gine['observaciones'] ?? 'N/A'}'),
      ]);
    }

    if (antecedente['no_patologicos'] != null) {
      final np = antecedente['no_patologicos'];
      details.addAll([
        Text('Tipo: Antecedentes No Patológicos',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Fuma: ${np['fuma'] ?? 'N/A'}'),
        Text('Bebe: ${np['bebe'] ?? 'N/A'}'),
        Text('Drogas: ${np['drogas'] ?? 'N/A'}'),
        Text('Observaciones: ${np['observaciones'] ?? 'N/A'}'),
      ]);
    }

    if (antecedente['patologicos_personales'] != null) {
      final pp = antecedente['patologicos_personales'];
      details.addAll([
        Text('Tipo: Antecedentes Patológicos Personales',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Estado de salud: ${pp['estado_salud'] ?? 'N/A'}'),
        Text('Tensión arterial: ${pp['tension_arterial'] ?? 'N/A'}'),
        Text('Observaciones: ${pp['observaciones'] ?? 'N/A'}'),
      ]);
    }

    return details;
  }
}
