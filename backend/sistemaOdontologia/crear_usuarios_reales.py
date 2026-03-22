#!/usr/bin/env python
"""
Script para eliminar usuarios estudiante/docente y crear con nombres reales
"""
import os
import django
import sys
import uuid
from random import choice, randint

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Usuarios, Roles, UsuarioRoles

# Datos sin tildes
NOMBRES_M = ['Juan', 'Carlos', 'Luis', 'Pedro', 'Miguel', 'Jorge', 'Roberto', 'Fernando', 'Diego', 'Andres',
             'Ricardo', 'Mario', 'Pablo', 'Javier', 'Sergio', 'Daniel', 'Alberto', 'Raul', 'Francisco', 'Manuel']
NOMBRES_F = ['Maria', 'Ana', 'Carmen', 'Laura', 'Sofia', 'Valentina', 'Camila', 'Isabella', 'Lucia', 'Martina',
             'Paula', 'Andrea', 'Daniela', 'Natalia', 'Carolina', 'Gabriela', 'Veronica', 'Monica', 'Patricia', 'Rosa']
APELLIDOS = ['Garcia', 'Rodriguez', 'Lopez', 'Martinez', 'Gonzalez', 'Perez', 'Sanchez', 'Ramirez', 'Torres', 'Flores',
             'Rivera', 'Gomez', 'Diaz', 'Cruz', 'Morales', 'Herrera', 'Jimenez', 'Alvarez', 'Romero', 'Mendoza']

ESPECIALIDADES = ['Cirugia Bucal', 'Endodoncia', 'Periodoncia', 'Ortodoncia', 'Protesis Dental', 
                  'Odontopediatria', 'Implantologia', 'Estetica Dental']

def limpiar_usuarios_antiguos():
    """Eliminar usuarios con usernames tipo estudianteX y docenteX"""
    print("\n🗑️  ELIMINANDO USUARIOS ANTIGUOS...")
    
    # Marcar como eliminados estudiantes con nombres genéricos
    estudiantes_viejos = Usuarios.objects.filter(username__startswith='estudiante')
    count_est = estudiantes_viejos.count()
    for usuario in estudiantes_viejos:
        usuario.soft_delete(user='admin')
    print(f"✓ Eliminados {count_est} estudiantes con usernames genericos")
    
    # Marcar como eliminados docentes con nombres genéricos
    docentes_viejos = Usuarios.objects.filter(username__startswith='docente')
    count_doc = docentes_viejos.count()
    for usuario in docentes_viejos:
        usuario.soft_delete(user='admin')
    print(f"✓ Eliminados {count_doc} docentes con usernames genericos")

