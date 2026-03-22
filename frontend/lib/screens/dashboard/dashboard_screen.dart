import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../constants.dart';
import '../../services/api_service.dart';
import 'components/header.dart';
import 'dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _usuario;
  List<String> _roles = [];
  bool _cargando = true;

  // Estadísticas
  int _totalPacientes = 0;
  int _citasPendientes = 0;
  int _citasHoy = 0;
  int _seguimientosActivos = 0;
  Map<String, int> _registrosPorMateria = {};
  List<Map<String, dynamic>> _citasRecientes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    try {
      // Cargar usuario actual
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');
      if (usuarioJson != null) {
        final usuario = jsonDecode(usuarioJson);
        final roles = (usuario['roles'] as List<dynamic>? ?? [])
            .map((r) => r['nombre'].toString())
            .toList();

        setState(() {
          _usuario = usuario;
          _roles = roles;
        });

        // Cargar estadísticas según el rol
        await _cargarEstadisticas();
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cargarEstadisticas() async {
    try {
      // Cargar pacientes
      final pacientes = await _apiService.fetchPacientes();

      // Cargar citas
      final citas = await _apiService.fetchCitas();
      final citasPendientes =
          citas.where((c) => c['estado'] == 'pendiente').length;

      // Citas de hoy
      final hoy = DateTime.now();
      final citasHoy = citas.where((c) {
        try {
          final fecha = DateTime.parse(c['fecha_hora']);
          return fecha.year == hoy.year &&
              fecha.month == hoy.month &&
              fecha.day == hoy.day;
        } catch (e) {
          return false;
        }
      }).length;

      // Seguimientos
      final seguimientos = await _apiService.fetchSeguimientos();
      final seguimientosActivos =
          seguimientos.where((s) => s['activo'] == true).length;

      // Últimas 5 citas
      final citasOrdenadas = List<Map<String, dynamic>>.from(citas);
      citasOrdenadas.sort((a, b) {
        try {
          final fechaA = DateTime.parse(a['fecha_hora']);
          final fechaB = DateTime.parse(b['fecha_hora']);
          return fechaB.compareTo(fechaA);
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        _totalPacientes = pacientes.length;
        _citasPendientes = citasPendientes;
        _citasHoy = citasHoy;
        _seguimientosActivos = seguimientosActivos;
        _citasRecientes = citasOrdenadas.take(5).toList();
      });
    } catch (e) {
      print('Error al cargar estadísticas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            if (_cargando)
              Center(child: CircularProgressIndicator())
            else ...[
              // Tarjetas de estadísticas principales
              DashboardWidgets.buildEstadisticasPrincipales(
                context,
                _totalPacientes,
                _citasPendientes,
                _citasHoy,
                _seguimientosActivos,
                Responsive.isMobile(context),
              ),
              SizedBox(height: defaultPadding),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        DashboardWidgets.buildCitasRecientes(_citasRecientes),
                        SizedBox(height: defaultPadding),
                        DashboardWidgets.buildGraficoCitas(_citasRecientes),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    SizedBox(width: defaultPadding),
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 2,
                      child:
                          DashboardWidgets.buildResumenRapido(_usuario, _roles),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
