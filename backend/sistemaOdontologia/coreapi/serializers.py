from rest_framework import serializers
from django.utils import timezone
import uuid
from .models import Pacientes, HistorialesClinicos, ContactosEmergencia, Usuarios, Roles, Asignaciones
from .models import (
    Antecedentes,
    AntecedentesFamiliares,
    AntecedentesGinecologicos,
    AntecedentesNoPatologicos,
    AntecedentesPatologicosPersonales,
    RegistroCirugiaBucal,
    RegistroOperatoriaEndodoncia,
    RegistroHistoriaClinica,
    RegistroProstodonciaFija,
    RegistroProstodonciaRemovible,
    RegistroOdontopediatria,
    RegistroSemiologia,
    SeguimientoPaciente,
    EntradaSeguimiento,
    ProtocoloQuirurgico,
    Permiso,
    RolPermiso,
    UsuarioPermiso,
    Citas,
    TratamientoMateria,
    PlanTratamiento,
    ProcedimientoPlan,
    EvolucionClinica,
    TransferenciaPaciente,
    RemisionInterCatedra,
)


class PacienteSerializer(serializers.ModelSerializer):
    id = serializers.CharField(required=False)
    creado_en = serializers.DateTimeField(required=False)
    nombre_completo = serializers.ReadOnlyField()
    deleted_at = serializers.DateTimeField(required=False, allow_null=True)
    deleted_by = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    
    class Meta:
        model = Pacientes
        fields = '__all__'

    def create(self, validated_data):
        # Ensure id and creado_en are set for legacy DB
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        if not validated_data.get('creado_en'):
            validated_data['creado_en'] = timezone.now()
        
        # Asegurar que los nuevos pacientes no estén eliminados
        validated_data['is_deleted'] = False
        validated_data['deleted_at'] = None
        validated_data['deleted_by'] = None
        
        # Create the patient (no automatic historial creation)
        paciente = super().create(validated_data)
        return paciente
    
    def to_representation(self, instance):
        """Personalizar la representación del paciente"""
        data = super().to_representation(instance)
        
        # Agregar información de estado de eliminación
        if instance.is_deleted:
            data['estado'] = 'Eliminado'
            data['eliminado_hace'] = self._tiempo_transcurrido(instance.deleted_at)
        else:
            data['estado'] = 'Activo'
            
        return data
    
    def _tiempo_transcurrido(self, fecha_eliminacion):
        """Calcular tiempo transcurrido desde la eliminación"""
        if not fecha_eliminacion:
            return None
            
        from django.utils import timezone
        ahora = timezone.now()
        diferencia = ahora - fecha_eliminacion
        
        if diferencia.days > 0:
            return f"hace {diferencia.days} día(s)"
        elif diferencia.seconds > 3600:
            horas = diferencia.seconds // 3600
            return f"hace {horas} hora(s)"
        elif diferencia.seconds > 60:
            minutos = diferencia.seconds // 60
            return f"hace {minutos} minuto(s)"
        else:
            return "hace unos momentos"


class HistorialClinicoSerializer(serializers.ModelSerializer):
    id = serializers.CharField(required=False)
    creado_en = serializers.DateTimeField(required=False)

    class Meta:
        model = HistorialesClinicos
        fields = '__all__'

    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        if not validated_data.get('creado_en'):
            validated_data['creado_en'] = timezone.now()
        return super().create(validated_data)


class AntecedenteSerializer(serializers.ModelSerializer):
    id = serializers.CharField(required=False)
    creado_en = serializers.DateTimeField(required=False)
    paciente_nombre_completo = serializers.SerializerMethodField()

    class Meta:
        model = Antecedentes
        fields = ['id', 'historial', 'tipo', 'observaciones', 'creado_en', 'paciente_nombre_completo']

    def get_paciente_nombre_completo(self, obj):
        try:
            return f"{obj.historial.paciente.nombres} {obj.historial.paciente.apellidos}"
        except:
            return "Paciente Desconocido"

    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        if not validated_data.get('creado_en'):
            validated_data['creado_en'] = timezone.now()
        return super().create(validated_data)


class ContactoEmergenciaSerializer(serializers.ModelSerializer):
    id = serializers.CharField(required=False)
    deleted_at = serializers.DateTimeField(required=False, allow_null=True)
    deleted_by = serializers.CharField(required=False, allow_null=True, allow_blank=True)

    class Meta:
        model = ContactosEmergencia
        fields = '__all__'

    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        
        # Asegurar que los nuevos contactos no estén eliminados
        validated_data['is_deleted'] = False
        validated_data['deleted_at'] = None
        validated_data['deleted_by'] = None
        
        return super().create(validated_data)
    
    def to_representation(self, instance):
        """Personalizar la representación del contacto"""
        data = super().to_representation(instance)
        
        # Agregar información de estado de eliminación
        if instance.is_deleted:
            data['estado'] = 'Eliminado'
        else:
            data['estado'] = 'Activo'
        
        # Agregar información del paciente asociado
        if instance.paciente:
            data['paciente_nombre'] = f"{instance.paciente.nombres} {instance.paciente.apellidos}".strip()
            data['paciente_celular'] = instance.paciente.celular
        else:
            data['paciente_nombre'] = None
            data['paciente_celular'] = None
            
        return data


class UsuarioSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, min_length=6)
    rol_id = serializers.CharField(write_only=True, required=False)
    id = serializers.CharField(required=False)
    creado_en = serializers.DateTimeField(required=False)
    nombre_completo = serializers.ReadOnlyField()
    esta_activo = serializers.ReadOnlyField()
    deleted_at = serializers.DateTimeField(required=False, allow_null=True)
    deleted_by = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    
    # Campos de solo lectura para roles (si los necesitamos)
    roles = serializers.SerializerMethodField()

    class Meta:
        model = Usuarios
        exclude = ('password_hash',)
        read_only_fields = ('id', 'creado_en', 'nombre_completo', 'esta_activo')
    
    def get_roles(self, obj):
        """Obtener roles del usuario"""
        try:
            from .models import UsuarioRoles
            usuario_roles = UsuarioRoles.objects.filter(usuario_id=obj.id).select_related('rol')
            return [{'id': ur.rol.id, 'nombre': ur.rol.nombre} for ur in usuario_roles]
        except:
            return []
    
    def validate_email(self, value):
        """Validar formato de email"""
        import re
        if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', value):
            raise serializers.ValidationError("Formato de email inválido")
        return value
    
    def validate_username(self, value):
        """Validar username"""
        if len(value) < 3:
            raise serializers.ValidationError("El username debe tener al menos 3 caracteres")
        if not value.replace('_', '').replace('.', '').isalnum():
            raise serializers.ValidationError("El username solo puede contener letras, números, guiones bajos y puntos")
        return value

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        rol_id = validated_data.pop('rol_id', None)
        
        # Valores por defecto
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        if not validated_data.get('creado_en'):
            validated_data['creado_en'] = timezone.now()
        if not validated_data.get('activo'):
            validated_data['activo'] = 1
        
        # Campos de eliminación lógica
        validated_data['is_deleted'] = False
        validated_data['deleted_at'] = None
        validated_data['deleted_by'] = None
        
        # Validar contraseña
        if password is None:
            raise serializers.ValidationError({"password": "La contraseña es requerida"})
        
        # Crear usuario sin password_hash en validated_data
        usuario = super().create(validated_data)
        
        # Usar set_password para hashear correctamente (compatible con Django auth)
        usuario.set_password(password)
        usuario.save()
        
        # Asignar rol si se proporcionó
        if rol_id:
            from .models import UsuarioRoles
            UsuarioRoles.objects.create(
                usuario_id=usuario.id,
                rol_id=rol_id
            )
        
        return usuario

    def update(self, instance, validated_data):
        # Manejar actualización de contraseña
        password = validated_data.pop('password', None)
        
        # Manejar actualización de rol
        rol_id = validated_data.pop('rol_id', None)
        if rol_id:
            from .models import UsuarioRoles
            # Eliminar roles anteriores y asignar el nuevo
            UsuarioRoles.objects.filter(usuario_id=instance.id).delete()
            UsuarioRoles.objects.create(
                usuario_id=instance.id,
                rol_id=rol_id
            )
        
        # Actualizar otros campos
        instance = super().update(instance, validated_data)
        
        # Si se proporcionó una nueva contraseña, hashearla correctamente
        if password is not None:
            instance.set_password(password)
            instance.save()
        
        return instance
    
    def to_representation(self, instance):
        """Personalizar representación del usuario"""
        data = super().to_representation(instance)
        
        # Agregar información de estado
        if instance.is_deleted:
            data['estado'] = 'Eliminado'
            if instance.deleted_at:
                data['eliminado_hace'] = self._tiempo_transcurrido(instance.deleted_at)
        elif not instance.activo:
            data['estado'] = 'Inactivo'
        else:
            data['estado'] = 'Activo'
        
        # Agregar información de tipo de usuario
        data['is_administrador'] = instance.is_administrador
        data['is_docente'] = instance.is_docente
        data['is_estudiante'] = instance.is_estudiante
        data['rol_principal'] = instance.get_rol_principal()
            
        return data
    
    def _tiempo_transcurrido(self, fecha):
        """Calcular tiempo transcurrido"""
        if not fecha:
            return None
            
        from django.utils import timezone
        ahora = timezone.now()
        diferencia = ahora - fecha
        
        if diferencia.days > 0:
            return f"hace {diferencia.days} día(s)"
        elif diferencia.seconds > 3600:
            horas = diferencia.seconds // 3600
            return f"hace {horas} hora(s)"
        elif diferencia.seconds > 60:
            minutos = diferencia.seconds // 60
            return f"hace {minutos} minuto(s)"
        else:
            return "hace unos momentos"


class RolSerializer(serializers.ModelSerializer):
    id = serializers.CharField(required=False)

    class Meta:
        model = Roles
        fields = '__all__'

    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class AsignacionSerializer(serializers.ModelSerializer):
    id = serializers.CharField(required=False)
    fecha_asignacion = serializers.DateTimeField(required=False)
    fecha_finalizacion = serializers.DateTimeField(required=False, allow_null=True)
    deleted_at = serializers.DateTimeField(required=False, allow_null=True)
    deleted_by = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    
    # Campos de solo lectura con información completa
    estudiante_nombre = serializers.SerializerMethodField()
    estudiante_codigo = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    paciente_celular = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    docente_especialidad = serializers.SerializerMethodField()
    
    class Meta:
        model = Asignaciones
        fields = '__all__'
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return obj.estudiante.nombre_completo
        return None
    
    def get_estudiante_codigo(self, obj):
        if obj.estudiante:
            return obj.estudiante.codigo_estudiante
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}".strip()
        return None
    
    def get_paciente_celular(self, obj):
        if obj.paciente:
            return obj.paciente.celular
        return None
    
    def get_docente_nombre(self, obj):
        if obj.docente:
            return obj.docente.nombre_completo
        return None
    
    def get_docente_especialidad(self, obj):
        if obj.docente:
            return obj.docente.especialidad
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        if not validated_data.get('fecha_asignacion'):
            validated_data['fecha_asignacion'] = timezone.now()
        
        # Asegurar que las nuevas asignaciones no estén eliminadas
        validated_data['is_deleted'] = False
        validated_data['deleted_at'] = None
        validated_data['deleted_by'] = None
        
        return super().create(validated_data)
    
    def to_representation(self, instance):
        """Personalizar la representación de la asignación"""
        data = super().to_representation(instance)
        
        # Agregar información de estado de eliminación
        if instance.is_deleted:
            data['estado_display'] = 'Eliminado'
        else:
            data['estado_display'] = dict(instance._meta.get_field('estado').choices).get(instance.estado, instance.estado)
        
        return data


