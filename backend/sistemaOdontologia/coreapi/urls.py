from rest_framework import routers
from django.urls import path, include
from .views import (
    PacienteViewSet,
    HistorialClinicoViewSet,
    ContactoEmergenciaViewSet,
    UsuarioViewSet,
    RolViewSet,
    AsignacionViewSet,
    AntecedenteViewSet,
    AntecedenteConsolidadoViewSet,
    RegistroCirugiaBucalViewSet,
    RegistroOperatoriaEndodonciaViewSet,
    RegistroHistoriaClinicaViewSet,
    RegistroProstodonciaFijaViewSet,
    RegistroProstodonciaRemovibleViewSet,
    RegistroOdontopediatriaViewSet,
    RegistroSemiologiaViewSet,
    ProtocoloQuirurgicoViewSet,
    PermisoViewSet,
    RolPermisoViewSet,
    UsuarioPermisoViewSet,
    CitaViewSet,
    TratamientoMateriaViewSet,
    PlanTratamientoViewSet,
    ProcedimientoPlanViewSet,
    EvolucionClinicaViewSet,
    TransferenciaPacienteViewSet,
    RemisionInterCatedraViewSet,
    register_user,
    obtener_registro_clinico,
)
from .viewsets_seguimiento import SeguimientoPacienteViewSet, EntradaSeguimientoViewSet, CupoEstudianteViewSet
from .views_reportes import ReportesViewSet

router = routers.DefaultRouter()
router.register(r'pacientes', PacienteViewSet)
router.register(r'historiales', HistorialClinicoViewSet)
router.register(r'contactos', ContactoEmergenciaViewSet)
router.register(r'usuarios', UsuarioViewSet)
router.register(r'roles', RolViewSet)
router.register(r'asignaciones', AsignacionViewSet)
# Ruta para tabla padre de antecedentes
router.register(r'antecedentes', AntecedenteViewSet, basename='antecedentes')
# Ruta simple de antecedentes consolidados
router.register(r'antecedentes_consolidados', AntecedenteConsolidadoViewSet, basename='antecedentes_consolidados')
# Rutas para materias clínicas
router.register(r'cirugia-bucal', RegistroCirugiaBucalViewSet)
router.register(r'operatoria-endodoncia', RegistroOperatoriaEndodonciaViewSet)
# Nueva ruta unificada para historia clínica modular
router.register(r'historia-clinica', RegistroHistoriaClinicaViewSet, basename='historia-clinica')
router.register(r'prostodoncia-fija', RegistroProstodonciaFijaViewSet)
router.register(r'prostodoncia-removible', RegistroProstodonciaRemovibleViewSet)
router.register(r'odontopediatria', RegistroOdontopediatriaViewSet)
router.register(r'semiologia', RegistroSemiologiaViewSet)
router.register(r'seguimientos', SeguimientoPacienteViewSet, basename='seguimientos')
router.register(r'entradas-seguimiento', EntradaSeguimientoViewSet, basename='entradas-seguimiento')
router.register(r'cupos-estudiante', CupoEstudianteViewSet, basename='cupos-estudiante')
router.register(r'protocolos-quirurgicos', ProtocoloQuirurgicoViewSet, basename='protocolos-quirurgicos')
# Gestión de permisos
router.register(r'permisos', PermisoViewSet, basename='permisos')
router.register(r'rol-permisos', RolPermisoViewSet, basename='rol-permisos')
router.register(r'usuario-permisos', UsuarioPermisoViewSet, basename='usuario-permisos')
# Citas médicas
router.register(r'citas', CitaViewSet, basename='citas')
# Tratamientos por materia
router.register(r'tratamientos', TratamientoMateriaViewSet, basename='tratamientos')
# Planes de tratamiento
router.register(r'planes-tratamiento', PlanTratamientoViewSet, basename='planes-tratamiento')
router.register(r'procedimientos-plan', ProcedimientoPlanViewSet, basename='procedimientos-plan')
router.register(r'evoluciones-clinicas', EvolucionClinicaViewSet, basename='evoluciones-clinicas')
router.register(r'transferencias-pacientes', TransferenciaPacienteViewSet, basename='transferencias-pacientes')
router.register(r'remisiones-intercatedra', RemisionInterCatedraViewSet, basename='remisiones-intercatedra')
# Reportes
router.register(r'reportes', ReportesViewSet, basename='reportes')

urlpatterns = [
    path('', include(router.urls)),
    path('auth/register/', register_user, name='register'),
    path('registro-clinico/<str:tipo_registro>/<str:registro_id>/', obtener_registro_clinico, name='obtener-registro-clinico'),
]
