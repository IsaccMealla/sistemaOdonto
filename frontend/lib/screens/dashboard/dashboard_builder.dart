import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dashboard_screen.dart';
import 'dashboard_estudiante_screen.dart';

class DashboardBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getRoles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final roles = snapshot.data ?? [];

        // Si es estudiante, mostrar dashboard específico
        if (roles.contains('Estudiante')) {
          return DashboardEstudianteScreen();
        }

        // Para otros roles, mostrar dashboard general
        return DashboardScreen();
      },
    );
  }

  Future<List<String>> _getRoles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');
      if (usuarioJson != null) {
        final usuario = jsonDecode(usuarioJson);
        return (usuario['roles'] as List<dynamic>? ?? [])
            .map((r) => r['nombre'].toString())
            .toList();
      }
    } catch (e) {
      print('Error al obtener roles: $e');
    }
    return [];
  }
}