# Serializer base para Antecedentes
class AntecedenteBaseSerializer(serializers.ModelSerializer):
    id = serializers.CharField(required=False)
    paciente_nombre_completo = serializers.SerializerMethodField()
    
    class Meta:
        model = Antecedentes
        fields = '__all__'
    
    def get_paciente_nombre_completo(self, obj):
        try:
            paciente = obj.historial.paciente
            return f"{paciente.nombres} {paciente.apellidos}".strip()
        except:
            return ""
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


# Serializers para cada tipo de antecedente con estructura padre-hijo
class AntecedenteFamiliarSerializer(serializers.ModelSerializer):
    # Campos del antecedente base
    historial = serializers.CharField()
    observaciones = serializers.CharField(required=False, allow_blank=True)
    paciente_nombre_completo = serializers.SerializerMethodField()
    
    class Meta:
        model = AntecedentesFamiliares
        fields = '__all__'
    
    def get_paciente_nombre_completo(self, obj):
        try:
            paciente = obj.antecedente.historial.paciente
            return f"{paciente.nombres} {paciente.apellidos}".strip()
        except:
            return ""
    
    def create(self, validated_data):
        # Extraer datos del antecedente base
        historial_id = validated_data.pop('historial')
        observaciones = validated_data.pop('observaciones', '')
        
        # Crear el antecedente base
        antecedente_base = Antecedentes.objects.create(
            id=str(uuid.uuid4()),
            historial_id=historial_id,
            tipo='familiar',
            observaciones=observaciones
        )
        
        # Crear el antecedente específico
        validated_data['antecedente'] = antecedente_base
        return super().create(validated_data)


class AntecedenteGinecologicoSerializer(serializers.ModelSerializer):
    historial = serializers.CharField()
    observaciones = serializers.CharField(required=False, allow_blank=True)
    paciente_nombre_completo = serializers.SerializerMethodField()
    
    class Meta:
        model = AntecedentesGinecologicos
        fields = '__all__'
    
    def get_paciente_nombre_completo(self, obj):
        try:
            paciente = obj.antecedente.historial.paciente
            return f"{paciente.nombres} {paciente.apellidos}".strip()
        except:
            return ""
    
    def create(self, validated_data):
        historial_id = validated_data.pop('historial')
        observaciones = validated_data.pop('observaciones', '')
        
        antecedente_base = Antecedentes.objects.create(
            id=str(uuid.uuid4()),
            historial_id=historial_id,
            tipo='ginecologico',
            observaciones=observaciones
        )
        
        validated_data['antecedente'] = antecedente_base
        return super().create(validated_data)


class AntecedenteNoPatologicoSerializer(serializers.ModelSerializer):
    historial = serializers.CharField()
    observaciones = serializers.CharField(required=False, allow_blank=True)
    paciente_nombre_completo = serializers.SerializerMethodField()
    
    class Meta:
        model = AntecedentesNoPatologicos
        fields = '__all__'
    
    def get_paciente_nombre_completo(self, obj):
        try:
            paciente = obj.antecedente.historial.paciente
            return f"{paciente.nombres} {paciente.apellidos}".strip()
        except:
            return ""
    
    def create(self, validated_data):
        historial_id = validated_data.pop('historial')
        observaciones = validated_data.pop('observaciones', '')
        
        antecedente_base = Antecedentes.objects.create(
            id=str(uuid.uuid4()),
            historial_id=historial_id,
            tipo='no_patologico',
            observaciones=observaciones
        )
        
        validated_data['antecedente'] = antecedente_base
        return super().create(validated_data)


class AntecedentePatologicoSerializer(serializers.ModelSerializer):
    historial = serializers.CharField()
    observaciones = serializers.CharField(required=False, allow_blank=True)
    paciente_nombre_completo = serializers.SerializerMethodField()
    
    class Meta:
        model = AntecedentesPatologicosPersonales
        fields = '__all__'
    
    def get_paciente_nombre_completo(self, obj):
        try:
            paciente = obj.antecedente.historial.paciente
            return f"{paciente.nombres} {paciente.apellidos}".strip()
        except:
            return ""
    
    def create(self, validated_data):
        historial_id = validated_data.pop('historial')
        observaciones = validated_data.pop('observaciones', '')
        
        antecedente_base = Antecedentes.objects.create(
            id=str(uuid.uuid4()),
            historial_id=historial_id,
            tipo='patologico',
            observaciones=observaciones
        )
        
        validated_data['antecedente'] = antecedente_base
        return super().create(validated_data)


