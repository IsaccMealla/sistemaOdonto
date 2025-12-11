import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = 'http://127.0.0.1:8000';
  String? _token;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  Future<String?> loadToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
    return _token;
  }

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) headers['Authorization'] = 'Token $_token';
    return headers;
  }

  Future<List<dynamic>> fetchPacientes() async {
    await loadToken();
    final res = await http.get(Uri.parse('$baseUrl/api/pacientes/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load pacientes');
  }

  Future<Map<String, dynamic>> createPaciente(Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(Uri.parse('$baseUrl/api/pacientes/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create paciente');
  }

  Future<Map<String, dynamic>> updatePaciente(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(Uri.parse('$baseUrl/api/pacientes/$id/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update paciente');
  }

  Future<void> deletePaciente(String id) async {
    await loadToken();
    final res = await http.delete(Uri.parse('$baseUrl/api/pacientes/$id/'),
        headers: _headers());
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete paciente');
  }

  // Métodos para eliminación lógica y física

  /// Eliminación lógica - mover a papelera
  Future<Map<String, dynamic>> softDeletePaciente(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/pacientes/$id/soft_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to soft delete paciente: ${res.body}');
  }

  /// Obtener pacientes eliminados (papelera)
  Future<List<dynamic>> fetchPacientesEliminados() async {
    await loadToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/pacientes/deleted/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch deleted pacientes');
  }

  /// Restaurar paciente de la papelera
  Future<Map<String, dynamic>> restaurarPaciente(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/pacientes/$id/restore/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to restore paciente: ${res.body}');
  }

  /// Eliminación física permanente (solo desde papelera)
  Future<Map<String, dynamic>> hardDeletePaciente(String id) async {
    await loadToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/pacientes/$id/hard_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to permanently delete paciente: ${res.body}');
  }

  // ===== USUARIOS =====

  /// Obtener lista de usuarios activos
  Future<List<dynamic>> fetchUsuarios() async {
    await loadToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/usuarios/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load usuarios');
  }

  /// Crear usuario
  Future<Map<String, dynamic>> createUsuario(Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/usuarios/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create usuario: ${res.body}');
  }

  /// Actualizar usuario
  Future<Map<String, dynamic>> updateUsuario(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(
      Uri.parse('$baseUrl/api/usuarios/$id/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update usuario: ${res.body}');
  }

  /// Eliminación lógica de usuario - mover a papelera
  Future<Map<String, dynamic>> softDeleteUsuario(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/usuarios/$id/soft_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to soft delete usuario: ${res.body}');
  }

  /// Obtener usuarios eliminados (papelera)
  Future<List<dynamic>> fetchUsuariosEliminados() async {
    await loadToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/usuarios/deleted/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch deleted usuarios');
  }

  /// Restaurar usuario de la papelera
  Future<Map<String, dynamic>> restaurarUsuario(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/usuarios/$id/restore/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to restore usuario: ${res.body}');
  }

  /// Eliminación física permanente de usuario (solo desde papelera)
  Future<Map<String, dynamic>> hardDeleteUsuario(String id) async {
    await loadToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/usuarios/$id/hard_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to permanently delete usuario: ${res.body}');
  }

  /// Cambiar contraseña de usuario
  Future<Map<String, dynamic>> changePassword(
      String id, String oldPassword, String newPassword) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/usuarios/$id/change_password/'),
      headers: _headers(),
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to change password: ${res.body}');
  }

  /// Activar usuario
  Future<Map<String, dynamic>> activateUsuario(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/usuarios/$id/activate/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to activate usuario: ${res.body}');
  }

  /// Desactivar usuario
  Future<Map<String, dynamic>> deactivateUsuario(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/usuarios/$id/deactivate/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to deactivate usuario: ${res.body}');
  }

  /// Registro público de usuario (sin autenticación)
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to register user: ${res.body}');
  }

  // Historiales
  Future<List<dynamic>> fetchHistoriales() async {
    await loadToken();
    final res = await http.get(Uri.parse('$baseUrl/api/historiales/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load historiales');
  }

  Future<Map<String, dynamic>> createHistorial(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(Uri.parse('$baseUrl/api/historiales/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create historial');
  }

  Future<Map<String, dynamic>> updateHistorial(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(Uri.parse('$baseUrl/api/historiales/$id/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update historial');
  }

  Future<void> deleteHistorial(String id) async {
    await loadToken();
    final res = await http.delete(Uri.parse('$baseUrl/api/historiales/$id/'),
        headers: _headers());
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete historial');
  }

  // Contactos
  Future<List<dynamic>> fetchContactos() async {
    await loadToken();
    final res = await http.get(Uri.parse('$baseUrl/api/contactos/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load contactos');
  }

  Future<Map<String, dynamic>> createContacto(Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(Uri.parse('$baseUrl/api/contactos/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create contacto');
  }

  Future<Map<String, dynamic>> updateContacto(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(Uri.parse('$baseUrl/api/contactos/$id/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update contacto');
  }

  Future<void> deleteContacto(String id) async {
    await loadToken();
    final res = await http.delete(Uri.parse('$baseUrl/api/contactos/$id/'),
        headers: _headers());
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete contacto');
  }

  // Soft delete para contactos
  Future<Map<String, dynamic>> softDeleteContacto(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/contactos/$id/soft_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to soft delete contacto');
  }

  // Fetch contactos eliminados
  Future<List<dynamic>> fetchContactosEliminados() async {
    await loadToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/contactos/?deleted=true'),
      headers: _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load deleted contactos');
  }

  // Restaurar contacto eliminado
  Future<Map<String, dynamic>> restaurarContacto(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/contactos/$id/restore/'),
      headers: _headers(),
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to restore contacto');
  }

  // Hard delete para contactos
  Future<Map<String, dynamic>> hardDeleteContacto(String id) async {
    await loadToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/contactos/$id/hard_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to hard delete contacto');
  }

  // Antecedentes Familiares
  Future<List<dynamic>> fetchAntecedentesFamiliares() async {
    await loadToken();
    final res = await http.get(
        Uri.parse('$baseUrl/api/antecedentes_familiares/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load antecedentes familiares');
  }

  Future<Map<String, dynamic>> createAntecedenteFamiliar(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
        Uri.parse('$baseUrl/api/antecedentes_familiares/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create antecedente familiar');
  }

  Future<Map<String, dynamic>> updateAntecedenteFamiliar(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(
        Uri.parse('$baseUrl/api/antecedentes_familiares/$id/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update antecedente familiar');
  }

  Future<void> deleteAntecedenteFamiliar(String id) async {
    await loadToken();
    final res = await http.delete(
        Uri.parse('$baseUrl/api/antecedentes_familiares/$id/'),
        headers: _headers());
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete antecedente familiar');
  }

  // Antecedentes Ginecologicos
  Future<List<dynamic>> fetchAntecedentesGinecologicos() async {
    await loadToken();
    final res = await http.get(
        Uri.parse('$baseUrl/api/antecedentes_ginecologicos/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load antecedentes ginecologicos');
  }

  Future<Map<String, dynamic>> createAntecedenteGinecologico(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
        Uri.parse('$baseUrl/api/antecedentes_ginecologicos/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create antecedente ginecologico');
  }

  Future<Map<String, dynamic>> updateAntecedenteGinecologico(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(
        Uri.parse('$baseUrl/api/antecedentes_ginecologicos/$id/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update antecedente ginecologico');
  }

  Future<void> deleteAntecedenteGinecologico(String id) async {
    await loadToken();
    final res = await http.delete(
        Uri.parse('$baseUrl/api/antecedentes_ginecologicos/$id/'),
        headers: _headers());
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete antecedente ginecologico');
  }

  // Antecedentes No Patologicos
  Future<List<dynamic>> fetchAntecedentesNoPatologicos() async {
    await loadToken();
    final res = await http.get(
        Uri.parse('$baseUrl/api/antecedentes_no_patologicos/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load antecedentes no patologicos');
  }

  Future<Map<String, dynamic>> createAntecedenteNoPatologico(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
        Uri.parse('$baseUrl/api/antecedentes_no_patologicos/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create antecedente no patologico');
  }

  Future<Map<String, dynamic>> updateAntecedenteNoPatologico(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(
        Uri.parse('$baseUrl/api/antecedentes_no_patologicos/$id/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update antecedente no patologico');
  }

  Future<void> deleteAntecedenteNoPatologico(String id) async {
    await loadToken();
    final res = await http.delete(
        Uri.parse('$baseUrl/api/antecedentes_no_patologicos/$id/'),
        headers: _headers());
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete antecedente no patologico');
  }

  // Antecedentes Patologicos Personales
  Future<List<dynamic>> fetchAntecedentesPatologicosPersonales() async {
    await loadToken();
    final res = await http.get(
        Uri.parse('$baseUrl/api/antecedentes_patologicos_personales/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load antecedentes patologicos personales');
  }

  Future<Map<String, dynamic>> createAntecedentePatologico(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
        Uri.parse('$baseUrl/api/antecedentes_patologicos_personales/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create antecedente patologico');
  }

  // Método para obtener antecedentes de la tabla padre
  Future<List<dynamic>> fetchAntecedentesBase() async {
    await loadToken();
    final res = await http.get(Uri.parse('$baseUrl/api/antecedentes/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load antecedentes base');
  }

  // Método mejorado que combina datos de tabla padre con detalles
  Future<List<dynamic>> fetchAntecedentesConsolidados() async {
    try {
      print('=== INTENTANDO MÉTODO MEJORADO ===');

      // Obtener datos de la tabla padre
      final antecedentesBase = await fetchAntecedentesBase();
      print('Antecedentes base obtenidos: ${antecedentesBase.length}');

      // Obtener datos de tablas específicas y otros datos necesarios
      final familiares = await fetchAntecedentesFamiliares();
      final ginecologicos = await fetchAntecedentesGinecologicos();
      final noPatologicos = await fetchAntecedentesNoPatologicos();
      final patologicos = await fetchAntecedentesPatologicosPersonales();
      final pacientes = await fetchPacientes();
      final historiales = await fetchHistoriales();

      print(
          'Datos específicos - Familiares: ${familiares.length}, Ginecológicos: ${ginecologicos.length}, No patológicos: ${noPatologicos.length}, Patológicos: ${patologicos.length}');

      List<dynamic> resultado = [];

      // Crear mapas para acceso rápido
      Map<String, Map<String, dynamic>> pacienteMap = {};
      for (var paciente in pacientes) {
        pacienteMap[paciente['id']] = paciente;
      }

      Map<String, Map<String, dynamic>> historialMap = {};
      for (var historial in historiales) {
        historialMap[historial['id']] = historial;
      }

      // Procesar cada antecedente base
      for (var antecedenteBase in antecedentesBase) {
        String historialId = antecedenteBase['historial']?.toString() ?? '';
        String tipo = antecedenteBase['tipo']?.toString() ?? '';

        print(
            'Procesando antecedente ID: ${antecedenteBase['id']}, Tipo: $tipo, Historial: $historialId');

        // Obtener información del paciente
        var historial = historialMap[historialId];
        String pacienteId = historial?['paciente']?.toString() ?? '';
        var paciente = pacienteMap[pacienteId];
        String pacienteNombre = paciente != null
            ? '${paciente['nombres']} ${paciente['apellidos']}'
            : 'Paciente Desconocido';

        // Buscar detalles específicos según el tipo
        Map<String, dynamic> detalles = {};
        String tipoDisplay = '';

        switch (tipo) {
          case 'familiar':
            tipoDisplay = 'Familiares';
            var detalle = familiares
                .where((f) =>
                    f['antecedente']?.toString() ==
                    antecedenteBase['id']?.toString())
                .toList();
            if (detalle.isNotEmpty)
              detalles = Map<String, dynamic>.from(detalle.first);
            break;
          case 'ginecologico':
            tipoDisplay = 'Ginecológicos';
            var detalle = ginecologicos
                .where((g) =>
                    g['antecedente']?.toString() ==
                    antecedenteBase['id']?.toString())
                .toList();
            if (detalle.isNotEmpty)
              detalles = Map<String, dynamic>.from(detalle.first);
            break;
          case 'no_patologico':
            tipoDisplay = 'No Patológicos';
            var detalle = noPatologicos
                .where((n) =>
                    n['antecedente']?.toString() ==
                    antecedenteBase['id']?.toString())
                .toList();
            if (detalle.isNotEmpty)
              detalles = Map<String, dynamic>.from(detalle.first);
            break;
          case 'patologico':
            tipoDisplay = 'Patológicos Personales';
            var detalle = patologicos
                .where((p) =>
                    p['antecedente']?.toString() ==
                    antecedenteBase['id']?.toString())
                .toList();
            if (detalle.isNotEmpty)
              detalles = Map<String, dynamic>.from(detalle.first);
            break;
        }

        print('Detalles encontrados para $tipo: ${detalles.keys.toList()}');

        // Combinar datos base con detalles
        Map<String, dynamic> antecedenteCompleto = {
          'id': antecedenteBase['id'],
          'historial': historialId,
          'tipo': tipo,
          'tipo_display': tipoDisplay,
          'observaciones': antecedenteBase['observaciones'],
          'creado_en': antecedenteBase['creado_en'],
          'paciente_id': pacienteId,
          'paciente_nombre_completo': pacienteNombre,
          ...detalles, // Agregar todos los campos específicos
        };

        resultado.add(antecedenteCompleto);
      }

      print('Total antecedentes consolidados generados: ${resultado.length}');
      return resultado;
    } catch (e) {
      print('Error en método mejorado: $e');
      // Fallback al método original si existe
      try {
        print('Intentando fallback al método original...');
        await loadToken();
        final res = await http.get(
            Uri.parse('$baseUrl/api/antecedentes_consolidados/'),
            headers: _headers());
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as List<dynamic>;
          print('Fallback exitoso: ${data.length} antecedentes');
          return data;
        }
      } catch (e2) {
        print('Fallback también falló: $e2');
      }
      throw Exception('Failed to load antecedentes consolidados: $e');
    }
  }

  // Método para crear antecedente consolidado
  Future<Map<String, dynamic>> createAntecedenteConsolidado(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
        Uri.parse('$baseUrl/api/antecedentes_consolidados/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create antecedente consolidado');
  }

  // Método mejorado que combina datos de todas las tablas específicas
  Future<Map<String, List<dynamic>>>
      fetchAntecedentesDetalladosPorPaciente() async {
    try {
      // Obtener datos de cada tabla específica
      final familiares = await fetchAntecedentesFamiliares();
      final ginecologicos = await fetchAntecedentesGinecologicos();
      final noPatologicos = await fetchAntecedentesNoPatologicos();
      final patologicos = await fetchAntecedentesPatologicosPersonales();
      final pacientes = await fetchPacientes();

      Map<String, List<dynamic>> resultado = {};

      // Crear mapa de pacientes para obtener nombres
      Map<String, String> pacienteNombres = {};
      for (var paciente in pacientes) {
        pacienteNombres[paciente['id']] =
            '${paciente['nombres']} ${paciente['apellidos']}';
      }

      // Procesar antecedentes familiares
      for (var antecedente in familiares) {
        String pacienteId = antecedente['historial']?.toString() ?? '';
        String pacienteNombre =
            _getPacienteNombrePorHistorial(pacienteId, pacientes);

        if (!resultado.containsKey(pacienteNombre)) {
          resultado[pacienteNombre] = [];
        }

        antecedente['tipo'] = 'familiares';
        antecedente['tipo_display'] = 'Familiares';
        antecedente['paciente_nombre_completo'] = pacienteNombre;
        resultado[pacienteNombre]!.add(antecedente);
      }

      // Procesar otros tipos de antecedentes de manera similar
      _procesarAntecedentes(ginecologicos, 'ginecologicos', 'Ginecológicos',
          resultado, pacientes);
      _procesarAntecedentes(noPatologicos, 'no_patologicos', 'No Patológicos',
          resultado, pacientes);
      _procesarAntecedentes(patologicos, 'patologicos_personales',
          'Patológicos Personales', resultado, pacientes);

      return resultado;
    } catch (e) {
      print('Error en fetchAntecedentesDetalladosPorPaciente: $e');
      return {};
    }
  }

  String _getPacienteNombrePorHistorial(
      String historialId, List<dynamic> pacientes) {
    for (var paciente in pacientes) {
      if (paciente['id']?.toString() == historialId) {
        return '${paciente['nombres']} ${paciente['apellidos']}';
      }
    }
    return 'Paciente Desconocido';
  }

  void _procesarAntecedentes(
      List<dynamic> antecedentes,
      String tipo,
      String tipoDisplay,
      Map<String, List<dynamic>> resultado,
      List<dynamic> pacientes) {
    for (var antecedente in antecedentes) {
      String historialId = antecedente['historial']?.toString() ?? '';
      String pacienteNombre =
          _getPacienteNombrePorHistorial(historialId, pacientes);

      if (!resultado.containsKey(pacienteNombre)) {
        resultado[pacienteNombre] = [];
      }

      antecedente['tipo'] = tipo;
      antecedente['tipo_display'] = tipoDisplay;
      antecedente['paciente_nombre_completo'] = pacienteNombre;
      resultado[pacienteNombre]!.add(antecedente);
    }
  }

  Future<Map<String, dynamic>> updateAntecedentePatologico(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(
        Uri.parse('$baseUrl/api/antecedentes_patologicos_personales/$id/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update antecedente patologico');
  }

  Future<void> deleteAntecedentePatologico(String id) async {
    await loadToken();
    final res = await http.delete(
        Uri.parse('$baseUrl/api/antecedentes_patologicos_personales/$id/'),
        headers: _headers());
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete antecedente patologico');
  }

  // Roles
  Future<List<dynamic>> fetchRoles() async {
    await loadToken();
    final res =
        await http.get(Uri.parse('$baseUrl/api/roles/'), headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load roles');
  }

  Future<Map<String, dynamic>> createRole(Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(Uri.parse('$baseUrl/api/roles/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create role');
  }

  Future<Map<String, dynamic>> updateRole(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(Uri.parse('$baseUrl/api/roles/$id/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update role');
  }

  Future<void> deleteRole(String id) async {
    await loadToken();
    final res = await http.delete(Uri.parse('$baseUrl/api/roles/$id/'),
        headers: _headers());
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete role');
  }

  // ========== ASIGNACIONES ==========
  Future<List<dynamic>> fetchAsignaciones() async {
    await loadToken();
    final res = await http.get(Uri.parse('$baseUrl/api/asignaciones/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load asignaciones');
  }

  Future<List<dynamic>> fetchAsignacionesEliminadas() async {
    await loadToken();
    final res = await http.get(Uri.parse('$baseUrl/api/asignaciones/deleted/'),
        headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load deleted asignaciones');
  }

  Future<Map<String, dynamic>> createAsignacion(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(Uri.parse('$baseUrl/api/asignaciones/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create asignacion');
  }

  Future<Map<String, dynamic>> updateAsignacion(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(Uri.parse('$baseUrl/api/asignaciones/$id/'),
        headers: _headers(), body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update asignacion');
  }

  Future<void> softDeleteAsignacion(String id) async {
    await loadToken();
    final res = await http.post(
        Uri.parse('$baseUrl/api/asignaciones/$id/soft_delete/'),
        headers: _headers());
    if (res.statusCode == 200) return;
    throw Exception('Failed to soft delete asignacion');
  }

  Future<void> restaurarAsignacion(String id) async {
    await loadToken();
    final res = await http.post(
        Uri.parse('$baseUrl/api/asignaciones/$id/restore/'),
        headers: _headers());
    if (res.statusCode == 200) return;
    throw Exception('Failed to restore asignacion');
  }

  Future<void> hardDeleteAsignacion(String id) async {
    await loadToken();
    final res = await http.delete(
        Uri.parse('$baseUrl/api/asignaciones/$id/hard_delete/'),
        headers: _headers());
    if (res.statusCode == 200) return;
    throw Exception('Failed to hard delete asignacion');
  }

  // Generic antecedente creation method
  Future<Map<String, dynamic>> createAntecedente(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
        Uri.parse('$baseUrl/api/antecedentes_consolidados/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 201)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to create antecedente: ${res.body}');
  }

  // Generic antecedente update method
  Future<Map<String, dynamic>> updateAntecedente(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(
        Uri.parse('$baseUrl/api/antecedentes_consolidados/$id/'),
        headers: _headers(),
        body: jsonEncode(data));
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to update antecedente: ${res.body}');
  }

  Future<void> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api-token-auth/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null) throw Exception('Token not returned');
      await setToken(token);
      return;
    }
    throw Exception('Login failed');
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
  }

  // Periodoncia methods
  Future<List<dynamic>> fetchPeriodoncia({String? pacienteId}) async {
    await loadToken();
    String url = '$baseUrl/api/periodoncia/';
    if (pacienteId != null) {
      url += '?paciente=$pacienteId';
    }
    final res = await http.get(Uri.parse(url), headers: _headers());
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load periodoncia');
  }

  Future<Map<String, dynamic>> fetchPeriodonciaById(String id) async {
    await loadToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/periodoncia/$id/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load periodoncia: ${res.body}');
  }

  Future<Map<String, dynamic>> createPeriodoncia(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/periodoncia/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create periodoncia: ${res.body}');
  }

  Future<Map<String, dynamic>> updatePeriodoncia(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(
      Uri.parse('$baseUrl/api/periodoncia/$id/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update periodoncia: ${res.body}');
  }

  Future<void> deletePeriodoncia(String id) async {
    await loadToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/periodoncia/$id/'),
      headers: _headers(),
    );
    if (res.statusCode == 204) return;
    throw Exception('Failed to delete periodoncia');
  }

  Future<Map<String, dynamic>> softDeletePeriodoncia(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/periodoncia/$id/soft_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to soft delete periodoncia: ${res.body}');
  }

  Future<List<dynamic>> fetchPeriodonciaEliminados() async {
    await loadToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/periodoncia/deleted/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch deleted periodoncia');
  }

  Future<Map<String, dynamic>> restaurarPeriodoncia(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/periodoncia/$id/restore/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to restore periodoncia: ${res.body}');
  }

  Future<void> hardDeletePeriodoncia(String id) async {
    await loadToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/periodoncia/$id/hard_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) return;
    throw Exception('Failed to hard delete periodoncia');
  }

  // ==================== HISTORIA CLÍNICA ====================

  /// Obtener todos los registros de historia clínica con filtros opcionales
  Future<List<dynamic>> fetchRegistrosHistoriaClinica({
    String? pacienteId,
    String? estudianteId,
    String? materia,
    String? tipoRegistro,
    String? estado,
    String? historialId,
  }) async {
    await loadToken();
    final queryParams = <String, String>{};
    if (pacienteId != null) queryParams['paciente'] = pacienteId;
    if (estudianteId != null) queryParams['estudiante'] = estudianteId;
    if (materia != null) queryParams['materia'] = materia;
    if (tipoRegistro != null) queryParams['tipo_registro'] = tipoRegistro;
    if (estado != null) queryParams['estado'] = estado;
    if (historialId != null) queryParams['historial'] = historialId;

    final uri = Uri.parse('$baseUrl/api/historia-clinica/')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _headers());

    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load registros historia clínica');
  }

  /// Obtener un registro de historia clínica por ID
  Future<Map<String, dynamic>> fetchRegistroHistoriaClinica(String id) async {
    await loadToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/historia-clinica/$id/'),
      headers: _headers(),
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to load registro historia clínica');
  }

  /// Crear un nuevo registro de historia clínica
  Future<Map<String, dynamic>> createRegistroHistoriaClinica(
      Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/historia-clinica/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create registro historia clínica: ${res.body}');
  }

  /// Actualizar un registro de historia clínica
  Future<Map<String, dynamic>> updateRegistroHistoriaClinica(
      String id, Map<String, dynamic> data) async {
    await loadToken();
    final res = await http.put(
      Uri.parse('$baseUrl/api/historia-clinica/$id/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update registro historia clínica: ${res.body}');
  }

  /// Obtener registros agrupados por materia para un paciente
  Future<Map<String, dynamic>> fetchRegistrosPorPaciente(
      String pacienteId) async {
    await loadToken();
    final res = await http.get(
      Uri.parse(
          '$baseUrl/api/historia-clinica/por_paciente/?paciente_id=$pacienteId'),
      headers: _headers(),
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to load registros por paciente');
  }

  /// Obtener registros del estudiante actual
  Future<List<dynamic>> fetchMisRegistrosHistoriaClinica({
    required String estudianteId,
    String? materia,
    String? estado,
  }) async {
    await loadToken();
    final queryParams = <String, String>{'estudiante_id': estudianteId};
    if (materia != null) queryParams['materia'] = materia;
    if (estado != null) queryParams['estado'] = estado;

    final uri = Uri.parse('$baseUrl/api/historia-clinica/mis_registros/')
        .replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: _headers());

    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to load mis registros');
  }

  /// Aprobar un registro
  Future<Map<String, dynamic>> aprobarRegistroHistoriaClinica(
      String id, String docenteId,
      {String? observaciones}) async {
    await loadToken();
    final data = {
      'docente_id': docenteId,
      if (observaciones != null) 'observaciones': observaciones,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/api/historia-clinica/$id/aprobar/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to aprobar registro: ${res.body}');
  }

  /// Rechazar un registro
  Future<Map<String, dynamic>> rechazarRegistroHistoriaClinica(
      String id, String docenteId, String observaciones) async {
    await loadToken();
    final data = {
      'docente_id': docenteId,
      'observaciones': observaciones,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/api/historia-clinica/$id/rechazar/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to rechazar registro: ${res.body}');
  }

  /// Solicitar corrección de un registro
  Future<Map<String, dynamic>> solicitarCorreccionHistoriaClinica(
      String id, String docenteId, String observaciones) async {
    await loadToken();
    final data = {
      'docente_id': docenteId,
      'observaciones': observaciones,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/api/historia-clinica/$id/solicitar_correccion/'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200)
      return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to solicitar corrección: ${res.body}');
  }

  /// Eliminación lógica (soft delete)
  Future<void> softDeleteRegistroHistoriaClinica(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/historia-clinica/$id/soft_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) return;
    throw Exception('Failed to soft delete registro: ${res.body}');
  }

  /// Restaurar registro eliminado
  Future<void> restoreRegistroHistoriaClinica(String id) async {
    await loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/historia-clinica/$id/restore/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) return;
    throw Exception('Failed to restore registro: ${res.body}');
  }

  /// Eliminación física permanente
  Future<void> hardDeleteRegistroHistoriaClinica(String id) async {
    await loadToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/api/historia-clinica/$id/hard_delete/'),
      headers: _headers(),
    );
    if (res.statusCode == 200) return;
    throw Exception('Failed to hard delete registro: ${res.body}');
  }
}
