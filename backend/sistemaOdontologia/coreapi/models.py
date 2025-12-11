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
        """Establecer contraseña hasheada"""
        import hashlib
        self.password_hash = hashlib.sha256(password.encode()).hexdigest()
        
    def check_password(self, password):
        """Verificar contraseña"""
        import hashlib
        return self.password_hash == hashlib.sha256(password.encode()).hexdigest()
    
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


class RegistroPeriodoncia(models.Model):
    """Registros de Periodoncia"""
    id = models.CharField(primary_key=True, max_length=36)
    historial = models.ForeignKey('HistorialesClinicos', on_delete=models.CASCADE, db_column='historial_id')
    estudiante = models.ForeignKey('Usuarios', on_delete=models.CASCADE, db_column='estudiante_id', related_name='periodoncias_realizadas')
    paciente = models.ForeignKey('Pacientes', on_delete=models.CASCADE, db_column='paciente_id')
    fecha_registro = models.DateTimeField(auto_now_add=True)
    
    # Periodontograma completo (datos JSON)
    periodontograma_datos = models.JSONField(default=dict, blank=True)
    
    # Índices periodontales
    indice_hios = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    indice_loe_silness = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    indice_gingival = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    
    # Plan de terapia básica y quirúrgica
    plan_terapia_basica = models.JSONField(default=dict, blank=True)
    plan_terapia_quirurgica = models.JSONField(default=dict, blank=True)
    
    # Control de mantenimiento
    controles_mantenimiento = models.JSONField(default=list, blank=True)
    
    # Aprobación docente
    aprobado_por = models.ForeignKey('Usuarios', on_delete=models.SET_NULL, null=True, blank=True, related_name='periodoncias_aprobadas')
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
        db_table = 'registro_periodoncia'
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

