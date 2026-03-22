import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants.dart';

class DashboardWidgets {
  static Widget buildEstadisticasPrincipales(
    BuildContext context,
    int totalPacientes,
    int citasPendientes,
    int citasHoy,
    int seguimientosActivos,
    bool isMobile,
  ) {
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: defaultPadding,
      mainAxisSpacing: defaultPadding,
      childAspectRatio: isMobile ? 1.2 : 1.4,
      children: [
        buildTarjetaEstadistica(
          'Total Pacientes',
          totalPacientes.toString(),
          Icons.people,
          Colors.blue,
        ),
        buildTarjetaEstadistica(
          'Citas Pendientes',
          citasPendientes.toString(),
          Icons.event_note,
          Colors.orange,
        ),
        buildTarjetaEstadistica(
          'Citas Hoy',
          citasHoy.toString(),
          Icons.today,
          Colors.green,
        ),
        buildTarjetaEstadistica(
          'Seguimientos',
          seguimientosActivos.toString(),
          Icons.assignment,
          Colors.purple,
        ),
      ],
    );
  }

  static Widget buildTarjetaEstadistica(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: 28),
          ),
          Spacer(),
          Text(
            valor,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildCitasRecientes(List<Map<String, dynamic>> citasRecientes) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Citas Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.calendar_today, color: Colors.white70, size: 20),
            ],
          ),
          SizedBox(height: defaultPadding),
          if (citasRecientes.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No hay citas registradas',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ...citasRecientes.map((cita) {
              final estado = cita['estado'] ?? 'pendiente';
              final color = getColorEstado(estado);

              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cita['paciente_nombre'] ?? 'Paciente',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            cita['estudiante_nombre'] ?? 'Estudiante',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            estado,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatearFecha(cita['fecha_hora']),
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  static Widget buildGraficoCitas(List<Map<String, dynamic>> citasRecientes) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de Citas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 2,
            child: citasRecientes.isEmpty
                ? Center(
                    child: Text(
                      'Sin datos para mostrar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : buildPieChart(citasRecientes),
          ),
        ],
      ),
    );
  }

  static Widget buildPieChart(List<Map<String, dynamic>> citasRecientes) {
    final estados = <String, int>{};
    for (var cita in citasRecientes) {
      final estado = cita['estado'] ?? 'pendiente';
      estados[estado] = (estados[estado] ?? 0) + 1;
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: estados.entries.map((entry) {
                return PieChartSectionData(
                  color: getColorEstado(entry.key),
                  value: entry.value.toDouble(),
                  title: '${entry.value}',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: estados.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: getColorEstado(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static Widget buildResumenRapido(
    Map<String, dynamic>? usuario,
    List<String> roles,
  ) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen Rápido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          buildItemResumen(
            Icons.person,
            'Usuario',
            usuario?['nombres'] ?? 'Usuario',
            Colors.blue,
          ),
          SizedBox(height: 16),
          buildItemResumen(
            Icons.badge,
            'Rol',
            roles.isNotEmpty ? roles.first : 'Sin rol',
            Colors.green,
          ),
          SizedBox(height: 16),
          buildItemResumen(
            Icons.schedule,
            'Última actualización',
            formatearHora(),
            Colors.orange,
          ),
          SizedBox(height: 20),
          Divider(color: Colors.white24),
          SizedBox(height: 20),
          Text(
            'Sistema Odontológico',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 12),
          buildBotonRapido('Nueva Cita', Icons.add_circle, Colors.teal),
          SizedBox(height: 8),
          buildBotonRapido('Ver Pacientes', Icons.people, Colors.blue),
          SizedBox(height: 8),
          buildBotonRapido('Seguimientos', Icons.assignment, Colors.purple),
        ],
      ),
    );
  }

  static Widget buildItemResumen(
      IconData icono, String titulo, String valor, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              Text(
                valor,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildBotonRapido(String texto, IconData icono, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Color getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'aprobada':
        return Colors.blue;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'rechazada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static String formatearFecha(String? fechaIso) {
    if (fechaIso == null) return 'Sin fecha';
    try {
      final fecha = DateTime.parse(fechaIso);
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  static String formatearHora() {
    final ahora = DateTime.now();
    return '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
  }
}
