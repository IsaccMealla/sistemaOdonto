import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.serializers import CitaSerializer
from coreapi.models import Usuarios, Pacientes
import json

# Obtener un estudiante y paciente real - ricardo.garcia es estudiante
estudiante = Usuarios.objects.filter(username='ricardo.garcia').first()
paciente = Pacientes.objects.filter(is_deleted=False).first()

print(f"Estudiante: {estudiante.id if estudiante else 'No encontrado'}")
print(f"Paciente: {paciente.id if paciente else 'No encontrado'}")

if estudiante and paciente:
    # Probar con los nombres sin _id (como espera el modelo)
    data = {
        'paciente': str(paciente.id),
        'estudiante': str(estudiante.id),
        'docente': None,
        'fecha_hora': '2025-12-20T10:00:00Z',
        'motivo': 'Consulta de prueba',
        'estado': 'pendiente',
    }
    
    print(f"\nDatos a enviar: {json.dumps(data, indent=2)}")
    
    serializer = CitaSerializer(data=data)
    if serializer.is_valid():
        print("\n✅ Serializer válido!")
        cita = serializer.save()
        print(f"Cita creada: {cita.id}")
        
        # Ahora ver cómo se serializa de vuelta
        print(f"\nDatos al serializar de vuelta:")
        print(json.dumps(CitaSerializer(cita).data, indent=2, default=str))
    else:
        print("\n❌ Errores de validación:")
        print(json.dumps(serializer.errors, indent=2))
else:
    print("No hay datos suficientes para la prueba")
