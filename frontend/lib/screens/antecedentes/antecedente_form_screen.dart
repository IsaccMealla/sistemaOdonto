import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AntecedenteFormScreen extends StatefulWidget {
  final String pacienteId;
  final String pacienteNombre;
  final VoidCallback onVolver;
  final VoidCallback onGuardar;
  final List<dynamic>? antecedentesExistentes; // Para modo edición
  final bool modoEdicion; // true = edición, false = creación

  const AntecedenteFormScreen({
    Key? key,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.onVolver,
    required this.onGuardar,
    this.antecedentesExistentes,
    this.modoEdicion = false,
  }) : super(key: key);

  @override
  _AntecedenteFormScreenState createState() => _AntecedenteFormScreenState();
}

class _AntecedenteFormScreenState extends State<AntecedenteFormScreen>
    with TickerProviderStateMixin {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers para observaciones
  final _observacionesFamiliarController = TextEditingController();
  final _observacionesGinecologicoController = TextEditingController();
  final _observacionesNoPatologicoController = TextEditingController();
  final _observacionesPatologicoController = TextEditingController();

  // Estados para Antecedentes Familiares (según modelo AntecedentesFamiliares)
  Map<String, bool> _antecedentesFamiliares = {
    'alergia': false,
    'asma_bronquial': false,
    'cardiologicos': false,
    'oncologicos': false,
    'discrasias_sanguineas': false,
    'diabetes': false,
    'hipertension_arterial': false,
    'renales': false,
  };

  // Estados para Antecedentes Ginecológicos (según modelo AntecedentesGinecologicos)
  Map<String, dynamic> _antecedentesGinecologicos = {
    'embarazada': false,
    'meses_embarazo': 0,
    'anticonceptivos': false,
  };

  // Estados para Antecedentes No Patológicos (según modelo AntecedentesNoPatologicos)
  Map<String, dynamic> _antecedentesNoPatologicos = {
    'respira_boca': false,
    'alimentos_citricos': false,
    'muerde_unas': false,
    'muerde_objetos': false,
    'fuma': false,
    'cantidad_cigarros': 0,
    'apretamiento_dentario': false,
  };

  // Estados para Antecedentes Patológicos Personales (según modelo AntecedentesPatologicosPersonales)
  Map<String, dynamic> _antecedentesPatologicos = {
    'estado_salud': 'buena',
    'fecha_ultimo_examen': '',
    'bajo_tratamiento_medico': false,
    'toma_medicamentos': false,
    'intervencion_quirurgica': false,
    'sangra_excesivamente': false,
    'problema_sanguineo': false,
    'anemia': false,
    'problemas_oncologicos': false,
    'leucemia': false,
    'problemas_renales': false,
    'hemofilia': false,
    'transfusion_sanguinea': false,
    'deficit_vitamina_k': false,
    'consume_drogas': false,
    'problemas_corazon': false,
    'alergia_penicilina': false,
    'alergia_anestesia': false,
    'alergia_aspirina': false,
    'alergia_yodo': false,
    'alergia_otros': '',
    'fiebre_reumatica': false,
    'asma': false,
    'diabetes': false,
    'ulcera_gastrica': false,
    'tension_arterial': 'normal',
    'herpes_aftas_recurrentes': false,
    'enfermedades_venereas': false,
    'vih_positivo': false,
    'otros': '',
  };

  bool _isLoading = false;

  // IDs de antecedentes existentes para modo edición
  Map<String, String> _antecedentesIds = {
    'familiar': '',
    'ginecologico': '',
    'no_patologico': '',
    'patologico': '',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Si es modo edición, cargar datos existentes
    if (widget.modoEdicion && widget.antecedentesExistentes != null) {
      _cargarDatosExistentes();
    }
  }

  void _cargarDatosExistentes() {
    print('Cargando datos existentes para edición...');

    for (var antecedente in widget.antecedentesExistentes!) {
      final tipo = antecedente['tipo'] as String;
      final id = antecedente['id'] as String;

      // Guardar ID para futuras actualizaciones
      _antecedentesIds[tipo] = id;

      // Cargar observaciones
      final observaciones = antecedente['observaciones'] ?? '';
      switch (tipo) {
        case 'familiar':
          _observacionesFamiliarController.text = observaciones;
          // Cargar campos específicos
          _antecedentesFamiliares.keys.forEach((key) {
            if (antecedente.containsKey(key)) {
              _antecedentesFamiliares[key] = antecedente[key] ?? false;
            }
          });
          break;
        case 'ginecologico':
          _observacionesGinecologicoController.text = observaciones;
          _antecedentesGinecologicos.keys.forEach((key) {
            if (antecedente.containsKey(key)) {
              _antecedentesGinecologicos[key] =
                  antecedente[key] ?? (key == 'meses_embarazo' ? 0 : false);
            }
          });
          break;
        case 'no_patologico':
          _observacionesNoPatologicoController.text = observaciones;
          _antecedentesNoPatologicos.keys.forEach((key) {
            if (antecedente.containsKey(key)) {
              _antecedentesNoPatologicos[key] =
                  antecedente[key] ?? (key == 'cantidad_cigarros' ? 0 : false);
            }
          });
          break;
        case 'patologico':
          _observacionesPatologicoController.text = observaciones;
          _antecedentesPatologicos.keys.forEach((key) {
            if (antecedente.containsKey(key)) {
              if (key == 'estado_salud' && antecedente[key] == null) {
                _antecedentesPatologicos[key] = 'buena';
              } else if (key == 'tension_arterial' &&
                  antecedente[key] == null) {
                _antecedentesPatologicos[key] = 'normal';
              } else {
                _antecedentesPatologicos[key] = antecedente[key] ??
                    (key.endsWith('_otros') ||
                            key == 'otros' ||
                            key.contains('fecha')
                        ? ''
                        : false);
              }
            }
          });
          break;
      }
    }

    print('Datos cargados - Familiares: $_antecedentesFamiliares');
    print('IDs de antecedentes: $_antecedentesIds');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _observacionesFamiliarController.dispose();
    _observacionesGinecologicoController.dispose();
    _observacionesNoPatologicoController.dispose();
    _observacionesPatologicoController.dispose();
    super.dispose();
  }

  // Método auxiliar para mostrar selector de fecha
  Future<void> _selectDate(BuildContext context, String fieldKey,
      Map<String, dynamic> dataMap) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        // Formato YYYY-MM-DD para el backend
        dataMap[fieldKey] =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  // Widget para campo de fecha con calendario
  Widget _buildDateField(
      String labelText, String fieldKey, Map<String, dynamic> dataMap,
      {String? hintText}) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? 'Seleccionar fecha',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      controller:
          TextEditingController(text: dataMap[fieldKey]?.toString() ?? ''),
      onTap: () => _selectDate(context, fieldKey, dataMap),
    );
  }

  Future<String?> _getOrCreateHistorial() async {
    try {
      print('=== OBTENIENDO HISTORIAL ===');
      print('Paciente ID: ${widget.pacienteId}');

      // Obtener todos los historiales
      final historiales = await api.fetchHistoriales();
      print('Historiales obtenidos: ${historiales.length}');

      // Debug: mostrar todos los historiales
      for (var h in historiales) {
        print('Historial: ${h['id']} -> Paciente: ${h['paciente']}');
      }

      // Buscar el historial del paciente
      final historial = historiales.firstWhere(
        (h) => h['paciente'] == widget.pacienteId,
        orElse: () => null,
      );

      if (historial != null) {
        print('Historial encontrado: ${historial['id']}');
        return historial['id'] as String;
      }

      print('Historial no encontrado, creando nuevo...');
      // Si no existe, crear uno nuevo
      final nuevoHistorial = await api.createHistorial({
        'paciente': widget.pacienteId,
      });

      print('Nuevo historial creado: ${nuevoHistorial['id']}');
      return nuevoHistorial['id'] as String;
    } catch (e) {
      print('Error obteniendo historial: $e');
      return null;
    }
  }

  Future<void> _guardarAntecedentes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? historialId;

      if (widget.modoEdicion) {
        print('=== MODO EDICIÓN ===');
        // En modo edición, obtener el historial del primer antecedente
        if (widget.antecedentesExistentes != null &&
            widget.antecedentesExistentes!.isNotEmpty) {
          historialId =
              widget.antecedentesExistentes!.first['historial']?.toString();
        }
      } else {
        print('=== MODO CREACIÓN ===');
        // Obtener o crear el historial clínico del paciente
        historialId = await _getOrCreateHistorial();
      }

      if (historialId == null) {
        throw Exception('No se pudo obtener el historial del paciente');
      }

      // Procesar antecedentes familiares
      await _guardarOActualizarAntecedente(
        historialId: historialId,
        tipo: 'familiar',
        datos: _antecedentesFamiliares,
        observaciones: _observacionesFamiliarController.text.isEmpty
            ? 'Antecedentes familiares evaluados'
            : _observacionesFamiliarController.text,
      );

      // Procesar antecedentes ginecológicos
      await _guardarOActualizarAntecedente(
        historialId: historialId,
        tipo: 'ginecologico',
        datos: _antecedentesGinecologicos,
        observaciones: _observacionesGinecologicoController.text.isEmpty
            ? 'Antecedentes ginecológicos evaluados'
            : _observacionesGinecologicoController.text,
      );

      // Procesar antecedentes no patológicos
      await _guardarOActualizarAntecedente(
        historialId: historialId,
        tipo: 'no_patologico',
        datos: _antecedentesNoPatologicos,
        observaciones: _observacionesNoPatologicoController.text.isEmpty
            ? 'Antecedentes no patológicos evaluados'
            : _observacionesNoPatologicoController.text,
      );

      // Procesar antecedentes patológicos
      await _guardarOActualizarAntecedente(
        historialId: historialId,
        tipo: 'patologico',
        datos: _antecedentesPatologicos,
        observaciones: _observacionesPatologicoController.text.isEmpty
            ? 'Antecedentes patológicos personales evaluados'
            : _observacionesPatologicoController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.modoEdicion
              ? 'Antecedentes actualizados exitosamente'
              : 'Antecedentes guardados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onGuardar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarOActualizarAntecedente({
    required String historialId,
    required String tipo,
    required Map<String, dynamic> datos,
    required String observaciones,
  }) async {
    final datosCompletos = {
      'historial': historialId,
      'tipo': tipo,
      'observaciones': observaciones,
      ...datos,
    };

    final tipoDisplay = {
          'familiar': 'FAMILIARES',
          'ginecologico': 'GINECOLÓGICOS',
          'no_patologico': 'NO PATOLÓGICOS',
          'patologico': 'PATOLÓGICOS',
        }[tipo] ??
        tipo.toUpperCase();

    if (widget.modoEdicion && _antecedentesIds[tipo]!.isNotEmpty) {
      // Modo actualización
      print('=== ACTUALIZANDO ANTECEDENTES $tipoDisplay ===');
      print('ID: ${_antecedentesIds[tipo]}');
      print('Datos: $datosCompletos');

      await api.updateAntecedente(_antecedentesIds[tipo]!, datosCompletos);
      print('Antecedentes $tipoDisplay actualizados exitosamente');
    } else {
      // Modo creación
      print('=== CREANDO ANTECEDENTES $tipoDisplay ===');
      print('Datos: $datosCompletos');

      await api.createAntecedente(datosCompletos);
      print('Antecedentes $tipoDisplay creados exitosamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.modoEdicion ? 'Editar' : 'Crear'} Antecedentes - ${widget.pacienteNombre}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onVolver,
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Familiares', icon: Icon(Icons.family_restroom)),
            Tab(text: 'Ginecológicos', icon: Icon(Icons.female)),
            Tab(text: 'No Patológicos', icon: Icon(Icons.health_and_safety)),
            Tab(text: 'Patológicos', icon: Icon(Icons.medical_services)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAntecedentesFamiliares(),
                  _buildAntecedentesGinecologicos(),
                  _buildAntecedentesNoPatologicos(),
                  _buildAntecedentesPatologicos(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onVolver,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _guardarAntecedentes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(widget.modoEdicion
                              ? 'Actualizar Antecedentes'
                              : 'Guardar Antecedentes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAntecedentesFamiliares() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Antecedentes Familiares',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        ..._antecedentesFamiliares.keys.map((key) => CheckboxListTile(
              title: Text(_getDisplayName(key)),
              value: _antecedentesFamiliares[key],
              onChanged: (value) {
                setState(() {
                  _antecedentesFamiliares[key] = value ?? false;
                });
              },
            )),
        SizedBox(height: 16),
        TextFormField(
          controller: _observacionesFamiliarController,
          decoration: InputDecoration(
            labelText: 'Observaciones adicionales',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAntecedentesGinecologicos() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Antecedentes Ginecológicos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),

        // Campos según modelo AntecedentesGinecologicos
        SizedBox(height: 16),

        // Solo los campos del modelo AntecedentesGinecologicos
        SizedBox(height: 16),

        // Campos según modelo AntecedentesGinecologicos
        CheckboxListTile(
          title: Text('¿Está embarazada?'),
          value: _antecedentesGinecologicos['embarazada'] ?? false,
          onChanged: (value) {
            setState(() {
              _antecedentesGinecologicos['embarazada'] = value ?? false;
            });
          },
        ),

        // Campo para meses de embarazo (solo si está embarazada)
        if (_antecedentesGinecologicos['embarazada'] == true) ...[
          SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Meses de embarazo',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _antecedentesGinecologicos['meses_embarazo'] =
                  int.tryParse(value) ?? 0;
            },
          ),
        ],

        CheckboxListTile(
          title: Text('¿Usa anticonceptivos?'),
          value: _antecedentesGinecologicos['anticonceptivos'] ?? false,
          onChanged: (value) {
            setState(() {
              _antecedentesGinecologicos['anticonceptivos'] = value ?? false;
            });
          },
        ),

        // Campo para tipo de anticonceptivos (solo si usa)
        if (_antecedentesGinecologicos['anticonceptivos'] == true) ...[
          SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Tipo de anticonceptivos',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _antecedentesGinecologicos['tipo_anticonceptivos'] = value;
            },
          ),
        ],

        SizedBox(height: 16),
        CheckboxListTile(
          title: Text('¿Ciclo menstrual regular?'),
          value: _antecedentesGinecologicos['ciclo_menstrual'] ?? false,
          onChanged: (value) {
            setState(() {
              _antecedentesGinecologicos['ciclo_menstrual'] = value ?? false;
            });
          },
        ),

        SizedBox(height: 12),
        _buildDateField(
          'Fecha última menstruación',
          'fecha_ultima_menstruacion',
          _antecedentesGinecologicos,
          hintText: 'Seleccionar fecha de última menstruación',
        ),

        SizedBox(height: 16),
        CheckboxListTile(
          title: Text('¿En menopausia?'),
          value: _antecedentesGinecologicos['menopausia'] ?? false,
          onChanged: (value) {
            setState(() {
              _antecedentesGinecologicos['menopausia'] = value ?? false;
            });
          },
        ),

        // Campo para edad de menopausia (solo si está en menopausia)
        if (_antecedentesGinecologicos['menopausia'] == true) ...[
          SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Edad de menopausia',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _antecedentesGinecologicos['edad_menopausia'] =
                  int.tryParse(value) ?? 0;
            },
          ),
        ],

        SizedBox(height: 16),
        CheckboxListTile(
          title: Text('¿Usa terapia hormonal?'),
          value: _antecedentesGinecologicos['terapia_hormonal'] ?? false,
          onChanged: (value) {
            setState(() {
              _antecedentesGinecologicos['terapia_hormonal'] = value ?? false;
            });
          },
        ),

        SizedBox(height: 16),
        CheckboxListTile(
          title: Text('¿Problemas ginecológicos?'),
          value: _antecedentesGinecologicos['problemas_ginecologicos'] ?? false,
          onChanged: (value) {
            setState(() {
              _antecedentesGinecologicos['problemas_ginecologicos'] =
                  value ?? false;
            });
          },
        ),

        // Campo para descripción de problemas (solo si tiene problemas)
        if (_antecedentesGinecologicos['problemas_ginecologicos'] == true) ...[
          SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Descripción de problemas ginecológicos',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) {
              _antecedentesGinecologicos[
                  'descripcion_problemas_ginecologicos'] = value;
            },
          ),
        ],

        SizedBox(height: 16),
        TextFormField(
          controller: _observacionesGinecologicoController,
          decoration: InputDecoration(
            labelText: 'Observaciones adicionales',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAntecedentesNoPatologicos() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Antecedentes No Patológicos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),

        // Checkboxes según modelo AntecedentesNoPatologicos
        ...[
          'respira_boca',
          'alimentos_citricos',
          'muerde_unas',
          'muerde_objetos',
          'fuma',
          'apretamiento_dentario'
        ].map((key) => CheckboxListTile(
              title: Text(_getDisplayName(key)),
              value: _antecedentesNoPatologicos[key] ?? false,
              onChanged: (value) {
                setState(() {
                  _antecedentesNoPatologicos[key] = value ?? false;
                });
              },
            )),

        SizedBox(height: 16),

        // Campo para cantidad de cigarros (solo si fuma)
        if (_antecedentesNoPatologicos['fuma'] == true) ...[
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Cantidad de cigarros por día',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _antecedentesNoPatologicos['cantidad_cigarros'] =
                  int.tryParse(value) ?? 0;
            },
          ),
          SizedBox(height: 16),
        ],

        SizedBox(height: 16),
        TextFormField(
          controller: _observacionesNoPatologicoController,
          decoration: InputDecoration(
            labelText: 'Observaciones adicionales',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAntecedentesPatologicos() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Antecedentes Patológicos Personales',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),

        // Estado de salud
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Estado de salud',
            border: OutlineInputBorder(),
          ),
          initialValue: _antecedentesPatologicos['estado_salud'],
          items: [
            DropdownMenuItem(value: 'buena', child: Text('Buena')),
            DropdownMenuItem(value: 'regular', child: Text('Regular')),
            DropdownMenuItem(value: 'mala', child: Text('Mala')),
          ],
          onChanged: (value) {
            setState(() {
              _antecedentesPatologicos['estado_salud'] = value ?? 'buena';
            });
          },
        ),
        SizedBox(height: 12),

        // Fecha último examen
        _buildDateField(
          'Fecha último examen médico (opcional)',
          'fecha_ultimo_examen',
          _antecedentesPatologicos,
          hintText: 'Seleccionar fecha del último examen',
        ),
        SizedBox(height: 16),

        // Checkboxes principales
        ...[
          'bajo_tratamiento_medico',
          'toma_medicamentos',
          'intervencion_quirurgica',
          'sangra_excesivamente',
          'problema_sanguineo',
          'anemia',
          'problemas_oncologicos',
          'leucemia',
          'problemas_renales',
          'hemofilia',
          'transfusion_sanguinea',
          'deficit_vitamina_k',
          'consume_drogas',
          'problemas_corazon'
        ].map((key) => CheckboxListTile(
              title: Text(_getDisplayName(key)),
              value: _antecedentesPatologicos[key] ?? false,
              onChanged: (value) {
                setState(() {
                  _antecedentesPatologicos[key] = value ?? false;
                });
              },
            )),

        // Sección de alergias
        Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alergias:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...[
                  'alergia_penicilina',
                  'alergia_anestesia',
                  'alergia_aspirina',
                  'alergia_yodo'
                ].map((key) => CheckboxListTile(
                      title: Text(_getDisplayName(key)),
                      value: _antecedentesPatologicos[key] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _antecedentesPatologicos[key] = value ?? false;
                        });
                      },
                    )),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Otras alergias',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _antecedentesPatologicos['alergia_otros'] = value;
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Otras condiciones
        ...[
          'fiebre_reumatica',
          'asma',
          'diabetes_patologico',
          'ulcera_gastrica',
          'herpes_aftas_recurrentes',
          'enfermedades_venereas',
          'vih_positivo'
        ].map((key) => CheckboxListTile(
              title: Text(_getDisplayName(key)),
              value: _antecedentesPatologicos[key] ?? false,
              onChanged: (value) {
                setState(() {
                  _antecedentesPatologicos[key] = value ?? false;
                });
              },
            )),

        // Tensión arterial
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Tensión arterial',
            border: OutlineInputBorder(),
          ),
          initialValue: _antecedentesPatologicos['tension_arterial'],
          items: [
            DropdownMenuItem(value: 'normal', child: Text('Normal')),
            DropdownMenuItem(value: 'alta', child: Text('Alta')),
            DropdownMenuItem(value: 'baja', child: Text('Baja')),
          ],
          onChanged: (value) {
            setState(() {
              _antecedentesPatologicos['tension_arterial'] = value ?? 'normal';
            });
          },
        ),
        SizedBox(height: 16),

        // Campo otros
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Otros antecedentes patológicos',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _antecedentesPatologicos['otros'] = value;
          },
          maxLines: 2,
        ),

        SizedBox(height: 16),
        TextFormField(
          controller: _observacionesPatologicoController,
          decoration: InputDecoration(
            labelText: 'Observaciones adicionales',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  String _getDisplayName(String key) {
    final names = {
      // Antecedentes Familiares (según modelo AntecedentesFamiliares)
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

      // Antecedentes Ginecológicos (según modelo AntecedentesGinecologicos)
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

      // Antecedentes No Patológicos (según modelo AntecedentesNoPatologicos)
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

      // Antecedentes Patológicos Personales (campos principales)
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

    return names[key] ?? key;
  }
}
