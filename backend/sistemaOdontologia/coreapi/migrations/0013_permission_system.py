# Generated manually for permission system

import django.db.models.deletion
import django.utils.timezone
import uuid
from django.db import migrations, models


def create_paciente_role_and_permissions(apps, schema_editor):
    """Crear rol Paciente y permisos predefinidos del sistema"""
    Roles = apps.get_model('coreapi', 'Roles')
    Permiso = apps.get_model('coreapi', 'Permiso')
    
    # Crear rol Paciente si no existe
    role, created = Roles.objects.get_or_create(
        nombre='Paciente',
        defaults={
            'id': str(uuid.uuid4()),
            'descripcion': 'Paciente que puede ver sus citas y su información personal'
        }
    )
    
    # Definir permisos predefinidos
    permisos_predefinidos = [
        # Pacientes
        {'codigo': 'pacientes.crear', 'nombre': 'Crear Paciente', 'categoria': 'pacientes', 'accion': 'crear', 'descripcion': 'Permite crear nuevos pacientes'},
        {'codigo': 'pacientes.editar', 'nombre': 'Editar Paciente', 'categoria': 'pacientes', 'accion': 'editar', 'descripcion': 'Permite editar información de pacientes'},
        {'codigo': 'pacientes.eliminar', 'nombre': 'Eliminar Paciente', 'categoria': 'pacientes', 'accion': 'eliminar', 'descripcion': 'Permite eliminar pacientes'},
        {'codigo': 'pacientes.ver', 'nombre': 'Ver Pacientes', 'categoria': 'pacientes', 'accion': 'ver', 'descripcion': 'Permite ver lista de pacientes'},
        
        # Usuarios
        {'codigo': 'usuarios.crear', 'nombre': 'Crear Usuario', 'categoria': 'usuarios', 'accion': 'crear', 'descripcion': 'Permite crear nuevos usuarios'},
        {'codigo': 'usuarios.editar', 'nombre': 'Editar Usuario', 'categoria': 'usuarios', 'accion': 'editar', 'descripcion': 'Permite editar usuarios'},
        {'codigo': 'usuarios.eliminar', 'nombre': 'Eliminar Usuario', 'categoria': 'usuarios', 'accion': 'eliminar', 'descripcion': 'Permite eliminar usuarios'},
        {'codigo': 'usuarios.ver', 'nombre': 'Ver Usuarios', 'categoria': 'usuarios', 'accion': 'ver', 'descripcion': 'Permite ver lista de usuarios'},
        
        # Historia Clínica
        {'codigo': 'historia_clinica.crear', 'nombre': 'Crear Historia Clínica', 'categoria': 'historia_clinica', 'accion': 'crear', 'descripcion': 'Permite crear registros de historia clínica'},
        {'codigo': 'historia_clinica.editar', 'nombre': 'Editar Historia Clínica', 'categoria': 'historia_clinica', 'accion': 'editar', 'descripcion': 'Permite editar historia clínica'},
        {'codigo': 'historia_clinica.eliminar', 'nombre': 'Eliminar Historia Clínica', 'categoria': 'historia_clinica', 'accion': 'eliminar', 'descripcion': 'Permite eliminar registros de historia'},
        {'codigo': 'historia_clinica.ver', 'nombre': 'Ver Historia Clínica', 'categoria': 'historia_clinica', 'accion': 'ver', 'descripcion': 'Permite ver historia clínica'},
        
        # Seguimiento
        {'codigo': 'seguimiento.crear', 'nombre': 'Crear Seguimiento', 'categoria': 'seguimiento', 'accion': 'crear', 'descripcion': 'Permite crear entradas de seguimiento'},
        {'codigo': 'seguimiento.editar', 'nombre': 'Editar Seguimiento', 'categoria': 'seguimiento', 'accion': 'editar', 'descripcion': 'Permite editar seguimientos'},
        {'codigo': 'seguimiento.eliminar', 'nombre': 'Eliminar Seguimiento', 'categoria': 'seguimiento', 'accion': 'eliminar', 'descripcion': 'Permite eliminar seguimientos'},
        {'codigo': 'seguimiento.ver', 'nombre': 'Ver Seguimiento', 'categoria': 'seguimiento', 'accion': 'ver', 'descripcion': 'Permite ver seguimientos clínicos'},
        {'codigo': 'seguimiento.firmar', 'nombre': 'Firmar Seguimiento', 'categoria': 'seguimiento', 'accion': 'firmar', 'descripcion': 'Permite firmar entradas de seguimiento como docente'},
        
        # Protocolo Quirúrgico
        {'codigo': 'protocolo_quirurgico.crear', 'nombre': 'Crear Protocolo Quirúrgico', 'categoria': 'protocolo_quirurgico', 'accion': 'crear', 'descripcion': 'Permite crear protocolos quirúrgicos'},
        {'codigo': 'protocolo_quirurgico.editar', 'nombre': 'Editar Protocolo Quirúrgico', 'categoria': 'protocolo_quirurgico', 'accion': 'editar', 'descripcion': 'Permite editar protocolos'},
        {'codigo': 'protocolo_quirurgico.eliminar', 'nombre': 'Eliminar Protocolo Quirúrgico', 'categoria': 'protocolo_quirurgico', 'accion': 'eliminar', 'descripcion': 'Permite eliminar protocolos'},
        {'codigo': 'protocolo_quirurgico.ver', 'nombre': 'Ver Protocolo Quirúrgico', 'categoria': 'protocolo_quirurgico', 'accion': 'ver', 'descripcion': 'Permite ver protocolos quirúrgicos'},
        
        # Asignaciones
        {'codigo': 'asignaciones.crear', 'nombre': 'Crear Asignación', 'categoria': 'asignaciones', 'accion': 'crear', 'descripcion': 'Permite crear asignaciones de pacientes'},
        {'codigo': 'asignaciones.editar', 'nombre': 'Editar Asignación', 'categoria': 'asignaciones', 'accion': 'editar', 'descripcion': 'Permite editar asignaciones'},
        {'codigo': 'asignaciones.eliminar', 'nombre': 'Eliminar Asignación', 'categoria': 'asignaciones', 'accion': 'eliminar', 'descripcion': 'Permite eliminar asignaciones'},
        {'codigo': 'asignaciones.ver', 'nombre': 'Ver Asignaciones', 'categoria': 'asignaciones', 'accion': 'ver', 'descripcion': 'Permite ver asignaciones'},
        
        # Permisos (módulo de gestión de permisos)
        {'codigo': 'permisos.gestionar', 'nombre': 'Gestionar Permisos', 'categoria': 'permisos', 'accion': 'gestionar', 'descripcion': 'Permite asignar y gestionar permisos del sistema'},
    ]
    
    # Crear permisos
    for permiso_data in permisos_predefinidos:
        Permiso.objects.get_or_create(
            codigo=permiso_data['codigo'],
            defaults={
                'id': str(uuid.uuid4()),
                'nombre': permiso_data['nombre'],
                'descripcion': permiso_data['descripcion'],
                'categoria': permiso_data['categoria'],
                'accion': permiso_data['accion'],
                'activo': True
            }
        )


