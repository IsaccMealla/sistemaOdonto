import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../shared/widgets/oclusion_widget.dart';

class OclusiOnScreen extends StatefulWidget {
  const OclusiOnScreen({Key? key}) : super(key: key);

  @override
  State<OclusiOnScreen> createState() => _OclusiOnScreenState();
}

class _OclusiOnScreenState extends State<OclusiOnScreen> {
  final ApiService _apiService = ApiService();

  String? _pacienteSeleccionado;
  List<dynamic> _pacientes = [];
  Map<String, dynamic> _datosOclusion = {};
  String? _registroId;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  Future<void> _cargarPacientes() async {
    try {
      final pacientes = await _apiService.fetchPacientes();
      setState(() {
        _pacientes = pacientes;
      });
    } catch (e) {
      _mostrarError('Error al cargar pacientes: $e');
    }
  }

  Future<void> _cargarRegistroExistente(String pacienteId) async {
    setState(() {
      _cargando = true;
    });

    try {
      final registros = await _apiService.fetchRegistrosHistoriaClinica(
        pacienteId: pacienteId,
        tipoRegistro: 'oclusion',
      );

      if (registros.isNotEmpty) {
        final registro = registros.first;
        setState(() {
          _registroId = registro['id'].toString();
          _datosOclusion = Map<String, dynamic>.from(registro['datos'] ?? {});
        });
      } else {
        setState(() {
          _registroId = null;
          _datosOclusion = {};
        });
      }
    } catch (e) {
      _mostrarError('Error al cargar registro: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _guardarRegistro() async {
    if (_pacienteSeleccionado == null) {
      _mostrarError('Debe seleccionar un paciente');
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      if (_registroId != null) {
        // Actualizar registro existente
        await _apiService.updateRegistroHistoriaClinica(
          _registroId!,
          {
            'datos': _datosOclusion,
          },
        );
        _mostrarExito('Registro actualizado correctamente');
      } else {
        // Crear nuevo registro
        final nuevoRegistro = await _apiService.createRegistroHistoriaClinica({
          'paciente': _pacienteSeleccionado!,
          'tipo_registro': 'oclusion',
          'materia': 'odontopediatria',
          'datos': _datosOclusion,
        });
        setState(() {
          _registroId = nuevoRegistro['id'].toString();
        });
        _mostrarExito('Registro guardado correctamente');
      }
    } catch (e) {
      _mostrarError('Error al guardar: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oclusión'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Selector de paciente
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Paciente',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _pacienteSeleccionado,
                    items: _pacientes.map((paciente) {
                      return DropdownMenuItem<String>(
                        value: paciente['id'].toString(),
                        child: Text(
                          '${paciente['nombres']} ${paciente['apellidos']} - CI: ${paciente['ci']}',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _pacienteSeleccionado = value;
                        if (value != null) {
                          _cargarRegistroExistente(value);
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _cargando ? null : _guardarRegistro,
                  icon: Icon(_cargando ? Icons.hourglass_empty : Icons.save),
                  label: Text(_cargando ? 'Guardando...' : 'Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),

          // Contenido del formulario
          Expanded(
            child: _cargando
                ? Center(child: CircularProgressIndicator())
                : _pacienteSeleccionado == null
                    ? Center(
                        child: Text(
                          'Seleccione un paciente para continuar',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: OclusiOnWidget(
                          data: _datosOclusion,
                          onDataChanged: (data) {
                            setState(() {
                              _datosOclusion = data;
                            });
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
