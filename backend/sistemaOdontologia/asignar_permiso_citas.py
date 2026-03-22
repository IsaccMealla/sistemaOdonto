import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Roles, Permiso, RolPermiso

# Buscar rol Estudiante
estudiante_rol = Roles.objects.filter(nombre='Estudiante').first()
print(f'Rol Estudiante: {estudiante_rol}')

if not estudiante_rol:
    print('❌ No se encontró el rol Estudiante')
    exit(1)

# Buscar todos los permisos de citas
permisos_citas = Permiso.objects.filter(categoria='citas')
print(f'\nPermisos de citas encontrados: {permisos_citas.count()}')

for permiso in permisos_citas:
    print(f'  - {permiso.codigo}: {permiso.nombre}')

# Asignar permisos de citas al estudiante (al menos citas.ver)
permiso_citas_ver = Permiso.objects.filter(codigo='citas.ver').first()

if permiso_citas_ver:
    rol_permiso, created = RolPermiso.objects.get_or_create(
        rol=estudiante_rol,
        permiso=permiso_citas_ver
    )
    if created:
        print(f'\n✅ Permiso "{permiso_citas_ver.codigo}" asignado al rol Estudiante')
    else:
        print(f'\n✓ El permiso "{permiso_citas_ver.codigo}" ya estaba asignado al rol Estudiante')
else:
    print('\n❌ No se encontró el permiso citas.ver')

# También podemos agregar permisos de crear y editar citas para estudiantes
permisos_adicionales = ['citas.crear', 'citas.editar']
for codigo in permisos_adicionales:
    permiso = Permiso.objects.filter(codigo=codigo).first()
    if permiso:
        rol_permiso, created = RolPermiso.objects.get_or_create(
            rol=estudiante_rol,
            permiso=permiso
        )
        if created:
            print(f'✅ Permiso "{codigo}" asignado al rol Estudiante')
        else:
            print(f'✓ El permiso "{codigo}" ya estaba asignado')

# Mostrar todos los permisos del estudiante
print(f'\n📋 Total de permisos del Estudiante: {RolPermiso.objects.filter(rol=estudiante_rol).count()}')
print('\nPermisos actuales del Estudiante:')
for rp in RolPermiso.objects.filter(rol=estudiante_rol).select_related('permiso'):
    print(f'  - {rp.permiso.codigo}: {rp.permiso.nombre}')

print('\n✅ ¡Proceso completado!')
