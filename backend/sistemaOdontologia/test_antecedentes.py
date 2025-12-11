#!/usr/bin/env python
import os
import sys
import django

# Add the project path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Pacientes, HistorialesClinicos, Antecedentes
from coreapi.models import AntecedentesFamiliares, AntecedentesGinecologicos
import uuid
from django.utils import timezone

def test_create_paciente_with_antecedentes():
    print("=== Testing Patient and Antecedents Creation ===")
    
    # Create a test patient
    paciente_id = str(uuid.uuid4())
    paciente = Pacientes.objects.create(
        id=paciente_id,
        nombres="Juan Carlos",
        apellidos="Pérez García",
        edad=35,
        sexo="M",
        creado_en=timezone.now()
    )
    print(f"✓ Created patient: {paciente.nombres} {paciente.apellidos}")
    
    # Check if historial was created automatically
    try:
        historial = HistorialesClinicos.objects.get(paciente=paciente)
        print(f"✓ Found historial: {historial.id}")
    except HistorialesClinicos.DoesNotExist:
        # If not created automatically, create it
        historial = HistorialesClinicos.objects.create(
            id=str(uuid.uuid4()),
            paciente=paciente,
            creado_en=timezone.now()
        )
        print(f"✓ Created historial manually: {historial.id}")
    
    # Create antecedente familiar
    antecedente_id = str(uuid.uuid4())
    antecedente_familiar = Antecedentes.objects.create(
        id=antecedente_id,
        historial=historial,
        tipo='familiar',
        observaciones='Prueba de antecedente familiar',
    )
    print(f"✓ Created antecedente base: {antecedente_familiar.id}")
    
    # Create familiar details
    familiar_details = AntecedentesFamiliares.objects.create(
        antecedente=antecedente_familiar,
        alergia=True,
        diabetes=True,
        hipertension_arterial=False
    )
    print(f"✓ Created familiar details")
    
    # Verify the relationship
    try:
        antecedente_with_patient = Antecedentes.objects.select_related('historial__paciente').get(id=antecedente_id)
        patient_name = f"{antecedente_with_patient.historial.paciente.nombres} {antecedente_with_patient.historial.paciente.apellidos}"
        print(f"✓ Verified relationship: {patient_name} - {antecedente_with_patient.tipo}")
        
        # Check familiar details
        familiar_data = antecedente_with_patient.antecedentesfamiliares
        print(f"✓ Familiar details - Alergia: {familiar_data.alergia}, Diabetes: {familiar_data.diabetes}")
        
    except Exception as e:
        print(f"✗ Error verifying relationship: {e}")
    
    # List all antecedents
    print("\n=== Current Antecedents in Database ===")
    antecedentes = Antecedentes.objects.select_related('historial__paciente').all()
    for ant in antecedentes:
        try:
            patient_name = f"{ant.historial.paciente.nombres} {ant.historial.paciente.apellidos}"
            print(f"- {ant.tipo}: {patient_name} (ID: {ant.id})")
        except Exception as e:
            print(f"- {ant.tipo}: Error getting patient name - {e}")
    
    print(f"\nTotal antecedents found: {antecedentes.count()}")

if __name__ == "__main__":
    test_create_paciente_with_antecedentes()