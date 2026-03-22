"""
Sistema de permisos basado en roles para el sistema odontológico
"""
from functools import wraps
from rest_framework.response import Response
from rest_framework import status


def get_user_roles(user):
    """Obtiene los nombres de roles de un usuario"""
    try:
        from .models import Usuarios, UsuarioRoles
        usuario = Usuarios.objects.get(username=user.username, is_deleted=False)
        # Obtener roles a través de UsuarioRoles
        usuario_roles = UsuarioRoles.objects.filter(usuario=usuario).select_related('rol')
        return [ur.rol.nombre.lower() for ur in usuario_roles]
    except Exception as e:
        print(f"Error obteniendo roles: {e}")
        return []


def role_required(*allowed_roles):
    """
    Decorador para requerir ciertos roles en las vistas.
    Uso: @role_required('admin', 'docente')
    """
    def decorator(func):
        @wraps(func)
        def wrapper(self, request, *args, **kwargs):
            if not request.user or not request.user.is_authenticated:
                return Response(
                    {'error': 'Autenticación requerida'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
            
            user_roles = get_user_roles(request.user)
            
            # Admin siempre tiene acceso
            if 'admin' in user_roles or 'administrador' in user_roles:
                return func(self, request, *args, **kwargs)
            
            # Verificar si el usuario tiene alguno de los roles permitidos
            if any(role.lower() in user_roles for role in allowed_roles):
                return func(self, request, *args, **kwargs)
            
            return Response(
                {'error': 'No tienes permisos para realizar esta acción',
                 'required_roles': list(allowed_roles),
                 'your_roles': user_roles},
                status=status.HTTP_403_FORBIDDEN
            )
        return wrapper
    return decorator


def check_permissions(action_type):
    """
    Decorador para verificar permisos según el tipo de acción.
    
    Reglas:
    - create: admin, docente, estudiante (según módulo)
    - update: admin, docente, estudiante (solo sus registros)
    - delete: admin, docente (no pueden eliminar usuarios)
    - view: todos los autenticados
    
    Uso: @check_permissions('create')
    """
    def decorator(func):
        @wraps(func)
        def wrapper(self, request, *args, **kwargs):
            if not request.user or not request.user.is_authenticated:
                return Response(
                    {'error': 'Autenticación requerida'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
            
            user_roles = get_user_roles(request.user)
            
            # Admin siempre tiene acceso total
            if 'admin' in user_roles or 'administrador' in user_roles:
                return func(self, request, *args, **kwargs)
            
            # Reglas por tipo de acción
            if action_type == 'create':
                # Docentes y estudiantes pueden crear en sus módulos
                if 'docente' in user_roles or 'estudiante' in user_roles:
                    return func(self, request, *args, **kwargs)
                    
            elif action_type == 'update':
                # Docentes y estudiantes pueden editar sus propios registros
                if 'docente' in user_roles or 'estudiante' in user_roles:
                    return func(self, request, *args, **kwargs)
                    
            elif action_type == 'delete':
                # Solo admin y docentes pueden eliminar (con restricciones)
                if 'docente' in user_roles:
                    # Docentes no pueden eliminar usuarios
                    model_name = self.queryset.model.__name__.lower()
                    if model_name == 'usuarios':
                        return Response(
                            {'error': 'Los docentes no pueden eliminar usuarios'},
                            status=status.HTTP_403_FORBIDDEN
                        )
                    return func(self, request, *args, **kwargs)
                    
            elif action_type == 'view':
                # Todos los autenticados pueden ver (con filtros propios)
                return func(self, request, *args, **kwargs)
            
            # Pacientes solo pueden ver sus propios datos
            if 'paciente' in user_roles:
                if action_type == 'view':
                    return func(self, request, *args, **kwargs)
                return Response(
                    {'error': 'Los pacientes solo tienen permisos de lectura'},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            return Response(
                {'error': f'No tienes permisos para {action_type}'},
                status=status.HTTP_403_FORBIDDEN
            )
        return wrapper
    return decorator


class IsOwnerOrAdmin:
    """
    Permiso personalizado para verificar si el usuario es el dueño del registro o admin
    """
    def has_object_permission(self, request, view, obj):
        user_roles = get_user_roles(request.user)
        
        # Admin tiene acceso total
        if 'admin' in user_roles or 'administrador' in user_roles:
            return True
        
        # Verificar si el objeto tiene campo estudiante, usuario o paciente
        if hasattr(obj, 'estudiante'):
            from .models import Usuarios
            try:
                usuario = Usuarios.objects.get(username=request.user.username)
                return obj.estudiante_id == usuario.id
            except:
                return False
        
        if hasattr(obj, 'usuario'):
            return obj.usuario.username == request.user.username
        
        if hasattr(obj, 'paciente'):
            # Los pacientes pueden ver sus propios datos
            if 'paciente' in user_roles:
                from .models import Usuarios
                try:
                    usuario = Usuarios.objects.get(username=request.user.username)
                    # Verificar si el usuario está vinculado al paciente
                    return obj.paciente.id == getattr(usuario, 'paciente_id', None)
                except:
                    return False
        
        return False


def filter_by_role(queryset, request):
    """
    Filtra el queryset según el rol del usuario
    """
    if not request.user or not request.user.is_authenticated:
        return queryset.none()
    
    user_roles = get_user_roles(request.user)
    
    # Admin ve todo
    if 'admin' in user_roles or 'administrador' in user_roles:
        return queryset
    
    # Obtener el usuario de la base de datos
    from .models import Usuarios
    try:
        usuario = Usuarios.objects.get(username=request.user.username, is_deleted=False)
    except:
        return queryset.none()
    
    # Estudiantes solo ven sus registros
    if 'estudiante' in user_roles:
        if hasattr(queryset.model, 'estudiante'):
            return queryset.filter(estudiante_id=usuario.id)
    
    # Pacientes solo ven sus datos
    if 'paciente' in user_roles:
        if hasattr(queryset.model, 'paciente'):
            paciente_id = getattr(usuario, 'paciente_id', None)
            if paciente_id:
                return queryset.filter(paciente_id=paciente_id)
            return queryset.none()
    
    # Docentes ven sus asignaciones y las de sus estudiantes
    if 'docente' in user_roles:
        if hasattr(queryset.model, 'docente'):
            return queryset.filter(docente_id=usuario.id)
        # Docentes también pueden ver estudiantes asignados a ellos
        if queryset.model.__name__ == 'SeguimientoPaciente':
            from .models import Asignaciones
            estudiantes_ids = Asignaciones.objects.filter(
                docente_id=usuario.id,
                is_deleted=False
            ).values_list('estudiante_id', flat=True)
            return queryset.filter(estudiante_id__in=estudiantes_ids)
    
    return queryset
