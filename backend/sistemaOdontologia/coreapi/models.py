# This is an auto-generated Django model module.

# You'll have to do the following manually to clean this up:

#   * Rearrange models' order

#   * Make sure each model has one field with primary_key=True

#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior

#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table

# Feel free to rename the models, but don't rename db_table values or field names.

from django.db import models
from django.utils import timezone
import uuid





class Antecedentes(models.Model):

    id = models.CharField(primary_key=True, max_length=36)

    historial = models.ForeignKey('HistorialesClinicos', on_delete=models.DO_NOTHING, db_column='historial_id')

    tipo = models.CharField(max_length=20)  # 'familiar', 'ginecologico', 'no_patologico', 'patologico'

    observaciones = models.TextField(blank=True, null=True)

    creado_en = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        try:
            paciente_nombre = f"{self.historial.paciente.nombres} {self.historial.paciente.apellidos}"
            return f"Antecedente {self.tipo} - {paciente_nombre}"
        except:
            return f"Antecedente {self.tipo} - {self.id}"

    class Meta:

        managed = True

        db_table = 'antecedentes'





class AntecedentesFamiliares(models.Model):

    antecedente = models.OneToOneField(Antecedentes, on_delete=models.CASCADE, primary_key=True, db_column='antecedente_id')

    alergia = models.BooleanField(default=False)

    asma_bronquial = models.BooleanField(default=False)

    cardiologicos = models.BooleanField(default=False)

    oncologicos = models.BooleanField(default=False)

    discrasias_sanguineas = models.BooleanField(default=False)

    diabetes = models.BooleanField(default=False)

    hipertension_arterial = models.BooleanField(default=False)

    renales = models.BooleanField(default=False)



    class Meta:

        managed = True

        db_table = 'antecedentes_familiares'





class AntecedentesGinecologicos(models.Model):

    antecedente = models.OneToOneField(Antecedentes, on_delete=models.CASCADE, primary_key=True, db_column='antecedente_id')

    embarazada = models.BooleanField(default=False)

    meses_embarazo = models.IntegerField(blank=True, null=True)

    anticonceptivos = models.BooleanField(default=False)

    ciclo_menstrual = models.BooleanField(default=False)

    fecha_ultima_menstruacion = models.DateField(blank=True, null=True)

    menopausia = models.BooleanField(default=False)

    edad_menopausia = models.IntegerField(blank=True, null=True)

    terapia_hormonal = models.BooleanField(default=False)



    class Meta:

        managed = True

        db_table = 'antecedentes_ginecologicos'





class AntecedentesNoPatologicos(models.Model):

    antecedente = models.OneToOneField(Antecedentes, on_delete=models.CASCADE, primary_key=True, db_column='antecedente_id')

    respira_boca = models.BooleanField(default=False)

    alimentos_citricos = models.BooleanField(default=False)

    muerde_unas = models.BooleanField(default=False)

    muerde_objetos = models.BooleanField(default=False)

    fuma = models.BooleanField(default=False)

    cantidad_cigarros = models.IntegerField(blank=True, null=True)

    apretamiento_dentario = models.BooleanField(default=False)



    class Meta:

        managed = True

        db_table = 'antecedentes_no_patologicos'





class AntecedentesPatologicosPersonales(models.Model):

    antecedente = models.OneToOneField(Antecedentes, on_delete=models.CASCADE, primary_key=True, db_column='antecedente_id')

    # Estado de salud
    ESTADO_CHOICES = [
        ('buena', 'Buena'),
        ('regular', 'Regular'),
        ('mala', 'Mala')
    ]
    estado_salud = models.CharField(max_length=10, choices=ESTADO_CHOICES, blank=True, null=True)

    fecha_ultimo_examen = models.DateField(blank=True, null=True)

    bajo_tratamiento_medico = models.BooleanField(default=False)

    toma_medicamentos = models.BooleanField(default=False)

    intervencion_quirurgica = models.BooleanField(default=False)

    sangra_excesivamente = models.BooleanField(default=False)

    problema_sanguineo = models.BooleanField(default=False)

    anemia = models.BooleanField(default=False)

    problemas_oncologicos = models.BooleanField(default=False)

    leucemia = models.BooleanField(default=False)

    problemas_renales = models.BooleanField(default=False)

    hemofilia = models.BooleanField(default=False)

    transfusion_sanguinea = models.BooleanField(default=False)

    deficit_vitamina_k = models.BooleanField(default=False)

    consume_drogas = models.BooleanField(default=False)

    problemas_corazon = models.BooleanField(default=False)

    # Alergias
    alergia_penicilina = models.BooleanField(default=False)

    alergia_anestesia = models.BooleanField(default=False)

    alergia_aspirina = models.BooleanField(default=False)

    alergia_yodo = models.BooleanField(default=False)

    alergia_otros = models.TextField(blank=True, null=True)

    fiebre_reumatica = models.BooleanField(default=False)

    asma = models.BooleanField(default=False)

    diabetes = models.BooleanField(default=False)

    ulcera_gastrica = models.BooleanField(default=False)

    # Tensión arterial
    TENSION_CHOICES = [
        ('normal', 'Normal'),
        ('alta', 'Alta'),
        ('baja', 'Baja')
    ]
    tension_arterial = models.CharField(max_length=10, choices=TENSION_CHOICES, blank=True, null=True)

    herpes_aftas_recurrentes = models.BooleanField(default=False)

    enfermedades_venereas = models.BooleanField(default=False)

    vih_positivo = models.BooleanField(default=False)

    otros = models.TextField(blank=True, null=True)



    class Meta:

        managed = True

        db_table = 'antecedentes_patologicos_personales'





class AuthGroup(models.Model):

    name = models.CharField(unique=True, max_length=150)



    class Meta:

        managed = False

        db_table = 'auth_group'





class AuthGroupPermissions(models.Model):

    id = models.BigAutoField(primary_key=True)

    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)



    class Meta:

        managed = False

        db_table = 'auth_group_permissions'

        unique_together = (('group', 'permission'),)





class AuthPermission(models.Model):

    name = models.CharField(max_length=255)

    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)

    codename = models.CharField(max_length=100)



    class Meta:

        managed = False

        db_table = 'auth_permission'

        unique_together = (('content_type', 'codename'),)





class AuthUser(models.Model):

    password = models.CharField(max_length=128)

    last_login = models.DateTimeField(blank=True, null=True)

    is_superuser = models.IntegerField()

    username = models.CharField(unique=True, max_length=150)

    first_name = models.CharField(max_length=150)

    last_name = models.CharField(max_length=150)

    email = models.CharField(max_length=254)

    is_staff = models.IntegerField()

    is_active = models.IntegerField()

    date_joined = models.DateTimeField()



    class Meta:

        managed = False

        db_table = 'auth_user'





class AuthUserGroups(models.Model):

    id = models.BigAutoField(primary_key=True)

    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)



    class Meta:

        managed = False

        db_table = 'auth_user_groups'

        unique_together = (('user', 'group'),)





class AuthUserUserPermissions(models.Model):

    id = models.BigAutoField(primary_key=True)

    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)



    class Meta:

        managed = False

        db_table = 'auth_user_user_permissions'

        unique_together = (('user', 'permission'),)





class ContactosEmergencia(models.Model):

    id = models.CharField(primary_key=True, max_length=36)

    paciente = models.ForeignKey('Pacientes', models.DO_NOTHING, blank=True, null=True)

    nombre = models.CharField(max_length=100)

    parentesco = models.CharField(max_length=50, blank=True, null=True)

    telefono = models.CharField(max_length=20, blank=True, null=True)
    
    # Campos para eliminación lógica
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(blank=True, null=True)
    deleted_by = models.CharField(max_length=100, blank=True, null=True)
    
    def soft_delete(self, user=None):
        """Eliminación lógica del contacto"""
        from django.utils import timezone
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.deleted_by = user
        self.save()
        
    def restore(self):
        """Restaurar contacto eliminado"""
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
        
    def hard_delete(self):
        """Eliminación física permanente"""
        try:
            from django.db import connection
            cursor = connection.cursor()
            
            # Eliminar el contacto permanentemente
            cursor.execute("DELETE FROM contactos_emergencia WHERE id = %s", [self.id])
            
        except Exception as e:
            raise Exception(f"Error al eliminar permanentemente el contacto: {str(e)}")



    class Meta:

        managed = True

        db_table = 'contactos_emergencia'





