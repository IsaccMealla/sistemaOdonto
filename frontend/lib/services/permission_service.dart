import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class PermissionService {
  static const String _permissionsKey = 'user_permissions';
  static List<Map<String, dynamic>> _cachedPermissions = [];
  static bool _isInitialized = false;

  // Notificador para cambios en permisos
  static final ValueNotifier<int> permissionsChanged = ValueNotifier<int>(0);

  /// Inicializar permisos del usuario actual
  static Future<void> initializePermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');

      print('=== INICIANDO PERMISOS ===');
      print('Usuario JSON: $usuarioJson');

      if (usuarioJson == null) {
        print('No hay usuario guardado');
        _cachedPermissions = [];
        _isInitialized = false;
        return;
      }

      final usuario = json.decode(usuarioJson);
      final usuarioId = usuario['id'];
      final rolNombre = usuario['rol_principal'] ?? 'Sin rol';
      final isAdmin = usuario['is_administrador'] ?? false;

      print('Usuario ID: $usuarioId, Rol: $rolNombre, IsAdmin: $isAdmin');

      // Obtener permisos efectivos del usuario desde el backend
      final api = ApiService();
      final data = await api.get(
        '/api/usuario-permisos/permisos_efectivos/',
        queryParameters: {'usuario_id': usuarioId.toString()},
      );

      print('Respuesta del servidor: $data');

      _cachedPermissions =
          List<Map<String, dynamic>>.from(data['permisos'] ?? []);

      print('Permisos cargados: ${_cachedPermissions.length}');
      _cachedPermissions
          .forEach((p) => print('  - ${p['codigo']} (${p['nombre']})'));

      // Si es Admin y no tiene permisos, inicializarlo como si tuviera todos
      // Esto permite que Admin funcione sin necesidad de asignar permisos en BD
      if (rolNombre == 'Admin' && _cachedPermissions.isEmpty) {
        print('ADMIN sin permisos asignados - dando acceso total');
        _cachedPermissions = [
          {
            'codigo': 'all',
            'nombre': 'Acceso Total Admin',
            'categoria': 'admin'
          }
        ];
      }

      // Guardar en local storage
      await prefs.setString(_permissionsKey, json.encode(_cachedPermissions));
      _isInitialized = true;

      print('Permisos inicializados exitosamente. IsAdmin: ${await isAdmin()}');
    } catch (e) {
      print('Error al cargar permisos: $e');
      // Intentar cargar desde cache local
      await _loadFromCache();
    }
  }

  /// Cargar permisos desde cache local
  static Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsJson = prefs.getString(_permissionsKey);

      if (permissionsJson != null) {
        _cachedPermissions =
            List<Map<String, dynamic>>.from(json.decode(permissionsJson));
        _isInitialized = true;
      }
    } catch (e) {
      print('Error al cargar permisos desde cache: $e');
      _cachedPermissions = [];
      _isInitialized = false;
    }
  }

  /// Verificar si el usuario es admin
  static Future<bool> isAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');

      if (usuarioJson != null) {
        final usuario = json.decode(usuarioJson);
        // Verificar por is_administrador o rol_principal
        if (usuario['is_administrador'] == true) return true;
        if (usuario['rol_principal'] == 'Administrador') return true;
        if (usuario['rol_principal'] == 'Admin') return true;
      }
    } catch (e) {
      print('Error al verificar si es admin: $e');
    }
    return false;
  }

  /// Verificar si el usuario tiene un permiso específico
  static Future<bool> hasPermission(String codigoPermiso) async {
    // Admin tiene todos los permisos
    if (await isAdmin()) {
      return true;
    }

    if (!_isInitialized) {
      return false;
    }

    return _cachedPermissions
        .any((permiso) => permiso['codigo'] == codigoPermiso);
  }

  /// Verificar si el usuario puede ver un módulo
  static Future<bool> canViewModule(String moduleName) async {
    return await hasPermission('$moduleName.ver');
  }

  /// Verificar si el usuario puede crear en un módulo
  static Future<bool> canCreate(String moduleName) async {
    return await hasPermission('$moduleName.crear');
  }

  /// Verificar si el usuario puede editar en un módulo
  static Future<bool> canEdit(String moduleName) async {
    return await hasPermission('$moduleName.editar');
  }

  /// Verificar si el usuario puede eliminar en un módulo
  static Future<bool> canDelete(String moduleName) async {
    return await hasPermission('$moduleName.eliminar');
  }

  /// Verificar múltiples permisos (OR logic)
  static Future<bool> hasAnyPermission(List<String> codigos) async {
    for (var codigo in codigos) {
      if (await hasPermission(codigo)) return true;
    }
    return false;
  }

  /// Verificar múltiples permisos (AND logic)
  static Future<bool> hasAllPermissions(List<String> codigos) async {
    for (var codigo in codigos) {
      if (!await hasPermission(codigo)) return false;
    }
    return true;
  }

  /// Obtener todos los permisos del usuario
  static List<Map<String, dynamic>> getAllPermissions() {
    return List.from(_cachedPermissions);
  }

  /// Limpiar permisos (logout)
  static Future<void> clearPermissions() async {
    _cachedPermissions = [];
    _isInitialized = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_permissionsKey);
  }

  /// Recargar permisos desde el servidor
  static Future<void> reloadPermissions() async {
    await initializePermissions();
    // Notificar que los permisos cambiaron
    permissionsChanged.value++;
  }

  /// Verificar si los permisos están inicializados
  static bool get isInitialized => _isInitialized;

  /// Obtener permisos por categoría
  static List<Map<String, dynamic>> getPermissionsByCategory(String categoria) {
    return _cachedPermissions
        .where((p) => p['categoria'] == categoria)
        .toList();
  }

  /// Verificar permiso con manejo síncrono para widgets
  static bool checkPermissionSync(String codigoPermiso) {
    // Si no está inicializado, retornar false
    if (!_isInitialized) {
      return false;
    }
    return _cachedPermissions
        .any((permiso) => permiso['codigo'] == codigoPermiso);
  }
}
