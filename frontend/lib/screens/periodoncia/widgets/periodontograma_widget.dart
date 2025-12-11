import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget del Periodontograma Vestibular
/// Muestra los dientes con campos para ingresar mediciones y gráficos dinámicos
class PeriodontogramaWidget extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool readOnly;
  final String titulo;

  const PeriodontogramaWidget({
    Key? key,
    required this.initialData,
    required this.onDataChanged,
    this.readOnly = false,
    this.titulo = 'PERIODONTOGRAMA PERIODONCIA VESTIBULAR',
  }) : super(key: key);

  @override
  State<PeriodontogramaWidget> createState() => _PeriodontogramaWidgetState();
}

class _PeriodontogramaWidgetState extends State<PeriodontogramaWidget> {
  late Map<String, dynamic> _data;

  // Números de dientes por arcada
  final List<int> dientesSuperiores = [
    18,
    17,
    16,
    15,
    14,
    13,
    12,
    11,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28
  ];
  final List<int> dientesInferiores = [
    48,
    47,
    46,
    45,
    44,
    43,
    42,
    41,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38
  ];

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.initialData);
    _initializeData();
  }

  void _initializeData() {
    // Inicializar estructura de datos si está vacía
    if (!_data.containsKey('vestibular')) {
      _data['vestibular'] = {
        'superiores': {},
        'inferiores': {},
      };
    }

    // Inicializar cada diente con todos los campos necesarios
    for (var diente in dientesSuperiores) {
      _data['vestibular']['superiores'][diente.toString()] ??= {
        'profundidad_surco': [
          '',
          '',
          ''
        ], // Prof. de Surco: Mesial, Central, Distal
        'nivel_insercion': [
          '',
          '',
          ''
        ], // Nv. de Inserción: Mesial, Central, Distal
        'margen_gingival': [
          '',
          '',
          ''
        ], // Posición Encía/Margen: Mesial, Central, Distal
        'anchura_encia': '', // Anchura de encía queratinizada
        'sangrado': [
          false,
          false,
          false
        ], // Sangrado al sondaje: Mesial, Central, Distal
        'supuracion': [
          false,
          false,
          false
        ], // Supuración: Mesial, Central, Distal
        'placa': false, // Placa bacteriana (por diente)
        'movilidad': '', // Movilidad dentaria (0, 1, 2, 3)
        'furca': '', // Compromiso de furcación (I, II, III)
        'ausente': false,
      };
    }

    for (var diente in dientesInferiores) {
      _data['vestibular']['inferiores'][diente.toString()] ??= {
        'profundidad_surco': [
          '',
          '',
          ''
        ], // Prof. de Surco: Mesial, Central, Distal
        'nivel_insercion': [
          '',
          '',
          ''
        ], // Nv. de Inserción: Mesial, Central, Distal
        'margen_gingival': [
          '',
          '',
          ''
        ], // Posición Encía/Margen: Mesial, Central, Distal
        'anchura_encia': '', // Anchura de encía queratinizada
        'sangrado': [
          false,
          false,
          false
        ], // Sangrado al sondaje: Mesial, Central, Distal
        'supuracion': [
          false,
          false,
          false
        ], // Supuración: Mesial, Central, Distal
        'placa': false, // Placa bacteriana (por diente)
        'movilidad': '', // Movilidad dentaria (0, 1, 2, 3)
        'furca': '', // Compromiso de furcación (I, II, III)
        'ausente': false,
      };
    }
  }

  void _updateData() {
    widget.onDataChanged(_data);
  }

  void _updateMeasurement(
      String arcada, String diente, String tipo, int index, String value) {
    setState(() {
      _data['vestibular'][arcada][diente][tipo][index] = value;
      _updateData();
    });
  }

  void _updateSimpleField(
      String arcada, String diente, String campo, String value) {
    setState(() {
      _data['vestibular'][arcada][diente][campo] = value;
      _updateData();
    });
  }

  void _toggleBoolean(String arcada, String diente, String campo) {
    setState(() {
      _data['vestibular'][arcada][diente][campo] =
          !(_data['vestibular'][arcada][diente][campo] ?? false);
      _updateData();
    });
  }

  void _toggleIndicador(String arcada, String diente, String tipo, int index) {
    setState(() {
      _data['vestibular'][arcada][diente][tipo][index] =
          !(_data['vestibular'][arcada][diente][tipo][index] ?? false);
      _updateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.titulo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 24),

          // Arcada Superior
          _buildArcada(
            arcada: 'superiores',
            dientes: dientesSuperiores,
            titulo: 'SUPERIOR',
            invertido: false,
          ),

          SizedBox(height: 40),

          // Línea divisoria
          Divider(thickness: 2, color: Colors.grey[400]),

          SizedBox(height: 40),

          // Arcada Inferior
          _buildArcada(
            arcada: 'inferiores',
            dientes: dientesInferiores,
            titulo: 'INFERIOR',
            invertido: true,
          ),

          SizedBox(height: 24),

          // Leyenda
          _buildLeyenda(),
        ],
      ),
    );
  }

  Widget _buildArcada({
    required String arcada,
    required List<int> dientes,
    required String titulo,
    required bool invertido,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),

        // Contenedor scrollable horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 979.0, // 80px (labels) + 899px (SVG)
            child: Column(
              children: [
                // Campos superiores o inferiores según invertido
                if (!invertido) _buildCamposSuperiorConLabels(arcada, dientes),

                // Dientes con imagen SVG completa + mediciones superpuestas
                Row(
                  children: [
                    SizedBox(width: 80), // Espacio para alinear con labels
                    _buildArcadaCompleta(
                      arcada: arcada,
                      dientes: dientes,
                      invertido: invertido,
                    ),
                  ],
                ),

                // Campos inferiores o superiores según invertido
                if (invertido) _buildCamposInferiorConLabels(arcada, dientes),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArcadaCompleta({
    required String arcada,
    required List<int> dientes,
    required bool invertido,
  }) {
    // Dimensiones reales del SVG
    final double anchoTotal = 899.0; // Ancho real del SVG
    final double alturaTotal = 171.0; // Altura real del SVG

    // Definir posiciones X aproximadas para cada diente (en píxeles del SVG)
    // Basado en análisis visual del SVG, distribución uniforme
    final posicionesX = _calcularPosicionesDientes(dientes);

    // Posición Y fija del CEJ (línea roja del margen gingival)
    // Para el SVG de 171px de altura
    final double cejY = arcada == 'superiores'
        ? alturaTotal * 0.65 // Superior: aproximadamente a 120px (70% de 171)
        : alturaTotal * 0.35; // Inferior: aproximadamente a 60px (35% de 171)

    return Container(
      width: anchoTotal,
      height: alturaTotal,
      child: Stack(
        children: [
          // Imagen completa de la arcada
          if (arcada == 'superiores')
            SvgPicture.asset(
              'assets/teeth/superior.svg',
              width: anchoTotal,
              height: alturaTotal,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            )
          else
            SvgPicture.asset(
              'assets/teeth/inferior.svg',
              width: anchoTotal,
              height: alturaTotal,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),

          // Mediciones superpuestas para todos los dientes
          Positioned.fill(
            child: CustomPaint(
              size: Size(anchoTotal, alturaTotal),
              painter: MedicionCompletaPainter(
                data: Map<String, dynamic>.from(
                    _data['vestibular'][arcada] as Map),
                dientes: dientes,
                posicionesX: posicionesX,
                cejY: cejY,
                invertido: invertido,
                ancho: anchoTotal,
                alto: alturaTotal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, double> _calcularPosicionesDientes(List<int> dientes) {
    // Distribuir uniformemente como las casillas (899px / 16 dientes)
    // Esto hace que la línea se alinee perfectamente con las columnas de casillas
    final Map<int, double> posiciones = <int, double>{};
    final double anchoTotal = 899.0;
    final double anchoPorDiente = anchoTotal / dientes.length; // 56.1875px

    for (int i = 0; i < dientes.length; i++) {
      final diente = dientes[i];
      // Centro de cada diente: mitad de su espacio
      posiciones[diente] = (i * anchoPorDiente) + (anchoPorDiente / 2);
    }

    return posiciones;
  }

  Widget _buildCamposSuperiorConLabels(String arcada, List<int> dientes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Números de dientes
        _buildFilaNumerosDientes(dientes),
        // Sangrado
        _buildFilaSangradoConLabel('Sangrado', arcada, dientes),
        // Supuración
        _buildFilaSupuracionConLabel('Supuración', arcada, dientes),
        // Margen Gingival
        _buildFilaConLabel('Marg. Ging.', arcada, dientes, 'margen_gingival'),
        // Profundidad Surco
        _buildFilaConLabel('Prof. Surco', arcada, dientes, 'profundidad_surco'),
        // Nivel Inserción (calculado automáticamente)
        _buildFilaNivelInsercionConLabel('Nivel Ins.', arcada, dientes),
        // Furca
        _buildFilaFurcaConLabel('Furca', arcada, dientes),
        // Movilidad
        _buildFilaMovilidadConLabel('Movilidad', arcada, dientes),
      ],
    );
  }

  Widget _buildCamposInferiorConLabels(String arcada, List<int> dientes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Movilidad
        _buildFilaMovilidadConLabel('Movilidad', arcada, dientes),
        // Furca
        _buildFilaFurcaConLabel('Furca', arcada, dientes),
        // Nivel Inserción (calculado automáticamente)
        _buildFilaNivelInsercionConLabel('Nivel Ins.', arcada, dientes),
        // Profundidad Surco
        _buildFilaConLabel('Prof. Surco', arcada, dientes, 'profundidad_surco'),
        // Margen Gingival
        _buildFilaConLabel('Marg. Ging.', arcada, dientes, 'margen_gingival'),
        // Supuración
        _buildFilaSupuracionConLabel('Supuración', arcada, dientes),
        // Sangrado
        _buildFilaSangradoConLabel('Sangrado', arcada, dientes),
        // Números de dientes
        _buildFilaNumerosDientes(dientes),
      ],
    );
  }

  Widget _buildFilaNumerosDientes(List<int> dientes) {
    return Row(
      children: [
        SizedBox(width: 80), // Espacio para label
        ...dientes
            .map((diente) => Container(
                  width: 56.1875,
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    diente.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildFilaConLabel(
      String label, String arcada, List<int> dientes, String tipo) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        ...dientes.map((diente) {
          final dienteData = _data['vestibular'][arcada][diente.toString()];
          final ausente = dienteData['ausente'] ?? false;
          final valores = List<String>.from(dienteData[tipo]);
          return Container(
            width: 56.1875,
            child: _buildCamposMedicion(
                arcada, diente.toString(), tipo, valores, ausente),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFilaNivelInsercionConLabel(
      String label, String arcada, List<int> dientes) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        ...dientes.map((diente) {
          final dienteData = _data['vestibular'][arcada][diente.toString()];
          final ausente = dienteData['ausente'] ?? false;
          final margenGingival =
              List<String>.from(dienteData['margen_gingival']);
          final profundidadSurco =
              List<String>.from(dienteData['profundidad_surco']);
          final nivelInsercion =
              List<String>.from(dienteData['nivel_insercion']);

          return Container(
            width: 56.1875,
            child: _buildCamposNivelInsercion(arcada, diente.toString(),
                margenGingival, profundidadSurco, nivelInsercion, ausente),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFilaSangradoConLabel(
      String label, String arcada, List<int> dientes) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        ...dientes.map((diente) {
          final dienteData = _data['vestibular'][arcada][diente.toString()];
          final ausente = dienteData['ausente'] ?? false;
          final sangrado = List<bool>.from(dienteData['sangrado']);
          return Container(
            width: 56.1875,
            child:
                _buildSangradoRow(arcada, diente.toString(), sangrado, ausente),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFilaSupuracionConLabel(
      String label, String arcada, List<int> dientes) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        ...dientes.map((diente) {
          final dienteData = _data['vestibular'][arcada][diente.toString()];
          final ausente = dienteData['ausente'] ?? false;
          final supuracion = List<bool>.from(dienteData['supuracion']);
          return Container(
            width: 56.1875,
            child: _buildSupuracionRow(
                arcada, diente.toString(), supuracion, ausente),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFilaFurcaConLabel(
      String label, String arcada, List<int> dientes) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        ...dientes.map((diente) {
          final dienteData = _data['vestibular'][arcada][diente.toString()];
          final ausente = dienteData['ausente'] ?? false;
          final furca = dienteData['furca'] ?? '';
          return Container(
            width: 56.1875,
            padding: EdgeInsets.symmetric(vertical: 2),
            child:
                _buildFurcaSelector(arcada, diente.toString(), furca, ausente),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFilaMovilidadConLabel(
      String label, String arcada, List<int> dientes) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        ...dientes.map((diente) {
          final dienteData = _data['vestibular'][arcada][diente.toString()];
          final ausente = dienteData['ausente'] ?? false;
          final movilidad = dienteData['movilidad'] ?? '';
          return Container(
            width: 56.1875,
            padding: EdgeInsets.symmetric(vertical: 2),
            child: _buildMovilidadSelector(
                arcada, diente.toString(), movilidad, ausente),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCamposNivelInsercion(
    String arcada,
    String diente,
    List<String> margenGingival,
    List<String> profundidadSurco,
    List<String> nivelInsercion,
    bool ausente,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          // Calcular valor automáticamente
          final margen = double.tryParse(margenGingival[index]) ?? 0.0;
          final profund = double.tryParse(profundidadSurco[index]) ?? 0.0;
          final calculado = (margen + profund).toStringAsFixed(0);

          // Usar valor calculado si el campo está vacío, sino usar el ingresado manualmente
          final valorMostrado =
              nivelInsercion[index].isEmpty ? calculado : nivelInsercion[index];

          return Container(
            width: 17,
            height: 24,
            child: TextField(
              enabled: !widget.readOnly && !ausente,
              controller: TextEditingController(text: valorMostrado),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: _getColorForValue(valorMostrado),
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
                filled: true,
                fillColor: ausente
                    ? Colors.grey[100]
                    : Colors.grey[
                        50], // Fondo gris claro para indicar que es calculado
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d{0,2}$')),
              ],
              onChanged: (value) {
                // Permitir edición manual pero actualizar el campo
                _updateMeasurement(
                    arcada, diente, 'nivel_insercion', index, value);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCamposMedicion(
    String arcada,
    String diente,
    String tipo,
    List<String> valores,
    bool ausente,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return Container(
            width: 17, // Ajustado para caber en 56.1875px
            height: 24,
            child: TextField(
              enabled: !widget.readOnly && !ausente,
              controller: TextEditingController(text: valores[index]),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: _getColorForValue(valores[index]),
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
                filled: true,
                fillColor: ausente ? Colors.grey[100] : Colors.white,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d{0,2}$')),
              ],
              onChanged: (value) {
                _updateMeasurement(arcada, diente, tipo, index, value);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCampoSimple(
    String arcada,
    String diente,
    String campo,
    bool ausente,
  ) {
    final data = _data['vestibular']?[arcada]?[diente] ?? {};
    final valor = data[campo]?.toString() ?? '';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Container(
        width: 54, // Ajustado para caber en 56.1875px
        height: 22,
        child: TextField(
          enabled: !widget.readOnly && !ausente,
          controller: TextEditingController(text: valor),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1),
            ),
            filled: true,
            fillColor: ausente ? Colors.grey[100] : Colors.white,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateSimpleField(arcada, diente, campo, value);
          },
        ),
      ),
    );
  }

  Widget _buildSangradoRow(
    String arcada,
    String diente,
    List<bool> sangrado,
    bool ausente,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sangrado (3 círculos rojos)
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: widget.readOnly || ausente
                    ? null
                    : () => _toggleIndicador(arcada, diente, 'sangrado', index),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: sangrado[index] ? Colors.red : Colors.white,
                    border: Border.all(color: Colors.grey[400]!, width: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSupuracionRow(
    String arcada,
    String diente,
    List<bool> supuracion,
    bool ausente,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Supuración (3 círculos amarillos)
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: widget.readOnly || ausente
                    ? null
                    : () =>
                        _toggleIndicador(arcada, diente, 'supuracion', index),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        supuracion[index] ? Colors.yellow[700] : Colors.white,
                    border: Border.all(color: Colors.grey[400]!, width: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFurcaSelector(
    String arcada,
    String diente,
    String furca,
    bool ausente,
  ) {
    final opciones = ['', 'I', 'II', 'III'];
    final colores = [
      Colors.grey[300]!, // Sin furca (vacío)
      Colors.green[300]!, // Grado I (leve)
      Colors.orange[400]!, // Grado II (moderado)
      Colors.red[400]!, // Grado III (severo)
    ];

    return PopupMenuButton<String>(
      enabled: !widget.readOnly && !ausente,
      initialValue: furca,
      offset: Offset(0, 30),
      child: Container(
        decoration: BoxDecoration(
          color: ausente
              ? Colors.grey[100]
              : colores[opciones.indexOf(furca.isEmpty ? '' : furca)],
          border: Border.all(color: Colors.grey[400]!, width: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            furca.isEmpty ? '○' : furca,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: furca.isEmpty ? Colors.grey[600] : Colors.white,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => opciones.map((opcion) {
        final index = opciones.indexOf(opcion);
        return PopupMenuItem<String>(
          value: opcion,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colores[index],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Center(
                  child: Text(
                    opcion.isEmpty ? '○' : opcion,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: opcion.isEmpty ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                opcion.isEmpty
                    ? 'Sin furca'
                    : 'Grado $opcion (${index == 1 ? 'Leve' : index == 2 ? 'Moderado' : 'Severo'})',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: (value) {
        _updateSimpleField(arcada, diente, 'furca', value);
      },
    );
  }

  Widget _buildMovilidadSelector(
    String arcada,
    String diente,
    String movilidad,
    bool ausente,
  ) {
    final opciones = ['0', '1', '2', '3'];
    final colores = [
      Colors.green[300]!, // Grado 0 (normal)
      Colors.blue[300]!, // Grado 1 (leve)
      Colors.orange[400]!, // Grado 2 (moderado)
      Colors.red[400]!, // Grado 3 (severo)
    ];

    final textos = [
      'Normal',
      'Leve (<1mm)',
      'Moderado (>1mm)',
      'Severo (vertical)',
    ];

    final indexActual = movilidad.isEmpty ? 0 : int.tryParse(movilidad) ?? 0;

    return PopupMenuButton<String>(
      enabled: !widget.readOnly && !ausente,
      initialValue: movilidad.isEmpty ? '0' : movilidad,
      offset: Offset(0, 30),
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          color: ausente ? Colors.grey[100] : colores[indexActual],
          border: Border.all(color: Colors.grey[400]!, width: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            movilidad.isEmpty ? '0' : movilidad,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => opciones.map((opcion) {
        final index = int.parse(opcion);
        return PopupMenuItem<String>(
          value: opcion,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colores[index],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Center(
                  child: Text(
                    opcion,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Grado $opcion: ${textos[index]}',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: (value) {
        _updateSimpleField(arcada, diente, 'movilidad', value);
      },
    );
  }

  Widget _buildLeyenda() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEYENDA',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blue[900]),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _buildLeyendaItem(Colors.red, 'Línea Roja: Margen Gingival'),
              _buildLeyendaItem(Colors.blue, 'Línea Azul: Nivel Inserción'),
              _buildLeyendaIndicador(Colors.blue.withOpacity(0.3), 'square',
                  'Área: Bolsa Periodontal'),
              _buildLeyendaIndicador(Colors.red, 'circle', 'Sangrado'),
              _buildLeyendaIndicador(
                  Colors.yellow[700]!, 'circle', 'Supuración'),
              _buildLeyendaIndicador(Colors.red, 'square', 'Placa'),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Fórmula: Nivel Inserción = Prof. Sondaje - Margen Gingival',
            style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            '• Campos: Nivel Inserción, Prof. Sondaje, Margen Gingival, Anchura Encía, Placa/Sangrado/Supuración, Furca/Movilidad',
            style: TextStyle(fontSize: 9, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            '• Mantén presionado un diente para marcarlo como ausente',
            style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildLeyendaItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildLeyendaIndicador(Color color, String shape, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: shape == 'square' ? BorderRadius.circular(2) : null,
            border: Border.all(color: Colors.grey[400]!, width: 0.5),
          ),
        ),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Color _getColorForValue(String value) {
    if (value.isEmpty) return Colors.black;
    final intValue = int.tryParse(value) ?? 0;
    if (intValue <= 3) return Colors.blue;
    if (intValue <= 5) return Colors.orange;
    return Colors.red;
  }
}

/// Painter personalizado para dibujar el diente con gráficos dinámicos
// Painter que dibuja margen gingival (línea roja), nivel inserción (línea azul) y bolsas
class MedicionPainter extends CustomPainter {
  final List<String> profundidad;
  final List<String> margenGingival;
  final List<String> nivelInsercion;
  final bool invertido;
  final List<bool> sangrado;
  final List<bool> supuracion;
  final double
      cejProporcion; // Proporción Y del CEJ en el SVG (ej: 18/55 = 0.327)

  MedicionPainter({
    required this.profundidad,
    required this.margenGingival,
    required this.nivelInsercion,
    required this.invertido,
    required this.sangrado,
    required this.supuracion,
    required this.cejProporcion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar margen gingival (línea roja), nivel inserción (línea azul) y bolsas
    _drawPeriodontograma(canvas, size);

    // Dibujar indicadores de sangrado/supuración
    _drawIndicadores(canvas, size);
  }

  void _drawPeriodontograma(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final xPositions = [w * 0.25, w * 0.5, w * 0.75]; // Mesial, Central, Distal

    // Convertir valores a números
    final valoresMargen = margenGingival.map((v) {
      return v.isEmpty ? 0.0 : (double.tryParse(v) ?? 0.0);
    }).toList();

    final valoresProfundidad = profundidad.map((v) {
      return v.isEmpty ? 0.0 : (double.tryParse(v) ?? 0.0);
    }).toList();

    // PASO 1: Dibujar grid de fondo (líneas horizontales grises finas)
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke;

    // Línea base del diente (CEJ - línea amelocementaria)
    // Usa la proporción exacta del CEJ en el SVG correspondiente
    final lineaCEJ = h * cejProporcion;

    // Dibujar líneas horizontales del grid (cada mm)
    final mmScale = 2.5; // Cada mm = 2.5 pixels
    for (int i = -5; i <= 12; i++) {
      final y = invertido ? lineaCEJ - (i * mmScale) : lineaCEJ + (i * mmScale);

      if (y >= 0 && y <= h) {
        canvas.drawLine(
          Offset(0, y),
          Offset(w, y),
          gridPaint,
        );
      }
    }

    // Calcular puntos para margen gingival y nivel de inserción
    final puntosMargen = <Offset>[];
    final puntosNivel = <Offset>[];
    bool hayDatos = false;

    for (int i = 0; i < 3; i++) {
      final x = xPositions[i];
      final margen = valoresMargen[i];
      final profund = valoresProfundidad[i];

      // Margen gingival: distancia desde CEJ
      // Positivo = apical al CEJ (encía retraída)
      // Negativo = coronal al CEJ (encía sobre el diente)
      final margenY = invertido
          ? lineaCEJ + (margen * mmScale)
          : lineaCEJ - (margen * mmScale);

      // Nivel de inserción = Margen + Profundidad
      // Es la distancia total desde CEJ hasta el fondo de la bolsa
      final nivel = margen + profund;
      final nivelY = invertido
          ? lineaCEJ + (nivel * mmScale)
          : lineaCEJ - (nivel * mmScale);

      puntosMargen.add(Offset(x, margenY));
      puntosNivel.add(Offset(x, nivelY));

      if (profund > 0 || margen != 0) {
        hayDatos = true;
      }
    }

    // PASO 2: Dibujar área sombreada (POCKET) entre margen y nivel de inserción
    if (hayDatos) {
      final pocketPaint = Paint()
        ..color = Colors.purple.withOpacity(0.15)
        ..style = PaintingStyle.fill;

      final pocketPath = Path();

      // Comenzar en el primer punto del margen
      pocketPath.moveTo(puntosMargen[0].dx, puntosMargen[0].dy);

      // Dibujar línea del margen gingival
      pocketPath.lineTo(puntosMargen[1].dx, puntosMargen[1].dy);
      pocketPath.lineTo(puntosMargen[2].dx, puntosMargen[2].dy);

      // Conectar al último punto del nivel
      pocketPath.lineTo(puntosNivel[2].dx, puntosNivel[2].dy);

      // Dibujar línea del nivel de inserción en reversa
      pocketPath.lineTo(puntosNivel[1].dx, puntosNivel[1].dy);
      pocketPath.lineTo(puntosNivel[0].dx, puntosNivel[0].dy);

      // Cerrar el path
      pocketPath.close();
      canvas.drawPath(pocketPath, pocketPaint);
    }

    // PASO 3: Dibujar línea ROJA (GINGIVAL MARGIN) - siempre visible
    final lineaRojaPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Si no hay datos, dibujar línea horizontal en el CEJ
    if (!hayDatos) {
      canvas.drawLine(
        Offset(0, lineaCEJ),
        Offset(w, lineaCEJ),
        lineaRojaPaint,
      );
    } else {
      // Dibujar línea que conecta los puntos del margen gingival
      final margenPath = Path();
      margenPath.moveTo(puntosMargen[0].dx, puntosMargen[0].dy);
      margenPath.lineTo(puntosMargen[1].dx, puntosMargen[1].dy);
      margenPath.lineTo(puntosMargen[2].dx, puntosMargen[2].dy);
      canvas.drawPath(margenPath, lineaRojaPaint);
    }

    // PASO 4: Dibujar línea NEGRA (ATTACHMENT LEVEL / NIVEL DE INSERCIÓN)
    if (hayDatos) {
      final lineaNegraPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final nivelPath = Path();
      nivelPath.moveTo(puntosNivel[0].dx, puntosNivel[0].dy);
      nivelPath.lineTo(puntosNivel[1].dx, puntosNivel[1].dy);
      nivelPath.lineTo(puntosNivel[2].dx, puntosNivel[2].dy);
      canvas.drawPath(nivelPath, lineaNegraPaint);

      // Dibujar puntos en cada medición
      final puntoPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      for (var punto in puntosNivel) {
        canvas.drawCircle(punto, 2.0, puntoPaint);
      }
    }
  }

  void _drawIndicadores(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final xPositions = [w * 0.25, w * 0.5, w * 0.75];

    for (int i = 0; i < 3; i++) {
      final x = xPositions[i];
      final y = invertido ? h * 0.92 : h * 0.05;

      // Sangrado (círculo rojo pequeño)
      if (sangrado[i]) {
        final paint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 2.5, paint);
      }

      // Supuración (círculo amarillo pequeño debajo)
      if (supuracion[i]) {
        final paint = Paint()
          ..color = Colors.amber[700]!
          ..style = PaintingStyle.fill;
        final yOffset = invertido ? y - 6 : y + 6;
        canvas.drawCircle(Offset(x, yOffset), 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(MedicionPainter oldDelegate) {
    return profundidad != oldDelegate.profundidad ||
        margenGingival != oldDelegate.margenGingival ||
        nivelInsercion != oldDelegate.nivelInsercion ||
        sangrado != oldDelegate.sangrado ||
        supuracion != oldDelegate.supuracion ||
        invertido != oldDelegate.invertido ||
        cejProporcion != oldDelegate.cejProporcion;
  }
}

/// Painter que dibuja las mediciones sobre toda la arcada completa
class MedicionCompletaPainter extends CustomPainter {
  final Map<String, dynamic> data;
  final List<int> dientes;
  final Map<int, double> posicionesX;
  final double cejY;
  final bool invertido;
  final double ancho;
  final double alto;

  MedicionCompletaPainter({
    required this.data,
    required this.dientes,
    required this.posicionesX,
    required this.cejY,
    required this.invertido,
    required this.ancho,
    required this.alto,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mmScale = 2.5 * 1.2; // Escala ajustada para 1.2x

    // Dibujar grid de fondo
    _drawGrid(canvas, size);

    // Recolectar TODOS los puntos de TODOS los dientes para crear polilíneas continuas
    final List<Offset> todosLosPuntosMargen = [];
    final List<Offset> todosLosPuntosNivel = [];
    final List<Map<String, dynamic>> todosLosIndicadores = [];

    for (final diente in dientes) {
      final dienteData = data[diente.toString()];
      if (dienteData == null) continue;

      final ausente = dienteData['ausente'] ?? false;

      final profundidadSurco =
          List<String>.from(dienteData['profundidad_surco']);
      final margenGingival = List<String>.from(dienteData['margen_gingival']);
      final sangrado = List<bool>.from(dienteData['sangrado']);
      final supuracion = List<bool>.from(dienteData['supuracion']);

      // POSICIONES ABSOLUTAS EN PÍXELES DESDE LA IZQUIERDA (0px)
      // Formato: [mesial, central, distal] para cada diente
      // Edita estos valores directamente para ajustar cada punto

      final Map<int, List<double>> posicionesAbsolutas = {
        // MOLARES (ancho del diente + separación)
        18: [0, 30, 60], // Diente 18: mesial=0px, central=28px, distal=55px
        17: [76, 106, 136], // Separación ~16px + diente
        16: [152, 182, 212],
        // PREMOLARES
        15: [227, 243, 258],
        14: [273, 289, 306],
        13: [320, 336, 351],
        // INCISIVOS LATERALES
        12: [363, 378, 393],
        11: [409, 425, 441],
        // INCISIVOS CENTRALES
        21: [457, 473, 488],
        22: [501, 516, 532],
        // INCISIVOS LATERALES
        23: [542, 558, 574],
        24: [587, 604, 621],
        // PREMOLARES
        25: [637, 655, 672],
        26: [689, 719, 747],
        27: [761, 791, 819],
        // MOLARES
        28: [837, 867, 899],

        // INFERIORES (ajustados - más cortos en los extremos)
        48: [15, 40, 73],
        47: [89, 121, 153],
        46: [168, 198, 228],
        45: [243, 258, 276],
        44: [295, 308, 323],
        43: [344, 358, 370],
        42: [384, 396, 407],
        41: [418, 430, 442],
        31: [456, 469, 480],
        32: [492, 505, 517],
        33: [528, 543, 556],
        34: [570, 586, 602],
        35: [617, 637, 655],
        36: [672, 702, 730],
        37: [749, 779, 806],
        38: [824, 855, 885],
      };

      final posiciones = posicionesAbsolutas[diente] ?? [0, 28, 56];
      final xMesial = posiciones[0];
      final xCentral = posiciones[1];
      final xDistal = posiciones[2];

      final xPositions = [xMesial, xCentral, xDistal];

      // Convertir valores a números
      final valoresMargen = margenGingival.map((v) {
        return v.isEmpty ? 0.0 : (double.tryParse(v) ?? 0.0);
      }).toList();

      final valoresProfundidad = profundidadSurco.map((v) {
        return v.isEmpty ? 0.0 : (double.tryParse(v) ?? 0.0);
      }).toList();

      // Calcular los 3 puntos de este diente (Mesial, Central, Distal)
      for (int i = 0; i < 3; i++) {
        final x = xPositions[i];
        final margen = valoresMargen[i];
        final profund = valoresProfundidad[i];

        // Punto del margen gingival
        // Valores positivos = recesión (encía baja, se aleja del diente)
        // Valores negativos = encía sobre el diente (se acerca a la corona)
        final margenY = ausente
            ? cejY // Si el diente está ausente, mantener en CEJ
            : (invertido
                ? cejY - (margen * mmScale)
                : cejY + (margen * mmScale));

        // Punto del nivel de inserción
        // La profundidad se mide desde el margen gingival hacia el CEJ
        // Nivel de inserción = margen - profundidad
        // Si margen = 3 y profundidad = 2, entonces nivel = 1
        final nivelInsercion = margen - profund;
        final nivelY = ausente
            ? cejY
            : (invertido
                ? cejY - (nivelInsercion * mmScale)
                : cejY + (nivelInsercion * mmScale));

        todosLosPuntosMargen.add(Offset(x, margenY));
        todosLosPuntosNivel.add(Offset(x, nivelY));

        // Guardar indicadores
        if (!ausente) {
          todosLosIndicadores.add({
            'x': x,
            'margenY': margenY,
            'nivelY': nivelY,
            'sangrado': sangrado[i],
            'supuracion': supuracion[i],
            'hayDatos': profund > 0 || margen != 0,
          });
        }
      }

      // Dibujar área sombreada (pocket) POR DIENTE
      if (!ausente) {
        bool hayDatos = valoresProfundidad.any((v) => v > 0) ||
            valoresMargen.any((v) => v != 0);

        if (hayDatos) {
          final pocketPaint = Paint()
            ..color = Colors.blue.withOpacity(0.2)
            ..style = PaintingStyle.fill;

          final startIndex = todosLosPuntosMargen.length - 3;
          final pocketPath = Path();

          // Dibujar desde los 3 puntos del margen
          pocketPath.moveTo(todosLosPuntosMargen[startIndex].dx,
              todosLosPuntosMargen[startIndex].dy);
          pocketPath.lineTo(todosLosPuntosMargen[startIndex + 1].dx,
              todosLosPuntosMargen[startIndex + 1].dy);
          pocketPath.lineTo(todosLosPuntosMargen[startIndex + 2].dx,
              todosLosPuntosMargen[startIndex + 2].dy);

          // Conectar con los 3 puntos del nivel en reversa
          pocketPath.lineTo(todosLosPuntosNivel[startIndex + 2].dx,
              todosLosPuntosNivel[startIndex + 2].dy);
          pocketPath.lineTo(todosLosPuntosNivel[startIndex + 1].dx,
              todosLosPuntosNivel[startIndex + 1].dy);
          pocketPath.lineTo(todosLosPuntosNivel[startIndex].dx,
              todosLosPuntosNivel[startIndex].dy);

          pocketPath.close();
          canvas.drawPath(pocketPath, pocketPaint);
        }
      }
    }

    // DIBUJAR POLILÍNEA CONTINUA ROJA (margen gingival) que atraviesa TODOS los dientes
    final lineaRojaPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (todosLosPuntosMargen.isNotEmpty) {
      final margenPath = Path();
      // Comenzar desde el primer punto
      margenPath.moveTo(todosLosPuntosMargen[0].dx, todosLosPuntosMargen[0].dy);

      // Conectar todos los puntos
      for (int i = 1; i < todosLosPuntosMargen.length; i++) {
        margenPath.lineTo(
            todosLosPuntosMargen[i].dx, todosLosPuntosMargen[i].dy);
      }

      canvas.drawPath(margenPath, lineaRojaPaint);
    }

    // DIBUJAR POLILÍNEA CONTINUA NEGRA (nivel de inserción) SOLO si hay datos de profundidad
    // Verificar si hay al menos un dato de profundidad > 0
    bool hayDatosProfundidad =
        todosLosIndicadores.any((ind) => ind['hayDatos'] == true);

    if (hayDatosProfundidad && todosLosPuntosNivel.isNotEmpty) {
      final lineaAzulPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final nivelPath = Path();
      nivelPath.moveTo(todosLosPuntosNivel[0].dx, todosLosPuntosNivel[0].dy);

      for (int i = 1; i < todosLosPuntosNivel.length; i++) {
        nivelPath.lineTo(todosLosPuntosNivel[i].dx, todosLosPuntosNivel[i].dy);
      }

      canvas.drawPath(nivelPath, lineaAzulPaint);

      // Puntos en cada medición del nivel (solo donde hay datos)
      final puntoPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      for (int i = 0; i < todosLosIndicadores.length; i++) {
        if (todosLosIndicadores[i]['hayDatos']) {
          canvas.drawCircle(todosLosPuntosNivel[i], 2.5, puntoPaint);
        }
      }
    }

    // Dibujar indicadores de sangrado y supuración
    for (final indicador in todosLosIndicadores) {
      final x = indicador['x'];
      final y = indicador['margenY'];

      if (indicador['sangrado']) {
        final paint = Paint()
          ..color = Colors.red[700]!
          ..style = PaintingStyle.fill;
        final yOffset = invertido ? y + 6 : y - 6;
        canvas.drawCircle(Offset(x, yOffset), 2.5, paint);
      }

      if (indicador['supuracion']) {
        final paint = Paint()
          ..color = Colors.amber[700]!
          ..style = PaintingStyle.fill;
        final yOffset = invertido ? y - 6 : y + 6;
        canvas.drawCircle(Offset(x, yOffset), 2.5, paint);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke;

    final mmScale = 2.5 * 1.2;

    for (int i = -5; i <= 12; i++) {
      final y = invertido ? cejY - (i * mmScale) : cejY + (i * mmScale);

      if (y >= 0 && y <= size.height) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(MedicionCompletaPainter oldDelegate) {
    return data != oldDelegate.data ||
        posicionesX != oldDelegate.posicionesX ||
        cejY != oldDelegate.cejY ||
        invertido != oldDelegate.invertido;
  }
}
