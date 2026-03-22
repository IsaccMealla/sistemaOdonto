from django.contrib.auth.backends import BaseBackend
from django.contrib.auth.hashers import check_password
from django.contrib.auth.models import User
from .models import Usuarios


class UsuariosAuthBackend(BaseBackend):
    """
    Backend de autenticación personalizado para el modelo Usuarios
    """
    
    def authenticate(self, request, username=None, password=None, **kwargs):
        """
        Autenticar usuario usando el modelo Usuarios
        """
        try:
            # Buscar usuario en tabla Usuarios
            usuario = Usuarios.objects.get(username=username, is_deleted=False)
            
            # Verificar si la contraseña está hasheada con Django (pbkdf2) o SHA256
            if usuario.password_hash.startswith('pbkdf2_sha256$'):
                # Contraseña hasheada con Django
                if check_password(password, usuario.password_hash):
                    # Crear o actualizar usuario en tabla auth_user de Django
                    django_user, created = User.objects.get_or_create(
                        username=usuario.username,
                        defaults={
                            'email': usuario.email,
                            'is_active': bool(usuario.activo),
                        }
                    )
                    
                    if not created:
                        # Actualizar email y estado activo
                        django_user.email = usuario.email
                        django_user.is_active = bool(usuario.activo)
                        django_user.save()
                    
                    # Sincronizar contraseña
                    django_user.password = usuario.password_hash
                    django_user.save(update_fields=['password'])
                    
                    return django_user
            else:
                # Contraseña antigua con SHA256 (por compatibilidad)
                if usuario.check_password(password):
                    # Migrar a Django password hasher
                    django_user, created = User.objects.get_or_create(
                        username=usuario.username,
                        defaults={
                            'email': usuario.email,
                            'is_active': bool(usuario.activo),
                        }
                    )
                    
                    # Establecer contraseña con hasher de Django
                    django_user.set_password(password)
                    django_user.save()
                    
                    # Actualizar password_hash en Usuarios
                    usuario.password_hash = django_user.password
                    usuario.save(update_fields=['password_hash'])
                    
                    return django_user
                    
        except Usuarios.DoesNotExist:
            return None
        except Exception as e:
            print(f"Error en autenticación: {e}")
            return None
        
        return None
    
    def get_user(self, user_id):
        """
        Obtener usuario de Django auth por ID
        """
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None
