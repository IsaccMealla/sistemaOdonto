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
    RegistroPeridonciaViewSet,
    RegistroHistoriaClinicaViewSet,
    RegistroProstodonciaFijaViewSet,
    RegistroProstodonciaRemovibleViewSet,
    RegistroOdontopediatriaViewSet,
    RegistroSemiologiaViewSet,
    register_user,
)

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
router.register(r'periodoncia', RegistroPeridonciaViewSet)
# Nueva ruta unificada para historia clínica modular
router.register(r'historia-clinica', RegistroHistoriaClinicaViewSet, basename='historia-clinica')
router.register(r'prostodoncia-fija', RegistroProstodonciaFijaViewSet)
router.register(r'prostodoncia-removible', RegistroProstodonciaRemovibleViewSet)
router.register(r'odontopediatria', RegistroOdontopediatriaViewSet)
router.register(r'semiologia', RegistroSemiologiaViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('auth/register/', register_user, name='register'),
]