def crear_usuarios():
    """Crear 10 estudiantes y 10 docentes con nombres reales"""
    print("\n" + "="*60)
    print("CREANDO USUARIOS CON NOMBRES REALES")
    print("="*60 + "\n")
    
    # Limpiar usuarios antiguos primero
    limpiar_usuarios_antiguos()
    
    # Obtener roles
    try:
        rol_estudiante = Roles.objects.get(nombre='Estudiante')
        rol_docente = Roles.objects.get(nombre='Docente')
    except Roles.DoesNotExist:
        print("ERROR: No se encontraron los roles.")
        return
    
    estudiantes_creados = []
    docentes_creados = []
    
    # Crear 10 estudiantes con nombres reales
    print("\n📚 CREANDO ESTUDIANTES...")
    for i in range(10):
        sexo = choice(['M', 'F'])
        nombres = choice(NOMBRES_M if sexo == 'M' else NOMBRES_F)
        apellido1 = choice(APELLIDOS)
        apellido2 = choice(APELLIDOS)
        apellidos = f"{apellido1} {apellido2}"
        
        # Username basado en nombre real
        username = f"{nombres.lower()}.{apellido1.lower()}"
        # Verificar si ya existe y agregar numero
        if Usuarios.objects.filter(username=username).exists():
            username = f"{nombres.lower()}.{apellido1.lower()}{randint(1,99)}"
        
        codigo = f"EST{2025000 + randint(100, 999)}"
        # Asegurar que el código sea único
        while Usuarios.objects.filter(codigo_estudiante=codigo).exists():
            codigo = f"EST{2025000 + randint(100, 999)}"
        semestre = randint(1, 10)
        
        try:
            # Crear usuario
            usuario = Usuarios.objects.create(
                id=str(uuid.uuid4()),
                username=username,
                email=f"{username}@odontologia.edu",
                nombres=nombres,
                apellidos=apellidos,
                activo=1,
                codigo_estudiante=codigo,
                semestre=semestre,
                is_deleted=False,
                deleted_at=None,
                deleted_by=None
            )
            # Establecer contraseña
            usuario.set_password('password123')
            usuario.save()
            
            # Asignar rol
            UsuarioRoles.objects.create(
                usuario=usuario,
                rol=rol_estudiante
            )
            
            estudiantes_creados.append(usuario)
            print(f"✓ Estudiante {i+1}/10: {username} - {nombres} {apellidos} - Semestre: {semestre}")
        except Exception as e:
            print(f"✗ Error creando estudiante {i+1}: {e}")
    
    # Crear 10 docentes con nombres reales
    print("\n👨‍🏫 CREANDO DOCENTES...")
    for i in range(10):
        sexo = choice(['M', 'F'])
        nombres = choice(NOMBRES_M if sexo == 'M' else NOMBRES_F)
        apellido1 = choice(APELLIDOS)
        apellido2 = choice(APELLIDOS)
        apellidos = f"{apellido1} {apellido2}"
        
        # Username basado en nombre real
        username = f"dr.{nombres.lower()}.{apellido1.lower()}"
        # Verificar si ya existe y agregar numero
        if Usuarios.objects.filter(username=username).exists():
            username = f"dr.{nombres.lower()}.{apellido1.lower()}{randint(1,99)}"
        
        codigo = f"DOC{4000 + randint(100, 999)}"
        # Asegurar que el código sea único
        while Usuarios.objects.filter(codigo_docente=codigo).exists():
            codigo = f"DOC{4000 + randint(100, 999)}"
        especialidad = choice(ESPECIALIDADES)
        
        try:
            # Crear usuario
            usuario = Usuarios.objects.create(
                id=str(uuid.uuid4()),
                username=username,
                email=f"{username}@odontologia.edu",
                nombres=nombres,
                apellidos=apellidos,
                activo=1,
                codigo_docente=codigo,
                especialidad=especialidad,
                is_deleted=False,
                deleted_at=None,
                deleted_by=None
            )
            # Establecer contraseña
            usuario.set_password('password123')
            usuario.save()
            
            # Asignar rol
            UsuarioRoles.objects.create(
                usuario=usuario,
                rol=rol_docente
            )
            
            docentes_creados.append(usuario)
            print(f"✓ Docente {i+1}/10: {username} - {nombres} {apellidos} - {especialidad}")
        except Exception as e:
            print(f"✗ Error creando docente {i+1}: {e}")
    
    print("\n" + "="*60)
    print(f"✅ COMPLETADO - {len(estudiantes_creados)} estudiantes y {len(docentes_creados)} docentes creados")
    print("="*60 + "\n")
    
    # Mostrar resumen
    print("\n📊 RESUMEN:")
    print(f"   Total estudiantes: {Usuarios.objects.filter(is_deleted=False, codigo_estudiante__isnull=False).count()}")
    print(f"   Total docentes: {Usuarios.objects.filter(is_deleted=False, codigo_docente__isnull=False).count()}")
    print(f"\n🔑 Contraseña para todos los usuarios: password123")
    print(f"\n✓ Script completado exitosamente\n")

if __name__ == '__main__':
    crear_usuarios()