def reverse_paciente_role_and_permissions(apps, schema_editor):
    """Eliminar rol Paciente y permisos creados"""
    Roles = apps.get_model('coreapi', 'Roles')
    Permiso = apps.get_model('coreapi', 'Permiso')
    
    # Eliminar rol Paciente
    Roles.objects.filter(nombre='Paciente').delete()
    
    # Eliminar permisos predefinidos
    codigos_permisos = [
        'pacientes.crear', 'pacientes.editar', 'pacientes.eliminar', 'pacientes.ver',
        'usuarios.crear', 'usuarios.editar', 'usuarios.eliminar', 'usuarios.ver',
        'historia_clinica.crear', 'historia_clinica.editar', 'historia_clinica.eliminar', 'historia_clinica.ver',
        'seguimiento.crear', 'seguimiento.editar', 'seguimiento.eliminar', 'seguimiento.ver', 'seguimiento.firmar',
        'protocolo_quirurgico.crear', 'protocolo_quirurgico.editar', 'protocolo_quirurgico.eliminar', 'protocolo_quirurgico.ver',
        'asignaciones.crear', 'asignaciones.editar', 'asignaciones.eliminar', 'asignaciones.ver',
        'permisos.gestionar',
    ]
    Permiso.objects.filter(codigo__in=codigos_permisos).delete()


class Migration(migrations.Migration):

    dependencies = [
        ('coreapi', '0012_complete'),
    ]

    operations = [
        migrations.CreateModel(
            name='Permiso',
            fields=[
                ('id', models.CharField(default=uuid.uuid4, max_length=36, primary_key=True, serialize=False)),
                ('codigo', models.CharField(db_index=True, max_length=100, unique=True)),
                ('nombre', models.CharField(max_length=200)),
                ('descripcion', models.TextField(blank=True, null=True)),
                ('categoria', models.CharField(db_index=True, max_length=50)),
                ('accion', models.CharField(max_length=20)),
                ('activo', models.BooleanField(default=True)),
                ('creado_en', models.DateTimeField(default=django.utils.timezone.now)),
            ],
            options={
                'verbose_name': 'Permiso',
                'verbose_name_plural': 'Permisos',
                'db_table': 'permisos',
                'ordering': ['categoria', 'accion'],
                'managed': True,
            },
        ),
        migrations.CreateModel(
            name='RolPermiso',
            fields=[
                ('id', models.CharField(default=uuid.uuid4, max_length=36, primary_key=True, serialize=False)),
                ('fecha_asignacion', models.DateTimeField(default=django.utils.timezone.now)),
                ('otorgado_por', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='permisos_otorgados_rol', to='coreapi.usuarios')),
                ('permiso', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='roles_permiso', to='coreapi.permiso')),
                ('rol', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='permisos_rol', to='coreapi.roles')),
            ],
            options={
                'verbose_name': 'Permiso de Rol',
                'verbose_name_plural': 'Permisos de Roles',
                'db_table': 'rol_permiso',
                'managed': True,
                'unique_together': {('rol', 'permiso')},
            },
        ),
        migrations.CreateModel(
            name='UsuarioPermiso',
            fields=[
                ('id', models.CharField(default=uuid.uuid4, max_length=36, primary_key=True, serialize=False)),
                ('tipo', models.CharField(choices=[('grant', 'Otorgar'), ('deny', 'Denegar')], default='grant', max_length=10)),
                ('fecha_asignacion', models.DateTimeField(default=django.utils.timezone.now)),
                ('motivo', models.TextField(blank=True, null=True)),
                ('otorgado_por', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='permisos_otorgados_usuario', to='coreapi.usuarios')),
                ('permiso', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='usuarios_permiso', to='coreapi.permiso')),
                ('usuario', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='permisos_especificos', to='coreapi.usuarios')),
            ],
            options={
                'verbose_name': 'Permiso de Usuario',
                'verbose_name_plural': 'Permisos de Usuarios',
                'db_table': 'usuario_permiso',
                'managed': True,
                'unique_together': {('usuario', 'permiso')},
            },
        ),
        # Crear rol Paciente y permisos predefinidos
        migrations.RunPython(
            create_paciente_role_and_permissions,
            reverse_paciente_role_and_permissions
        ),
    ]