class DjangoAdminLog(models.Model):

    action_time = models.DateTimeField()

    object_id = models.TextField(blank=True, null=True)

    object_repr = models.CharField(max_length=200)

    action_flag = models.PositiveSmallIntegerField()

    change_message = models.TextField()

    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)

    user = models.ForeignKey(AuthUser, models.DO_NOTHING)



    class Meta:

        managed = False

        db_table = 'django_admin_log'





class DjangoContentType(models.Model):

    app_label = models.CharField(max_length=100)

    model = models.CharField(max_length=100)



    class Meta:

        managed = False

        db_table = 'django_content_type'

        unique_together = (('app_label', 'model'),)





class DjangoMigrations(models.Model):

    id = models.BigAutoField(primary_key=True)

    app = models.CharField(max_length=255)

    name = models.CharField(max_length=255)

    applied = models.DateTimeField()



    class Meta:

        managed = False

        db_table = 'django_migrations'





class DjangoSession(models.Model):

    session_key = models.CharField(primary_key=True, max_length=40)

    session_data = models.TextField()

    expire_date = models.DateTimeField()



    class Meta:

        managed = False

        db_table = 'django_session'





class HistorialesClinicos(models.Model):

    id = models.CharField(primary_key=True, max_length=36)

    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE)

    creado_en = models.DateTimeField(auto_now_add=True)



    class Meta:

        managed = True

        db_table = 'historiales_clinicos'





class ModeloPermisos(models.Model):

    pk = models.CompositePrimaryKey('modelo_id', 'permiso_id')

    modelo = models.ForeignKey('Modelos', models.DO_NOTHING)

    permiso = models.ForeignKey('Permisos', models.DO_NOTHING)



    class Meta:

        managed = False

        db_table = 'modelo_permisos'





class ModeloRoles(models.Model):

    pk = models.CompositePrimaryKey('modelo_id', 'rol_id')

    modelo = models.ForeignKey('Modelos', models.DO_NOTHING)

    rol = models.ForeignKey('Roles', models.DO_NOTHING)



    class Meta:

        managed = False

        db_table = 'modelo_roles'





class Modelos(models.Model):

    id = models.CharField(primary_key=True, max_length=36)

    nombre = models.CharField(unique=True, max_length=50)

    descripcion = models.TextField(blank=True, null=True)



    class Meta:

        managed = False

        db_table = 'modelos'





class Pacientes(models.Model):

    id = models.CharField(primary_key=True, max_length=36)

    apellidos = models.CharField(max_length=100)

    nombres = models.CharField(max_length=100)

    ci = models.CharField(max_length=20, blank=True, null=True, verbose_name='Cédula de Identidad')

    edad = models.IntegerField(blank=True, null=True)

    sexo = models.CharField(max_length=10, blank=True, null=True)

    fecha_nacimiento = models.DateField(blank=True, null=True)

    estado_civil = models.CharField(max_length=20, blank=True, null=True)

    ocupacion = models.CharField(max_length=100, blank=True, null=True)

    direccion = models.TextField(blank=True, null=True)

    celular = models.CharField(max_length=20, blank=True, null=True)

    ultima_consulta = models.DateField(blank=True, null=True)

    motivo_ultima_consulta = models.TextField(blank=True, null=True)

    creado_en = models.DateTimeField(auto_now_add=True)
    
    # Campos para eliminación lógica
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(blank=True, null=True)
    deleted_by = models.CharField(max_length=100, blank=True, null=True)  # Usuario que eliminó
    
    def soft_delete(self, user=None):
        """Eliminación lógica"""
        from django.utils import timezone
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.deleted_by = user
        self.save()
        
    def restore(self):
        """Restaurar paciente eliminado"""
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
        
    def hard_delete(self):
        """Eliminación física (permanente) con eliminación en cascada"""
        try:
            # Eliminar todos los registros relacionados manualmente
            
            # 1. Eliminar antecedentes (a través de historiales)
            from django.db import connection
            cursor = connection.cursor()
            
            # Obtener historiales del paciente
            cursor.execute("""
                SELECT id FROM historiales_clinicos 
                WHERE paciente_id = %s
            """, [self.id])
            historial_ids = [row[0] for row in cursor.fetchall()]
            
            # Eliminar antecedentes relacionados a estos historiales
            for historial_id in historial_ids:
                cursor.execute("DELETE FROM antecedentes_familiares WHERE antecedente_id IN (SELECT id FROM antecedentes WHERE historial_id = %s)", [historial_id])
                cursor.execute("DELETE FROM antecedentes_ginecologicos WHERE antecedente_id IN (SELECT id FROM antecedentes WHERE historial_id = %s)", [historial_id])
                cursor.execute("DELETE FROM antecedentes_no_patologicos WHERE antecedente_id IN (SELECT id FROM antecedentes WHERE historial_id = %s)", [historial_id])
                cursor.execute("DELETE FROM antecedentes_patologicos_personales WHERE antecedente_id IN (SELECT id FROM antecedentes WHERE historial_id = %s)", [historial_id])
                cursor.execute("DELETE FROM antecedentes WHERE historial_id = %s", [historial_id])
            
            # 2. Eliminar historiales clínicos
            cursor.execute("DELETE FROM historiales_clinicos WHERE paciente_id = %s", [self.id])
            
            # 3. Eliminar contactos de emergencia
            cursor.execute("DELETE FROM contactos_emergencia WHERE paciente_id = %s", [self.id])
            
            # 4. Finalmente eliminar el paciente
            cursor.execute("DELETE FROM pacientes WHERE id = %s", [self.id])
            
        except Exception as e:
            raise Exception(f"Error al eliminar permanentemente el paciente: {str(e)}")
        
    @property
    def nombre_completo(self):
        return f"{self.nombres} {self.apellidos}"



    class Meta:

        managed = True

        db_table = 'pacientes'





class Permisos(models.Model):

    id = models.CharField(primary_key=True, max_length=36)

    nombre = models.CharField(unique=True, max_length=100)

    descripcion = models.TextField(blank=True, null=True)



    class Meta:

        managed = False

        db_table = 'permisos'





class RolPermisos(models.Model):

    pk = models.CompositePrimaryKey('rol_id', 'permiso_id')

    rol = models.ForeignKey('Roles', models.DO_NOTHING)

    permiso = models.ForeignKey(Permisos, models.DO_NOTHING)



    class Meta:

        managed = False

        db_table = 'rol_permisos'





class Roles(models.Model):

    id = models.CharField(primary_key=True, max_length=36)

    nombre = models.CharField(unique=True, max_length=50)

    descripcion = models.TextField(blank=True, null=True)



    class Meta:

        managed = False

        db_table = 'roles'





class UsuarioRoles(models.Model):

    pk = models.CompositePrimaryKey('usuario_id', 'rol_id')

    usuario = models.ForeignKey('Usuarios', models.DO_NOTHING)

    rol = models.ForeignKey(Roles, models.DO_NOTHING)



    class Meta:

        managed = False

        db_table = 'usuario_roles'





