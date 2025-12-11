import 'package:flutter/material.dart';

class ExamenDentalWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const ExamenDentalWidget({
    Key? key,
    required this.data,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<ExamenDentalWidget> createState() => _ExamenDentalWidgetState();
}

class _ExamenDentalWidgetState extends State<ExamenDentalWidget> {
  // Datos del odontograma: estructura por diente con símbolos
  Map<String, dynamic> _odontogramaData = {};
  
  // Condiciones dentales con sus colores/símbolos
  final Map<String, Map<String, dynamic>> _condiciones = {
    'caries': {'nombre': 'Caries', 'color': Colors.red, 'simbolo': ''},
    'resina': {'nombre': 'Obturación Resina', 'color': Colors.green, 'simbolo': ''},
    'amalgama': {'nombre': 'Obturación Amalgama', 'color': Colors.blue, 'simbolo': 'X'},
    'calculo': {'nombre': 'Cálculo', 'color': Colors.blue, 'simbolo': '-'},
    'extraer': {'nombre': 'Por Extraer', 'color': Colors.red, 'simbolo': 'X'},
    'corona': {'nombre': 'Corona', 'color': Colors.black, 'simbolo': ''},
    'ausente': {'nombre': 'Ausente', 'color': Colors.red, 'simbolo': 'O'},
  };

  // Numeración FDI de dientes
  final List<int> _dientesSuperiores = [18, 17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27, 28];
  final List<int> _dientesInferiores = [48, 47, 46, 45, 44, 43, 42, 41, 31, 32, 33, 34, 35, 36, 37, 38];

  @override
  void initState() {
    super.initState();
    _odontogramaData = Map<String, dynamic>.from(widget.data['odontograma'] ?? {});
    _inicializarDientes();
  }

  void _inicializarDientes() {
    // Inicializar estructura de datos si no existe
    for (var diente in [..._dientesSuperiores, ..._dientesInferiores]) {
      if (!_odontogramaData.containsKey(diente.toString())) {
        _odontogramaData[diente.toString()] = {
          'simbolos': [], // Lista de símbolos aplicados
        };
      }
    }
  }

  void _agregarSimbolo(int diente, String condicion) {
    setState(() {
      if (!_odontogramaData.containsKey(diente.toString())) {
        _odontogramaData[diente.toString()] = {'simbolos': []};
      }
      
      final simbolos = _odontogramaData[diente.toString()]['simbolos'] as List;
      
      // Si ya existe ese símbolo, no agregarlo de nuevo
      if (!simbolos.contains(condicion)) {
        simbolos.add(condicion);
      }

      widget.onDataChanged({
        ...widget.data,
        'odontograma': _odontogramaData,
      });
    });
  }

  void _removerSimbolo(int diente, String condicion) {
    setState(() {
      if (_odontogramaData.containsKey(diente.toString())) {
        final simbolos = _odontogramaData[diente.toString()]['simbolos'] as List;
        simbolos.remove(condicion);
        
        widget.onDataChanged({
          ...widget.data,
          'odontograma': _odontogramaData,
        });
      }
    });
  }

  Widget _buildLeyenda() {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Arrastra los símbolos sobre los dientes para marcarlos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Leyenda de Condiciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: _condiciones.entries.map((entry) {
                return _buildItemDraggable(entry.key, entry.value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDraggable(String key, Map<String, dynamic> condicion) {
    return Draggable<String>(
      data: key,
      feedback: Material(
        elevation: 6,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: condicion['color'].withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                condicion['simbolo'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                condicion['nombre'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildItemCondicion(condicion),
      ),
      child: _buildItemCondicion(condicion),
    );
  }

  Widget _buildItemCondicion(Map<String, dynamic> condicion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: condicion['color'], width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: condicion['color'],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                condicion['simbolo'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            condicion['nombre'],
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOdontograma() {
    return Column(
      children: [
        // Arcada superior
        _buildArcada('superior', _dientesSuperiores),
        const SizedBox(height: 40),
        // Arcada inferior
        _buildArcada('inferior', _dientesInferiores),
      ],
    );
  }

  Widget _buildArcada(String tipo, List<int> dientes) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              tipo == 'superior' ? 'DIENTES SUPERIORES' : 'DIENTES INFERIORES',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            
            // Contenedor con imagen de fondo del odontograma
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Área de la imagen del odontograma con DragTarget
                  AspectRatio(
                    aspectRatio: 16 / 6, // Proporción ajustable según tu imagen
                    child: Stack(
                      children: [
                        // Placeholder mientras no hay imagen
                        Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Text(
                              'Imagen odontograma $tipo\n(Agrega: assets/images/odontograma_$tipo.png)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ),
                        ),
                        
                        // Grid de DragTargets sobre los dientes
                        Positioned.fill(
                          child: Row(
                            children: dientes.map((diente) {
                              return Expanded(
                                child: _buildDienteTarget(diente),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Casillas con registro de símbolos por diente
                  _buildCasillasDientes(dientes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDienteTarget(int diente) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) {
        _agregarSimbolo(diente, data.data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Condición aplicada al diente $diente',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isHovering 
                ? Colors.blue.withOpacity(0.2) 
                : Colors.transparent,
            border: Border.all(
              color: isHovering ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  diente.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isHovering ? Colors.blue.shade900 : Colors.grey.shade600,
                  ),
                ),
                // Mostrar símbolos actuales
                if (_odontogramaData[diente.toString()]?['simbolos'] != null)
                  ..._buildSimbolosDiente(diente),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSimbolosDiente(int diente) {
    final simbolos = _odontogramaData[diente.toString()]?['simbolos'] as List? ?? [];
    
    return simbolos.map<Widget>((condicionKey) {
      final condicion = _condiciones[condicionKey];
      if (condicion == null) return SizedBox.shrink();
      
      return Text(
        condicion['simbolo'],
        style: TextStyle(
          color: condicion['color'],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Widget _buildCasillasDientes(List<int> dientes) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: dientes.map((diente) {
          return Expanded(
            child: _buildCasillaDiente(diente),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCasillaDiente(int diente) {
    final simbolos = _odontogramaData[diente.toString()]?['simbolos'] as List? ?? [];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      constraints: BoxConstraints(minHeight: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            diente.toString(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          if (simbolos.isEmpty)
            Text(
              '-',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            )
          else
            Wrap(
              spacing: 2,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: simbolos.map<Widget>((condicionKey) {
                final condicion = _condiciones[condicionKey];
                if (condicion == null) return SizedBox.shrink();
                
                return GestureDetector(
                  onTap: () => _removerSimbolo(diente, condicionKey),
                  child: Tooltip(
                    message: 'Clic para eliminar: ${condicion['nombre']}',
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: condicion['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        condicion['simbolo'],
                        style: TextStyle(
                          color: condicion['color'],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeyenda(),
          const SizedBox(height: 24),
          _buildOdontograma(),
        ],
      ),
    );
  }
}
