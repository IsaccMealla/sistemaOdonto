#!/usr/bin/env python
"""
Script para resetear contraseñas de usuarios existentes
Uso: python reset_passwords.py
"""
import os
import sys
import django

# Configurar Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Usuarios

def reset_all_passwords():
    """Resetear todas las contraseñas a 'password123'"""
    default_password = 'password123'
    
    usuarios = Usuarios.objects.filter(is_deleted=False)
    
    print(f"\n{'='*60}")
    print(f"RESETEO DE CONTRASEÑAS")
    print(f"{'='*60}\n")
    print(f"Se resetearán las contraseñas de {usuarios.count()} usuarios\n")
    
    for usuario in usuarios:
        usuario.set_password(default_password)
        usuario.save()
        print(f"✓ Usuario: {usuario.username:<20} - Nueva contraseña: {default_password}")
    
    print(f"\n{'='*60}")
    print(f"COMPLETADO - Todas las contraseñas han sido reseteadas")
    print(f"Contraseña temporal: {default_password}")
    print(f"{'='*60}\n")

if __name__ == '__main__':
    reset_all_passwords()
