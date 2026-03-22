"""
Script para asignar roles a los usuarios de prueba
"""
import os
import django
import sys
import uuid

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from coreapi.models import Usuarios, Roles, UsuarioRoles

def asignar_roles():
    print("=" * 60)
    print("👥 ASIGNANDO ROLES A USUARIOS")
    print("=" * 60)
    
    try:
        # Obtener roles
        admin_rol = Roles.objects.get(nombre='Administrador')
        docente_rol = Roles.objects.get(nombre='Docente')
        estudiante_rol = Roles.objects.get(nombre='Estudiante')
        
        # Definir distribución de roles
        asignaciones = [
            # Administradores
            {'username': 'user01', 'rol': admin_rol, 'tipo': 'Administrador'},
            
            # Docentes (con especialidades y materias)
            {'username': 'user02', 'rol': docente_rol, 'tipo': 'Docente', 
             'codigo_docente': 'DOC001', 'especialidad': 'Periodoncia', 'materia': 'Periodoncia'},
            {'username': 'user03', 'rol': docente_rol, 'tipo': 'Docente',
             'codigo_docente': 'DOC002', 'especialidad': 'Cirugía Oral', 'materia': 'Cirugía Bucal'},
            {'username': 'user04', 'rol': docente_rol, 'tipo': 'Docente',
             'codigo_docente': 'DOC003', 'especialidad': 'Endodoncia', 'materia': 'Endodoncia'},
            
            # Estudiantes (con código y semestre)
            {'username': 'user05', 'rol': estudiante_rol, 'tipo': 'Estudiante',
             'codigo_estudiante': 'EST2021001', 'semestre': 7},
            {'username': 'user06', 'rol': estudiante_rol, 'tipo': 'Estudiante',
             'codigo_estudiante': 'EST2021002', 'semestre': 8},
            {'username': 'user07', 'rol': estudiante_rol, 'tipo': 'Estudiante',
             'codigo_estudiante': 'EST2022001', 'semestre': 6},
            {'username': 'user08', 'rol': estudiante_rol, 'tipo': 'Estudiante',
             'codigo_estudiante': 'EST2022002', 'semestre': 7},
            {'username': 'user09', 'rol': estudiante_rol, 'tipo': 'Estudiante',
             'codigo_estudiante': 'EST2023001', 'semestre': 5},
            {'username': 'user10', 'rol': estudiante_rol, 'tipo': 'Estudiante',
             'codigo_estudiante': 'EST2023002', 'semestre': 6},
        ]
        
        print(f"\n✅ Roles encontrados:")
        print(f"   • Administrador: {admin_rol.id}")
        print(f"   • Docente: {docente_rol.id}")
        print(f"   • Estudiante: {estudiante_rol.id}")
        
        print(f"\n📝 Asignando roles a usuarios...")
        
        for asignacion in asignaciones:
            try:
                usuario = Usuarios.objects.get(username=asignacion['username'])
                
                # Actualizar campos específicos del usuario
                if asignacion['tipo'] == 'Docente':
                    usuario.codigo_docente = asignacion.get('codigo_docente')
                    usuario.especialidad = asignacion.get('especialidad')
                    usuario.materia = asignacion.get('materia')
                    usuario.codigo_estudiante = None
                    usuario.semestre = None
                elif asignacion['tipo'] == 'Estudiante':
                    usuario.codigo_estudiante = asignacion.get('codigo_estudiante')
                    usuario.semestre = asignacion.get('semestre')
                    usuario.codigo_docente = None
                    usuario.especialidad = None
                    usuario.materia = None
                else:  # Administrador
                    usuario.codigo_docente = None
                    usuario.codigo_estudiante = None
                    usuario.especialidad = None
                    usuario.materia = None
                    usuario.semestre = None
                
                usuario.save()
                
                # Crear o actualizar relación usuario-rol
                usuario_rol, created = UsuarioRoles.objects.get_or_create(
                    usuario=usuario,
                    rol=asignacion['rol']
                )
                
                if created:
                    print(f"   ✅ {usuario.username} -> {asignacion['tipo']}", end='')
                    if asignacion['tipo'] == 'Docente':
                        print(f" ({asignacion['especialidad']})")
                    elif asignacion['tipo'] == 'Estudiante':
                        print(f" (Semestre {asignacion['semestre']})")
                    else:
                        print()
                else:
                    print(f"   ℹ️  {usuario.username} ya tenía rol {asignacion['tipo']}")
                    
            except Usuarios.DoesNotExist:
                print(f"   ⚠️  Usuario {asignacion['username']} no encontrado")
            except Exception as e:
                print(f"   ❌ Error asignando rol a {asignacion['username']}: {e}")
        
        print("\n" + "=" * 60)
        print("✅ ROLES ASIGNADOS EXITOSAMENTE")
        print("=" * 60)
        
        # Mostrar resumen
        print(f"\n📊 Resumen de usuarios por rol:")
        print(f"   • Administradores: {UsuarioRoles.objects.filter(rol=admin_rol).count()}")
        print(f"   • Docentes: {UsuarioRoles.objects.filter(rol=docente_rol).count()}")
        print(f"   • Estudiantes: {UsuarioRoles.objects.filter(rol=estudiante_rol).count()}")
        
        print(f"\n📋 Detalle de usuarios:")
        for usuario in Usuarios.objects.filter(username__startswith='user').order_by('username'):
            roles = UsuarioRoles.objects.filter(usuario=usuario)
            rol_nombres = ', '.join([ur.rol.nombre for ur in roles])
            extra = ''
            if usuario.codigo_estudiante:
                extra = f" - {usuario.codigo_estudiante} (Sem. {usuario.semestre})"
            elif usuario.codigo_docente:
                extra = f" - {usuario.codigo_docente} ({usuario.especialidad})"
            print(f"   • {usuario.username}: {usuario.nombres} {usuario.apellidos} [{rol_nombres}]{extra}")
        
    except Roles.DoesNotExist as e:
        print(f"\n❌ Error: No se encontraron roles necesarios: {e}")
        print("   Asegúrate de que los roles 'Administrador', 'Docente' y 'Estudiante' existan en la BD")
    except Exception as e:
        print(f"\n❌ Error general: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    asignar_roles()
