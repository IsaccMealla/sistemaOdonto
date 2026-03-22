"""
Script para crear datos de prueba en el sistema
"""
import os
import django
import sys
import uuid
from datetime import datetime, timedelta
from random import choice, randint, random

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from django.utils import timezone
from coreapi.models import (
    Pacientes, Usuarios, Antecedentes, ContactosEmergencia, 
    RegistroHistoriaClinica, Asignaciones, SeguimientoPaciente,
    HistorialesClinicos
)

# Datos de prueba
NOMBRES_M = ['Juan', 'Carlos', 'Luis', 'Pedro', 'Miguel', 'Jorge', 'Roberto', 'Fernando', 'Diego', 'Andrés']
NOMBRES_F = ['María', 'Ana', 'Carmen', 'Laura', 'Sofia', 'Valentina', 'Camila', 'Isabella', 'Lucía', 'Martina']
APELLIDOS = ['García', 'Rodríguez', 'López', 'Martínez', 'González', 'Pérez', 'Sánchez', 'Ramírez', 'Torres', 'Flores', 'Rivera', 'Gómez', 'Díaz', 'Cruz', 'Morales']

ESTADOS_CIVIL = ['Soltero/a', 'Casado/a', 'Divorciado/a', 'Viudo/a']
OCUPACIONES = ['Estudiante', 'Ingeniero', 'Médico', 'Profesor', 'Comerciante', 'Contador', 'Abogado', 'Arquitecto', 'Empresario', 'Empleado']
TRATAMIENTOS = ['Operatoria Dental', 'Cirugía Oral', 'Endodoncia', 'Periodoncia', 'Prótesis', 'Ortodoncia']

def crear_pacientes():
    """Crear 10 pacientes de prueba"""
    print("\n📋 Creando pacientes...")
    pacientes_creados = []
    
    for i in range(10):
        sexo = choice(['M', 'F'])
        nombres = choice(NOMBRES_M if sexo == 'M' else NOMBRES_F)
        apellidos = f"{choice(APELLIDOS)} {choice(APELLIDOS)}"
        
        # Generar fecha de nacimiento (entre 18 y 80 años)
        edad = randint(18, 80)
        fecha_nac = datetime.now() - timedelta(days=edad*365 + randint(0, 365))
        
        paciente = Pacientes.objects.create(
            id=str(uuid.uuid4()),
            nombres=nombres,
            apellidos=apellidos,
            ci=f"{7000000 + i}{randint(0, 9)}",
            edad=edad,
            sexo=sexo,
            fecha_nacimiento=fecha_nac.date(),
            estado_civil=choice(ESTADOS_CIVIL),
            direccion=f"Zona {choice(['Norte', 'Sur', 'Este', 'Oeste'])} Calle {randint(1, 50)} #{randint(100, 999)}",
            celular=f"7{randint(1, 9)}{randint(100000, 999999)}",
            ocupacion=choice(OCUPACIONES),
        )
        pacientes_creados.append(paciente)
        print(f"  ✅ Paciente creado: {paciente.nombres} {paciente.apellidos} - CI: {paciente.ci}")
    
    return pacientes_creados

def crear_usuarios():
    """Crear 10 usuarios de prueba"""
    print("\n👥 Creando usuarios...")
    usuarios_creados = []
    
    for i in range(10):
        sexo = choice(['M', 'F'])
        nombres = choice(NOMBRES_M if sexo == 'M' else NOMBRES_F)
        apellidos = f"{choice(APELLIDOS)} {choice(APELLIDOS)}"
        username = f"user{i+1:02d}"
        
        # Usar get_or_create para evitar duplicados
        usuario, created = Usuarios.objects.get_or_create(
            username=username,
            defaults={
                'id': str(uuid.uuid4()),
                'email': f"{username}@odonto.edu.bo",
                'nombres': nombres,
                'apellidos': apellidos,
                'activo': 1,
                'creado_en': timezone.now(),
                'password_hash': '',
            }
        )
        
        if created:
            usuario.set_password('password123')
            usuario.save()
            print(f"  ✅ Usuario creado: {usuario.username} - {usuario.nombres} {usuario.apellidos}")
        else:
            print(f"  ℹ️  Usuario ya existe: {usuario.username}")
        
        usuarios_creados.append(usuario)
    
    return usuarios_creados

