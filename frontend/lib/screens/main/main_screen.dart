import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/pacientes/pacientes_screen.dart';
import 'package:admin/screens/historiales/historiales_screen.dart';
import 'package:admin/screens/contactos/contactos_screen.dart';
import 'package:admin/screens/contactos/papelera_contactos_screen.dart';
import 'package:admin/screens/usuarios/usuarios_screen.dart';
import 'package:admin/screens/usuarios/papelera_usuarios_screen.dart';
import 'package:admin/screens/roles/roles_screen.dart';
import 'package:admin/screens/pacientes/paciente_form.dart';
import 'package:admin/screens/historiales/historial_form.dart';
import 'package:admin/screens/contactos/contacto_form.dart';
import 'package:admin/screens/usuarios/usuario_form.dart';
import 'package:admin/screens/roles/role_form.dart';
import 'package:admin/screens/antecedentes/antecedentes_screen.dart';
import 'package:admin/screens/antecedentes/antecedente_familiar_form.dart';
import 'package:admin/screens/antecedentes/antecedente_ginecologico_form.dart';
import 'package:admin/screens/antecedentes/antecedente_no_patologico_form.dart';
import 'package:admin/screens/antecedentes/antecedente_patologico_form.dart';
import 'package:admin/screens/asignaciones/asignaciones_screen.dart';
import 'package:admin/screens/asignaciones/asignacion_form.dart';
import 'package:admin/screens/asignaciones/papelera_asignaciones_screen.dart';
import 'package:admin/screens/periodoncia/periodoncia_screen.dart';
import 'package:admin/screens/historia_clinica/habitos/habitos_screen.dart';
import 'package:admin/screens/historia_clinica/antecedentes/antecedentes_screen.dart';
import 'package:admin/screens/historia_clinica/examen/examen_screen.dart';
import 'package:admin/screens/historia_clinica/diagnostico/diagnostico_screen.dart';
import 'package:admin/screens/historia_clinica/examen_dental/examen_dental_screen.dart';
import 'package:admin/screens/historia_clinica/odontopediatria/odontopediatria_screen.dart';
import 'package:admin/screens/historia_clinica/oclusion/oclusion_screen.dart';
import 'package:admin/screens/historia_clinica/prostodoncia_removible/prostodoncia_removible_screen.dart';
import 'package:admin/screens/historia_clinica/prostodoncia_fija/prostodoncia_fija_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: Consumer<MenuAppController>(
                builder: (context, controller, _) {
                  switch (controller.currentPage) {
                    case 'pacientes':
                      return PacientesScreen();
                    case 'historiales':
                      return HistorialesScreen();
                    case 'contactos':
                      return ContactosScreen();
                    case 'papelera_contactos':
                      return PapeleraContactosScreen();
                    case 'usuarios':
                      return UsuariosScreen();
                    case 'papelera_usuarios':
                      return PapeleraUsuariosScreen();
                    case 'roles':
                      return RolesScreen();
                    case 'asignaciones':
                      return AsignacionesScreen();
                    case 'papelera_asignaciones':
                      return PapeleraAsignacionesScreen();
                    case 'paciente_form':
                      return PacienteForm(
                          paciente: controller.currentPageArgs?['paciente'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    case 'historial_form':
                      return HistorialForm(
                          historial: controller.currentPageArgs?['historial'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    case 'contacto_form':
                      return ContactoForm(
                          contacto: controller.currentPageArgs?['contacto'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    case 'usuario_form':
                      return UsuarioForm(
                          usuario: controller.currentPageArgs?['usuario'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    case 'role_form':
                      return RoleForm(
                          role: controller.currentPageArgs?['role'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    case 'asignacion_form':
                      return AsignacionForm(
                          asignacion: controller.currentPageArgs?['asignacion'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    // Historia Clínica - Módulos individuales
                    case 'habitos':
                      return HabitosScreen();
                    case 'antecedentes_periodontales':
                      return AntecedentesPeriodontalScreen();
                    case 'examen_periodontal':
                      return ExamenPeriodontalScreen();
                    case 'periodontograma':
                      return PeridonciaScreen(
                        pacienteId: controller.currentPageArgs?['pacienteId'],
                        historialId: controller.currentPageArgs?['historialId'],
                        estudianteId:
                            controller.currentPageArgs?['estudianteId'],
                        registroId: controller.currentPageArgs?['registroId'],
                      );
                    case 'diagnostico_radiografico':
                      return DiagnosticoRadiograficoScreen();
                    case 'examen_dental':
                      return ExamenDentalScreen();
                    case 'clinica_odontopediatria':
                      return OdontopediatriaScreen();
                    case 'oclusion':
                      return OclusiOnScreen();
                    case 'clinica_prostodoncia_removible':
                      return ProstodonciaRemovibleScreen();
                    case 'clinica_prostodoncia_fija':
                      return ProstodonciaFijaScreen();

                    case 'antecedentes':
                      return AntecedentesScreen();
                    case 'antecedente_familiar_form':
                      return AntecedenteFamiliarForm(
                          antecedente:
                              controller.currentPageArgs?['antecedente'],
                          paciente: controller.currentPageArgs?['paciente'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    case 'antecedente_ginecologico_form':
                      return AntecedenteGinecologicoForm(
                          antecedente:
                              controller.currentPageArgs?['antecedente'],
                          paciente: controller.currentPageArgs?['paciente'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    case 'antecedente_no_patologico_form':
                      return AntecedenteNoPatologicoForm(
                          antecedente:
                              controller.currentPageArgs?['antecedente'],
                          paciente: controller.currentPageArgs?['paciente'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);
                    case 'antecedente_patologico_form':
                      return AntecedentePatologicoForm(
                          antecedente:
                              controller.currentPageArgs?['antecedente'],
                          paciente: controller.currentPageArgs?['paciente'],
                          embedded: true,
                          viewOnly:
                              controller.currentPageArgs?['viewOnly'] ?? false);

                    // Materias Clínicas
                    case 'periodoncia':
                      return PeridonciaScreen(
                        pacienteId: controller.currentPageArgs?['pacienteId'],
                        historialId: controller.currentPageArgs?['historialId'],
                        estudianteId:
                            controller.currentPageArgs?['estudianteId'],
                        registroId: controller.currentPageArgs?['registroId'],
                      );
                    case 'cirugia_bucal':
                      return Center(
                        child: Text(
                          'Cirugía Bucal - Próximamente',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      );
                    case 'operatoria_endodoncia':
                      return Center(
                        child: Text(
                          'Operatoria y Endodoncia - Próximamente',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      );
                    case 'prostodoncia_fija':
                      return Center(
                        child: Text(
                          'Prostodoncia Fija - Próximamente',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      );
                    case 'prostodoncia_removible':
                      return Center(
                        child: Text(
                          'Prostodoncia Removible - Próximamente',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      );
                    case 'odontopediatria':
                      return Center(
                        child: Text(
                          'Odontopediatría - Próximamente',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      );
                    case 'semiologia':
                      return Center(
                        child: Text(
                          'Semiología - Próximamente',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      );

                    case 'dashboard':
                    default:
                      return DashboardScreen();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
