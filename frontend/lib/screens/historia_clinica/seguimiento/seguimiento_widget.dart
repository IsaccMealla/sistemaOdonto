import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';

class SeguimientoWidget extends StatefulWidget {
  final Map<String, dynamic> seguimiento;
  final VoidCallback onActualizar;
  final bool modoSoloLectura;

  const SeguimientoWidget({
    Key? key,
    required this.seguimiento,
    required this.onActualizar,
    this.modoSoloLectura = false,
  }) : super(key: key);

  @override
  State<SeguimientoWidget> createState() => _SeguimientoWidgetState();
}

class _SeguimientoWidgetState extends State<SeguimientoWidget> {
  final ApiService _apiService = ApiService();
  List<dynamic> _entradas = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarEntradas();
  }

  @override
  void didUpdateWidget(SeguimientoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seguimiento['id'] != oldWidget.seguimiento['id']) {
      _cargarEntradas();
    }
  }

  Future<void> _cargarEntradas() async {
    setState(() {
      _cargando = true;
    });

    try {
      final entradas = await _apiService.fetchEntradasSeguimiento(
        seguimientoId: widget.seguimiento['id'].toString(),
      );
      setState(() {
        _entradas = entradas;
      });
    } catch (e) {
      _mostrarError('Error al cargar entradas: $e');
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _agregarEntrada() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FormularioEntradaDialog(),
    );

    if (result != null) {
      try {
        await _apiService.createEntradaSeguimiento({
          'seguimiento': widget.seguimiento['id'],
          'fecha': result['fecha'],
          'pieza_dental': result['pieza_dental'],
          'tratamiento': result['tratamiento'],
          'nro_presupuesto': result['nro_presupuesto'] ?? '',
          'firmado': false,
          'observaciones': '',
          'orden': _entradas.length,
        });
        _cargarEntradas();
        _mostrarExito('Entrada agregada correctamente');
        widget.onActualizar();
      } catch (e) {
        _mostrarError('Error al agregar entrada: $e');
      }
    }
  }

  Future<void> _eliminarEntrada(String entradaId) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('¿Seguro que deseas eliminar esta entrada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _apiService.deleteEntradaSeguimiento(entradaId);
        _cargarEntradas();
        _mostrarExito('Entrada eliminada');
        widget.onActualizar();
      } catch (e) {
        _mostrarError('Error al eliminar: $e');
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Encabezado
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.teal[50],
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estudiante: ${widget.seguimiento['estudiante_nombre'] ?? 'Sin nombre'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Paciente: ${widget.seguimiento['paciente_nombre'] ?? 'Sin nombre'} - CI: ${widget.seguimiento['paciente_ci'] ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Total entradas: ${widget.seguimiento['total_entradas'] ?? 0} | ' +
                          'Firmadas: ${widget.seguimiento['entradas_firmadas'] ?? 0} | ' +
                          'Pendientes: ${widget.seguimiento['entradas_pendientes'] ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.modoSoloLectura)
                ElevatedButton.icon(
                  onPressed: _agregarEntrada,
                  icon: Icon(Icons.add),
                  label: Text('Nueva Entrada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),

        // Tabla de entradas
        Expanded(
          child: _cargando
              ? Center(child: CircularProgressIndicator())
              : _entradas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.note_add_outlined,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay entradas registradas',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Haz clic en "Nueva Entrada" para agregar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Fecha')),
                            DataColumn(label: Text('Pieza')),
                            DataColumn(label: Text('Tratamiento')),
                            DataColumn(label: Text('Presupuesto')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Observaciones')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: _entradas.map<DataRow>((entrada) {
                            final firmado = entrada['firmado'] == true;
                            final fecha = entrada['fecha'] ?? '';
                            return DataRow(
                              cells: [
                                DataCell(Text(fecha)),
                                DataCell(Text(entrada['pieza_dental'] ?? '')),
                                DataCell(
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 300),
                                    child: Text(
                                      entrada['tratamiento'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                DataCell(
                                    Text(entrada['nro_presupuesto'] ?? '-')),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        firmado
                                            ? Icons.check_circle
                                            : Icons.schedule,
                                        color: firmado
                                            ? Colors.green
                                            : Colors.orange,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        firmado ? 'Firmado' : 'Pendiente',
                                        style: TextStyle(
                                          color: firmado
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    entrada['observaciones'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!firmado && !widget.modoSoloLectura)
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _eliminarEntrada(
                                              entrada['id'].toString()),
                                          tooltip: 'Eliminar',
                                        ),
                                      if (firmado)
                                        Tooltip(
                                          message:
                                              'Firmado por: ${entrada['firmado_por_nombre'] ?? 'Desconocido'}',
                                          child: Icon(Icons.info_outline,
                                              color: Colors.blue),
                                        ),
                                      if (widget.modoSoloLectura && !firmado)
                                        Tooltip(
                                          message: 'Puedes firmar esta entrada',
                                          child: Icon(Icons.edit_note,
                                              color: Colors.orange),
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
      ],
    );
  }
}

class _FormularioEntradaDialog extends StatefulWidget {
  @override
  State<_FormularioEntradaDialog> createState() =>
      _FormularioEntradaDialogState();
}

class _FormularioEntradaDialogState extends State<_FormularioEntradaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _piezaController = TextEditingController();
  final _tratamientoController = TextEditingController();
  final _presupuestoController = TextEditingController();
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(fecha);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nueva Entrada de Tratamiento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _seleccionarFecha,
                  ),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _piezaController,
                decoration: InputDecoration(
                  labelText: 'Pieza Dental',
                  hintText: 'Ej: 1.6, 3.2',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _tratamientoController,
                decoration: InputDecoration(
                  labelText: 'Tratamiento',
                  hintText: 'Descripción del tratamiento realizado',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _presupuestoController,
                decoration: InputDecoration(
                  labelText: 'Nro. Presupuesto (opcional)',
                  hintText: 'Ej: P-001',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'fecha': _fechaController.text,
                'pieza_dental': _piezaController.text,
                'tratamiento': _tratamientoController.text,
                'nro_presupuesto': _presupuestoController.text,
              });
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: Text('Guardar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _piezaController.dispose();
    _tratamientoController.dispose();
    _presupuestoController.dispose();
    super.dispose();
  }
}