class Usuarios(models.Model):

    id = models.CharField(primary_key=True, max_length=36)

    username = models.CharField(unique=True, max_length=50)

    email = models.CharField(unique=True, max_length=100)

    password_hash = models.TextField()

    activo = models.IntegerField(blank=True, null=True)

    creado_en = models.DateTimeField()
    
    # Campos adicionales
    nombres = models.CharField(max_length=100, blank=True, null=True)
    apellidos = models.CharField(max_length=100, blank=True, null=True)
    
    # Campos específicos para Estudiantes
    codigo_estudiante = models.CharField(max_length=20, blank=True, null=True, unique=True)
    semestre = models.IntegerField(blank=True, null=True)
    
    # Campos específicos para Docentes
    codigo_docente = models.CharField(max_length=20, blank=True, null=True, unique=True)
    especialidad = models.CharField(max_length=100, blank=True, null=True)
    materia = models.CharField(max_length=100, blank=True, null=True)  # Ej: Periodoncia, Odontopediatría, Prostodoncia, etc.
    
    # Campos para eliminación lógica
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(blank=True, null=True)
    deleted_by = models.CharField(max_length=100, blank=True, null=True)
    
    def soft_delete(self, user=None):
        """Eliminación lógica - desactiva el usuario"""
        from django.utils import timezone
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.deleted_by = user
        self.activo = 0  # También desactivar
        self.save()
        
    def restore(self):
        """Restaurar usuario eliminado"""
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.activo = 1  # Reactivar
        self.save()
        
    def hard_delete(self):
        """Eliminación física permanente"""
        try:
            from django.db import connection
            cursor = connection.cursor()
            
            # 1. Eliminar relaciones usuario-roles
            cursor.execute("DELETE FROM usuario_roles WHERE usuario_id = %s", [self.id])
            
            # 2. Eliminar el usuario
            cursor.execute("DELETE FROM usuarios WHERE id = %s", [self.id])
            
        except Exception as e:
            raise Exception(f"Error al eliminar permanentemente el usuario: {str(e)}")
    
    def set_password(self, password):
        """Establecer contraseña hasheada usando Django password hasher"""
        from django.contrib.auth.hashers import make_password
        self.password_hash = make_password(password)
        
    def check_password(self, password):
        """Verificar contraseña usando Django password hasher"""
        from django.contrib.auth.hashers import check_password
        return check_password(password, self.password_hash)
    
    def activate(self):
        """Activar usuario"""
        self.activo = 1
        self.save()
        
    def deactivate(self):
        """Desactivar usuario"""
        self.activo = 0
        self.save()
    
    @property
    def nombre_completo(self):
        if self.nombres and self.apellidos:
            return f"{self.nombres} {self.apellidos}"
        return self.username
    
    @property
    def esta_activo(self):
        return bool(self.activo) and not self.is_deleted
    
    # Propiedades de tipo de usuario basadas en roles
    @property
    def roles_list(self):
        """Retorna lista de nombres de roles del usuario"""
        try:
            return list(UsuarioRoles.objects.filter(usuario=self).values_list('rol__nombre', flat=True))
        except:
            return []
    
    @property
    def is_administrador(self):
        """Verifica si el usuario tiene rol de Administrador"""
        return 'Administrador' in self.roles_list
    
    @property
    def is_docente(self):
        """Verifica si el usuario tiene rol de Docente"""
        return 'Docente' in self.roles_list
    
    @property
    def is_estudiante(self):
        """Verifica si el usuario tiene rol de Estudiante"""
        return 'Estudiante' in self.roles_list
    
    def get_rol_principal(self):
        """Obtiene el rol principal del usuario (prioridad: Admin > Docente > Estudiante)"""
        if self.is_administrador:
            return 'Administrador'
        elif self.is_docente:
            return 'Docente'
        elif self.is_estudiante:
            return 'Estudiante'
        return 'Sin rol'



    class Meta:

        managed = True

        db_table = 'usuarios'


class Asignaciones(models.Model):
    """
    Modelo para asignaciones de pacientes a estudiantes con supervisión de docentes
    """
    id = models.CharField(primary_key=True, max_length=36)
    estudiante = models.ForeignKey(
        Usuarios, 
        on_delete=models.RESTRICT,
        related_name='asignaciones_estudiante',
        db_column='estudiante_id',
        limit_choices_to={'is_deleted': False}
    )
    paciente = models.ForeignKey(
        Pacientes,
        on_delete=models.RESTRICT,
        related_name='asignaciones_paciente',
        db_column='paciente_id',
        limit_choices_to={'is_deleted': False}
    )
    docente = models.ForeignKey(
        Usuarios,
        on_delete=models.RESTRICT,
        related_name='asignaciones_docente',
        db_column='docente_id',
        limit_choices_to={'is_deleted': False}
    )
    materia = models.CharField(max_length=100)  # Ej: Cirugía Bucal, Periodoncia, etc.
    fecha_asignacion = models.DateTimeField(default=timezone.now)
    fecha_finalizacion = models.DateTimeField(blank=True, null=True)
    estado = models.CharField(
        max_length=20,
        default='activa',
        choices=[
            ('activa', 'Activa'),
            ('en_progreso', 'En Progreso'),
            ('completada', 'Completada'),
            ('cancelada', 'Cancelada')
        ]
    )
    observaciones = models.TextField(blank=True, null=True)
    creado_en = models.DateTimeField(default=timezone.now)
    
    # Campos para soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(blank=True, null=True)
    deleted_by = models.CharField(max_length=100, blank=True, null=True)
    
    def soft_delete(self, user=None):
        """Eliminar asignación lógicamente"""
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        """Restaurar asignación eliminada"""
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    def hard_delete(self):
        """Eliminar permanentemente"""
        super().delete()
    
    class Meta:
        managed = True
        db_table = 'asignaciones'
        ordering = ['-fecha_asignacion']


# ========================================
# MODELOS DE MATERIAS CLÍNICAS
# ========================================

class RegistroCirugiaBucal(models.Model):
    """Registros de Cirugía Bucal"""
    id = models.CharField(primary_key=True, max_length=36)
    historial = models.ForeignKey('HistorialesClinicos', on_delete=models.CASCADE, db_column='historial_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, db_column='estudiante_id', related_name='cirugias_realizadas')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, db_column='paciente_id')
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Evaluación quirúrgica
    evaluacion_quirurgica = models.JSONField(default=dict, blank=True)
    
    # Evaluación anestésica
    evaluacion_anestesica = models.JSONField(default=dict, blank=True)
    
    # Registro operatorio (acto quirúrgico)
    registro_operatorio = models.JSONField(default=dict, blank=True)
    
    # Control postoperatorio
    control_postoperatorio = models.JSONField(default=list, blank=True)
    
    # Aprobación docente
    aprobado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='cirugias_aprobadas')
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    observaciones_docente = models.TextField(blank=True, null=True)
    estado = models.CharField(max_length=20, default='pendiente')  # pendiente, aprobado, rechazado
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    class Meta:
        managed = True
        db_table = 'registro_cirugia_bucal'
        ordering = ['-fecha_registro']


class RegistroOperatoriaEndodoncia(models.Model):
    """Registros de Operatoria y Endodoncia"""
    id = models.CharField(primary_key=True, max_length=36)
    historial = models.ForeignKey('HistorialesClinicos', on_delete=models.CASCADE, db_column='historial_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, db_column='estudiante_id', related_name='operatorias_realizadas')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, db_column='paciente_id')
    pieza_dental = models.CharField(max_length=5)
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Diagnósticos pulpares y periapicales
    diagnostico_pulpar = models.CharField(max_length=100, blank=True)
    diagnostico_periapical = models.CharField(max_length=100, blank=True)
    
    # Pruebas de sensibilidad
    pruebas_sensibilidad = models.JSONField(default=dict, blank=True)
    
    # Radiografías (URLs o paths)
    radiografia_pre = models.TextField(blank=True, null=True)
    radiografia_trans = models.TextField(blank=True, null=True)
    radiografia_post = models.TextField(blank=True, null=True)
    
    # Ficha operatoria restauradora
    ficha_operatoria = models.JSONField(default=dict, blank=True)
    
    # Registro completo del tratamiento endodóntico
    tratamiento_endodontico = models.JSONField(default=dict, blank=True)
    
    # Aprobación docente
    aprobado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='operatorias_aprobadas')
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    observaciones_docente = models.TextField(blank=True, null=True)
    estado = models.CharField(max_length=20, default='pendiente')
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    class Meta:
        managed = True
        db_table = 'registro_operatoria_endodoncia'
        ordering = ['-fecha_registro']