def crear_antecedentes(pacientes):
    """Crear historiales clínicos y antecedentes para pacientes"""
    print("\n🏥 Creando historiales clínicos y antecedentes...")
    
    for paciente in pacientes[:7]:  # Solo para algunos pacientes
        # Primero crear historial clínico
        historial = HistorialesClinicos.objects.create(
            id=str(uuid.uuid4()),
            paciente=paciente,
            creado_en=datetime.now(),
        )
        
        # Crear antecedente familiar
        antecedente = Antecedentes.objects.create(
            id=str(uuid.uuid4()),
            historial=historial,
            tipo='familiar',
            observaciones=f"Historia familiar de {choice(['diabetes', 'hipertensión', 'cáncer', 'ninguna enfermedad'])}",
        )
        
        print(f"  ✅ Historial y antecedentes creados para: {paciente.nombres} {paciente.apellidos}")

def crear_contactos(pacientes):
    """Crear contactos de emergencia para pacientes"""
    print("\n📞 Creando contactos de emergencia...")
    
    parentescos = ['Madre', 'Padre', 'Hermano/a', 'Esposo/a', 'Hijo/a', 'Amigo/a']
    
    for paciente in pacientes[:8]:  # Solo para algunos pacientes
        ContactosEmergencia.objects.create(
            id=str(uuid.uuid4()),
            paciente=paciente,
            nombre=f"{choice(NOMBRES_M + NOMBRES_F)} {choice(APELLIDOS)}",
            parentesco=choice(parentescos),
            telefono=f"7{randint(1, 9)}{randint(100000, 999999)}",
        )
        print(f"  ✅ Contacto creado para: {paciente.nombres} {paciente.apellidos}")

def crear_historias_clinicas(pacientes, usuarios):
    """Crear registros de historia clínica"""
    print("\n📝 Creando historias clínicas...")
    
    materias = ['periodoncia', 'cirugia', 'endodoncia', 'operatoria', 'prostodoncia_fija', 'odontopediatria']
    tipos_registro = ['habitos', 'examen_periodontal', 'periodontograma', 'diagnostico', 'plan_tratamiento']
    estados = ['pendiente', 'revision', 'aprobado', 'rechazado']
    
    for i, paciente in enumerate(pacientes):
        # Primero asegurar que el paciente tenga un historial
        historial, created = HistorialesClinicos.objects.get_or_create(
            paciente=paciente,
            defaults={
                'id': str(uuid.uuid4()),
                'creado_en': datetime.now(),
            }
        )
        
        # Crear 1-3 registros por paciente
        num_registros = randint(1, 3)
        for j in range(num_registros):
            fecha = datetime.now() - timedelta(days=randint(1, 180))
            materia = choice(materias)
            
            RegistroHistoriaClinica.objects.create(
                id=str(uuid.uuid4()),
                historial=historial,
                paciente=paciente,
                estudiante=choice(usuarios),
                materia=materia,
                tipo_registro=choice(tipos_registro),
                datos={
                    'observaciones': f"Paciente {choice(['colaborador', 'nervioso', 'tranquilo'])}. {choice(['Sin complicaciones', 'Requiere seguimiento', 'Evolución favorable'])}.",
                    'diagnostico': f"Diagnóstico para {materia}"
                },
                estado=choice(estados),
            )
        print(f"  ✅ {num_registros} registros clínicos creados para: {paciente.nombres} {paciente.apellidos}")

