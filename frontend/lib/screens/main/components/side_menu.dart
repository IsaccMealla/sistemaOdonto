import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../auth/login_screen.dart';
import '../../../services/api_service.dart';
import '../../../controllers/menu_app_controller.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              context.read<MenuAppController>().setPage('dashboard');
            },
          ),
          DrawerListTile(
            title: "Pacientes",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              context.read<MenuAppController>().setPage('pacientes');
            },
          ),
          DrawerListTile(
            title: "Historiales",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('historiales');
            },
          ),
          DrawerListTile(
            title: "Antecedentes",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('antecedentes');
            },
          ),
          DrawerListTile(
            title: "Contactos",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              context.read<MenuAppController>().setPage('contactos');
            },
          ),
          DrawerListTile(
            title: "Usuarios",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              context.read<MenuAppController>().setPage('usuarios');
            },
          ),
          DrawerListTile(
            title: "Roles",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              context.read<MenuAppController>().setPage('roles');
            },
          ),
          DrawerListTile(
            title: "Asignaciones",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('asignaciones');
            },
          ),

          // Separador de Historia Clínica
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

          DrawerListTile(
            title: "Hábitos",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('habitos');
            },
          ),
          DrawerListTile(
            title: "Antecedentes Periodontales",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context
                  .read<MenuAppController>()
                  .setPage('antecedentes_periodontales');
            },
          ),
          DrawerListTile(
            title: "Examen Periodontal",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('examen_periodontal');
            },
          ),
          DrawerListTile(
            title: "Periodontograma",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('periodontograma');
            },
          ),
          DrawerListTile(
            title: "Diagnóstico Radiográfico",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context
                  .read<MenuAppController>()
                  .setPage('diagnostico_radiografico');
            },
          ),
          DrawerListTile(
            title: "Examen Dental",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('examen_dental');
            },
          ),
          DrawerListTile(
            title: "Clínica Odontopediatría",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('clinica_odontopediatria');
            },
          ),
          DrawerListTile(
            title: "Oclusión",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('oclusion');
            },
          ),
          DrawerListTile(
            title: "Clínica Prostodoncia Removible",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('clinica_prostodoncia_removible');
            },
          ),
          DrawerListTile(
            title: "Clínica Prostodoncia Fija",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('clinica_prostodoncia_fija');
            },
          ),

          // Separador de Materias Clínicas
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

          DrawerListTile(
            title: "Cirugía Bucal",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('cirugia_bucal');
            },
          ),
          DrawerListTile(
            title: "Operatoria y Endodoncia",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context
                  .read<MenuAppController>()
                  .setPage('operatoria_endodoncia');
            },
          ),
          DrawerListTile(
            title: "Periodoncia",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('periodoncia');
            },
          ),
          DrawerListTile(
            title: "Prostodoncia Fija",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('prostodoncia_fija');
            },
          ),
          DrawerListTile(
            title: "Prostodoncia Removible",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context
                  .read<MenuAppController>()
                  .setPage('prostodoncia_removible');
            },
          ),
          DrawerListTile(
            title: "Odontopediatría",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('odontopediatria');
            },
          ),
          DrawerListTile(
            title: "Semiología",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.read<MenuAppController>().setPage('semiologia');
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
