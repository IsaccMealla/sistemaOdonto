from django.contrib import admin
from .models import Pacientes, HistorialesClinicos, ContactosEmergencia, Usuarios, Roles, RegistroHistoriaClinica


@admin.register(Pacientes)
class PacientesAdmin(admin.ModelAdmin):
    list_display = ('id', 'nombres', 'apellidos', 'celular', 'ultima_consulta')
    search_fields = ('nombres', 'apellidos', 'celular')


@admin.register(HistorialesClinicos)
class HistorialesClinicosAdmin(admin.ModelAdmin):
    list_display = ('id', 'paciente', 'creado_en')
    search_fields = ('paciente__nombres', 'paciente__apellidos')


@admin.register(ContactosEmergencia)
class ContactosEmergenciaAdmin(admin.ModelAdmin):
    list_display = ('id', 'nombre', 'telefono', 'paciente')
    search_fields = ('nombre', 'telefono')


@admin.register(Usuarios)
class UsuariosAdmin(admin.ModelAdmin):
    list_display = ('id', 'username', 'email', 'activo', 'creado_en')
    search_fields = ('username', 'email')


@admin.register(Roles)
class RolesAdmin(admin.ModelAdmin):
    list_display = ('id', 'nombre')
    search_fields = ('nombre',)


@admin.register(RegistroHistoriaClinica)
class RegistroHistoriaClinicaAdmin(admin.ModelAdmin):
    list_display = ('id', 'paciente', 'estudiante', 'materia', 'tipo_registro', 'estado', 'fecha_registro')
    list_filter = ('materia', 'tipo_registro', 'estado', 'is_deleted', 'fecha_registro')
    search_fields = ('paciente__nombres', 'paciente__apellidos', 'estudiante__username', 'estudiante__nombres')
    date_hierarchy = 'fecha_registro'
    readonly_fields = ('fecha_registro', 'fecha_modificacion', 'fecha_aprobacion')
    
    fieldsets = (
        ('Información Básica', {
            'fields': ('id', 'historial', 'estudiante', 'paciente')
        }),
        ('Categorización', {
            'fields': ('materia', 'tipo_registro', 'estado')
        }),
        ('Datos del Registro', {
            'fields': ('datos',)
        }),
        ('Aprobación', {
            'fields': ('aprobado_por', 'fecha_aprobacion', 'observaciones_docente')
        }),
        ('Auditoría', {
            'fields': ('fecha_registro', 'fecha_modificacion', 'is_deleted', 'deleted_at', 'deleted_by'),
            'classes': ('collapse',)
        }),
    )
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('paciente', 'estudiante', 'aprobado_por')
