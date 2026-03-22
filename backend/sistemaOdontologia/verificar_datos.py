"""
Script para verificar y mostrar datos de usuarios y asignaciones
"""
import os
import django
import sys

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Usuarios, UsuarioRoles, Asignaciones, Pacientes

print("=" * 80)
print("📊 VERIFICACIÓN DE DATOS - USUARIOS Y ASIGNACIONES")
print("=" * 80)

print("\n👥 USUARIOS EN EL SISTEMA:")
print("-" * 80)
usuarios = Usuarios.objects.filter(username__startswith='user', is_deleted=False).order_by('username')
for usuario in usuarios:
    roles = UsuarioRoles.objects.filter(usuario=usuario)
    rol_nombres = ', '.join([ur.rol.nombre for ur in roles]) if roles.exists() else 'Sin rol'
    extra = ''
    if usuario.codigo_estudiante:
        extra = f" | Código: {usuario.codigo_estudiante} | Semestre: {usuario.semestre}"
    elif usuario.codigo_docente:
        extra = f" | Código: {usuario.codigo_docente} | Esp: {usuario.especialidad}"
    print(f"  {usuario.username:8} | {usuario.nombres:20} {usuario.apellidos:20} | {rol_nombres:15}{extra}")

print(f"\n📚 ASIGNACIONES EN EL SISTEMA:")
print("-" * 80)
asignaciones = Asignaciones.objects.filter(is_deleted=False)[:15]
for asig in asignaciones:
    est_nombre = f"{asig.estudiante.nombres} {asig.estudiante.apellidos}"
    pac_nombre = f"{asig.paciente.nombres} {asig.paciente.apellidos}"
    doc_nombre = f"{asig.docente.nombres} {asig.docente.apellidos}"
    print(f"  Estudiante: {est_nombre:30} -> Paciente: {pac_nombre:30}")
    print(f"    Docente: {doc_nombre:30} | Materia: {asig.materia:20} | Estado: {asig.estado}")
    print()

print("\n📋 PACIENTES EN EL SISTEMA:")
print("-" * 80)
pacientes = Pacientes.objects.filter(is_deleted=False)[:10]
for pac in pacientes:
    print(f"  {pac.nombres:20} {pac.apellidos:20} | CI: {pac.ci:10} | Edad: {pac.edad}")

print("\n" + "=" * 80)
print(f"TOTALES:")
print(f"  • Usuarios activos: {Usuarios.objects.filter(is_deleted=False).count()}")
print(f"  • Usuarios con roles: {UsuarioRoles.objects.count()}")
print(f"  • Asignaciones activas: {Asignaciones.objects.filter(is_deleted=False).count()}")
print(f"  • Pacientes activos: {Pacientes.objects.filter(is_deleted=False).count()}")
print("=" * 80)