class RegistroHistoriaClinica(models.Model):
    """
    Modelo unificado para todos los registros de historia clínica.
    Usa enfoque modular con datos flexibles en JSON.
    Permite registrar cualquier tipo de módulo clínico (hábitos, exámenes, etc.)
    para cualquier materia de forma escalable.
    """
    
    MATERIA_CHOICES = [
        ('periodoncia', 'Periodoncia'),
        ('cirugia', 'Cirugía'),
        ('endodoncia', 'Endodoncia'),
        ('operatoria', 'Operatoria'),
        ('prostodoncia_fija', 'Prostodoncia Fija'),
        ('prostodoncia_removible', 'Prostodoncia Removible'),
        ('odontopediatria', 'Odontopediatría'),
        ('ortodoncia', 'Ortodoncia'),
    ]
    
    TIPO_REGISTRO_CHOICES = [
        # Periodoncia
        ('habitos', 'Hábitos'),
        ('antecedentes_periodontal', 'Antecedentes Periodontales'),
        ('examen_periodontal', 'Examen Periodontal'),
        ('periodontograma', 'Periodontograma'),
        ('diagnostico_radiografico', 'Diagnóstico Radiográfico'),
        ('examen_dental', 'Examen Dental'),
        
        # Odontopediatría
        ('clinica_odontopediatria', 'Clínica Odontopediatría'),
        ('oclusion', 'Oclusión'),
        
        # Prostodoncia
        ('prostodoncia_removible', 'Clínica de Prostodoncia Removible'),
        ('prostodoncia_fija', 'Clínica de Prostodoncia Fija'),
        
        # Otras materias (se pueden agregar más según necesidad)
        ('evaluacion_oclusal', 'Evaluación Oclusal'),
        ('radiografia', 'Radiografía'),
        ('diagnostico', 'Diagnóstico'),
        ('plan_tratamiento', 'Plan de Tratamiento'),
    ]
    
    ESTADO_CHOICES = [
        ('pendiente', 'Pendiente de Revisión'),
        ('revision', 'En Revisión'),
        ('aprobado', 'Aprobado'),
        ('rechazado', 'Rechazado'),
        ('corregir', 'Necesita Correcciones'),
    ]
    
    # Identificación
    id = models.CharField(primary_key=True, max_length=36, editable=False)
    
    # Relaciones
    historial = models.ForeignKey(
        'HistorialesClinicos',
        on_delete=models.CASCADE,
        db_column='historial_id',
        related_name='registros_clinicos',
        null=True,
        blank=True
    )
    estudiante = models.ForeignKey(
        'Usuarios',
        on_delete=models.CASCADE,
        db_column='estudiante_id',
        related_name='registros_realizados',
        null=True,
        blank=True
    )
    paciente = models.ForeignKey(
        'Pacientes',
        on_delete=models.CASCADE,
        db_column='paciente_id',
        related_name='registros_clinicos'
    )
    
    # Categorización
    materia = models.CharField(
        max_length=50,
        choices=MATERIA_CHOICES,
        db_index=True,
        help_text='Materia a la que pertenece este registro'
    )
    tipo_registro = models.CharField(
        max_length=50,
        choices=TIPO_REGISTRO_CHOICES,
        db_index=True,
        help_text='Tipo específico de registro (hábitos, periodontograma, etc.)'
    )
    
    # Datos flexibles
    datos = models.JSONField(
        default=dict,
        blank=True,
        help_text='Contenido del formulario en formato JSON'
    )
    
    # Auditoría
    fecha_registro = models.DateTimeField(auto_now_add=True)
    fecha_modificacion = models.DateTimeField(auto_now=True)
    
    # Aprobación docente
    aprobado_por = models.ForeignKey(
        'Usuarios',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        db_column='aprobado_por_id',
        related_name='registros_aprobados'
    )
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    observaciones_docente = models.TextField(blank=True, null=True)
    estado = models.CharField(
        max_length=20,
        choices=ESTADO_CHOICES,
        default='pendiente',
        db_index=True
    )
    
    # Soft delete
    is_deleted = models.BooleanField(default=False, db_index=True)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def __str__(self):
        try:
            tipo_display = dict(self.TIPO_REGISTRO_CHOICES).get(self.tipo_registro, self.tipo_registro)
            paciente_nombre = f"{self.paciente.nombres} {self.paciente.apellidos}"
            return f"{tipo_display} - {paciente_nombre} ({self.fecha_registro.strftime('%d/%m/%Y')})"
        except:
            return f"Registro {self.id}"
    
    def soft_delete(self, user=None):
        """Eliminación lógica del registro"""
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        """Restaurar registro eliminado"""
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    def aprobar(self, docente, observaciones=''):
        """Aprobar el registro"""
        self.estado = 'aprobado'
        self.aprobado_por = docente
        self.fecha_aprobacion = timezone.now()
        self.observaciones_docente = observaciones
        self.save()
    
    def rechazar(self, docente, observaciones):
        """Rechazar el registro"""
        self.estado = 'rechazado'
        self.aprobado_por = docente
        self.fecha_aprobacion = timezone.now()
        self.observaciones_docente = observaciones
        self.save()
    
    def solicitar_correccion(self, docente, observaciones):
        """Solicitar correcciones al estudiante"""
        self.estado = 'corregir'
        self.aprobado_por = docente
        self.observaciones_docente = observaciones
        self.save()
    
    class Meta:
        managed = True
        db_table = 'registro_historia_clinica'
        ordering = ['-fecha_registro']
        indexes = [
            # Índices compuestos para consultas comunes
            models.Index(fields=['paciente', 'materia', 'tipo_registro'], name='idx_pac_mat_tipo'),
            models.Index(fields=['estudiante', 'estado', 'fecha_registro'], name='idx_est_estado_fecha'),
            models.Index(fields=['historial', '-fecha_registro'], name='idx_hist_fecha'),
            models.Index(fields=['materia', 'tipo_registro', 'estado'], name='idx_mat_tipo_estado'),
        ]
        verbose_name = 'Registro de Historia Clínica'
        verbose_name_plural = 'Registros de Historia Clínica'


class RegistroProstodonciaFija(models.Model):
    """Registros de Prostodoncia Fija"""
    id = models.CharField(primary_key=True, max_length=36)
    historial = models.ForeignKey('HistorialesClinicos', on_delete=models.CASCADE, db_column='historial_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, db_column='estudiante_id', related_name='prostodoncia_fija_realizadas')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, db_column='paciente_id')
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Evaluación y selección de pilares
    evaluacion_pilares = models.JSONField(default=dict, blank=True)
    
    # Preparación y provisionales
    preparacion_provisionales = models.JSONField(default=dict, blank=True)
    
    # Materiales y laboratorio
    materiales_laboratorio = models.JSONField(default=dict, blank=True)
    
    # Prueba y cementación definitiva
    prueba_cementacion = models.JSONField(default=dict, blank=True)
    
    # Aprobación docente
    aprobado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='prostodoncia_fija_aprobadas')
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    observaciones_docente = models.TextField(blank=True, null=True)
    estado = models.CharField(max_length=20, default='pendiente')
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    class Meta:
        managed = True
        db_table = 'registro_prostodoncia_fija'
        ordering = ['-fecha_registro']


class RegistroProstodonciaRemovible(models.Model):
    """Registros de Prostodoncia Removible"""
    id = models.CharField(primary_key=True, max_length=36)
    historial = models.ForeignKey('HistorialesClinicos', on_delete=models.CASCADE, db_column='historial_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, db_column='estudiante_id', related_name='prostodoncia_removible_realizadas')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, db_column='paciente_id')
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Diseño protésico
    diseno_protesico = models.JSONField(default=dict, blank=True)
    
    # Pruebas clínicas secuenciales
    pruebas_clinicas = models.JSONField(default=list, blank=True)
    
    # Registro de laboratorio
    registro_laboratorio = models.JSONField(default=dict, blank=True)
    
    # Controles de adaptación
    controles_adaptacion = models.JSONField(default=list, blank=True)
    
    # Aprobación docente
    aprobado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='prostodoncia_removible_aprobadas')
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    observaciones_docente = models.TextField(blank=True, null=True)
    estado = models.CharField(max_length=20, default='pendiente')
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    class Meta:
        managed = True
        db_table = 'registro_prostodoncia_removible'
        ordering = ['-fecha_registro']