# Serializer para vista consolidada de antecedentes
class AntecedenteConsolidadoSerializer(serializers.ModelSerializer):
    paciente_nombre_completo = serializers.SerializerMethodField()
    paciente_id = serializers.SerializerMethodField()
    tipo_display = serializers.SerializerMethodField()
    detalles = serializers.SerializerMethodField()
    
    # Campos para escribir detalles específicos
    detalles_familiares = serializers.DictField(required=False, write_only=True)
    detalles_ginecologicos = serializers.DictField(required=False, write_only=True)
    detalles_no_patologicos = serializers.DictField(required=False, write_only=True)
    detalles_patologicos = serializers.DictField(required=False, write_only=True)
    
    class Meta:
        model = Antecedentes
        fields = ['id', 'historial', 'tipo', 'tipo_display', 'observaciones', 'creado_en', 
                 'paciente_nombre_completo', 'paciente_id', 'detalles', 
                 'detalles_familiares', 'detalles_ginecologicos', 
                 'detalles_no_patologicos', 'detalles_patologicos']
        extra_kwargs = {
            'id': {'required': False},
            'creado_en': {'read_only': True},
        }
    
    def to_representation(self, instance):
        # Obtener la representación base
        data = super().to_representation(instance)
        
        # Obtener detalles específicos
        detalles = self.get_detalles(instance)
        
        # Aplanar los detalles en el nivel superior
        data.update(detalles)
        
        return data
    
    def get_paciente_nombre_completo(self, obj):
        try:
            paciente = obj.historial.paciente
            return f"{paciente.nombres} {paciente.apellidos}".strip()
        except:
            return ""
    
    def get_paciente_id(self, obj):
        try:
            return obj.historial.paciente.id
        except:
            return None
    
    def get_tipo_display(self, obj):
        tipos = {
            'familiar': 'Antecedentes Familiares',
            'ginecologico': 'Antecedentes Ginecologicos', 
            'no_patologico': 'Antecedentes No Patologicos',
            'patologico': 'Antecedentes Patologicos Personales'
        }
        return tipos.get(obj.tipo, obj.tipo)
    
    def get_detalles(self, obj):
        # Obtener los detalles específicos según el tipo
        detalles = {}
        
        try:
            if obj.tipo == 'familiar':
                detalle = obj.antecedentesfamiliares
                # Usar reflexión para obtener todos los campos
                for field in detalle._meta.fields:
                    if field.name not in ['id', 'antecedente']:
                        detalles[field.name] = getattr(detalle, field.name, None)
                        
            elif obj.tipo == 'ginecologico':
                detalle = obj.antecedentesginecologicos
                for field in detalle._meta.fields:
                    if field.name not in ['id', 'antecedente']:
                        detalles[field.name] = getattr(detalle, field.name, None)
                        
            elif obj.tipo == 'no_patologico':
                detalle = obj.antecedentesnopatologicos
                for field in detalle._meta.fields:
                    if field.name not in ['id', 'antecedente']:
                        detalles[field.name] = getattr(detalle, field.name, None)
                        
            elif obj.tipo == 'patologico':
                detalle = obj.antecedentespatologicospersonales
                for field in detalle._meta.fields:
                    if field.name not in ['id', 'antecedente']:
                        detalles[field.name] = getattr(detalle, field.name, None)
                        
        except Exception as e:
            print(f"Error obteniendo detalles para {obj.tipo}: {e}")
            
        return detalles
    
    def create(self, validated_data):
        import uuid
        print(f"=== CREATE ANTECEDENTE ===")
        print(f"Datos recibidos: {validated_data}")
        
        # Generar UUID para el ID
        if 'id' not in validated_data:
            validated_data['id'] = str(uuid.uuid4())
        
        # Extraer campos base del antecedente
        historial = validated_data.get('historial')
        tipo = validated_data.get('tipo')
        observaciones = validated_data.get('observaciones', '')
        
        print(f"Historial recibido: {historial} (tipo: {type(historial)}), Tipo: {tipo}")
        
        # Verificar si ya es un objeto o necesitamos obtenerlo
        from .models import HistorialesClinicos
        if isinstance(historial, HistorialesClinicos):
            historial_obj = historial
            print(f"Historial ya es objeto: {historial_obj.id}")
        elif isinstance(historial, str):
            try:
                historial_obj = HistorialesClinicos.objects.get(id=historial)
                print(f"Historial encontrado por ID: {historial_obj.id}")
            except HistorialesClinicos.DoesNotExist:
                print(f"ERROR: Historial con ID {historial} no existe")
                historiales_existentes = list(HistorialesClinicos.objects.values('id', 'paciente_id'))
                print(f"Historiales disponibles: {historiales_existentes}")
                raise serializers.ValidationError(f'Historial con ID {historial} no existe')
        else:
            raise serializers.ValidationError(f'Tipo de historial no válido: {type(historial)}')
        
        # Crear el antecedente base
        antecedente = Antecedentes.objects.create(
            id=validated_data['id'],
            historial=historial_obj,
            tipo=tipo,
            observaciones=observaciones
        )
        print(f"Antecedente padre creado: {antecedente.id}")
        
        # Extraer todos los campos específicos (excluyendo los campos base)
        campos_excluir = {'id', 'historial', 'tipo', 'observaciones', 'creado_en', 
                         'paciente_nombre_completo', 'paciente_id', 'tipo_display', 'detalles',
                         'detalles_familiares', 'detalles_ginecologicos', 
                         'detalles_no_patologicos', 'detalles_patologicos'}
        
        # Obtener los datos originales antes de que Django los procese
        original_data = self.initial_data
        print(f"Datos originales del request: {original_data}")
        
        campos_especificos = {k: v for k, v in original_data.items() if k not in campos_excluir}
        
        # Limpiar campos de fecha vacíos (convertir strings vacíos a None)
        campos_fecha = ['fecha_ultimo_examen', 'fecha_ultima_menstruacion', 'fecha_nacimiento']
        for campo in campos_fecha:
            if campo in campos_especificos and campos_especificos[campo] == '':
                campos_especificos[campo] = None
        
        # Limpiar campos de texto vacíos (convertir strings vacíos a None para campos que lo permiten)
        campos_texto_nullable = ['alergia_otros', 'otros', 'otros_familiares', 'otros_no_patologicos']
        for campo in campos_texto_nullable:
            if campo in campos_especificos and campos_especificos[campo] == '':
                campos_especificos[campo] = None
                
        print(f"Campos específicos para tabla hijo (limpiados): {campos_especificos}")
        
        # Crear el detalle específico según el tipo
        try:
            if tipo == 'familiar':
                detalle = AntecedentesFamiliares.objects.create(
                    antecedente=antecedente,
                    **campos_especificos
                )
                print(f"Antecedente familiar creado: {detalle}")
            elif tipo == 'ginecologico':
                detalle = AntecedentesGinecologicos.objects.create(
                    antecedente=antecedente,
                    **campos_especificos
                )
                print(f"Antecedente ginecológico creado: {detalle}")
            elif tipo == 'no_patologico':
                detalle = AntecedentesNoPatologicos.objects.create(
                    antecedente=antecedente,
                    **campos_especificos
                )
                print(f"Antecedente no patológico creado: {detalle}")
            elif tipo == 'patologico':
                detalle = AntecedentesPatologicosPersonales.objects.create(
                    antecedente=antecedente,
                    **campos_especificos
                )
                print(f"Antecedente patológico creado: {detalle}")
            
            print(f"Antecedente {tipo} creado exitosamente con ID: {antecedente.id}")
        except Exception as e:
            print(f"Error creando detalle específico: {e}")
            print(f"Tipo de error: {type(e)}")
            import traceback
            traceback.print_exc()
            # Si hay error, eliminar el antecedente base
            try:
                antecedente.delete()
            except:
                pass
            raise serializers.ValidationError(f'Error creando detalle específico: {str(e)}')
        
        return antecedente
    
    def update(self, instance, validated_data):
        print(f"=== UPDATE ANTECEDENTE ===")
        print(f"Instance ID: {instance.id}, Tipo: {instance.tipo}")
        print(f"Datos recibidos para actualización: {validated_data}")
        
        # Obtener los datos originales
        original_data = self.initial_data
        print(f"Datos originales del request: {original_data}")
        
        # Actualizar campos base del antecedente
        tipo = original_data.get('tipo', instance.tipo)
        observaciones = original_data.get('observaciones', instance.observaciones)
        
        instance.tipo = tipo
        instance.observaciones = observaciones
        instance.save()
        
        print(f"Antecedente padre actualizado: {instance.id}")
        
        # Extraer campos específicos para actualizar
        campos_excluir = {'id', 'historial', 'tipo', 'observaciones', 'creado_en', 
                         'paciente_nombre_completo', 'paciente_id', 'tipo_display', 'detalles',
                         'detalles_familiares', 'detalles_ginecologicos', 
                         'detalles_no_patologicos', 'detalles_patologicos'}
        
        campos_especificos = {k: v for k, v in original_data.items() if k not in campos_excluir}
        
        # Limpiar campos de fecha y texto vacíos
        campos_fecha = ['fecha_ultimo_examen', 'fecha_ultima_menstruacion', 'fecha_nacimiento']
        for campo in campos_fecha:
            if campo in campos_especificos and campos_especificos[campo] == '':
                campos_especificos[campo] = None
        
        campos_texto_nullable = ['alergia_otros', 'otros', 'otros_familiares', 'otros_no_patologicos']
        for campo in campos_texto_nullable:
            if campo in campos_especificos and campos_especificos[campo] == '':
                campos_especificos[campo] = None
                
        print(f"Campos específicos para actualizar: {campos_especificos}")
        
        # Actualizar el detalle específico según el tipo
        try:
            if tipo == 'familiar':
                detalle, created = AntecedentesFamiliares.objects.get_or_create(
                    antecedente=instance,
                    defaults=campos_especificos
                )
                if not created:
                    for key, value in campos_especificos.items():
                        setattr(detalle, key, value)
                    detalle.save()
                print(f"Antecedente familiar {'creado' if created else 'actualizado'}")
                
            elif tipo == 'ginecologico':
                detalle, created = AntecedentesGinecologicos.objects.get_or_create(
                    antecedente=instance,
                    defaults=campos_especificos
                )
                if not created:
                    for key, value in campos_especificos.items():
                        setattr(detalle, key, value)
                    detalle.save()
                print(f"Antecedente ginecológico {'creado' if created else 'actualizado'}")
                
            elif tipo == 'no_patologico':
                detalle, created = AntecedentesNoPatologicos.objects.get_or_create(
                    antecedente=instance,
                    defaults=campos_especificos
                )
                if not created:
                    for key, value in campos_especificos.items():
                        setattr(detalle, key, value)
                    detalle.save()
                print(f"Antecedente no patológico {'creado' if created else 'actualizado'}")
                
            elif tipo == 'patologico':
                detalle, created = AntecedentesPatologicosPersonales.objects.get_or_create(
                    antecedente=instance,
                    defaults=campos_especificos
                )
                if not created:
                    for key, value in campos_especificos.items():
                        setattr(detalle, key, value)
                    detalle.save()
                print(f"Antecedente patológico {'creado' if created else 'actualizado'}")
            
            print(f"Antecedente {tipo} actualizado exitosamente")
        except Exception as e:
            print(f"Error actualizando detalle específico: {e}")
            import traceback
            traceback.print_exc()
            raise serializers.ValidationError(f'Error actualizando detalle específico: {str(e)}')
        
        return instance


