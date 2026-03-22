#!/usr/bin/env python
"""
Script para verificar roles de usuarios
"""
import os
import sys
import django

# Configurar Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Usuarios, UsuarioRoles

def verificar_roles():
    """Verificar roles asignados a usuarios"""
    usuarios = Usuarios.objects.filter(is_deleted=False)
    
    print(f"\n{'='*60}")
    print(f"VERIFICACIÓN DE ROLES")
    print(f"{'='*60}\n")
    
    for usuario in usuarios:
        roles = UsuarioRoles.objects.filter(usuario_id=usuario.id).select_related('rol')
        roles_nombres = [ur.rol.nombre for ur in roles]
        
        print(f"Usuario: {usuario.username:<20} - Roles: {', '.join(roles_nombres) if roles_nombres else 'SIN ROLES'}")
    
    print(f"\n{'='*60}\n")

if __name__ == '__main__':
    verificar_roles()