class RegistroOdontopediatria(models.Model):
    """Registros de Odontopediatría"""
    id = models.CharField(primary_key=True, max_length=36)
    historial = models.ForeignKey('HistorialesClinicos', on_delete=models.CASCADE, db_column='historial_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, db_column='estudiante_id', related_name='odontopediatrias_realizadas')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, db_column='paciente_id')
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Ficha psicosocial y conducta
    ficha_psicosocial = models.JSONField(default=dict, blank=True)
    
    # Odontograma infantil (20 dientes)
    odontograma_infantil = models.JSONField(default=dict, blank=True)
    
    # Guía erupcional
    guia_erupcional = models.JSONField(default=dict, blank=True)
    
    # Tratamientos: sellantes, fluorización, pulpotomía, etc.
    tratamientos_realizados = models.JSONField(default=list, blank=True)
    
    # Aprobación docente
    aprobado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='odontopediatrias_aprobadas')
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    observaciones_docente = models.TextField(blank=True, null=True)
    estado = models.CharField(max_length=20, default='pendiente')
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    class Meta:
        managed = True
        db_table = 'registro_odontopediatria'
        ordering = ['-fecha_registro']


class RegistroSemiologia(models.Model):
    """Registros de Semiología"""
    id = models.CharField(primary_key=True, max_length=36)
    historial = models.ForeignKey('HistorialesClinicos', on_delete=models.CASCADE, db_column='historial_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, db_column='estudiante_id', related_name='semiologias_realizadas')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, db_column='paciente_id')
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Lesiones orales: descripción, clasificación y diagnóstico presuntivo
    lesiones_orales = models.JSONField(default=list, blank=True)
    
    # Imágenes adjuntas (URLs)
    imagenes = models.JSONField(default=list, blank=True)
    
    # Referencias
    referencias = models.TextField(blank=True, null=True)
    
    # Registro de biopsias y resultados
    biopsias = models.JSONField(default=list, blank=True)
    
    # Aprobación docente
    aprobado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='semiologias_aprobadas')
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    observaciones_docente = models.TextField(blank=True, null=True)
    estado = models.CharField(max_length=20, default='pendiente')
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    class Meta:
        managed = True
        db_table = 'registro_semiologia'
        ordering = ['-fecha_registro']


class SeguimientoPaciente(models.Model):
    """Hoja de seguimiento de un estudiante con un paciente"""
    MATERIAS_CHOICES = [
        ('cirugia_bucal', 'Cirugía Bucal'),
        ('operatoria_endodoncia', 'Operatoria y Endodoncia'),
        ('periodoncia', 'Periodoncia'),
        ('prostodoncia_fija', 'Prostodoncia Fija'),
        ('prostodoncia_removible', 'Prostodoncia Removible'),
        ('odontopediatria', 'Odontopediatría'),
        ('semiologia', 'Semiología'),
    ]
    
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='seguimientos_estudiante')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, related_name='seguimientos')
    materia_clinica = models.CharField(max_length=50, choices=MATERIAS_CHOICES, null=True, blank=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    activo = models.BooleanField(default=True)
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    def __str__(self):
        return f"Seguimiento: {self.estudiante.username} - {self.paciente.nombres} {self.paciente.apellidos}"
    
    class Meta:
        managed = True
        db_table = 'seguimiento_paciente'
        ordering = ['-fecha_creacion']


class EntradaSeguimiento(models.Model):
    """Cada fila de la hoja de seguimiento con referencias a registros clínicos"""
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    seguimiento = models.ForeignKey('SeguimientoPaciente', on_delete=models.CASCADE, related_name='entradas')
    fecha = models.DateField()
    pieza_dental = models.CharField(max_length=10)  # Ej: "1.6", "4.3"
    tratamiento = models.TextField()  # Descripción del tratamiento realizado
    nro_presupuesto = models.CharField(max_length=50, blank=True, null=True)
    
    # Referencias a registros de historia clínica (JSON)
    # Formato: [{"tipo": "periodontograma", "registro_id": "uuid", "descripcion": "Periodontograma inicial", "fecha": "2025-12-16"}]
    referencias_clinicas = models.JSONField(default=list, blank=True)
    
    # Firma del docente
    firmado = models.BooleanField(default=False)
    firmado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='entradas_firmadas')
    fecha_firma = models.DateTimeField(null=True, blank=True)
    observaciones = models.TextField(blank=True)
    
    orden = models.IntegerField(default=0)
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    def __str__(self):
        return f"{self.fecha} - Pieza {self.pieza_dental}: {self.tratamiento[:50]}"
    
    class Meta:
        managed = True
        db_table = 'entrada_seguimiento'
        ordering = ['-fecha', '-fecha_registro']


class ProtocoloQuirurgico(models.Model):
    """Protocolo quirúrgico para procedimientos como extracciones"""
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    paciente = models.ForeignKey(
        'Pacientes',
        on_delete=models.RESTRICT,
        related_name='protocolos_quirurgicos',
        limit_choices_to={'is_deleted': False}
    )
    estudiante = models.ForeignKey(
        'Usuarios',
        on_delete=models.RESTRICT,
        related_name='protocolos_estudiante',
        limit_choices_to={'is_deleted': False}
    )
    
    # Campos generales del protocolo
    observaciones = models.TextField(blank=True, null=True)
    diagnostico_preoperatorio = models.TextField()
    diagnostico_postoperatorio = models.TextField()
    cirujano = models.CharField(max_length=200)
    anestesiologo = models.CharField(max_length=200, blank=True, null=True)
    ayudantes = models.CharField(max_length=300, blank=True, null=True)
    instrumentista = models.CharField(max_length=200, blank=True, null=True)
    circulantes = models.CharField(max_length=200, blank=True, null=True)
    tecnica_anestesia = models.CharField(max_length=200, blank=True, null=True)
    duracion_cirugia = models.CharField(max_length=100, blank=True, null=True)  # Ej: "45 minutos"
    docente = models.ForeignKey(
        'Usuarios',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='protocolos_supervisados',
        limit_choices_to={'is_deleted': False}
    )
    
    # HALLAZGOS PRE-QUIRÚRGICOS
    hallazgos_clinicos = models.TextField(blank=True, null=True)
    hallazgos_radiograficos = models.TextField(blank=True, null=True)
    hallazgos_laboratoriales = models.TextField(blank=True, null=True)
    hallazgos_otros = models.TextField(blank=True, null=True)
    
    # DESCRIPCIONES
    descripcion_procedimiento = models.TextField()
    hallazgos_quirurgicos = models.TextField(blank=True, null=True)
    accidentes_quirurgicos = models.TextField(blank=True, null=True)
    indicaciones_posquirurgicas = models.TextField(blank=True, null=True)
    receta = models.TextField(blank=True, null=True)
    
    # Metadatos
    fecha_cirugia = models.DateField()
    fecha_creacion = models.DateTimeField(default=timezone.now)
    fecha_modificacion = models.DateTimeField(auto_now=True)
    
    # Soft delete
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.CharField(max_length=100, null=True, blank=True)
    
    def soft_delete(self, user=None):
        self.is_deleted = True
        self.deleted_at = timezone.now()
        if user:
            self.deleted_by = user if isinstance(user, str) else getattr(user, 'username', str(user))
        self.save()
    
    def restore(self):
        self.is_deleted = False
        self.deleted_at = None
        self.deleted_by = None
        self.save()
    
    def __str__(self):
        return f"Protocolo Quirúrgico - {self.paciente.nombres} {self.paciente.apellidos} ({self.fecha_cirugia})"
    
    class Meta:
        managed = True
        db_table = 'protocolo_quirurgico'
        ordering = ['-fecha_cirugia', '-fecha_creacion']