# Serializers para Materias Clínicas

class RegistroCirugiaBucalSerializer(serializers.ModelSerializer):
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = RegistroCirugiaBucal
        fields = '__all__'
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_docente_nombre(self, obj):
        if obj.aprobado_por:
            return f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class RegistroOperatoriaEndodonciaSerializer(serializers.ModelSerializer):
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = RegistroOperatoriaEndodoncia
        fields = '__all__'
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_docente_nombre(self, obj):
        if obj.aprobado_por:
            return f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class RegistroHistoriaClinicaSerializer(serializers.ModelSerializer):
    """Serializer para el modelo unificado de historia clínica"""
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    materia_display = serializers.SerializerMethodField()
    tipo_registro_display = serializers.SerializerMethodField()
    estado_display = serializers.SerializerMethodField()
    
    # Hacer campos opcionales
    from .models import Usuarios, HistorialesClinicos
    historial = serializers.SlugRelatedField(
        slug_field='id',
        queryset=HistorialesClinicos.objects.all(),
        required=False,
        allow_null=True
    )
    estudiante = serializers.SlugRelatedField(
        slug_field='id',
        queryset=Usuarios.objects.all(),
        required=False,
        allow_null=True
    )
    
    class Meta:
        model = RegistroHistoriaClinica
        fields = '__all__'
        read_only_fields = ('fecha_registro', 'fecha_modificacion', 'fecha_aprobacion')
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_docente_nombre(self, obj):
        if obj.aprobado_por:
            return f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip()
        return None
    
    def get_materia_display(self, obj):
        return dict(RegistroHistoriaClinica.MATERIA_CHOICES).get(obj.materia, obj.materia)
    
    def get_tipo_registro_display(self, obj):
        return dict(RegistroHistoriaClinica.TIPO_REGISTRO_CHOICES).get(obj.tipo_registro, obj.tipo_registro)
    
    def get_estado_display(self, obj):
        return dict(RegistroHistoriaClinica.ESTADO_CHOICES).get(obj.estado, obj.estado)
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)
    
    def validate(self, data):
        """Validaciones personalizadas"""
        # Validar que la materia sea válida
        materia = data.get('materia')
        if materia and materia not in dict(RegistroHistoriaClinica.MATERIA_CHOICES):
            raise serializers.ValidationError({'materia': 'Materia no válida'})
        
        # Validar que el tipo_registro sea válido
        tipo_registro = data.get('tipo_registro')
        if tipo_registro and tipo_registro not in dict(RegistroHistoriaClinica.TIPO_REGISTRO_CHOICES):
            raise serializers.ValidationError({'tipo_registro': 'Tipo de registro no válido'})
        
        return data