def crear_asignaciones(pacientes, usuarios):
    """Crear asignaciones de estudiantes a pacientes"""
    print("\n📚 Creando asignaciones académicas...")
    
    materias = ['Periodoncia', 'Cirugía Bucal', 'Endodoncia', 'Operatoria Dental', 'Prostodoncia', 'Odontopediatría']
    estados = ['activa', 'en_progreso', 'completada', 'cancelada']
    
    for i in range(12):  # Crear 12 asignaciones
        fecha_asig = datetime.now() - timedelta(days=randint(1, 120))
        
        estudiante = choice(usuarios)
        docente = choice([u for u in usuarios if u != estudiante])
        
        Asignaciones.objects.create(
            id=str(uuid.uuid4()),
            estudiante=estudiante,
            paciente=choice(pacientes),
            docente=docente,
            materia=choice(materias),
            fecha_asignacion=fecha_asig,
            fecha_finalizacion=(fecha_asig + timedelta(days=randint(30, 90))) if random() > 0.5 else None,
            estado=choice(estados),
            observaciones=f"Asignación para práctica clínica. {choice(['Paciente colaborador', 'Caso complejo', 'Caso de rutina'])}.",
        )
        print(f"  ✅ Asignación creada: {estudiante.username} -> Paciente")

def crear_seguimientos(pacientes, usuarios):
    """Crear seguimientos de pacientes con entradas"""
    print("\n📊 Creando seguimientos de pacientes...")
    
    from coreapi.models import EntradaSeguimiento
    
    for i in range(15):  # Crear 15 seguimientos
        try:
            seguimiento = SeguimientoPaciente.objects.create(
                id=str(uuid.uuid4()),
                paciente=choice(pacientes),
                estudiante=choice(usuarios),
                activo=choice([True, True, True, False]),  # 75% activos
            )
            
            # Crear 1-3 entradas por seguimiento
            num_entradas = randint(1, 3)
            for j in range(num_entradas):
                fecha = datetime.now() - timedelta(days=randint(1, 90))
                EntradaSeguimiento.objects.create(
                    id=str(uuid.uuid4()),
                    seguimiento=seguimiento,
                    fecha=fecha.date(),
                    pieza_dental=f"{randint(1,4)}.{randint(1,8)}",
                    tratamiento=choice(['Limpieza dental', 'Obturación', 'Extracción', 'Endodoncia', 'Corona']),
                    nro_presupuesto=f"P{randint(1000,9999)}",
                    firmado=choice([True, False]),
                    observaciones=f"{choice(['Sin complicaciones', 'Evolución favorable', 'Requiere seguimiento'])}",
                    orden=j+1,
                )
            
            print(f"  ✅ Seguimiento creado con {num_entradas} entradas")
        except Exception as e:
            print(f"  ⚠️ Error creando seguimiento: {e}")

def main():
    print("=" * 60)
    print("🦷 SISTEMA ODONTOLOGÍA - CREACIÓN DE DATOS DE PRUEBA")
    print("=" * 60)
    
    try:
        # Crear datos en orden
        pacientes = crear_pacientes()
        usuarios = crear_usuarios()
        crear_antecedentes(pacientes)
        crear_contactos(pacientes)
        crear_historias_clinicas(pacientes, usuarios)
        crear_asignaciones(pacientes, usuarios)
        crear_seguimientos(pacientes, usuarios)
        
        print("\n" + "=" * 60)
        print("✅ DATOS DE PRUEBA CREADOS EXITOSAMENTE")
        print("=" * 60)
        print(f"\n📊 Resumen:")
        print(f"  • Pacientes: {len(pacientes)}")
        print(f"  • Usuarios: {len(usuarios)}")
        print(f"  • Historiales Clínicos: {HistorialesClinicos.objects.count()}")
        print(f"  • Antecedentes: {Antecedentes.objects.count()}")
        print(f"  • Contactos: {ContactosEmergencia.objects.count()}")
        print(f"  • Registros Clínicos: {RegistroHistoriaClinica.objects.count()}")
        print(f"  • Asignaciones: {Asignaciones.objects.count()}")
        print(f"  • Seguimientos: {SeguimientoPaciente.objects.count()}")
        
        print("\n💡 Nota: Todos los usuarios tienen password: 'password123'")
        print("   Puedes asignarles roles desde el panel de administración")
        
    except Exception as e:
        print(f"\n❌ Error al crear datos: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()