class Permiso(models.Model):
    """
    Permisos granulares del sistema
    Ej: pacientes.crear, pacientes.editar, usuarios.eliminar
    """
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    codigo = models.CharField(max_length=100, unique=True, db_index=True)  # Ej: "pacientes.crear"
    nombre = models.CharField(max_length=200)  # Ej: "Crear Pacientes"
    descripcion = models.TextField(blank=True, null=True)
    categoria = models.CharField(max_length=50, db_index=True)  # Ej: "pacientes", "usuarios", "historiales"
    accion = models.CharField(max_length=20)  # Ej: "crear", "editar", "eliminar", "ver"
    activo = models.BooleanField(default=True)
    creado_en = models.DateTimeField(default=timezone.now)
    
    class Meta:
        managed = True
        db_table = 'permisos'
        ordering = ['categoria', 'accion']
        verbose_name = 'Permiso'
        verbose_name_plural = 'Permisos'
    
    def __str__(self):
        return f"{self.nombre} ({self.codigo})"


class RolPermiso(models.Model):
    """Permisos asignados a un rol"""
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    rol = models.ForeignKey('Roles', on_delete=models.CASCADE, related_name='permisos_rol')
    permiso = models.ForeignKey('Permiso', on_delete=models.CASCADE, related_name='roles_permiso')
    otorgado_por = models.ForeignKey(
        'Usuarios',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='permisos_otorgados_rol'
    )
    fecha_asignacion = models.DateTimeField(default=timezone.now)
    
    class Meta:
        managed = True
        db_table = 'rol_permiso'
        unique_together = ['rol', 'permiso']
        verbose_name = 'Permiso de Rol'
        verbose_name_plural = 'Permisos de Roles'
    
    def __str__(self):
        return f"{self.rol.nombre} - {self.permiso.codigo}"


class UsuarioPermiso(models.Model):
    """
    Permisos específicos asignados a un usuario individual
    Estos permisos se suman a los del rol (no los reemplazan)
    """
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    usuario = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='permisos_especificos')
    permiso = models.ForeignKey('Permiso', on_delete=models.CASCADE, related_name='usuarios_permiso')
    tipo = models.CharField(
        max_length=10,
        choices=[
            ('grant', 'Otorgar'),  # Dar permiso adicional
            ('deny', 'Denegar'),   # Quitar permiso específico
        ],
        default='grant'
    )
    otorgado_por = models.ForeignKey(
        'Usuarios',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='permisos_otorgados_usuario'
    )
    fecha_asignacion = models.DateTimeField(default=timezone.now)
    motivo = models.TextField(blank=True, null=True)  # Razón de la asignación específica
    
    class Meta:
        managed = True
        db_table = 'usuario_permiso'
        unique_together = ['usuario', 'permiso']
        verbose_name = 'Permiso de Usuario'
        verbose_name_plural = 'Permisos de Usuarios'
    
    def __str__(self):
        return f"{self.usuario.username} - {self.permiso.codigo} ({self.tipo})"


class Citas(models.Model):
    """
    Modelo para gestionar citas médicas entre pacientes, estudiantes y docentes
    """
    ESTADO_CHOICES = [
        ('pendiente', 'Pendiente'),
        ('aprobada', 'Aprobada'),
        ('rechazada', 'Rechazada'),
        ('completada', 'Completada'),
        ('cancelada', 'Cancelada'),
    ]
    
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, related_name='citas', db_column='paciente_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='citas_estudiante', db_column='estudiante_id')
    docente = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='citas_docente', db_column='docente_id', null=True, blank=True)
    fecha_hora = models.DateTimeField()
    motivo = models.TextField()
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='pendiente')
    observaciones_docente = models.TextField(blank=True, null=True)
    motivo_cancelacion = models.TextField(blank=True, null=True)
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = True
        db_table = 'citas'
        verbose_name = 'Cita'
        verbose_name_plural = 'Citas'
        ordering = ['-fecha_hora']
    
    def __str__(self):
        return f"Cita {self.id} - {self.paciente} - {self.fecha_hora.strftime('%Y-%m-%d %H:%M')}"


class TratamientoMateria(models.Model):
    """
    Registro de tratamientos completados por estudiantes en cada materia clínica.
    Permite controlar el progreso de cupos por materia (objetivo: 10 por semestre).
    """
    MATERIAS_CHOICES = [
        ('cirugia_bucal', 'Cirugía Bucal'),
        ('operatoria_endodoncia', 'Operatoria y Endodoncia'),
        ('periodoncia', 'Periodoncia'),
        ('prostodoncia_fija', 'Prostodoncia Fija'),
        ('prostodoncia_removible', 'Prostodoncia Removible'),
        ('odontopediatria', 'Odontopediatría'),
        ('semiologia', 'Semiología'),
    ]
    
    ESTADO_CHOICES = [
        ('borrador', 'Borrador'),
        ('solicitado', 'Pendiente de Aprobación'),
        ('aprobado', 'Aprobado'),
        ('rechazado', 'Rechazado'),
    ]
    
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='tratamientos_estudiante', db_column='estudiante_id')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, related_name='tratamientos_paciente', db_column='paciente_id')
    materia = models.CharField(max_length=50, choices=MATERIAS_CHOICES)
    seguimiento = models.ForeignKey('SeguimientoPaciente', on_delete=models.CASCADE, related_name='tratamientos', db_column='seguimiento_id', null=True, blank=True)
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='borrador')
    
    # Fechas de seguimiento
    fecha_solicitud = models.DateTimeField(null=True, blank=True)
    fecha_revision = models.DateTimeField(null=True, blank=True)
    
    # Revisión docente
    docente_revisor = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='tratamientos_revisados', db_column='docente_revisor_id')
    observaciones_docente = models.TextField(blank=True, null=True)
    
    # Control de cupos
    cupo_numero = models.IntegerField(null=True, blank=True)  # 1 al 10
    
    # Metadata
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = True
        db_table = 'tratamiento_materia'
        verbose_name = 'Tratamiento de Materia'
        verbose_name_plural = 'Tratamientos de Materias'
        ordering = ['-creado_en']
        indexes = [
            models.Index(fields=['estudiante', 'materia']),
            models.Index(fields=['estado']),
        ]
    
    def __str__(self):
        return f"{self.get_materia_display()} - {self.estudiante.username} - Cupo {self.cupo_numero or 'N/A'}"
    
    def solicitar_aprobacion(self):
        """Cambia el estado a 'solicitado' y registra la fecha"""
        self.estado = 'solicitado'
        self.fecha_solicitud = timezone.now()
        self.save()
    
    def aprobar(self, docente, observaciones=''):
        """Aprueba el tratamiento y asigna número de cupo"""
        self.estado = 'aprobado'
        self.fecha_revision = timezone.now()
        self.docente_revisor = docente
        self.observaciones_docente = observaciones
        
        # Asignar número de cupo automáticamente
        if not self.cupo_numero:
            ultimo_cupo = TratamientoMateria.objects.filter(
                estudiante=self.estudiante,
                materia=self.materia,
                estado='aprobado'
            ).exclude(id=self.id).aggregate(models.Max('cupo_numero'))
            
            self.cupo_numero = (ultimo_cupo['cupo_numero__max'] or 0) + 1
        
        self.save()
    
    def rechazar(self, docente, observaciones):
        """Rechaza el tratamiento con observaciones"""
        self.estado = 'rechazado'
        self.fecha_revision = timezone.now()
        self.docente_revisor = docente
        self.observaciones_docente = observaciones
        self.save()


