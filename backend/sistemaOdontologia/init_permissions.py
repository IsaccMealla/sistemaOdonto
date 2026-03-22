import os
import django
import sys
import uuid

# Setup Django
sys.path.append('c:\\Users\\U S E R\\Desktop\\sistemaOdontologia\\backend\\sistemaOdontologia')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Roles, Permiso

# Crear rol Paciente si no existe
role, created = Roles.objects.get_or_create(
    nombre='Paciente',
    defaults={
        'id': str(uuid.uuid4()),
        'descripcion': 'Paciente que puede ver sus citas y su información personal'
    }
)

if created:
    print(f"✓ Rol 'Paciente' creado exitosamente")
else:
    print(f"✓ Rol 'Paciente' ya existía")

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
    
    # Citas
    {'codigo': 'citas.crear', 'nombre': 'Crear Cita', 'categoria': 'citas', 'accion': 'crear', 'descripcion': 'Permite crear nuevas citas médicas'},
    {'codigo': 'citas.editar', 'nombre': 'Editar Cita', 'categoria': 'citas', 'accion': 'editar', 'descripcion': 'Permite editar citas existentes'},
    {'codigo': 'citas.eliminar', 'nombre': 'Eliminar Cita', 'categoria': 'citas', 'accion': 'eliminar', 'descripcion': 'Permite eliminar citas'},
    {'codigo': 'citas.ver', 'nombre': 'Ver Citas', 'categoria': 'citas', 'accion': 'ver', 'descripcion': 'Permite ver el módulo de citas'},
    
    # Reportes
    {'codigo': 'reportes.ver', 'nombre': 'Ver Reportes', 'categoria': 'reportes', 'accion': 'ver', 'descripcion': 'Permite acceder al módulo de reportes'},
    
    # Permisos
    {'codigo': 'permisos.gestionar', 'nombre': 'Gestionar Permisos', 'categoria': 'permisos', 'accion': 'gestionar', 'descripcion': 'Permite asignar y gestionar permisos del sistema'},
]

# Crear permisos
contador_creados = 0
contador_existentes = 0

for permiso_data in permisos_predefinidos:
    permiso, created = Permiso.objects.get_or_create(
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
    if created:
        contador_creados += 1
    else:
        contador_existentes += 1

print(f"\n✓ Permisos creados: {contador_creados}")
print(f"✓ Permisos existentes: {contador_existentes}")
print(f"✓ Total: {len(permisos_predefinidos)}")
print("\n✅ Sistema de permisos inicializado correctamente")
