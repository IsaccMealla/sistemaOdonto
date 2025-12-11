#!/usr/bin/env python
import requests
import json
import uuid

BASE_URL = "http://127.0.0.1:8000/api"

def test_api_create_patient_and_antecedents():
    print("=== Testing API Patient and Antecedents Creation ===")
    
    # Create a test patient via API
    patient_data = {
        "nombres": "María Elena",
        "apellidos": "González López", 
        "edad": 28,
        "sexo": "F"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/pacientes/", 
                               headers={"Content-Type": "application/json"},
                               data=json.dumps(patient_data))
        
        if response.status_code == 201:
            patient = response.json()
            print(f"✓ Created patient via API: {patient['nombres']} {patient['apellidos']}")
            patient_id = patient['id']
        else:
            print(f"✗ Failed to create patient: {response.status_code} - {response.text}")
            return
    except Exception as e:
        print(f"✗ Error creating patient: {e}")
        return
    
    # Wait a bit and get historial
    import time
    time.sleep(1)
    
    try:
        response = requests.get(f"{BASE_URL}/historiales/")
        if response.status_code == 200:
            historiales = response.json()
            historial = None
            for h in historiales:
                if str(h['paciente']) == str(patient_id):
                    historial = h
                    break
            
            if historial:
                print(f"✓ Found historial for patient: {historial['id']}")
                historial_id = historial['id']
            else:
                print("✗ No historial found for patient")
                return
        else:
            print(f"✗ Failed to get historiales: {response.status_code}")
            return
    except Exception as e:
        print(f"✗ Error getting historiales: {e}")
        return
    
    # Create antecedent via consolidado API
    antecedent_data = {
        "historial": historial_id,
        "tipo": "familiar",
        "observaciones": "Prueba API antecedente familiar",
        "detalles_familiares": {
            "alergia": True,
            "diabetes": False,
            "hipertension_arterial": True,
            "cardiologicos": False,
            "asma_bronquial": True,
            "oncologicos": False,
            "discrasias_sanguineas": False,
            "renales": False
        }
    }
    
    try:
        response = requests.post(f"{BASE_URL}/antecedentes_consolidados/",
                               headers={"Content-Type": "application/json"},
                               data=json.dumps(antecedent_data))
        
        if response.status_code == 201:
            antecedent = response.json()
            print(f"✓ Created antecedent via API: {antecedent['tipo']} for {antecedent.get('paciente_nombre_completo', 'Unknown')}")
        else:
            print(f"✗ Failed to create antecedent: {response.status_code} - {response.text}")
            return
    except Exception as e:
        print(f"✗ Error creating antecedent: {e}")
        return
    
    # List all antecedents via consolidado API  
    try:
        response = requests.get(f"{BASE_URL}/antecedentes_consolidados/")
        if response.status_code == 200:
            antecedents = response.json()
            print(f"\n=== Current Antecedents via API ===")
            for ant in antecedents:
                patient_name = ant.get('paciente_nombre_completo', 'N/A')
                tipo = ant.get('tipo_display', ant.get('tipo', 'N/A'))
                print(f"- {tipo}: {patient_name}")
            
            print(f"\nTotal antecedents via API: {len(antecedents)}")
        else:
            print(f"✗ Failed to get antecedents: {response.status_code}")
    except Exception as e:
        print(f"✗ Error getting antecedents: {e}")

if __name__ == "__main__":
    test_api_create_patient_and_antecedents()