import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'antecedente_form_screen.dart';

class AntecedentesScreen extends StatefulWidget {
  final Map<String, dynamic>? args;

  AntecedentesScreen({this.args});

  @override
  _AntecedentesScreenState createState() => _AntecedentesScreenState();
}

class _AntecedentesScreenState extends State<AntecedentesScreen>
    with TickerProviderStateMixin {
  final ApiService api = ApiService();
  late TabController _tabController;

  late Future<Map<String, List<dynamic>>> _antecedentesAgrupados;
  late Future<List<dynamic>> _pacientesSinAntecedentes;

  // Variables para crear antecedentes de un paciente específico
  String? _pacienteSeleccionadoId;
  String? _pacienteSeleccionadoNombre;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Si viene de la lista de pacientes con un paciente específico
    if (widget.args != null && widget.args!['paciente_id'] != null) {
      _pacienteSeleccionadoId = widget.args!['paciente_id'];
      _pacienteSeleccionadoNombre = widget.args!['paciente_nombre'];
      print(
          'INICIALIZANDO con paciente desde args: $_pacienteSeleccionadoId - $_pacienteSeleccionadoNombre');

      // Si viene para crear antecedentes directamente, navegar al formulario
      if (widget.args!['ver_antecedentes'] == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navegarAFormulario(
              _pacienteSeleccionadoId!, _pacienteSeleccionadoNombre!);
        });
        return;
      }

      // Si viene para ver antecedentes, ir al tab 0
      _tabController.index = 0;
      print('Tab inicial configurado a: ${_tabController.index}');
    } else {
      print('Sin args o sin paciente_id en initState');
    }

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navegarAFormulario(String pacienteId, String pacienteNombre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AntecedenteFormScreen(
          pacienteId: pacienteId,
          pacienteNombre: pacienteNombre,
          onVolver: () {
            Navigator.pop(context);
          },
          onGuardar: () {
            Navigator.pop(context);
            _refresh();
          },
        ),
      ),
    );
  }

  void _loadData() {
    _antecedentesAgrupados = _fetchAntecedentesAgrupados();
    _pacientesSinAntecedentes = _fetchPacientesSinAntecedentes();
  }

  Future<List<dynamic>> _fetchPacientesSinAntecedentes() async {
    try {
      // Obtener todos los pacientes
      final pacientes = await api.fetchPacientes();

      // Obtener antecedentes consolidados
      final antecedentes = await api.fetchAntecedentesConsolidados();

      // Crear set de IDs de pacientes que ya tienen antecedentes
      final pacientesConAntecedentes = antecedentes
          .map((ant) => ant['paciente_id'])
          .where((id) => id != null)
          .toSet();

      // Filtrar pacientes sin antecedentes
      return pacientes
          .where(
              (paciente) => !pacientesConAntecedentes.contains(paciente['id']))
          .toList();
    } catch (e) {
      print('Error fetching pacientes sin antecedentes: $e');
      return [];
    }
  }

  void _refresh() {
    setState(() {
      _loadData();
    });
  }

  Future<Map<String, List<dynamic>>> _fetchAntecedentesAgrupados() async {
    try {
      print('=== OBTENIENDO ANTECEDENTES CONSOLIDADOS ===');
      final antecedentes = await api.fetchAntecedentesConsolidados();
      print('Total de antecedentes consolidados: ${antecedentes.length}');

      Map<String, List<dynamic>> agrupados = {};

      for (var antecedente in antecedentes) {
        print('=== ANTECEDENTE INDIVIDUAL ===');
        print('Estructura completa: $antecedente');

        String pacienteNombre =
            antecedente['paciente_nombre_completo'] ?? 'N/A';
        print('Paciente: $pacienteNombre');

        if (!agrupados.containsKey(pacienteNombre)) {
          agrupados[pacienteNombre] = [];
        }
        agrupados[pacienteNombre]!.add(antecedente);
      }

      print('Antecedentes agrupados: ${agrupados.length} pacientes');
      agrupados.forEach((paciente, lista) {
        print('- $paciente: ${lista.length} antecedentes');
      });

      return agrupados;
    } catch (e) {
      print('Error fetching antecedentes: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Antecedentes Médicos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Ver Antecedentes', icon: Icon(Icons.list)),
            Tab(text: 'Crear Antecedentes', icon: Icon(Icons.add_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVerAntecedentesTab(),
          _buildCrearAntecedentesTab(),
        ],
      ),
    );
  }

  Widget _buildVerAntecedentesTab() {
    return FutureBuilder<Map<String, List<dynamic>>>(
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
                        DataCell(Text('${antecedentes.length} antecedente(s)')),
                        DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: Icon(Icons.visibility,
                                  color: Theme.of(context).colorScheme.primary),
                              onPressed: () {
                                _showPacienteAntecedentes(
                                    pacienteNombre, antecedentes);
                              }),
                          IconButton(
                              icon: Icon(Icons.edit,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              onPressed: () {
                                _editarAntecedentes(
                                    pacienteNombre, antecedentes);
                              }),
                          IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () =>
                                  _eliminarAntecedentes(antecedentes)),
                        ])),
                      ]);
                    }).toList()),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildCrearAntecedentesTab() {
    print(
        '_buildCrearAntecedentesTab llamado. _pacienteSeleccionadoId: $_pacienteSeleccionadoId');
    if (_pacienteSeleccionadoId != null &&
        _pacienteSeleccionadoNombre != null) {
      // Mostrar formulario directo para el paciente seleccionado
      print('Mostrando formulario para: $_pacienteSeleccionadoNombre');
      return _buildFormularioAntecedentes(
          _pacienteSeleccionadoId!, _pacienteSeleccionadoNombre!);
    }

    return FutureBuilder<List<dynamic>>(
      future: _pacientesSinAntecedentes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final pacientesSinAntecedentes = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text(
                'Pacientes sin antecedentes registrados',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              if (pacientesSinAntecedentes.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text('¡Excelente!'),
                          Text(
                              'Todos los pacientes tienen antecedentes registrados'),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...pacientesSinAntecedentes.map((paciente) => Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                            '${paciente['nombres']} ${paciente['apellidos']}'),
                        subtitle: Text(
                            'ID: ${paciente['id']} • Edad: ${paciente['edad'] ?? 'N/A'}'),
                        trailing: ElevatedButton(
                          child: Text('Agregar Antecedentes'),
                          onPressed: () {
                            print(
                                'Botón presionado para paciente: ${paciente['nombres']} ${paciente['apellidos']}');
                            setState(() {
                              _pacienteSeleccionadoId = paciente['id'];
                              _pacienteSeleccionadoNombre =
                                  '${paciente['nombres']} ${paciente['apellidos']}';
                            });
                          },
                        ),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormularioAntecedentes(
      String pacienteId, String pacienteNombre) {
    return AntecedenteFormScreen(
      pacienteId: pacienteId,
      pacienteNombre: pacienteNombre,
      onVolver: () {
        setState(() {
          _pacienteSeleccionadoId = null;
          _pacienteSeleccionadoNombre = null;
        });
      },
      onGuardar: () {
        _refresh();
        setState(() {
          _pacienteSeleccionadoId = null;
          _pacienteSeleccionadoNombre = null;
        });
      },
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

  Future<void> _eliminarAntecedentes(List<dynamic> antecedentes) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar eliminacion'),
        content: Text(
            '¿Estas seguro de eliminar ${antecedentes.length} antecedente(s)? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        for (var antecedente in antecedentes) {
          await api.deleteAntecedente(antecedente['id'].toString());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Antecedentes eliminados exitosamente')),
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

  void _editarAntecedentes(
      String pacienteNombre, List<dynamic> antecedentes) async {
    print('=== MÉTODO EDITAR ANTECEDENTES LLAMADO - NUEVA VERSIÓN ===');
    print('Paciente: $pacienteNombre');
    print('Número de antecedentes: ${antecedentes.length}');

    if (antecedentes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('NUEVA VERSIÓN: No hay antecedentes para editar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // PRUEBA TEMPORAL: Mostrar mensaje para confirmar que se ejecuta la nueva versión
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('NUEVA VERSIÓN DEL CÓDIGO - Editando $pacienteNombre'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );

    // Obtener el paciente ID del primer antecedente
    String pacienteId = '';
    try {
      // Intentar obtener de paciente_id directo
      pacienteId = antecedentes.first['paciente_id']?.toString() ?? '';

      if (pacienteId.isEmpty) {
        // Si no está disponible, obtener desde todos los pacientes
        final pacientes = await api.fetchPacientes();
        final pacienteEncontrado = pacientes.firstWhere(
          (p) => '${p['nombres']} ${p['apellidos']}' == pacienteNombre,
          orElse: () => null,
        );

        if (pacienteEncontrado != null) {
          pacienteId = pacienteEncontrado['id'];
        }
      }

      if (pacienteId.isEmpty) {
        throw Exception('ID de paciente no encontrado');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error: No se pudo obtener la información del paciente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('=== EDITANDO ANTECEDENTES ===');
    print('Paciente: $pacienteNombre (ID: $pacienteId)');
    print('Antecedentes disponibles: ${antecedentes.length}');

    // Debug: mostrar estructura de antecedentes
    for (int i = 0; i < antecedentes.length; i++) {
      print('Antecedente $i: ${antecedentes[i]}');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AntecedenteFormScreen(
          pacienteId: pacienteId,
          pacienteNombre: pacienteNombre,
          modoEdicion: true,
          antecedentesExistentes: antecedentes,
          onVolver: () {
            Navigator.pop(context);
          },
          onGuardar: () {
            Navigator.pop(context);
            _refresh();
          },
        ),
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
    final tipo = antecedente['tipo'] ?? '';
    final tipoDisplay = _getNombreTipoSinTildes(tipo);

    // DEBUG: Imprimir toda la estructura del antecedente
    print('=== DEBUG ANTECEDENTE COMPLETO ===');
    print('Tipo: $tipo');
    antecedente.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });
    print('================================');

    // Título del tipo
    details.add(Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade800, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.medical_information, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text('$tipoDisplay',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16)),
        ],
      ),
    ));
    details.add(SizedBox(height: 12));

    // Observaciones
    if (antecedente['observaciones'] != null &&
        antecedente['observaciones'].toString().isNotEmpty) {
      details.add(Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.note, color: Colors.grey.shade700, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text('Observaciones: ${antecedente['observaciones']}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  )),
            ),
          ],
        ),
      ));
      details.add(SizedBox(height: 12));
    }

    // Crear tabla con todos los datos del antecedente
    List<DataRow> tableRows = [];

    // Procesar todos los campos del antecedente, incluyendo detalles
    Map<String, dynamic> camposAProcesar = Map.from(antecedente);

    // Si hay un campo 'detalles' y es un mapa, agregamos sus campos al procesamiento
    if (antecedente['detalles'] != null && antecedente['detalles'] is Map) {
      Map<String, dynamic> detalles =
          antecedente['detalles'] as Map<String, dynamic>;
      print('DEBUG: Procesando detalles: $detalles');
      camposAProcesar.addAll(detalles);
    }

    camposAProcesar.forEach((key, value) {
      // Omitir campos de metadata y el campo detalles ya que lo procesamos arriba
      if (![
        'id',
        'historial',
        'tipo',
        'creado_en',
        'actualizado_en',
        'observaciones',
        'tipo_display',
        'paciente_id',
        'paciente_nombre_completo',
        'detalles' // Agregamos detalles a la lista de exclusión
      ].contains(key)) {
        // Mostrar todos los campos, incluso los que son false/No
        if (value != null) {
          String displayKey = _getDisplayName(key);
          String displayValue = _formatValue(value);

          // Mostrar TODOS los valores para debugging - temporal
          print('DEBUG: Campo $key = $value (display: $displayValue)');
          // Mostrar todos los datos, incluyendo los "No"
          if (true) {
            tableRows.add(DataRow(
              cells: [
                DataCell(
                  Text(displayKey,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        fontSize: 14,
                      )),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: displayValue == 'Si' || displayValue == 'true'
                            ? [Colors.green.shade100, Colors.green.shade50]
                            : displayValue == 'No' || displayValue == 'false'
                                ? [Colors.red.shade100, Colors.red.shade50]
                                : displayValue
                                            .toLowerCase()
                                            .contains('buena') ||
                                        displayValue
                                            .toLowerCase()
                                            .contains('normal')
                                    ? [
                                        Colors.blue.shade100,
                                        Colors.blue.shade50
                                      ]
                                    : displayValue
                                                .toLowerCase()
                                                .contains('mala') ||
                                            displayValue
                                                .toLowerCase()
                                                .contains('alta')
                                        ? [
                                            Colors.orange.shade100,
                                            Colors.orange.shade50
                                          ]
                                        : [
                                            Colors.purple.shade100,
                                            Colors.purple.shade50
                                          ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 2,
                        color: displayValue == 'Si' || displayValue == 'true'
                            ? Colors.green.shade400
                            : displayValue == 'No' || displayValue == 'false'
                                ? Colors.red.shade400
                                : displayValue
                                            .toLowerCase()
                                            .contains('buena') ||
                                        displayValue
                                            .toLowerCase()
                                            .contains('normal')
                                    ? Colors.blue.shade400
                                    : displayValue
                                                .toLowerCase()
                                                .contains('mala') ||
                                            displayValue
                                                .toLowerCase()
                                                .contains('alta')
                                        ? Colors.orange.shade400
                                        : Colors.purple.shade400,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (displayValue == 'Si' || displayValue == 'true'
                                  ? Colors.green.shade200
                                  : displayValue == 'No' ||
                                          displayValue == 'false'
                                      ? Colors.red.shade200
                                      : Colors.grey.shade300)
                              .withOpacity(0.5),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          displayValue == 'Si' || displayValue == 'true'
                              ? Icons.check_circle
                              : displayValue == 'No' || displayValue == 'false'
                                  ? Icons.cancel
                                  : displayValue
                                              .toLowerCase()
                                              .contains('buena') ||
                                          displayValue
                                              .toLowerCase()
                                              .contains('normal')
                                      ? Icons.thumb_up
                                      : displayValue
                                                  .toLowerCase()
                                                  .contains('mala') ||
                                              displayValue
                                                  .toLowerCase()
                                                  .contains('alta')
                                          ? Icons.warning
                                          : Icons.info,
                          color: displayValue == 'Si' || displayValue == 'true'
                              ? Colors.green.shade700
                              : displayValue == 'No' || displayValue == 'false'
                                  ? Colors.red.shade700
                                  : displayValue
                                              .toLowerCase()
                                              .contains('buena') ||
                                          displayValue
                                              .toLowerCase()
                                              .contains('normal')
                                      ? Colors.blue.shade700
                                      : displayValue
                                                  .toLowerCase()
                                                  .contains('mala') ||
                                              displayValue
                                                  .toLowerCase()
                                                  .contains('alta')
                                          ? Colors.orange.shade700
                                          : Colors.purple.shade700,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(displayValue,
                            style: TextStyle(
                              color:
                                  displayValue == 'Si' || displayValue == 'true'
                                      ? Colors.green.shade900
                                      : displayValue == 'No' ||
                                              displayValue == 'false'
                                          ? Colors.red.shade900
                                          : displayValue
                                                      .toLowerCase()
                                                      .contains('buena') ||
                                                  displayValue
                                                      .toLowerCase()
                                                      .contains('normal')
                                              ? Colors.blue.shade900
                                              : displayValue
                                                          .toLowerCase()
                                                          .contains('mala') ||
                                                      displayValue
                                                          .toLowerCase()
                                                          .contains('alta')
                                                  ? Colors.orange.shade900
                                                  : Colors.purple.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ));
          }
        }
      }
    });

    if (tableRows.isNotEmpty) {
      details.add(Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor:
              WidgetStateColor.resolveWith((states) => Colors.grey.shade300),
          columns: [
            DataColumn(
              label: Text('Campo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 15,
                  )),
            ),
            DataColumn(
              label: Text('Valor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 15,
                  )),
            ),
          ],
          rows: tableRows,
        ),
      ));
    } else {
      details.add(Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade300, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade800, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No se encontraron datos específicos para este antecedente',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ));
    }

    return details;
  }

  String _formatValue(dynamic value) {
    if (value is bool) {
      return value ? 'Si' : 'No';
    } else if (value.toString().toLowerCase() == 'true') {
      return 'Si';
    } else if (value.toString().toLowerCase() == 'false') {
      return 'No';
    } else if (value.toString().isEmpty) {
      return 'No especificado';
    } else if (value == 0 && value is! String) {
      return '0'; // Mostrar ceros como números
    } else {
      return value.toString();
    }
  }

  bool _isImportantField(String fieldName) {
    // Campos que siempre queremos mostrar aunque sean 'No'
    final importantFields = [
      'estado_salud',
      'tension_arterial',
      'fecha_ultimo_examen',
      'meses_embarazo',
      'tipo_anticonceptivos',
      'fecha_ultima_menstruacion',
      'edad_menopausia',
      'cigarrillos_diarios',
      'tiempo_fumando',
      'frecuencia_alcohol',
      'tipo_droga',
      'frecuencia_droga',
      'tipo_actividad_fisica',
      'frecuencia_actividad_fisica',
      'tipo_dieta',
      'cuales_vitaminas',
      'horas_sueno',
      'calidad_sueno',
      'alergia_otros',
      'otros_familiares',
      'otros_no_patologicos',
      'otros'
    ];
    return importantFields.contains(fieldName);
  }

  String _getDisplayName(String fieldName) {
    final names = {
      // Antecedentes Familiares
      'alergia': 'Alergia',
      'asma_bronquial': 'Asma Bronquial',
      'cardiologicos': 'Problemas Cardiológicos',
      'oncologicos': 'Problemas Oncológicos',
      'discrasias_sanguineas': 'Discrasias Sanguíneas',
      'diabetes': 'Diabetes',
      'hipertension_arterial': 'Hipertensión Arterial',
      'renales': 'Problemas Renales',
      'tuberculosis': 'Tuberculosis',
      'enfermedades_corazon': 'Enfermedades del corazón',
      'hipertension': 'Hipertensión',
      'enfermedades_renales': 'Enfermedades renales',
      'cancer_cual': 'Cáncer (especificar)',
      'enfermedades_mentales': 'Enfermedades mentales',
      'epilepsia': 'Epilepsia',
      'malformaciones_congenitas': 'Malformaciones congénitas',
      'otros_familiares': 'Otros antecedentes familiares',

      // Antecedentes Ginecológicos
      'embarazada': 'Embarazada',
      'meses_embarazo': 'Meses de embarazo',
      'anticonceptivos': 'Usa anticonceptivos',
      'tipo_anticonceptivos': 'Tipo de anticonceptivos',
      'ciclo_menstrual': 'Ciclo menstrual regular',
      'fecha_ultima_menstruacion': 'Fecha última menstruación',
      'menopausia': 'Menopausia',
      'edad_menopausia': 'Edad de menopausia',
      'terapia_hormonal': 'Terapia hormonal',
      'problemas_ginecologicos': 'Problemas ginecológicos',
      'descripcion_problemas_ginecologicos':
          'Descripción problemas ginecológicos',

      // Antecedentes No Patológicos
      'respira_boca': 'Respira por la boca',
      'alimentos_citricos': 'Come alimentos cítricos',
      'muerde_unas': 'Se muerde las uñas',
      'muerde_objetos': 'Se muerde objetos',
      'fuma': 'Fuma',
      'apretamiento_dentario': 'Apretamiento dentario',
      'cigarrillos_diarios': 'Cigarrillos al día',
      'tiempo_fumando': 'Tiempo fumando',
      'bebe_alcohol': 'Bebe alcohol',
      'frecuencia_alcohol': 'Frecuencia alcohol',
      'droga_recreacional': 'Uso de drogas recreacionales',
      'tipo_droga': 'Tipo de droga',
      'frecuencia_droga': 'Frecuencia uso droga',
      'actividad_fisica': 'Actividad física',
      'tipo_actividad_fisica': 'Tipo de actividad física',
      'frecuencia_actividad_fisica': 'Frecuencia actividad física',
      'dieta_especial': 'Dieta especial',
      'tipo_dieta': 'Tipo de dieta',
      'vitaminas_suplementos': 'Vitaminas o suplementos',
      'cuales_vitaminas': 'Cuáles vitaminas',
      'horas_sueno': 'Horas de sueño',
      'calidad_sueno': 'Calidad del sueño',
      'otros_no_patologicos': 'Otros antecedentes no patológicos',

      // Antecedentes Patológicos Personales
      'estado_salud': 'Estado de salud general',
      'fecha_ultimo_examen': 'Fecha último examen médico',
      'bajo_tratamiento_medico': 'Bajo tratamiento médico',
      'toma_medicamentos': 'Toma medicamentos',
      'intervencion_quirurgica': 'Ha tenido intervenciones quirúrgicas',
      'sangra_excesivamente': 'Sangra excesivamente',
      'problema_sanguineo': 'Problemas sanguíneos',
      'anemia': 'Anemia',
      'problemas_oncologicos': 'Problemas oncológicos',
      'leucemia': 'Leucemia',
      'problemas_renales': 'Problemas renales',
      'hemofilia': 'Hemofilia',
      'transfusion_sanguinea': 'Ha recibido transfusiones sanguíneas',
      'deficit_vitamina_k': 'Déficit de vitamina K',
      'consume_drogas': 'Consume drogas',
      'problemas_corazon': 'Problemas del corazón',
      'alergia_penicilina': 'Alergia a la penicilina',
      'alergia_anestesia': 'Alergia a la anestesia',
      'alergia_aspirina': 'Alergia a la aspirina',
      'alergia_yodo': 'Alergia al yodo',
      'alergia_otros': 'Otras alergias',
      'fiebre_reumatica': 'Fiebre reumática',
      'asma': 'Asma',
      'diabetes_patologico': 'Diabetes',
      'ulcera_gastrica': 'Úlcera gástrica',
      'herpes_aftas_recurrentes': 'Herpes/aftas recurrentes',
      'enfermedades_venereas': 'Enfermedades venéreas',
      'vih_positivo': 'VIH positivo',
      'tension_arterial': 'Tensión arterial',
      'otros': 'Otros antecedentes patológicos',
    };

    return names[fieldName] ??
        fieldName
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '')
            .join(' ');
  }

  Widget _buildNewAntecedenteDetails(Map<String, dynamic> antecedente) {
    // Filtrar solo los datos relevantes (que tienen valor "Si" o datos importantes)
    final datosRelevantes = <MapEntry<String, dynamic>>[];

    antecedente.entries.forEach((entry) {
      if (entry.key == 'tipo_display' ||
          entry.key == 'paciente_nombre_completo' ||
          entry.key == 'id' ||
          entry.key == 'historial' ||
          entry.key == 'tipo' ||
          entry.key == 'creado_en' ||
          entry.key == 'paciente_id' ||
          entry.key == 'observaciones') {
        return;
      }

      if (entry.value == null ||
          entry.value.toString().isEmpty ||
          entry.value.toString() == 'normal' ||
          entry.value.toString() == 'buena') {
        return;
      }

      // Convertir y verificar si el valor es positivo (Si)
      final valorFormateado = _formatFieldValue(entry.value);
      if (valorFormateado == 'Si' ||
          (valorFormateado != 'No' &&
              entry.value.toString() != '0' &&
              entry.value.toString().toLowerCase() != 'false')) {
        datosRelevantes.add(entry);
      }
    });

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del tipo con mejor diseño
              Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  antecedente['tipo_display'] ?? 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

              if (datosRelevantes.isNotEmpty) ...[
                SizedBox(height: 12),
                // Grid de datos relevantes con mejor formato
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: datosRelevantes.map((entry) {
                    final valor = _formatFieldValue(entry.value);
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: valor == 'Si'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: valor == 'Si'
                              ? Colors.green.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            valor == 'Si' ? Icons.check_circle : Icons.info,
                            size: 14,
                            color: valor == 'Si' ? Colors.green : Colors.blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatFieldName(entry.key),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (valor != 'Si') ...[
                            Text(': ', style: TextStyle(fontSize: 12)),
                            Text(
                              valor,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Mostrar observaciones si existen
              if (antecedente['observaciones'] != null &&
                  antecedente['observaciones'].toString().isNotEmpty &&
                  !antecedente['observaciones']
                      .toString()
                      .toLowerCase()
                      .contains('evaluados'))
                Container(
                  margin: EdgeInsets.only(top: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_alt,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          antecedente['observaciones'].toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFieldName(String field) {
    // Convertir snake_case a formato legible
    return field
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatFieldValue(dynamic value) {
    if (value == null) return 'No';
    if (value is bool) return value ? 'Si' : 'No';
    if (value is int && (value == 0 || value == 1))
      return value == 1 ? 'Si' : 'No';

    String stringValue = value.toString().toLowerCase();
    if (stringValue == 'true') return 'Si';
    if (stringValue == 'false') return 'No';
    if (stringValue == '1') return 'Si';
    if (stringValue == '0') return 'No';

    return value.toString();
  }
}
