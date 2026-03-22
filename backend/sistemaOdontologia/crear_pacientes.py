#!/usr/bin/env python
"""
Script para crear 30 pacientes con datos variados
"""
import os
import django
import sys
import uuid
from datetime import datetime, timedelta
from random import choice, randint

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Pacientes

# Datos sin tildes
NOMBRES_M = ['Juan', 'Carlos', 'Luis', 'Pedro', 'Miguel', 'Jorge', 'Roberto', 'Fernando', 'Diego', 'Andres',
             'Ricardo', 'Mario', 'Pablo', 'Javier', 'Sergio', 'Daniel', 'Alberto', 'Raul', 'Francisco', 'Manuel']
NOMBRES_F = ['Maria', 'Ana', 'Carmen', 'Laura', 'Sofia', 'Valentina', 'Camila', 'Isabella', 'Lucia', 'Martina',
             'Paula', 'Andrea', 'Daniela', 'Natalia', 'Carolina', 'Gabriela', 'Veronica', 'Monica', 'Patricia', 'Rosa']
APELLIDOS = ['Garcia', 'Rodriguez', 'Lopez', 'Martinez', 'Gonzalez', 'Perez', 'Sanchez', 'Ramirez', 'Torres', 'Flores',
             'Rivera', 'Gomez', 'Diaz', 'Cruz', 'Morales', 'Herrera', 'Jimenez', 'Alvarez', 'Romero', 'Mendoza',
             'Vargas', 'Castro', 'Ortiz', 'Ruiz', 'Silva']

ESTADOS_CIVIL = ['Soltero', 'Casado', 'Divorciado', 'Viudo']
OCUPACIONES = ['Estudiante', 'Ingeniero', 'Medico', 'Profesor', 'Comerciante', 'Contador', 'Abogado', 'Arquitecto',
               'Empresario', 'Empleado', 'Mecanico', 'Electricista', 'Chef', 'Designer', 'Programador', 
               'Enfermero', 'Secretario', 'Conductor', 'Agricultor', 'Artista']

DIRECCIONES = [
    'Av. Banzer Zona Norte',
    'Calle Libertad #123',
    'Barrio Equipetrol',
    'Av. Cristo Redentor',
    'Plan 3000 UV 45',
    'Zona Centro Calle Junin',
    'Barrio Hamacas',
    'Av. Busch #456',
    'Zona Sur Calle Florida',
    'Urb. Las Palmas',
    'Villa 1ro de Mayo',
    'Av. Roca y Coronado',
    'Barrio San Martin',
    'Zona Oeste',
    'Av. Santos Dumont'
]

def crear_pacientes():
    """Crear 30 pacientes con datos variados"""
    print("\n" + "="*60)
    print("CREANDO 30 PACIENTES")
    print("="*60 + "\n")
    
    pacientes_creados = []
    
    for i in range(30):
        sexo = choice(['M', 'F'])
        nombres = choice(NOMBRES_M if sexo == 'M' else NOMBRES_F)
        apellidos = f"{choice(APELLIDOS)} {choice(APELLIDOS)}"
        
        # Generar edad (entre 18 y 80 años)
        edad = randint(18, 80)
        fecha_nac = datetime.now() - timedelta(days=edad*365 + randint(0, 365))
        fecha_nac_str = fecha_nac.strftime('%Y-%m-%d')
        
        # CI unico
        ci = f"{7000000 + (i * 1234)}{randint(0, 9)}"
        
        # Celular
        celular = f"7{randint(0, 9)}{randint(100000, 999999)}"
        
        try:
            paciente = Pacientes.objects.create(
                id=str(uuid.uuid4()),
                nombres=nombres,
                apellidos=apellidos,
                ci=ci,
                celular=celular,
                edad=edad,
                sexo=sexo,
                fecha_nacimiento=fecha_nac_str,
                estado_civil=choice(ESTADOS_CIVIL),
                ocupacion=choice(OCUPACIONES),
                direccion=choice(DIRECCIONES),
                ultima_consulta=None,
                motivo_ultima_consulta='',
                is_deleted=False,
                deleted_at=None,
                deleted_by=None
            )
            pacientes_creados.append(paciente)
            print(f"✓ Paciente {i+1}/30: {nombres} {apellidos} - CI: {ci}")
        except Exception as e:
            print(f"✗ Error creando paciente {i+1}: {e}")
    
    print("\n" + "="*60)
    print(f"✅ COMPLETADO - {len(pacientes_creados)} pacientes creados")
    print("="*60 + "\n")
    
    # Mostrar resumen
    print("\n📊 RESUMEN:")
    print(f"   Total pacientes: {Pacientes.objects.filter(is_deleted=False).count()}")
    print(f"   Hombres: {Pacientes.objects.filter(sexo='M', is_deleted=False).count()}")
    print(f"   Mujeres: {Pacientes.objects.filter(sexo='F', is_deleted=False).count()}")
    print(f"\n✓ Script completado exitosamente\n")

if __name__ == '__main__':
    crear_pacientes()
