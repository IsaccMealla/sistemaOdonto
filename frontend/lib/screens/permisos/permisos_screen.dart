import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../services/api_service.dart';
import '../../../services/permission_service.dart';

class PermisosScreen extends StatefulWidget {
  @override
  _PermisosScreenState createState() => _PermisosScreenState();
}

class _PermisosScreenState extends State<PermisosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _roles = [];
  List<dynamic> _permisos = [];
  List<dynamic> _categorias = [];
  Map<String, List<dynamic>> _permisosPorCategoria = {};
  Map<String, Map<String, bool>> _rolPermisos =
      {}; // rol_id -> {permiso_id: tiene}
  bool _isLoading = true;
  String? _rolSeleccionado;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();

      // Cargar roles
      final rolesRes = await api.get('/api/roles/');
      _roles = rolesRes;

      // Cargar permisos
      final permisosRes = await api.get('/api/permisos/');
      _permisos = permisosRes;

      // Obtener categorías únicas
      final categoriasRes = await api.get('/api/permisos/categorias/');
      // Eliminar duplicados usando Set y mantener orden
      _categorias = (categoriasRes['categorias'] as List).toSet().toList();

      // Agrupar permisos por categoría
      _permisosPorCategoria = {};
      for (var categoria in _categorias) {
        _permisosPorCategoria[categoria] =
            _permisos.where((p) => p['categoria'] == categoria).toList();
      }

      // Cargar permisos de cada rol
      await _cargarPermisosRoles();

      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarPermisosRoles() async {
    final api = ApiService();
    for (var rol in _roles) {
      final rolId = rol['id'];
      final res = await api.get(
        '/api/rol-permisos/',
        queryParameters: {'rol_id': rolId},
      );

      Map<String, bool> permisosMap = {};
      for (var rp in res) {
        permisosMap[rp['permiso']] = true;
      }
      _rolPermisos[rolId] = permisosMap;
    }
  }

  Future<bool> _recargarPermisosUsuarioSiNecesario(String rolId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');

      if (usuarioJson != null) {
        final usuario = json.decode(usuarioJson);
        final rolesUsuario = usuario['roles'] as List?;

        // Verificar si el usuario tiene el rol que se está modificando
        if (rolesUsuario != null && rolesUsuario.any((r) => r['id'] == rolId)) {
          print('Recargando permisos del usuario actual...');
          await PermissionService.reloadPermissions();

          // Forzar actualización de la UI
          if (mounted) {
            setState(() {});
          }
          return true;
        }
      }
    } catch (e) {
      print('Error al recargar permisos: $e');
    }
    return false;
  }

  Future<void> _togglePermisoRol(
      String rolId, String permisoId, bool agregar) async {
    try {
      final api = ApiService();
      if (agregar) {
        await api.post('/api/rol-permisos/', data: {
          'rol': rolId,
          'permiso': permisoId,
        });
      } else {
        // Buscar el ID del RolPermiso para eliminarlo
        final res = await api.get(
          '/api/rol-permisos/',
          queryParameters: {'rol_id': rolId},
        );
        final rolPermiso = (res as List).firstWhere(
          (rp) => rp['permiso'] == permisoId,
          orElse: () => null,
        );

        if (rolPermiso != null) {
          await api.delete('/api/rol-permisos/${rolPermiso['id']}/');
        }
      }

      // Actualizar estado local
      setState(() {
        if (_rolPermisos[rolId] == null) {
          _rolPermisos[rolId] = {};
        }
        _rolPermisos[rolId]![permisoId] = agregar;
      });

      // Verificar si el usuario actual tiene este rol para recargar sus permisos
      final permisosRecargados =
          await _recargarPermisosUsuarioSiNecesario(rolId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(agregar
              ? 'Permiso agregado${permisosRecargados ? ' - Permisos actualizados' : ''}'
              : 'Permiso eliminado${permisosRecargados ? ' - Permisos actualizados' : ''}'),
          duration: Duration(seconds: 2),
          action: permisosRecargados
              ? SnackBarAction(
                  label: 'Recargar',
                  onPressed: () {
                    // Forzar reconstrucción completa
                    setState(() {});
                  },
                )
              : null,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Permisos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Permisos por Rol'),
            Tab(text: 'Permisos por Usuario'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPermisosRolTab(),
                _buildPermisosUsuarioTab(),
              ],
            ),
    );
  }

  Widget _buildPermisosRolTab() {
    return Row(
      children: [
        // Lista de roles (sidebar)
        Container(
          width: 250,
          color: Colors.grey[100],
          child: ListView.builder(
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final rol = _roles[index];
              final isSelected = _rolSeleccionado == rol['id'];

              return ListTile(
                title: Text(
                  rol['nombre'],
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(rol['descripcion'] ?? ''),
                selected: isSelected,
                selectedTileColor: Colors.blue[50],
                onTap: () {
                  setState(() {
                    _rolSeleccionado = rol['id'];
                  });
                },
              );
            },
          ),
        ),

        // Panel de permisos
        Expanded(
          child: _rolSeleccionado == null
              ? Center(
                  child: Text(
                    'Selecciona un rol para gestionar sus permisos',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : _buildPermisosPanel(),
        ),
      ],
    );
  }

  Widget _buildPermisosPanel() {
    final rolData = _roles.firstWhere((r) => r['id'] == _rolSeleccionado);
    final permisosRol = _rolPermisos[_rolSeleccionado] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue[700],
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.white),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permisos de: ${rolData['nombre']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    rolData['descripcion'] ?? '',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de permisos por categoría
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: _categorias.map((categoria) {
              final permisos = _permisosPorCategoria[categoria] ?? [];

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(
                    categoria.toString().toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  initiallyExpanded: true,
                  children: permisos.map<Widget>((permiso) {
                    final permisoId = permiso['id'];
                    final tienePermiso = permisosRol[permisoId] ?? false;

                    return CheckboxListTile(
                      title: Text(permiso['nombre']),
                      subtitle: Text(permiso['descripcion'] ?? ''),
                      value: tienePermiso,
                      onChanged: (value) {
                        _togglePermisoRol(
                            _rolSeleccionado!, permisoId, value ?? false);
                      },
                      secondary: Icon(
                        _getIconForAccion(permiso['accion']),
                        color: tienePermiso ? Colors.green : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPermisosUsuarioTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Gestión de permisos por usuario',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Text(
            'Próximamente podrás asignar permisos específicos a usuarios',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getIconForAccion(String accion) {
    switch (accion) {
      case 'crear':
        return Icons.add_circle;
      case 'editar':
        return Icons.edit;
      case 'eliminar':
        return Icons.delete;
      case 'ver':
        return Icons.visibility;
      case 'firmar':
        return Icons.check_circle;
      case 'gestionar':
        return Icons.settings;
      default:
        return Icons.check;
    }
  }
}
