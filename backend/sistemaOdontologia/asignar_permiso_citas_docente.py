import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Roles, Permiso, RolPermiso

# Buscar rol Docente
docente_rol = Roles.objects.filter(nombre='Docente').first()
print(f'Rol Docente: {docente_rol}')

if not docente_rol:
    print('❌ No se encontró el rol Docente')
    exit(1)

# Buscar todos los permisos de citas
permisos_citas = Permiso.objects.filter(categoria='citas')
print(f'\nPermisos de citas encontrados: {permisos_citas.count()}')

# Asignar todos los permisos de citas al docente
for permiso in permisos_citas:
    rol_permiso, created = RolPermiso.objects.get_or_create(
        rol=docente_rol,
        permiso=permiso
    )
    if created:
        print(f'✅ Permiso "{permiso.codigo}" asignado al rol Docente')
    else:
        print(f'✓ El permiso "{permiso.codigo}" ya estaba asignado')

print('\n✅ ¡Proceso completado!')