class PlanTratamiento(models.Model):
    """
    Plan de tratamiento odontológico para un paciente.
    Agrupa procedimientos y evoluciones clínicas por materia.
    """
    ESTADO_CHOICES = [
        ('borrador', 'Borrador'),
        ('aprobado', 'Aprobado'),
        ('en_ejecucion', 'En Ejecución'),
        ('completado', 'Completado'),
        ('suspendido', 'Suspendido'),
    ]
    
    MATERIAS_CHOICES = [
        ('cirugia_bucal', 'Cirugía Bucal'),
        ('operatoria_endodoncia', 'Operatoria y Endodoncia'),
        ('periodoncia', 'Periodoncia'),
        ('prostodoncia_fija', 'Prostodoncia Fija'),
        ('prostodoncia_removible', 'Prostodoncia Removible'),
        ('odontopediatria', 'Odontopediatría'),
        ('semiologia', 'Semiología'),
    ]
    
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, related_name='planes_tratamiento', db_column='paciente_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='planes_creados', db_column='estudiante_id')
    materia = models.CharField(max_length=50, choices=MATERIAS_CHOICES)
    
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='borrador')
    
    # Aprobación docente
    aprobado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='planes_aprobados', db_column='aprobado_por_id')
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    
    observaciones_generales = models.TextField(blank=True)
    
    # Estadísticas (calculadas automáticamente)
    total_procedimientos = models.IntegerField(default=0)
    procedimientos_completados = models.IntegerField(default=0)
    progreso_porcentaje = models.FloatField(default=0.0)
    
    actualizado_en = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = True
        db_table = 'plan_tratamiento'
        verbose_name = 'Plan de Tratamiento'
        verbose_name_plural = 'Planes de Tratamiento'
        ordering = ['-fecha_creacion']
    
    def __str__(self):
        return f"Plan {self.get_materia_display()} - {self.paciente.nombres} {self.paciente.apellidos}"
    
    def actualizar_estadisticas(self):
        """Recalcula las estadísticas del plan"""
        procedimientos = self.procedimientos.all()
        self.total_procedimientos = procedimientos.count()
        self.procedimientos_completados = procedimientos.filter(estado='completado').count()
        if self.total_procedimientos > 0:
            self.progreso_porcentaje = (self.procedimientos_completados / self.total_procedimientos) * 100
        else:
            self.progreso_porcentaje = 0.0
        self.save()
    
    def aprobar(self, docente):
        """Aprueba el plan de tratamiento"""
        self.estado = 'aprobado'
        self.aprobado_por = docente
        self.fecha_aprobacion = timezone.now()
        self.save()


class ProcedimientoPlan(models.Model):
    """
    Procedimiento individual dentro de un plan de tratamiento.
    """
    PRIORIDAD_CHOICES = [
        ('urgente', 'Urgente'),
        ('alta', 'Alta'),
        ('media', 'Media'),
        ('baja', 'Baja'),
    ]
    
    ESTADO_CHOICES = [
        ('pendiente', 'Pendiente'),
        ('en_progreso', 'En Progreso'),
        ('completado', 'Completado'),
        ('cancelado', 'Cancelado'),
    ]
    
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    plan = models.ForeignKey('PlanTratamiento', on_delete=models.CASCADE, related_name='procedimientos', db_column='plan_id')
    
    secuencia = models.IntegerField()  # Orden en el plan
    codigo_tratamiento = models.CharField(max_length=50, blank=True)  # Ej: "EXO-01"
    descripcion = models.TextField()
    pieza_dental = models.CharField(max_length=10, blank=True, null=True)  # "1.8", "4.3"
    
    prioridad = models.CharField(max_length=20, choices=PRIORIDAD_CHOICES, default='media')
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='pendiente')
    
    # Fechas
    fecha_planificada = models.DateField(null=True, blank=True)
    fecha_iniciado = models.DateField(null=True, blank=True)
    fecha_completado = models.DateField(null=True, blank=True)
    
    # Costos
    costo_estimado = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    costo_real = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    observaciones = models.TextField(blank=True)
    motivo_cancelacion = models.TextField(blank=True, null=True)
    
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = True
        db_table = 'procedimiento_plan'
        verbose_name = 'Procedimiento del Plan'
        verbose_name_plural = 'Procedimientos del Plan'
        ordering = ['plan', 'secuencia']
    
    def __str__(self):
        return f"{self.secuencia}. {self.descripcion[:50]}"
    
    def completar(self, costo_real=None):
        """Marca el procedimiento como completado y actualiza cupos del estudiante"""
        self.estado = 'completado'
        self.fecha_completado = timezone.now().date()
        if costo_real is not None:
            self.costo_real = costo_real
        self.save()
        
        # Actualizar estadísticas del plan
        self.plan.actualizar_estadisticas()
        
        # Incrementar cupo del estudiante en esta materia
        from .models import CupoEstudiante
        CupoEstudiante.incrementar_cupo(
            estudiante=self.plan.estudiante,
            materia=self.plan.materia
        )
    
    def iniciar(self):
        """Marca el procedimiento como en progreso"""
        if self.estado == 'pendiente':
            self.estado = 'en_progreso'
            self.fecha_iniciado = timezone.now().date()
            self.save()


class EvolucionClinica(models.Model):
    """
    Registro de evolución clínica por sesión.
    Diario de lo realizado en cada cita.
    Incluye referencias a registros de historia clínica vinculados.
    """
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    plan = models.ForeignKey('PlanTratamiento', on_delete=models.CASCADE, related_name='evoluciones', db_column='plan_id')
    procedimiento = models.ForeignKey('ProcedimientoPlan', on_delete=models.SET_NULL, null=True, blank=True, related_name='evoluciones', db_column='procedimiento_id')
    
    # Sesión
    fecha_sesion = models.DateTimeField()
    numero_sesion = models.IntegerField()
    
    # Registro clínico
    tratamiento_realizado = models.TextField()
    hallazgos_clinicos = models.TextField(blank=True)
    complicaciones = models.TextField(blank=True)
    materiales_usados = models.TextField(blank=True)
    
    # Referencias a registros de historia clínica (JSON)
    # Formato: [{"tipo": "periodontograma", "registro_id": "uuid", "descripcion": "Periodontograma inicial", "fecha": "2025-12-16"}]
    referencias_clinicas = models.JSONField(default=list, blank=True)
    
    # Archivos adjuntos (fotos, documentos)
    # Formato: [{"nombre": "foto_antes.jpg", "url": "/media/...", "tipo": "imagen", "descripcion": "Foto antes del tratamiento"}]
    archivos_adjuntos = models.JSONField(default=list, blank=True)
    
    # Próxima cita
    proxima_cita = models.DateField(null=True, blank=True)
    indicaciones_proxima_cita = models.TextField(blank=True)
    
    # Firmas
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='evoluciones_estudiante', db_column='estudiante_id')
    docente_supervisor = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='evoluciones_docente', db_column='docente_supervisor_id')
    firmado_estudiante = models.BooleanField(default=False)
    firmado_docente = models.BooleanField(default=False)
    fecha_firma_estudiante = models.DateTimeField(null=True, blank=True)
    fecha_firma_docente = models.DateTimeField(null=True, blank=True)
    
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = True
        db_table = 'evolucion_clinica'
        verbose_name = 'Evolución Clínica'
        verbose_name_plural = 'Evoluciones Clínicas'
        ordering = ['plan', '-fecha_sesion']
    
    def __str__(self):
        return f"Sesión {self.numero_sesion} - {self.plan.paciente.nombres}"
    
    def firmar_estudiante(self):
        """Firma de estudiante"""
        self.firmado_estudiante = True
        self.fecha_firma_estudiante = timezone.now()
        self.save()
    
    def firmar_docente(self):
        """Firma de docente"""
        self.firmado_docente = True
        self.fecha_firma_docente = timezone.now()
        self.save()