class RegistroProstodonciaFijaSerializer(serializers.ModelSerializer):
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = RegistroProstodonciaFija
        fields = '__all__'
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_docente_nombre(self, obj):
        if obj.aprobado_por:
            return f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class RegistroProstodonciaRemovibleSerializer(serializers.ModelSerializer):
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = RegistroProstodonciaRemovible
        fields = '__all__'
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_docente_nombre(self, obj):
        if obj.aprobado_por:
            return f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class RegistroOdontopediatriaSerializer(serializers.ModelSerializer):
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = RegistroOdontopediatria
        fields = '__all__'
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_docente_nombre(self, obj):
        if obj.aprobado_por:
            return f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class RegistroSemiologiaSerializer(serializers.ModelSerializer):
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = RegistroSemiologia
        fields = '__all__'
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_docente_nombre(self, obj):
        if obj.aprobado_por:
            return f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class EntradaSeguimientoSerializer(serializers.ModelSerializer):
    """Serializer para cada entrada de tratamiento"""
    firmado_por_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = EntradaSeguimiento
        fields = '__all__'
    
    def get_firmado_por_nombre(self, obj):
        if obj.firmado_por:
            return f"{obj.firmado_por.nombres or ''} {obj.firmado_por.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class SeguimientoPacienteSerializer(serializers.ModelSerializer):
    """Serializer para la hoja de seguimiento"""
    entradas = EntradaSeguimientoSerializer(many=True, read_only=True)
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    paciente_ci = serializers.SerializerMethodField()
    total_entradas = serializers.SerializerMethodField()
    entradas_firmadas = serializers.SerializerMethodField()
    entradas_pendientes = serializers.SerializerMethodField()
    
    class Meta:
        model = SeguimientoPaciente
        fields = '__all__'
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_paciente_ci(self, obj):
        if obj.paciente:
            return obj.paciente.ci
        return None
    
    def get_total_entradas(self, obj):
        return obj.entradas.filter(is_deleted=False).count()
    
    def get_entradas_firmadas(self, obj):
        return obj.entradas.filter(is_deleted=False, firmado=True).count()
    
    def get_entradas_pendientes(self, obj):
        return obj.entradas.filter(is_deleted=False, firmado=False).count()
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class ProtocoloQuirurgicoSerializer(serializers.ModelSerializer):
    """Serializer para Protocolo Quirúrgico"""
    paciente_nombre = serializers.SerializerMethodField()
    paciente_sexo = serializers.SerializerMethodField()
    estudiante_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = ProtocoloQuirurgico
        fields = '__all__'
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_paciente_sexo(self, obj):
        if obj.paciente:
            return obj.paciente.sexo
        return None
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_docente_nombre(self, obj):
        if obj.docente:
            return f"{obj.docente.nombres or ''} {obj.docente.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        if not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


# ===================== PERMISSION SERIALIZERS =====================

class PermisoSerializer(serializers.ModelSerializer):
    """Serializer para Permiso"""
    
    class Meta:
        model = Permiso
        fields = '__all__'
        read_only_fields = ['creado_en']


