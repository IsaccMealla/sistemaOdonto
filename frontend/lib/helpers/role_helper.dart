/// Helper para manejo de roles y permisos en el frontend
class RoleHelper {
  /// Verifica si el usuario tiene un rol específico
  static bool hasRole(Map<String, dynamic>? usuario, String roleName) {
    if (usuario == null) return false;

    final roles = usuario['roles'] as List<dynamic>? ?? [];
    return roles.any((rol) =>
        rol['nombre']?.toString().toLowerCase() == roleName.toLowerCase());
  }

  /// Verifica si el usuario es administrador
  static bool isAdmin(Map<String, dynamic>? usuario) {
    return hasRole(usuario, 'admin') || hasRole(usuario, 'administrador');
  }

  /// Verifica si el usuario es docente
  static bool isDocente(Map<String, dynamic>? usuario) {
    return hasRole(usuario, 'docente');
  }

  /// Verifica si el usuario es estudiante
  static bool isEstudiante(Map<String, dynamic>? usuario) {
    return hasRole(usuario, 'estudiante');
  }

  /// Verifica si el usuario es paciente
  static bool isPaciente(Map<String, dynamic>? usuario) {
    return hasRole(usuario, 'paciente');
  }

  /// Verifica si el usuario puede crear registros
  static bool canCreate(Map<String, dynamic>? usuario) {
    return isAdmin(usuario) || isDocente(usuario) || isEstudiante(usuario);
  }

  /// Verifica si el usuario puede editar registros
  static bool canEdit(Map<String, dynamic>? usuario) {
    return isAdmin(usuario) || isDocente(usuario) || isEstudiante(usuario);
  }

  /// Verifica si el usuario puede eliminar registros
  static bool canDelete(Map<String, dynamic>? usuario) {
    return isAdmin(usuario) || isDocente(usuario);
  }

  /// Verifica si el usuario puede ver el módulo de usuarios
  static bool canViewUsers(Map<String, dynamic>? usuario) {
    return isAdmin(usuario);
  }

  /// Verifica si el usuario puede eliminar usuarios
  static bool canDeleteUsers(Map<String, dynamic>? usuario) {
    return isAdmin(usuario);
  }

  /// Verifica si el usuario puede ver todos los pacientes
  static bool canViewAllPatients(Map<String, dynamic>? usuario) {
    return isAdmin(usuario) || isDocente(usuario) || isEstudiante(usuario);
  }

  /// Verifica si el usuario puede gestionar asignaciones
  static bool canManageAssignments(Map<String, dynamic>? usuario) {
    return isAdmin(usuario) || isDocente(usuario);
  }

  /// Obtiene el nombre del rol principal
  static String getRoleName(Map<String, dynamic>? usuario) {
    if (usuario == null) return 'Sin rol';

    if (isAdmin(usuario)) return 'Administrador';
    if (isDocente(usuario)) return 'Docente';
    if (isEstudiante(usuario)) return 'Estudiante';
    if (isPaciente(usuario)) return 'Paciente';

    return 'Usuario';
  }

  /// Obtiene una lista de nombres de roles
  static List<String> getRoleNames(Map<String, dynamic>? usuario) {
    if (usuario == null) return [];

    final roles = usuario['roles'] as List<dynamic>? ?? [];
    return roles
        .map((rol) => rol['nombre']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Verifica si el usuario puede acceder a un módulo específico
  static bool canAccessModule(
      Map<String, dynamic>? usuario, String moduleName) {
    if (isPaciente(usuario)) {
      // Pacientes solo pueden acceder a sus citas e información personal
      return ['citas', 'perfil', 'mi_informacion']
          .contains(moduleName.toLowerCase());
    }

    if (isEstudiante(usuario)) {
      // Estudiantes no pueden acceder a módulos administrativos
      final restrictedModules = ['usuarios', 'roles', 'configuracion'];
      return !restrictedModules.contains(moduleName.toLowerCase());
    }

    if (isDocente(usuario)) {
      // Docentes no pueden acceder al módulo de usuarios
      return moduleName.toLowerCase() != 'usuarios';
    }

    // Admin tiene acceso a todo
    return isAdmin(usuario);
  }

  /// Mensaje de error por falta de permisos
  static String getPermissionErrorMessage(Map<String, dynamic>? usuario) {
    final roleName = getRoleName(usuario);
    return 'Tu rol de $roleName no tiene permisos para realizar esta acción';
  }
}

/// Extension para agregar métodos de permisos a Map
extension UsuarioPermissions on Map<String, dynamic> {
  bool get isAdmin => RoleHelper.isAdmin(this);
  bool get isDocente => RoleHelper.isDocente(this);
  bool get isEstudiante => RoleHelper.isEstudiante(this);
  bool get isPaciente => RoleHelper.isPaciente(this);
  bool get canCreate => RoleHelper.canCreate(this);
  bool get canEdit => RoleHelper.canEdit(this);
  bool get canDelete => RoleHelper.canDelete(this);
  String get roleName => RoleHelper.getRoleName(this);
}
