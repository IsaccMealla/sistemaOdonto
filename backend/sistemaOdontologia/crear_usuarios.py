#!/usr/bin/env python
"""
Script para crear 10 estudiantes y 10 docentes
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

def crear_usuarios():
    """Crear 10 estudiantes y 10 docentes"""
    print("\n" + "="*60)
    print("CREANDO USUARIOS - 10 ESTUDIANTES Y 10 DOCENTES")
    print("="*60 + "\n")
    
    # Obtener roles
    try:
        rol_estudiante = Roles.objects.get(nombre='Estudiante')
        rol_docente = Roles.objects.get(nombre='Docente')
    except Roles.DoesNotExist:
        print("ERROR: No se encontraron los roles. Ejecuta primero el script de inicializacion.")
        return
    
    estudiantes_creados = []
    docentes_creados = []
    
    # Crear 10 estudiantes (contador empieza desde un numero alto para evitar duplicados)
    print("\n📚 CREANDO ESTUDIANTES...")
    contador = Usuarios.objects.filter(username__startswith='estudiante').count() + 1
    for i in range(10):
        sexo = choice(['M', 'F'])
        nombres = choice(NOMBRES_M if sexo == 'M' else NOMBRES_F)
        apellidos = f"{choice(APELLIDOS)} {choice(APELLIDOS)}"
        username = f"estudiante{contador + i}"
        codigo = f"EST{2024000 + contador + i}"
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
    
    # Crear 10 docentes (contador empieza desde un numero alto para evitar duplicados)
    print("\n👨‍🏫 CREANDO DOCENTES...")
    contador_doc = Usuarios.objects.filter(username__startswith='docente').count() + 1
    for i in range(10):
        sexo = choice(['M', 'F'])
        nombres = choice(NOMBRES_M if sexo == 'M' else NOMBRES_F)
        apellidos = f"{choice(APELLIDOS)} {choice(APELLIDOS)}"
        username = f"docente{contador_doc + i}"
        codigo = f"DOC{3000 + contador_doc + i}"
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