class RolPermisoSerializer(serializers.ModelSerializer):
    """Serializer para RolPermiso con información detallada"""
    permiso_nombre = serializers.SerializerMethodField()
    permiso_codigo = serializers.SerializerMethodField()
    permiso_descripcion = serializers.SerializerMethodField()
    rol_nombre = serializers.SerializerMethodField()
    otorgado_por_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = RolPermiso
        fields = '__all__'
        read_only_fields = ['fecha_asignacion']
    
    def get_permiso_nombre(self, obj):
        return obj.permiso.nombre if obj.permiso else None
    
    def get_permiso_codigo(self, obj):
        return obj.permiso.codigo if obj.permiso else None
    
    def get_permiso_descripcion(self, obj):
        return obj.permiso.descripcion if obj.permiso else None
    
    def get_rol_nombre(self, obj):
        return obj.rol.nombre if obj.rol else None
    
    def get_otorgado_por_nombre(self, obj):
        if obj.otorgado_por:
            return f"{obj.otorgado_por.nombres or ''} {obj.otorgado_por.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        """Crear RolPermiso con UUID generado automáticamente"""
        import uuid
        if 'id' not in validated_data or not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class UsuarioPermisoSerializer(serializers.ModelSerializer):
    """Serializer para UsuarioPermiso con información detallada"""
    permiso_nombre = serializers.SerializerMethodField()
    permiso_codigo = serializers.SerializerMethodField()
    permiso_descripcion = serializers.SerializerMethodField()
    usuario_nombre = serializers.SerializerMethodField()
    otorgado_por_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = UsuarioPermiso
        fields = '__all__'
        read_only_fields = ['fecha_asignacion']
    
    def get_permiso_nombre(self, obj):
        return obj.permiso.nombre if obj.permiso else None
    
    def get_permiso_codigo(self, obj):
        return obj.permiso.codigo if obj.permiso else None
    
    def get_permiso_descripcion(self, obj):
        return obj.permiso.descripcion if obj.permiso else None
    
    def get_usuario_nombre(self, obj):
        if obj.usuario:
            return f"{obj.usuario.nombres or ''} {obj.usuario.apellidos or ''}".strip()
        return None
    
    def get_otorgado_por_nombre(self, obj):
        if obj.otorgado_por:
            return f"{obj.otorgado_por.nombres or ''} {obj.otorgado_por.apellidos or ''}".strip()
        return None


class CitaSerializer(serializers.ModelSerializer):
    """Serializer para Citas con información detallada de relaciones"""
    paciente_nombre = serializers.SerializerMethodField()
    estudiante_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    
    class Meta:
        model = Citas
        fields = '__all__'
        read_only_fields = ['creado_en', 'actualizado_en']
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
        return None
    
    def get_docente_nombre(self, obj):
        if obj.docente:
            return f"{obj.docente.nombres or ''} {obj.docente.apellidos or ''}".strip()
        return None
    
    def create(self, validated_data):
        """Crear cita con UUID generado automáticamente"""
        import uuid
        if 'id' not in validated_data or not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class TratamientoMateriaSerializer(serializers.ModelSerializer):
    """Serializer para TratamientoMateria con información detallada"""
    estudiante_nombre = serializers.SerializerMethodField()
    paciente_nombre = serializers.SerializerMethodField()
    docente_revisor_nombre = serializers.SerializerMethodField()
    materia_display = serializers.CharField(source='get_materia_display', read_only=True)
    estado_display = serializers.CharField(source='get_estado_display', read_only=True)
    
    class Meta:
        model = TratamientoMateria
        fields = '__all__'
        read_only_fields = ['creado_en', 'actualizado_en', 'fecha_solicitud', 'fecha_revision', 'cupo_numero']
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip() or obj.estudiante.username
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_docente_revisor_nombre(self, obj):
        if obj.docente_revisor:
            return f"{obj.docente_revisor.nombres or ''} {obj.docente_revisor.apellidos or ''}".strip() or obj.docente_revisor.username
        return None
    
    def create(self, validated_data):
        """Crear tratamiento con UUID generado automáticamente"""
        import uuid
        if 'id' not in validated_data or not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class ProcedimientoPlanSerializer(serializers.ModelSerializer):
    """Serializer para procedimientos del plan"""
    prioridad_display = serializers.CharField(source='get_prioridad_display', read_only=True)
    estado_display = serializers.CharField(source='get_estado_display', read_only=True)
    
    class Meta:
        model = ProcedimientoPlan
        fields = '__all__'
        read_only_fields = ['creado_en', 'actualizado_en']
    
    def create(self, validated_data):
        import uuid
        if 'id' not in validated_data or not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class EvolucionClinicaSerializer(serializers.ModelSerializer):
    """Serializer para evoluciones clínicas"""
    estudiante_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    procedimiento_descripcion = serializers.SerializerMethodField()
    
    class Meta:
        model = EvolucionClinica
        fields = '__all__'
        read_only_fields = ['creado_en', 'actualizado_en', 'fecha_firma_estudiante', 'fecha_firma_docente']
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip() or obj.estudiante.username
        return None
    
    def get_docente_nombre(self, obj):
        if obj.docente_supervisor:
            return f"{obj.docente_supervisor.nombres or ''} {obj.docente_supervisor.apellidos or ''}".strip() or obj.docente_supervisor.username
        return None
    
    def get_procedimiento_descripcion(self, obj):
        if obj.procedimiento:
            return obj.procedimiento.descripcion
        return None
    
    def create(self, validated_data):
        import uuid
        if 'id' not in validated_data or not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class PlanTratamientoSerializer(serializers.ModelSerializer):
    """Serializer para planes de tratamiento con procedimientos y evoluciones"""
    procedimientos = ProcedimientoPlanSerializer(many=True, read_only=True)
    evoluciones = EvolucionClinicaSerializer(many=True, read_only=True)
    
    # Serializers anidados para objetos completos
    paciente = PacienteSerializer(read_only=True)
    estudiante = serializers.SerializerMethodField()
    aprobado_por = serializers.SerializerMethodField()
    
    # IDs para escritura
    paciente_id = serializers.CharField(write_only=True, required=False, source='paciente')
    estudiante_id = serializers.CharField(write_only=True, required=False, source='estudiante')
    aprobado_por_id = serializers.CharField(write_only=True, required=False, source='aprobado_por')
    
    paciente_nombre = serializers.SerializerMethodField()
    estudiante_nombre = serializers.SerializerMethodField()
    aprobado_por_nombre = serializers.SerializerMethodField()
    materia_display = serializers.CharField(source='get_materia_display', read_only=True)
    estado_display = serializers.CharField(source='get_estado_display', read_only=True)
    
    class Meta:
        model = PlanTratamiento
        fields = '__all__'
        read_only_fields = ['fecha_creacion', 'actualizado_en', 'total_procedimientos', 
                           'procedimientos_completados', 'progreso_porcentaje', 'fecha_aprobacion']
    
    def get_estudiante(self, obj):
        if obj.estudiante:
            return {
                'id': obj.estudiante.id,
                'username': obj.estudiante.username,
                'nombres': obj.estudiante.nombres,
                'apellidos': obj.estudiante.apellidos,
                'nombre_completo': f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip()
            }
        return None
    
    def get_aprobado_por(self, obj):
        if obj.aprobado_por:
            return {
                'id': obj.aprobado_por.id,
                'username': obj.aprobado_por.username,
                'nombres': obj.aprobado_por.nombres,
                'apellidos': obj.aprobado_por.apellidos,
                'nombre_completo': f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip()
            }
        return None
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_estudiante_nombre(self, obj):
        if obj.estudiante:
            return f"{obj.estudiante.nombres or ''} {obj.estudiante.apellidos or ''}".strip() or obj.estudiante.username
        return None
    
    def get_aprobado_por_nombre(self, obj):
        if obj.aprobado_por:
            return f"{obj.aprobado_por.nombres or ''} {obj.aprobado_por.apellidos or ''}".strip() or obj.aprobado_por.username
        return None
    
    def create(self, validated_data):
        import uuid
        if 'id' not in validated_data or not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class TransferenciaPacienteSerializer(serializers.ModelSerializer):
    """Serializer para transferencias de pacientes a otras materias"""
    paciente_nombre = serializers.SerializerMethodField()
    estudiante_origen_nombre = serializers.SerializerMethodField()
    estudiante_destino_nombre = serializers.SerializerMethodField()
    docente_aprobador_nombre = serializers.SerializerMethodField()
    materia_origen_nombre = serializers.CharField(source='get_materia_origen_display', read_only=True)
    materia_destino_nombre = serializers.CharField(source='get_materia_destino_display', read_only=True)
    motivo_display = serializers.CharField(source='get_motivo_display', read_only=True)
    estado_display = serializers.CharField(source='get_estado_display', read_only=True)
    
    class Meta:
        model = TransferenciaPaciente
        fields = '__all__'
        read_only_fields = ['fecha_solicitud', 'fecha_aprobacion', 'fecha_asignacion', 'nueva_asignacion', 'docente_aprobador']
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_estudiante_origen_nombre(self, obj):
        if obj.estudiante_origen:
            return f"{obj.estudiante_origen.nombres or ''} {obj.estudiante_origen.apellidos or ''}".strip() or obj.estudiante_origen.username
        return None
    
    def get_estudiante_destino_nombre(self, obj):
        if obj.estudiante_destino:
            return f"{obj.estudiante_destino.nombres or ''} {obj.estudiante_destino.apellidos or ''}".strip() or obj.estudiante_destino.username
        return "Pendiente de Asignación"
    
    def get_docente_aprobador_nombre(self, obj):
        if obj.docente_aprobador:
            return f"{obj.docente_aprobador.nombres or ''} {obj.docente_aprobador.apellidos or ''}".strip() or obj.docente_aprobador.username
        return None
    
    def create(self, validated_data):
        import uuid
        if 'id' not in validated_data or not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)


class RemisionInterCatedraSerializer(serializers.ModelSerializer):
    """Serializer para remisiones inter-cátedra"""
    paciente_nombre = serializers.SerializerMethodField()
    estudiante_remite_nombre = serializers.SerializerMethodField()
    estudiante_recibe_nombre = serializers.SerializerMethodField()
    docente_nombre = serializers.SerializerMethodField()
    materia_origen_display = serializers.CharField(source='get_materia_origen_display', read_only=True)
    materia_destino_display = serializers.CharField(source='get_materia_destino_display', read_only=True)
    estado_display = serializers.CharField(source='get_estado_display', read_only=True)
    
    class Meta:
        model = RemisionInterCatedra
        fields = '__all__'
        read_only_fields = ['fecha_remision', 'actualizado_en', 'fecha_atencion']
    
    def get_paciente_nombre(self, obj):
        if obj.paciente:
            return f"{obj.paciente.nombres} {obj.paciente.apellidos}"
        return None
    
    def get_estudiante_remite_nombre(self, obj):
        if obj.estudiante_remite:
            return f"{obj.estudiante_remite.nombres or ''} {obj.estudiante_remite.apellidos or ''}".strip() or obj.estudiante_remite.username
        return None
    
    def get_estudiante_recibe_nombre(self, obj):
        if obj.estudiante_recibe:
            return f"{obj.estudiante_recibe.nombres or ''} {obj.estudiante_recibe.apellidos or ''}".strip() or obj.estudiante_recibe.username
        return None
    
    def get_docente_nombre(self, obj):
        if obj.docente_autoriza:
            return f"{obj.docente_autoriza.nombres or ''} {obj.docente_autoriza.apellidos or ''}".strip() or obj.docente_autoriza.username
        return None
    
    def create(self, validated_data):
        import uuid
        if 'id' not in validated_data or not validated_data.get('id'):
            validated_data['id'] = str(uuid.uuid4())
        return super().create(validated_data)
