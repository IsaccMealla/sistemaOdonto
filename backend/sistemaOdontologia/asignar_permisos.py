import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Roles, Permiso, RolPermiso

# Buscar roles
admin_rol = Roles.objects.filter(nombre='Administrador').first()
docente_rol = Roles.objects.filter(nombre='Docente').first()
estudiante_rol = Roles.objects.filter(nombre='Estudiante').first()

print(f'Admin: {admin_rol}')
print(f'Docente: {docente_rol}')
print(f'Estudiante: {estudiante_rol}')

# Obtener todos los permisos
permisos = Permiso.objects.all()
print(f'\nTotal permisos: {permisos.count()}')

# Asignar TODOS los permisos al Administrador
if admin_rol:
    count = 0
    for permiso in permisos:
        _, created = RolPermiso.objects.get_or_create(rol=admin_rol, permiso=permiso)
        if created:
            count += 1
    print(f'Permisos NUEVOS asignados a Admin: {count}')
    print(f'Total permisos de Admin: {RolPermiso.objects.filter(rol=admin_rol).count()}')

# Asignar permisos de lectura y edición al Docente (sin eliminar)
if docente_rol:
    count = 0
    permisos_docente = permisos.filter(accion__in=['ver', 'crear', 'editar'])
    for permiso in permisos_docente:
        _, created = RolPermiso.objects.get_or_create(rol=docente_rol, permiso=permiso)
        if created:
            count += 1
    print(f'Permisos NUEVOS asignados a Docente: {count}')
    print(f'Total permisos de Docente: {RolPermiso.objects.filter(rol=docente_rol).count()}')

# Asignar permisos básicos al Estudiante (pacientes, HC, seguimiento, citas)
if estudiante_rol:
    count = 0
    # Permisos de ver para estudiante
    categorias_estudiante = ['pacientes', 'historia_clinica', 'seguimiento', 'citas']
    permisos_estudiante = permisos.filter(categoria__in=categorias_estudiante, accion='ver')
    for permiso in permisos_estudiante:
        _, created = RolPermiso.objects.get_or_create(rol=estudiante_rol, permiso=permiso)
        if created:
            count += 1
    print(f'Permisos NUEVOS asignados a Estudiante: {count}')
    print(f'Total permisos de Estudiante: {RolPermiso.objects.filter(rol=estudiante_rol).count()}')

print('\n¡Permisos asignados exitosamente!')