class TransferenciaPaciente(models.Model):
    """
    Transferencia de paciente a otra materia/especialidad con motivo y aprobación.
    El docente de la materia destino asignará al estudiante correspondiente.
    """
    MATERIAS_CHOICES = PlanTratamiento.MATERIAS_CHOICES
    
    MOTIVO_CHOICES = [
        ('graduacion', 'Graduación del Estudiante'),
        ('cambio_grupo', 'Cambio de Grupo'),
        ('abandono_estudiante', 'Abandono del Estudiante'),
        ('solicitud_paciente', 'Solicitud del Paciente'),
        ('requiere_especialidad', 'Requiere Otra Especialidad'),
        ('otro', 'Otro'),
    ]
    
    ESTADO_CHOICES = [
        ('solicitada', 'Solicitada'),
        ('aprobada', 'Aprobada'),
        ('asignada', 'Asignada a Estudiante'),
        ('rechazada', 'Rechazada'),
    ]
    
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, related_name='transferencias', db_column='paciente_id')
    
    # Origen
    estudiante_origen = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='transferencias_origen', db_column='estudiante_origen_id')
    materia_origen = models.CharField(max_length=50, choices=MATERIAS_CHOICES)
    
    # Destino (materia, NO estudiante específico)
    materia_destino = models.CharField(max_length=50, choices=MATERIAS_CHOICES)
    estudiante_destino = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='transferencias_destino', null=True, blank=True, db_column='estudiante_destino_id')
    
    # Motivo
    motivo = models.CharField(max_length=50, choices=MOTIVO_CHOICES)
    motivo_detalle = models.TextField()
    
    # Estado del tratamiento
    plan_original = models.ForeignKey('PlanTratamiento', on_delete=models.SET_NULL, null=True, blank=True, related_name='transferencias', db_column='plan_original_id')
    resumen_tratamiento = models.TextField()  # Qué se hizo
    tratamiento_pendiente = models.TextField()  # Qué falta
    
    # Aprobación
    docente_aprobador = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='transferencias_aprobadas', null=True, blank=True, db_column='docente_aprobador_id')
    fecha_solicitud = models.DateTimeField(auto_now_add=True)
    fecha_aprobacion = models.DateTimeField(null=True, blank=True)
    fecha_asignacion = models.DateTimeField(null=True, blank=True)
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='solicitada')
    observaciones_docente = models.TextField(blank=True)
    
    
    # Nueva asignación
    nueva_asignacion = models.ForeignKey('Asignaciones', on_delete=models.SET_NULL, null=True, blank=True, db_column='nueva_asignacion_id')
    
    class Meta:
        managed = True
        db_table = 'transferencia_paciente'
        verbose_name = 'Transferencia de Paciente'
        verbose_name_plural = 'Transferencias de Pacientes'
        ordering = ['-fecha_solicitud']
    
    def __str__(self):
        destino = self.estudiante_destino.username if self.estudiante_destino else self.get_materia_destino_display()
        return f"Transferencia: {self.paciente.nombres} → {destino}"
    
    def aprobar(self, docente, observaciones=''):
        """Aprueba la transferencia - queda pendiente asignación de estudiante"""
        self.estado = 'aprobada'
        self.fecha_aprobacion = timezone.now()
        self.docente_aprobador = docente
        self.observaciones_docente = observaciones
        self.save()
        return self
    
    def asignar_estudiante(self, estudiante_destino, docente):
        """Asigna el estudiante específico y crea nueva asignación"""
        self.estudiante_destino = estudiante_destino
        self.estado = 'asignada'
        self.fecha_asignacion = timezone.now()
        
        # Crear nueva asignación
        nueva_asignacion = Asignaciones.objects.create(
            paciente=self.paciente,
            estudiante=estudiante_destino,
            docente=docente,
        )
        self.nueva_asignacion = nueva_asignacion
        
        # Desactivar asignación anterior (soft)
        asignacion_anterior = Asignaciones.objects.filter(
            paciente=self.paciente,
            estudiante=self.estudiante_origen,
            activo=True
        ).first()
        if asignacion_anterior:
            asignacion_anterior.activo = False
            asignacion_anterior.save()
        
        self.save()
        return self
    
    def rechazar(self, docente, observaciones):
        """Rechaza la transferencia"""
        self.estado = 'rechazada'
        self.fecha_aprobacion = timezone.now()
        self.docente_aprobador = docente
        self.observaciones_docente = observaciones
        self.save()
        return self


class RemisionInterCatedra(models.Model):
    """
    Remisión de paciente entre diferentes cátedras/materias para procedimientos específicos.
    """
    MATERIAS_CHOICES = PlanTratamiento.MATERIAS_CHOICES
    
    ESTADO_CHOICES = [
        ('pendiente', 'Pendiente'),
        ('en_atencion', 'En Atención'),
        ('completada', 'Completada'),
        ('rechazada', 'Rechazada'),
    ]
    
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, related_name='remisiones', db_column='paciente_id')
    plan_origen = models.ForeignKey('PlanTratamiento', on_delete=models.CASCADE, related_name='remisiones_origen', db_column='plan_origen_id')
    
    # Origen
    materia_origen = models.CharField(max_length=50, choices=MATERIAS_CHOICES)
    estudiante_remite = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='remisiones_emite', db_column='estudiante_remite_id')
    docente_autoriza = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='remisiones_autoriza', db_column='docente_autoriza_id')
    
    # Destino
    materia_destino = models.CharField(max_length=50, choices=MATERIAS_CHOICES)
    estudiante_recibe = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='remisiones_recibe', db_column='estudiante_recibe_id')
    
    # Motivo de remisión
    fecha_remision = models.DateTimeField(auto_now_add=True)
    diagnostico_origen = models.TextField()
    tratamiento_solicitado = models.TextField()
    hallazgos_relevantes = models.TextField(blank=True)
    urgencia = models.BooleanField(default=False)
    
    # Contra-referencia (respuesta desde materia destino)
    fecha_atencion = models.DateTimeField(null=True, blank=True)
    tratamiento_realizado = models.TextField(blank=True)
    hallazgos_catedra_destino = models.TextField(blank=True)
    recomendaciones = models.TextField(blank=True)
    
    # Estado
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='pendiente')
    plan_destino = models.ForeignKey('PlanTratamiento', on_delete=models.SET_NULL, null=True, blank=True, related_name='remisiones_destino', db_column='plan_destino_id')
    
    actualizado_en = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = True
        db_table = 'remision_inter_catedra'
        verbose_name = 'Remisión Inter-Cátedra'
        verbose_name_plural = 'Remisiones Inter-Cátedra'
        ordering = ['-fecha_remision']
    
    def __str__(self):
        return f"Remisión: {self.get_materia_origen_display()} → {self.get_materia_destino_display()}"
    
    def completar_atencion(self, tratamiento_realizado, hallazgos, recomendaciones=''):
        """Registra la atención en la cátedra destino"""
        self.estado = 'completada'
        self.fecha_atencion = timezone.now()
        self.tratamiento_realizado = tratamiento_realizado
        self.hallazgos_catedra_destino = hallazgos
        self.recomendaciones = recomendaciones
        self.save()


class CupoEstudiante(models.Model):
    """
    Tracking de cupos/requisitos completados por estudiante en cada materia.
    Se actualiza automáticamente al completar procedimientos.
    """
    MATERIAS_CHOICES = [
        ('cirugia_bucal', 'Cirugía Bucal'),
        ('operatoria_endodoncia', 'Operatoria y Endodoncia'),
        ('periodoncia', 'Periodoncia'),
        ('prostodoncia_fija', 'Prostodoncia Fija'),
        ('prostodoncia_removible', 'Prostodoncia Removible'),
        ('odontopediatria', 'Odontopediatría'),
        ('semiologia', 'Semiología'),
    ]
    
    id = models.CharField(primary_key=True, max_length=36, default=uuid.uuid4)
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, related_name='cupos', db_column='estudiante_id')
    materia = models.CharField(max_length=50, choices=MATERIAS_CHOICES)
    
    # Contadores
    procedimientos_completados = models.IntegerField(default=0)
    ultimo_procedimiento_fecha = models.DateField(null=True, blank=True)
    
    # Meta info
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = True
        db_table = 'cupo_estudiante'
        verbose_name = 'Cupo de Estudiante'
        verbose_name_plural = 'Cupos de Estudiantes'
        unique_together = ['estudiante', 'materia']
        ordering = ['estudiante', 'materia']
    
    def __str__(self):
        return f"{self.estudiante.username} - {self.get_materia_display()}: {self.procedimientos_completados}"
    
    @classmethod
    def incrementar_cupo(cls, estudiante, materia):
        """Incrementa el contador de cupos para un estudiante en una materia"""
        cupo, created = cls.objects.get_or_create(
            estudiante=estudiante,
            materia=materia,
            defaults={'procedimientos_completados': 0}
        )
        cupo.procedimientos_completados += 1
        cupo.ultimo_procedimiento_fecha = timezone.now().date()
        cupo.save()
        return cupo
