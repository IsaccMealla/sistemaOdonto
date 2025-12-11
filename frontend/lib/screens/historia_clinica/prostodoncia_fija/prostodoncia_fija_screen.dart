import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../shared/widgets/prostodoncia_fija_widget.dart';

class ProstodonciaFijaScreen extends StatefulWidget {
  const ProstodonciaFijaScreen({Key? key}) : super(key: key);

  @override
  State<ProstodonciaFijaScreen> createState() => _ProstodonciaFijaScreenState();
}

class _ProstodonciaFijaScreenState extends State<ProstodonciaFijaScreen> {
  final ApiService _apiService = ApiService();

  String? _pacienteSeleccionado;
  List<dynamic> _pacientes = [];
  Map<String, dynamic> _datosProstodonciaFija = {};
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
        tipoRegistro: 'prostodoncia_fija',
      );

      if (registros.isNotEmpty) {
        final registro = registros.first;
        setState(() {
          _registroId = registro['id'].toString();
          _datosProstodonciaFija =
              Map<String, dynamic>.from(registro['datos'] ?? {});
        });
      } else {
        setState(() {
          _registroId = null;
          _datosProstodonciaFija = {};
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
            'datos': _datosProstodonciaFija,
          },
        );
        _mostrarExito('Registro actualizado correctamente');
      } else {
        // Crear nuevo registro
        final nuevoRegistro = await _apiService.createRegistroHistoriaClinica({
          'paciente': _pacienteSeleccionado!,
          'tipo_registro': 'prostodoncia_fija',
          'materia': 'prostodoncia_fija',
          'datos': _datosProstodonciaFija,
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
        title: Text('Clínica de Prostodoncia Fija'),
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
                        child: ProstodonciaFijaWidget(
                          data: _datosProstodonciaFija,
                          onDataChanged: (data) {
                            setState(() {
                              _datosProstodonciaFija = data;
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
