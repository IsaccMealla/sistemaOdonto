import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../auth/login_screen.dart';
import '../../../services/api_service.dart';
import '../../../services/permission_service.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../citas/citas_screen.dart';
import '../../plan_tratamiento/planes_tratamiento_screen.dart';
import '../../plan_tratamiento/dashboard_docente_screen.dart';
import '../../cupos/cupos_estudiante_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _isAdmin = false;
  bool _isLoading = true;
  String _roleName = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    // Escuchar cambios en permisos
    PermissionService.permissionsChanged.addListener(_onPermissionsChanged);
  }

  @override
  void dispose() {
    PermissionService.permissionsChanged.removeListener(_onPermissionsChanged);
    super.dispose();
  }

  void _onPermissionsChanged() {
    // Recargar rol y reconstruir
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');

      if (usuarioJson != null) {
        final usuario = json.decode(usuarioJson);
        final isAdministrador = usuario['is_administrador'] ?? false;
        final rolPrincipal = usuario['rol_principal'] ?? '';

        setState(() {
          _isAdmin = isAdministrador ||
              rolPrincipal == 'Administrador' ||
              rolPrincipal == 'Admin';
          _roleName = rolPrincipal;
          _isLoading = false;
        });

        print(
            'Usuario cargado: ${usuario['username']}, Rol: $_roleName, isAdmin: $_isAdmin');
        print('Permisos inicializados: ${PermissionService.isInitialized}');
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar rol de usuario: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _hasPermission(String permissionCode) {
    // Admin tiene todos los permisos
    if (_isAdmin) {
      print('Admin tiene todos los permisos, mostrando: $permissionCode');
      return true;
    }

    // Verificar permiso específico
    bool hasIt = PermissionService.checkPermissionSync(permissionCode);
    print('Verificando permiso $permissionCode: $hasIt');
    return hasIt;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),

          // Dashboard - Visible para todos
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              context.read<MenuAppController>().setPage('dashboard');
            },
          ),

          // Citas Médicas
          if (_hasPermission('citas.ver'))
            DrawerListTile(
              title: "Citas Médicas",
              svgSrc: "assets/icons/menu_dashboard.svg",
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CitasScreen(userRole: _roleName),
                  ),
                );
              },
            ),

          // Plan de Tratamiento
          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Planes de Tratamiento",
              svgSrc: "assets/icons/menu_task.svg",
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlanesTratamientoScreen(),
                  ),
                );
              },
            ),

          // Aprobaciones (solo para docentes)
          if (_roleName == 'Docente' || _roleName == 'Administrador')
            DrawerListTile(
              title: "Aprobaciones",
              svgSrc: "assets/icons/menu_task.svg",
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DashboardDocenteScreen(),
                  ),
                );
              },
            ),

          // Mis Cupos (solo para estudiantes)
          if (_roleName == 'Estudiante')
            DrawerListTile(
              title: "Mis Cupos",
              svgSrc: "assets/icons/menu_task.svg",
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CuposEstudianteScreen(),
                  ),
                );
              },
            ),

          // Pacientes
          if (_hasPermission('pacientes.ver'))
            DrawerListTile(
              title: "Pacientes",
              svgSrc: "assets/icons/menu_profile.svg",
              press: () {
                context.read<MenuAppController>().setPage('pacientes');
              },
            ),

          // Historiales - Historia clínica general
          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Historiales",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('historiales');
              },
            ),

          // Antecedentes (parte de historia clínica)
          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Antecedentes",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('antecedentes');
              },
            ),

          // Contactos de emergencia
          if (_hasPermission('pacientes.ver'))
            DrawerListTile(
              title: "Contactos",
              svgSrc: "assets/icons/menu_profile.svg",
              press: () {
                context.read<MenuAppController>().setPage('contactos');
              },
            ),

          // Usuarios - Solo admin y docentes
          if (_hasPermission('usuarios.ver'))
            DrawerListTile(
              title: "Usuarios",
              svgSrc: "assets/icons/menu_profile.svg",
              press: () {
                context.read<MenuAppController>().setPage('usuarios');
              },
            ),

          // Roles - Solo admin
          if (_isAdmin)
            DrawerListTile(
              title: "Roles",
              svgSrc: "assets/icons/menu_profile.svg",
              press: () {
                context.read<MenuAppController>().setPage('roles');
              },
            ),

          // Asignaciones
          if (_hasPermission('asignaciones.ver'))
            DrawerListTile(
              title: "Asignaciones",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('asignaciones');
              },
            ),

          // Permisos - Solo admin
          if (_isAdmin)
            DrawerListTile(
              title: "Permisos",
              svgSrc: "assets/icons/menu_setting.svg",
              press: () {
                context.read<MenuAppController>().setPage('permisos');
              },
            ),

          // Reportes
          if (_hasPermission('reportes.ver'))
            DrawerListTile(
              title: "Reportes",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('reportes');
              },
            ),

          // Separador de Historia Clínica - Solo mostrar si tiene algún permiso de HC
          if (_hasPermission('historia_clinica.ver'))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'HISTORIA CLÍNICA',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Hábitos",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('habitos');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Antecedentes Periodontales",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('antecedentes_periodontales');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Examen Periodontal",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('examen_periodontal');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Periodontograma",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('periodontograma');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Diagnóstico Radiográfico",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('diagnostico_radiografico');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Examen Dental",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('examen_dental');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Clínica Odontopediatría",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('clinica_odontopediatria');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Oclusión",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('oclusion');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Clínica Prostodoncia Removible",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('clinica_prostodoncia_removible');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Clínica Prostodoncia Fija",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('clinica_prostodoncia_fija');
              },
            ),

          if (_hasPermission('seguimiento.ver'))
            DrawerListTile(
              title: "Seguimiento Clínico",
              svgSrc: "assets/icons/menu_task.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('seguimiento_clinico');
              },
            ),

          // Separador de Materias Clínicas - Mostrar si tiene algún permiso de historia clínica
          if (_hasPermission('historia_clinica.ver'))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'MATERIAS CLÍNICAS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Cirugía Bucal",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('cirugia_bucal');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Operatoria y Endodoncia",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('operatoria_endodoncia');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Periodoncia",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('periodoncia');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Prostodoncia Fija",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('prostodoncia_fija');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Prostodoncia Removible",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('prostodoncia_removible');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Odontopediatría",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('odontopediatria');
              },
            ),

          if (_hasPermission('historia_clinica.ver'))
            DrawerListTile(
              title: "Semiología",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context.read<MenuAppController>().setPage('semiologia');
              },
            ),

          if (_hasPermission('protocolo_quirurgico.ver'))
            DrawerListTile(
              title: "Protocolo Quirúrgico",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                context
                    .read<MenuAppController>()
                    .setPage('protocolo_quirurgico');
              },
            ),

          Divider(color: Colors.white24, height: 32),

          DrawerListTile(
            title: "Logout",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () async {
              await ApiService().clearToken();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
