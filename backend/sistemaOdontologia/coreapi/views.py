from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.utils import timezone
from .permissions import role_required, check_permissions, filter_by_role, get_user_roles
from .models import (
	Pacientes,
	HistorialesClinicos,
	ContactosEmergencia,
	Usuarios,
	Roles,
	Asignaciones,
	Antecedentes,
	AntecedentesFamiliares,
	AntecedentesGinecologicos,
	AntecedentesNoPatologicos,
	AntecedentesPatologicosPersonales,
	RegistroCirugiaBucal,
	RegistroOperatoriaEndodoncia,
	RegistroHistoriaClinica,
	RegistroProstodonciaFija,
	RegistroProstodonciaRemovible,
	RegistroOdontopediatria,
	RegistroSemiologia,
	SeguimientoPaciente,
	EntradaSeguimiento,
	ProtocoloQuirurgico,
	Permiso,
	RolPermiso,
	UsuarioPermiso,
	Citas,
	TratamientoMateria,
	PlanTratamiento,
	ProcedimientoPlan,
	EvolucionClinica,
	TransferenciaPaciente,
	RemisionInterCatedra,
)
from .serializers import (
	PacienteSerializer,
	HistorialClinicoSerializer,
	ContactoEmergenciaSerializer,
	UsuarioSerializer,
	RolSerializer,
	AsignacionSerializer,
	AntecedenteSerializer,
	AntecedenteConsolidadoSerializer,
	RegistroCirugiaBucalSerializer,
	RegistroOperatoriaEndodonciaSerializer,
	RegistroHistoriaClinicaSerializer,
	RegistroProstodonciaFijaSerializer,
	RegistroProstodonciaRemovibleSerializer,
	RegistroOdontopediatriaSerializer,
	RegistroSemiologiaSerializer,
	SeguimientoPacienteSerializer,
	EntradaSeguimientoSerializer,
	ProtocoloQuirurgicoSerializer,
	PermisoSerializer,
	RolPermisoSerializer,
	UsuarioPermisoSerializer,
	CitaSerializer,
	TratamientoMateriaSerializer,
	PlanTratamientoSerializer,
	ProcedimientoPlanSerializer,
	EvolucionClinicaSerializer,
	TransferenciaPacienteSerializer,
	RemisionInterCatedraSerializer,
)


class PacienteViewSet(viewsets.ModelViewSet):
	queryset = Pacientes.objects.all()
	serializer_class = PacienteSerializer
	
	def get_queryset(self):
		"""Filtrar pacientes según el parámetro 'deleted' y permisos del usuario"""
		from .models import Asignaciones
		
		deleted = self.request.query_params.get('deleted', 'false')
		
		# Obtener el objeto Usuario del username
		try:
			usuario = Usuarios.objects.get(username=self.request.user.username)
		except Usuarios.DoesNotExist:
			# Si no se encuentra el usuario, devolver queryset vacío
			return Pacientes.objects.none()
		
		# Obtener roles del usuario
		user_roles = get_user_roles(self.request.user)
		
		# Filtro base según deleted
		if deleted.lower() == 'true':
			queryset = Pacientes.objects.filter(is_deleted=True)
		else:
			queryset = Pacientes.objects.filter(is_deleted=False)
		
		# Si es estudiante, filtrar solo sus pacientes asignados
		if 'estudiante' in user_roles and 'admin' not in user_roles and 'administrador' not in user_roles:
			# Obtener IDs de pacientes asignados al estudiante
			pacientes_asignados = Asignaciones.objects.filter(
				estudiante=usuario,
				is_deleted=False
			).values_list('paciente_id', flat=True)
			
			queryset = queryset.filter(id__in=pacientes_asignados)
		
		return queryset
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		"""Eliminación lógica - mover a papelera"""
		try:
			paciente = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			
			paciente.soft_delete(user=user)
			
			return Response({
				'message': f'Paciente {paciente.nombre_completo} eliminado temporalmente',
				'deleted_at': paciente.deleted_at,
				'deleted_by': paciente.deleted_by
			}, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		"""Restaurar paciente de la papelera"""
		try:
			# Obtener paciente eliminado
			paciente = Pacientes.objects.get(pk=pk, is_deleted=True)
			paciente.restore()
			
			return Response({
				'message': f'Paciente {paciente.nombre_completo} restaurado exitosamente'
			}, status=status.HTTP_200_OK)
		except Pacientes.DoesNotExist:
			return Response({'error': 'Paciente no encontrado en papelera'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		"""Eliminación física - permanente"""
		try:
			# Solo permitir eliminar permanentemente si está en papelera
			paciente = Pacientes.objects.get(pk=pk, is_deleted=True)
			nombre_completo = paciente.nombre_completo
			
			paciente.hard_delete()
			
			return Response({
				'message': f'Paciente {nombre_completo} eliminado permanentemente'
			}, status=status.HTTP_200_OK)
		except Pacientes.DoesNotExist:
			return Response({'error': 'Paciente no encontrado en papelera'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def deleted(self, request):
		"""Obtener todos los pacientes eliminados (papelera)"""
		try:
			pacientes_eliminados = Pacientes.objects.filter(is_deleted=True)
			serializer = self.get_serializer(pacientes_eliminados, many=True)
			return Response(serializer.data)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class HistorialClinicoViewSet(viewsets.ModelViewSet):
	queryset = HistorialesClinicos.objects.all()
	serializer_class = HistorialClinicoSerializer


class ContactoEmergenciaViewSet(viewsets.ModelViewSet):
	queryset = ContactosEmergencia.objects.all()
	serializer_class = ContactoEmergenciaSerializer
	
	def get_queryset(self):
		"""Filtrar contactos según el parámetro 'deleted'"""
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			# Mostrar solo contactos eliminados
			return ContactosEmergencia.objects.filter(is_deleted=True)
		else:
			# Mostrar solo contactos activos (no eliminados)
			return ContactosEmergencia.objects.filter(is_deleted=False)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		"""Eliminación lógica del contacto"""
		contacto = self.get_object()
		user = request.user.username if request.user.is_authenticated else None
		contacto.soft_delete(user)
		return Response({'status': 'contacto eliminado'}, status=status.HTTP_200_OK)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		"""Restaurar contacto eliminado"""
		contacto = self.get_object()
		contacto.restore()
		return Response({'status': 'contacto restaurado'}, status=status.HTTP_200_OK)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		"""Eliminación física permanente del contacto"""
		contacto = self.get_object()
		contacto.hard_delete()
		return Response({'status': 'contacto eliminado permanentemente'}, status=status.HTTP_200_OK)


class UsuarioViewSet(viewsets.ModelViewSet):
	queryset = Usuarios.objects.all()
	serializer_class = UsuarioSerializer
	
	def get_queryset(self):
		"""Filtrar usuarios según el parámetro 'deleted' y rol"""
		from .permissions import get_user_roles
		
		deleted = self.request.query_params.get('deleted', 'false')
		user_roles = get_user_roles(self.request.user)
		
		# Docentes no pueden ver el módulo de usuarios
		if 'docente' in user_roles and 'admin' not in user_roles and 'administrador' not in user_roles:
			return Usuarios.objects.none()
		
		if deleted.lower() == 'true':
			# Mostrar solo usuarios eliminados
			return Usuarios.objects.filter(is_deleted=True)
		else:
			# Mostrar solo usuarios activos (por defecto)
			return Usuarios.objects.filter(is_deleted=False)
	
	@action(detail=True, methods=['post'])
	@role_required('admin', 'administrador')
	def soft_delete(self, request, pk=None):
		"""Eliminación lógica - mover a papelera (solo admin)"""
		try:
			usuario = self.get_object()
			current_user = request.user.username if hasattr(request.user, 'username') else 'admin'
			
			# Evitar auto-eliminación
			if usuario.username == current_user:
				return Response({
					'error': 'No puedes eliminar tu propio usuario'
				}, status=status.HTTP_400_BAD_REQUEST)
			
			usuario.soft_delete(user=current_user)
			
			return Response({
				'message': f'Usuario {usuario.username} eliminado temporalmente',
				'deleted_at': usuario.deleted_at,
				'deleted_by': usuario.deleted_by
			}, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	@role_required('admin', 'administrador')
	def restore(self, request, pk=None):
		"""Restaurar usuario de la papelera (solo admin)"""
		try:
			usuario = Usuarios.objects.get(pk=pk, is_deleted=True)
			usuario.restore()
			
			return Response({
				'message': f'Usuario {usuario.username} restaurado exitosamente'
			}, status=status.HTTP_200_OK)
		except Usuarios.DoesNotExist:
			return Response({'error': 'Usuario no encontrado en papelera'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	@role_required('admin', 'administrador')
	def hard_delete(self, request, pk=None):
		"""Eliminación física permanente - solo admin"""
		try:
			usuario = Usuarios.objects.get(pk=pk, is_deleted=True)
			username = usuario.username
			
			usuario.hard_delete()
			
			return Response({
				'message': f'Usuario {username} eliminado permanentemente'
			}, status=status.HTTP_200_OK)
		except Usuarios.DoesNotExist:
			return Response({'error': 'Usuario no encontrado en papelera'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def deleted(self, request):
		"""Obtener todos los usuarios eliminados (papelera)"""
		try:
			usuarios_eliminados = Usuarios.objects.filter(is_deleted=True)
			serializer = self.get_serializer(usuarios_eliminados, many=True)
			return Response(serializer.data)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def change_password(self, request, pk=None):
		"""Cambiar contraseña del usuario"""
		try:
			usuario = self.get_object()
			old_password = request.data.get('old_password')
			new_password = request.data.get('new_password')
			
			if not old_password or not new_password:
				return Response({
					'error': 'Se requieren old_password y new_password'
				}, status=status.HTTP_400_BAD_REQUEST)
			
			# Verificar contraseña antigua
			if not usuario.check_password(old_password):
				return Response({
					'error': 'Contraseña actual incorrecta'
				}, status=status.HTTP_400_BAD_REQUEST)
			
			# Validar nueva contraseña
			if len(new_password) < 6:
				return Response({
					'error': 'La nueva contraseña debe tener al menos 6 caracteres'
				}, status=status.HTTP_400_BAD_REQUEST)
			
			# Establecer nueva contraseña
			usuario.set_password(new_password)
			usuario.save()
			
			return Response({
				'message': 'Contraseña cambiada exitosamente'
			}, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def activate(self, request, pk=None):
		"""Activar usuario"""
		try:
			usuario = self.get_object()
			usuario.activate()
			
			return Response({
				'message': f'Usuario {usuario.username} activado'
			}, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def deactivate(self, request, pk=None):
		"""Desactivar usuario"""
		try:
			usuario = self.get_object()
			current_user = request.user.username if hasattr(request.user, 'username') else 'admin'
			
			# Evitar auto-desactivación
			if usuario.username == current_user:
				return Response({
					'error': 'No puedes desactivar tu propio usuario'
				}, status=status.HTTP_400_BAD_REQUEST)
			
			usuario.deactivate()
			
			return Response({
				'message': f'Usuario {usuario.username} desactivado'
			}, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def me(self, request):
		"""Obtener información del usuario autenticado"""
		try:
			# Obtener el usuario del token de autenticación
			user = request.user
			if not user.is_authenticated:
				return Response({
					'error': 'No autenticado'
				}, status=status.HTTP_401_UNAUTHORIZED)
			
			# Buscar el usuario en la tabla Usuarios
			try:
				usuario = Usuarios.objects.get(username=user.username, is_deleted=False)
				serializer = self.get_serializer(usuario)
				return Response(serializer.data)
			except Usuarios.DoesNotExist:
				return Response({
					'error': 'Usuario no encontrado'
				}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RolViewSet(viewsets.ModelViewSet):
	queryset = Roles.objects.all()
	serializer_class = RolSerializer


class AsignacionViewSet(viewsets.ModelViewSet):
	queryset = Asignaciones.objects.all()
	serializer_class = AsignacionSerializer
	
	def get_queryset(self):
		"""Filtrar asignaciones según el parámetro 'deleted'"""
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			# Mostrar solo asignaciones eliminadas
			return Asignaciones.objects.filter(is_deleted=True).select_related(
				'estudiante', 'paciente', 'docente'
			)
		else:
			# Mostrar solo asignaciones activas (por defecto)
			return Asignaciones.objects.filter(is_deleted=False).select_related(
				'estudiante', 'paciente', 'docente'
			)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		"""Eliminación lógica - mover a papelera"""
		try:
			asignacion = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			
			asignacion.soft_delete(user=user)
			
			return Response({
				'message': 'Asignación eliminada temporalmente',
				'deleted_at': asignacion.deleted_at,
				'deleted_by': asignacion.deleted_by
			}, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		"""Restaurar asignación de la papelera"""
		try:
			asignacion = Asignaciones.objects.get(pk=pk, is_deleted=True)
			asignacion.restore()
			
			return Response({
				'message': 'Asignación restaurada exitosamente'
			}, status=status.HTTP_200_OK)
		except Asignaciones.DoesNotExist:
			return Response({'error': 'Asignación no encontrada en papelera'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		"""Eliminación física - permanente"""
		try:
			asignacion = Asignaciones.objects.get(pk=pk, is_deleted=True)
			asignacion.hard_delete()
			
			return Response({
				'message': 'Asignación eliminada permanentemente'
			}, status=status.HTTP_200_OK)
		except Asignaciones.DoesNotExist:
			return Response({'error': 'Asignación no encontrada en papelera'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def deleted(self, request):
		"""Obtener todas las asignaciones eliminadas (papelera)"""
		try:
			asignaciones_eliminadas = Asignaciones.objects.filter(is_deleted=True).select_related(
				'estudiante', 'paciente', 'docente'
			)
			serializer = self.get_serializer(asignaciones_eliminadas, many=True)
			return Response(serializer.data)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def mis_pacientes(self, request):
		"""Obtener pacientes asignados a un estudiante con info de asignación"""
		try:
			estudiante_id = request.query_params.get('estudiante_id')
			if not estudiante_id:
				return Response({'error': 'estudiante_id requerido'}, status=status.HTTP_400_BAD_REQUEST)
			
			# Obtener asignaciones activas del estudiante
			asignaciones = Asignaciones.objects.filter(
				estudiante_id=estudiante_id,
				is_deleted=False,
				estado__in=['activa', 'en_progreso']
			).select_related('paciente', 'docente')
			
			# Construir respuesta con info del paciente y asignación
			pacientes_data = []
			for asignacion in asignaciones:
				paciente = asignacion.paciente
				docente = asignacion.docente
				
				pacientes_data.append({
					'id': paciente.id,
					'nombres': paciente.nombres,
					'apellidos': paciente.apellidos,
					'ci': paciente.ci,
					'asignacion': {
						'id': asignacion.id,
						'materia': asignacion.materia,
						'docente_nombre': f"{docente.nombres} {docente.apellidos}" if docente.nombres else docente.username,
						'fecha_asignacion': asignacion.fecha_asignacion,
						'estado': asignacion.estado,
						'observaciones': asignacion.observaciones
					}
				})
			
			return Response(pacientes_data)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def asignaciones_docente(self, request):
		"""Obtener estudiantes y sus asignaciones para un docente"""
		try:
			docente_id = request.query_params.get('docente_id')
			if not docente_id:
				return Response({'error': 'docente_id requerido'}, status=status.HTTP_400_BAD_REQUEST)
			
			# Obtener asignaciones activas del docente
			asignaciones = Asignaciones.objects.filter(
				docente_id=docente_id,
				is_deleted=False,
				estado__in=['activa', 'en_progreso']
			).select_related('estudiante', 'paciente').order_by('estudiante__apellidos', 'estudiante__nombres')
			
			# Agrupar por estudiante
			estudiantes_dict = {}
			for asignacion in asignaciones:
				estudiante = asignacion.estudiante
				est_key = estudiante.id
				
				if est_key not in estudiantes_dict:
					estudiantes_dict[est_key] = {
						'id': estudiante.id,
						'nombres': estudiante.nombres,
						'apellidos': estudiante.apellidos,
						'username': estudiante.username,
						'asignaciones': []
					}
				
				paciente = asignacion.paciente
				estudiantes_dict[est_key]['asignaciones'].append({
					'id': asignacion.id,
					'materia': asignacion.materia,
					'fecha_asignacion': asignacion.fecha_asignacion,
					'estado': asignacion.estado,
					'observaciones': asignacion.observaciones,
					'paciente': {
						'id': paciente.id,
						'nombres': paciente.nombres,
						'apellidos': paciente.apellidos,
						'ci': paciente.ci
					}
				})
			
			# Convertir a lista
			estudiantes_data = list(estudiantes_dict.values())
			
			return Response(estudiantes_data)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class AntecedenteViewSet(viewsets.ModelViewSet):
	"""Vista para la tabla padre Antecedentes"""
	queryset = Antecedentes.objects.select_related('historial__paciente').all()
	serializer_class = AntecedenteSerializer
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		"""Eliminación física permanente"""
		try:
			antecedente = self.get_object()
			antecedente.delete()
			return Response({
				'message': 'Antecedente eliminado permanentemente'
			}, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


# Vista consolidada de antecedentes
class AntecedenteConsolidadoViewSet(viewsets.ModelViewSet):
	"""Vista consolidada de todos los antecedentes con nombres de pacientes"""
	queryset = Antecedentes.objects.select_related('historial__paciente').all()
	serializer_class = AntecedenteConsolidadoSerializer
	
	def list(self, request):
		try:
			antecedentes = self.queryset.all()
			serializer = self.serializer_class(antecedentes, many=True)
			return Response(serializer.data)
		except Exception as e:
			print(f"Error in AntecedenteConsolidadoViewSet.list: {e}")
			return Response({'error': str(e)}, status=500)
	
	def create(self, request):
		try:
			print(f"Received data for antecedente: {request.data}")
			serializer = self.serializer_class(data=request.data)
			if serializer.is_valid():
				antecedente = serializer.save()
				return Response(self.serializer_class(antecedente).data, status=201)
			else:
				print(f"Serializer errors: {serializer.errors}")
				return Response(serializer.errors, status=400)
		except Exception as e:
			print(f"Error creating antecedente: {e}")
			return Response({'error': str(e)}, status=500)


# Vista pública para registro de usuarios
@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request):
	"""Endpoint público para registro de nuevos usuarios"""
	try:
		data = request.data.copy()
		
		# Validaciones básicas
		required_fields = ['username', 'email', 'password']
		for field in required_fields:
			if not data.get(field):
				return Response({
					'error': f'El campo {field} es requerido'
				}, status=status.HTTP_400_BAD_REQUEST)
		
		# Verificar si el usuario ya existe
		if Usuarios.objects.filter(username=data['username']).exists():
			return Response({
				'error': 'El nombre de usuario ya está en uso'
			}, status=status.HTTP_400_BAD_REQUEST)
		
		# Verificar si el email ya existe
		if Usuarios.objects.filter(email=data['email']).exists():
			return Response({
				'error': 'El correo electrónico ya está registrado'
			}, status=status.HTTP_400_BAD_REQUEST)
		
		# Crear el usuario
		serializer = UsuarioSerializer(data=data)
		if serializer.is_valid():
			usuario = serializer.save()
			
			# Respuesta exitosa sin incluir datos sensibles
			return Response({
				'message': 'Usuario registrado exitosamente',
				'username': usuario.username,
				'email': usuario.email,
				'id': usuario.id
			}, status=status.HTTP_201_CREATED)
		else:
			return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
			
	except Exception as e:
		return Response({
			'error': f'Error al registrar usuario: {str(e)}'
		}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# ViewSets para Materias Clínicas

class RegistroCirugiaBucalViewSet(viewsets.ModelViewSet):
	queryset = RegistroCirugiaBucal.objects.all()
	serializer_class = RegistroCirugiaBucalSerializer
	
	def get_queryset(self):
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			return RegistroCirugiaBucal.objects.filter(is_deleted=True)
		else:
			return RegistroCirugiaBucal.objects.filter(is_deleted=False).select_related(
				'historial', 'estudiante', 'paciente', 'aprobado_por'
			)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			registro.soft_delete(user)
			return Response({'message': 'Registro movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.restore()
			return Response({'message': 'Registro restaurado exitosamente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.delete()
			return Response({'message': 'Registro eliminado permanentemente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RegistroOperatoriaEndodonciaViewSet(viewsets.ModelViewSet):
	queryset = RegistroOperatoriaEndodoncia.objects.all()
	serializer_class = RegistroOperatoriaEndodonciaSerializer
	
	def get_queryset(self):
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			return RegistroOperatoriaEndodoncia.objects.filter(is_deleted=True)
		else:
			return RegistroOperatoriaEndodoncia.objects.filter(is_deleted=False).select_related(
				'historial', 'estudiante', 'paciente', 'aprobado_por'
			)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			registro.soft_delete(user)
			return Response({'message': 'Registro movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.restore()
			return Response({'message': 'Registro restaurado exitosamente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.delete()
			return Response({'message': 'Registro eliminado permanentemente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)




class RegistroHistoriaClinicaViewSet(viewsets.ModelViewSet):
	"""ViewSet para el modelo unificado de historia clínica"""
	queryset = RegistroHistoriaClinica.objects.all()
	serializer_class = RegistroHistoriaClinicaSerializer
	
	def get_queryset(self):
		"""Filtrar registros con opciones avanzadas"""
		queryset = RegistroHistoriaClinica.objects.all()
		
		# Filtro de eliminados
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			queryset = queryset.filter(is_deleted=True)
		else:
			queryset = queryset.filter(is_deleted=False)
		
		# Filtro por paciente
		paciente_id = self.request.query_params.get('paciente')
		if paciente_id:
			queryset = queryset.filter(paciente_id=paciente_id)
		
		# Filtro por estudiante
		estudiante_id = self.request.query_params.get('estudiante')
		if estudiante_id:
			queryset = queryset.filter(estudiante_id=estudiante_id)
		
		# Filtro por materia
		materia = self.request.query_params.get('materia')
		if materia:
			queryset = queryset.filter(materia=materia)
		
		# Filtro por tipo de registro
		tipo_registro = self.request.query_params.get('tipo_registro')
		if tipo_registro:
			queryset = queryset.filter(tipo_registro=tipo_registro)
		
		# Filtro por estado
		estado = self.request.query_params.get('estado')
		if estado:
			queryset = queryset.filter(estado=estado)
		
		# Filtro por historial
		historial_id = self.request.query_params.get('historial')
		if historial_id:
			queryset = queryset.filter(historial_id=historial_id)
		
		return queryset.select_related(
			'historial', 'estudiante', 'paciente', 'aprobado_por'
		).order_by('-fecha_registro')
	
	@action(detail=False, methods=['get'])
	def por_paciente(self, request):
		"""Obtener todos los registros de un paciente agrupados por materia"""
		paciente_id = request.query_params.get('paciente_id')
		if not paciente_id:
			return Response({'error': 'Se requiere paciente_id'}, status=status.HTTP_400_BAD_REQUEST)
		
		registros = RegistroHistoriaClinica.objects.filter(
			paciente_id=paciente_id,
			is_deleted=False
		).select_related('estudiante', 'aprobado_por').order_by('-fecha_registro')
		
		# Agrupar por materia
		agrupados = {}
		for registro in registros:
			if registro.materia not in agrupados:
				agrupados[registro.materia] = []
			agrupados[registro.materia].append(RegistroHistoriaClinicaSerializer(registro).data)
		
		return Response(agrupados)
	
	@action(detail=False, methods=['get'])
	def mis_registros(self, request):
		"""Obtener registros del estudiante actual filtrados por materia y estado"""
		estudiante_id = request.query_params.get('estudiante_id')
		if not estudiante_id:
			return Response({'error': 'Se requiere estudiante_id'}, status=status.HTTP_400_BAD_REQUEST)
		
		materia = request.query_params.get('materia')
		estado = request.query_params.get('estado', 'pendiente')
		
		queryset = RegistroHistoriaClinica.objects.filter(
			estudiante_id=estudiante_id,
			is_deleted=False,
			estado=estado
		)
		
		if materia:
			queryset = queryset.filter(materia=materia)
		
		registros = queryset.select_related('paciente', 'aprobado_por').order_by('-fecha_registro')
		serializer = RegistroHistoriaClinicaSerializer(registros, many=True)
		return Response(serializer.data)
	
	@action(detail=True, methods=['post'])
	def aprobar(self, request, pk=None):
		"""Aprobar un registro"""
		try:
			registro = self.get_object()
			docente_id = request.data.get('docente_id')
			observaciones = request.data.get('observaciones', '')
			
			if not docente_id:
				return Response({'error': 'Se requiere docente_id'}, status=status.HTTP_400_BAD_REQUEST)
			
			docente = Usuarios.objects.get(id=docente_id)
			registro.aprobar(docente, observaciones)
			
			return Response({
				'message': 'Registro aprobado exitosamente',
				'registro': RegistroHistoriaClinicaSerializer(registro).data
			})
		except Usuarios.DoesNotExist:
			return Response({'error': 'Docente no encontrado'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def rechazar(self, request, pk=None):
		"""Rechazar un registro"""
		try:
			registro = self.get_object()
			docente_id = request.data.get('docente_id')
			observaciones = request.data.get('observaciones', '')
			
			if not docente_id or not observaciones:
				return Response(
					{'error': 'Se requiere docente_id y observaciones'},
					status=status.HTTP_400_BAD_REQUEST
				)
			
			docente = Usuarios.objects.get(id=docente_id)
			registro.rechazar(docente, observaciones)
			
			return Response({
				'message': 'Registro rechazado',
				'registro': RegistroHistoriaClinicaSerializer(registro).data
			})
		except Usuarios.DoesNotExist:
			return Response({'error': 'Docente no encontrado'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def solicitar_correccion(self, request, pk=None):
		"""Solicitar correcciones en un registro"""
		try:
			registro = self.get_object()
			docente_id = request.data.get('docente_id')
			observaciones = request.data.get('observaciones', '')
			
			if not docente_id or not observaciones:
				return Response(
					{'error': 'Se requiere docente_id y observaciones'},
					status=status.HTTP_400_BAD_REQUEST
				)
			
			docente = Usuarios.objects.get(id=docente_id)
			registro.solicitar_correccion(docente, observaciones)
			
			return Response({
				'message': 'Se solicitaron correcciones',
				'registro': RegistroHistoriaClinicaSerializer(registro).data
			})
		except Usuarios.DoesNotExist:
			return Response({'error': 'Docente no encontrado'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		"""Eliminación lógica del registro"""
		try:
			registro = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			registro.soft_delete(user)
			return Response({'message': 'Registro movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		"""Restaurar registro eliminado"""
		try:
			registro = self.get_object()
			registro.restore()
			return Response({'message': 'Registro restaurado exitosamente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		"""Eliminación física del registro"""
		try:
			registro = self.get_object()
			registro.delete()
			return Response({'message': 'Registro eliminado permanentemente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RegistroProstodonciaFijaViewSet(viewsets.ModelViewSet):
	queryset = RegistroProstodonciaFija.objects.all()
	serializer_class = RegistroProstodonciaFijaSerializer
	
	def get_queryset(self):
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			return RegistroProstodonciaFija.objects.filter(is_deleted=True)
		else:
			return RegistroProstodonciaFija.objects.filter(is_deleted=False).select_related(
				'historial', 'estudiante', 'paciente', 'aprobado_por'
			)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			registro.soft_delete(user)
			return Response({'message': 'Registro movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.restore()
			return Response({'message': 'Registro restaurado exitosamente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.delete()
			return Response({'message': 'Registro eliminado permanentemente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RegistroProstodonciaRemovibleViewSet(viewsets.ModelViewSet):
	queryset = RegistroProstodonciaRemovible.objects.all()
	serializer_class = RegistroProstodonciaRemovibleSerializer
	
	def get_queryset(self):
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			return RegistroProstodonciaRemovible.objects.filter(is_deleted=True)
		else:
			return RegistroProstodonciaRemovible.objects.filter(is_deleted=False).select_related(
				'historial', 'estudiante', 'paciente', 'aprobado_por'
			)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			registro.soft_delete(user)
			return Response({'message': 'Registro movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.restore()
			return Response({'message': 'Registro restaurado exitosamente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.delete()
			return Response({'message': 'Registro eliminado permanentemente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RegistroOdontopediatriaViewSet(viewsets.ModelViewSet):
	queryset = RegistroOdontopediatria.objects.all()
	serializer_class = RegistroOdontopediatriaSerializer
	
	def get_queryset(self):
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			return RegistroOdontopediatria.objects.filter(is_deleted=True)
		else:
			return RegistroOdontopediatria.objects.filter(is_deleted=False).select_related(
				'historial', 'estudiante', 'paciente', 'aprobado_por'
			)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			registro.soft_delete(user)
			return Response({'message': 'Registro movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.restore()
			return Response({'message': 'Registro restaurado exitosamente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.delete()
			return Response({'message': 'Registro eliminado permanentemente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RegistroSemiologiaViewSet(viewsets.ModelViewSet):
	queryset = RegistroSemiologia.objects.all()
	serializer_class = RegistroSemiologiaSerializer
	
	def get_queryset(self):
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			return RegistroSemiologia.objects.filter(is_deleted=True)
		else:
			return RegistroSemiologia.objects.filter(is_deleted=False).select_related(
				'historial', 'estudiante', 'paciente', 'aprobado_por'
			)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			registro.soft_delete(user)
			return Response({'message': 'Registro movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.restore()
			return Response({'message': 'Registro restaurado exitosamente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		try:
			registro = self.get_object()
			registro.delete()
			return Response({'message': 'Registro eliminado permanentemente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class ProtocoloQuirurgicoViewSet(viewsets.ModelViewSet):
	queryset = ProtocoloQuirurgico.objects.all()
	serializer_class = ProtocoloQuirurgicoSerializer
	
	def get_queryset(self):
		deleted = self.request.query_params.get('deleted', 'false')
		paciente_id = self.request.query_params.get('paciente_id')
		estudiante_id = self.request.query_params.get('estudiante_id')
		
		queryset = ProtocoloQuirurgico.objects.all()
		
		if deleted.lower() == 'true':
			queryset = queryset.filter(is_deleted=True)
		else:
			queryset = queryset.filter(is_deleted=False)
		
		if paciente_id:
			queryset = queryset.filter(paciente_id=paciente_id)
		
		if estudiante_id:
			queryset = queryset.filter(estudiante_id=estudiante_id)
		
		return queryset.select_related('paciente', 'estudiante', 'docente').order_by('-fecha_cirugia')
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			protocolo = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			protocolo.soft_delete(user)
			return Response({'message': 'Protocolo movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def restore(self, request, pk=None):
		try:
			protocolo = self.get_object()
			protocolo.restore()
			return Response({'message': 'Protocolo restaurado exitosamente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['delete'])
	def hard_delete(self, request, pk=None):
		try:
			protocolo = self.get_object()
			protocolo.delete()
			return Response({'message': 'Protocolo eliminado permanentemente'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


# ===================== PERMISSION VIEWSETS =====================

class PermisoViewSet(viewsets.ModelViewSet):
	"""ViewSet para gestionar permisos del sistema"""
	queryset = Permiso.objects.all()
	serializer_class = PermisoSerializer
	
	def get_queryset(self):
		queryset = Permiso.objects.filter(activo=True)
		categoria = self.request.query_params.get('categoria', None)
		if categoria:
			queryset = queryset.filter(categoria=categoria)
		return queryset.order_by('categoria', 'accion')
	
	@action(detail=False, methods=['get'])
	def categorias(self, request):
		"""Obtener lista de categorías únicas"""
		categorias = Permiso.objects.filter(activo=True).values_list('categoria', flat=True).distinct()
		return Response({'categorias': list(categorias)})


class RolPermisoViewSet(viewsets.ModelViewSet):
	"""ViewSet para gestionar permisos asignados a roles"""
	queryset = RolPermiso.objects.all()
	serializer_class = RolPermisoSerializer
	
	def get_queryset(self):
		queryset = RolPermiso.objects.select_related('rol', 'permiso')
		rol_id = self.request.query_params.get('rol_id', None)
		if rol_id:
			queryset = queryset.filter(rol_id=rol_id)
		return queryset.order_by('rol__nombre', 'permiso__categoria', 'permiso__accion')
	
	def perform_create(self, serializer):
		"""Asignar el usuario que otorga el permiso - opcional"""
		# No asignar otorgado_por para evitar conflictos con autenticación por token
		serializer.save()
	
	@action(detail=False, methods=['post'])
	def asignar_multiples(self, request):
		"""Asignar múltiples permisos a un rol de una vez"""
		rol_id = request.data.get('rol_id')
		permiso_ids = request.data.get('permiso_ids', [])
		
		if not rol_id or not permiso_ids:
			return Response(
				{'error': 'Se requieren rol_id y permiso_ids'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		try:
			rol = Roles.objects.get(id=rol_id)
			permisos_creados = []
			
			for permiso_id in permiso_ids:
				try:
					permiso = Permiso.objects.get(id=permiso_id)
					rol_permiso, created = RolPermiso.objects.get_or_create(
						rol=rol,
						permiso=permiso,
						defaults={'otorgado_por': request.user}
					)
					if created:
						permisos_creados.append(rol_permiso.id)
				except Permiso.DoesNotExist:
					continue
			
			return Response({
				'message': f'{len(permisos_creados)} permisos asignados exitosamente',
				'permisos_creados': permisos_creados
			})
		except Roles.DoesNotExist:
			return Response({'error': 'Rol no encontrado'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['delete'])
	def eliminar_multiples(self, request):
		"""Eliminar múltiples permisos de un rol"""
		rol_id = request.data.get('rol_id')
		permiso_ids = request.data.get('permiso_ids', [])
		
		if not rol_id or not permiso_ids:
			return Response(
				{'error': 'Se requieren rol_id y permiso_ids'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		try:
			eliminados = RolPermiso.objects.filter(
				rol_id=rol_id,
				permiso_id__in=permiso_ids
			).delete()
			
			return Response({
				'message': f'{eliminados[0]} permisos eliminados exitosamente'
			})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class UsuarioPermisoViewSet(viewsets.ModelViewSet):
	"""ViewSet para gestionar permisos específicos de usuarios"""
	queryset = UsuarioPermiso.objects.all()
	serializer_class = UsuarioPermisoSerializer
	
	def get_queryset(self):
		queryset = UsuarioPermiso.objects.select_related('usuario', 'permiso', 'otorgado_por')
		usuario_id = self.request.query_params.get('usuario_id', None)
		if usuario_id:
			queryset = queryset.filter(usuario_id=usuario_id)
		return queryset.order_by('usuario__nombres', 'permiso__categoria', 'permiso__accion')
	
	def perform_create(self, serializer):
		"""Asignar el usuario que otorga el permiso"""
		serializer.save(otorgado_por=self.request.user)
	
	@action(detail=False, methods=['get'])
	def permisos_efectivos(self, request):
		"""Obtener todos los permisos efectivos de un usuario (rol + usuario)"""
		usuario_id = request.query_params.get('usuario_id')
		
		if not usuario_id:
			return Response(
				{'error': 'Se requiere usuario_id'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		try:
			usuario = Usuarios.objects.get(id=usuario_id)
			
			# Obtener roles del usuario a través de UsuarioRoles
			from .models import UsuarioRoles
			usuario_roles_rel = UsuarioRoles.objects.filter(usuario=usuario).select_related('rol')
			roles_ids = [ur.rol.id for ur in usuario_roles_rel]
			
			# Permisos del rol
			permisos_rol = []
			if roles_ids:
				permisos_rol = RolPermiso.objects.filter(
					rol_id__in=roles_ids
				).select_related('permiso').values(
					'permiso__id',
					'permiso__codigo',
					'permiso__nombre',
					'permiso__categoria',
					'permiso__accion',
					'permiso__descripcion'
				)
			
			# Permisos específicos del usuario
			permisos_usuario = UsuarioPermiso.objects.filter(
				usuario=usuario
			).select_related('permiso').values(
				'permiso__id',
				'permiso__codigo',
				'permiso__nombre',
				'permiso__categoria',
				'permiso__accion',
				'permiso__descripcion',
				'tipo'
			)
			
			# Construir lista de permisos efectivos
			permisos_efectivos = {}
			
			# Agregar permisos del rol
			for p in permisos_rol:
				permisos_efectivos[p['permiso__codigo']] = {
					'id': p['permiso__id'],
					'codigo': p['permiso__codigo'],
					'nombre': p['permiso__nombre'],
					'categoria': p['permiso__categoria'],
					'accion': p['permiso__accion'],
					'descripcion': p['permiso__descripcion'],
					'origen': 'rol'
				}
			
			# Aplicar permisos específicos del usuario (grant o deny)
			for p in permisos_usuario:
				codigo = p['permiso__codigo']
				if p['tipo'] == 'grant':
					permisos_efectivos[codigo] = {
						'id': p['permiso__id'],
						'codigo': codigo,
						'nombre': p['permiso__nombre'],
						'categoria': p['permiso__categoria'],
						'accion': p['permiso__accion'],
						'descripcion': p['permiso__descripcion'],
						'origen': 'usuario_grant'
					}
				elif p['tipo'] == 'deny' and codigo in permisos_efectivos:
					# Eliminar el permiso si está denegado
					del permisos_efectivos[codigo]
			
			return Response({
				'usuario_id': usuario_id,
				'usuario_nombre': f"{usuario.nombres or ''} {usuario.apellidos or ''}".strip(),
				'rol': usuario.get_rol_principal(),
				'roles': [ur.rol.nombre for ur in usuario_roles_rel],
				'permisos': list(permisos_efectivos.values())
			})
		except Usuarios.DoesNotExist:
			return Response({'error': 'Usuario no encontrado'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CitaViewSet(viewsets.ModelViewSet):
	"""
	ViewSet para gestionar Citas
	- Estudiantes ven sus propias citas
	- Docentes ven citas de sus estudiantes asignados
	- Permite filtrar por paciente, estudiante, docente y estado
	"""
	queryset = Citas.objects.all()
	serializer_class = CitaSerializer
	
	def get_queryset(self):
		"""Filtrar citas según el rol del usuario"""
		queryset = Citas.objects.select_related('paciente', 'estudiante', 'docente').all()
		
		# Obtener el usuario actual
		try:
			usuario = Usuarios.objects.get(username=self.request.user.username)
		except Usuarios.DoesNotExist:
			return Citas.objects.none()
		
		# Obtener roles del usuario
		user_roles = get_user_roles(self.request.user)
		
		# Filtros de query params
		paciente_id = self.request.query_params.get('paciente_id', None)
		estudiante_id = self.request.query_params.get('estudiante_id', None)
		docente_id = self.request.query_params.get('docente_id', None)
		estado = self.request.query_params.get('estado', None)
		
		# Admin o Administrador ve todas las citas
		if 'admin' in user_roles or 'administrador' in user_roles:
			pass  # No filtrar, ve todo
		# Docente ve TODAS las citas (no solo las suyas)
		elif 'docente' in user_roles:
			pass  # No filtrar, ve todas las citas de todos los estudiantes
		# Estudiante ve sus propias citas
		elif 'estudiante' in user_roles:
			queryset = queryset.filter(estudiante=usuario)
		# Paciente ve sus propias citas (si existe rol paciente)
		elif 'paciente' in user_roles:
			# Buscar si el usuario tiene un paciente relacionado
			paciente = Pacientes.objects.filter(email=usuario.email).first()
			if paciente:
				queryset = queryset.filter(paciente=paciente)
			else:
				return Citas.objects.none()
		else:
			return Citas.objects.none()
		
		# Aplicar filtros adicionales si se proporcionan
		if paciente_id:
			queryset = queryset.filter(paciente_id=paciente_id)
		if estudiante_id:
			queryset = queryset.filter(estudiante_id=estudiante_id)
		if docente_id:
			queryset = queryset.filter(docente_id=docente_id)
		if estado:
			queryset = queryset.filter(estado=estado)
		
		return queryset.order_by('-fecha_hora')
	
	def perform_create(self, serializer):
		"""Crear cita con validaciones"""
		serializer.save()
	
	def perform_update(self, serializer):
		"""Actualizar cita"""
		serializer.save()


class TratamientoMateriaViewSet(viewsets.ModelViewSet):
	"""
	ViewSet para gestionar TratamientoMateria
	- Estudiantes ven y crean sus tratamientos
	- Docentes aprueban/rechazan tratamientos
	- Permite filtrar por estudiante, materia y estado
	"""
	queryset = TratamientoMateria.objects.all()
	serializer_class = TratamientoMateriaSerializer
	
	def get_queryset(self):
		"""Filtrar tratamientos según el rol del usuario"""
		queryset = TratamientoMateria.objects.select_related(
			'estudiante', 'paciente', 'docente_revisor', 'seguimiento'
		).all()
		
		# Obtener el usuario actual
		try:
			usuario = Usuarios.objects.get(username=self.request.user.username)
		except Usuarios.DoesNotExist:
			return TratamientoMateria.objects.none()
		
		# Obtener roles del usuario
		user_roles = get_user_roles(self.request.user)
		
		# Filtros de query params
		estudiante_id = self.request.query_params.get('estudiante_id', None)
		paciente_id = self.request.query_params.get('paciente_id', None)
		materia = self.request.query_params.get('materia', None)
		estado = self.request.query_params.get('estado', None)
		
		# Admin o Administrador ve todos los tratamientos
		if 'admin' in user_roles or 'administrador' in user_roles:
			pass  # No filtrar, ve todo
		# Docente ve todos los tratamientos para revisar
		elif 'docente' in user_roles:
			pass  # Ve todos para poder aprobar/rechazar
		# Estudiante ve solo sus propios tratamientos
		elif 'estudiante' in user_roles:
			queryset = queryset.filter(estudiante=usuario)
		else:
			return TratamientoMateria.objects.none()
		
		# Aplicar filtros adicionales
		if estudiante_id:
			queryset = queryset.filter(estudiante_id=estudiante_id)
		if paciente_id:
			queryset = queryset.filter(paciente_id=paciente_id)
		if materia:
			queryset = queryset.filter(materia=materia)
		if estado:
			queryset = queryset.filter(estado=estado)
		
		return queryset.order_by('-creado_en')
	
	@action(detail=True, methods=['post'])
	def solicitar_aprobacion(self, request, pk=None):
		"""Endpoint para que el estudiante solicite aprobación"""
		tratamiento = self.get_object()
		
		# Verificar que el usuario es el estudiante del tratamiento
		try:
			usuario = Usuarios.objects.get(username=request.user.username)
			if tratamiento.estudiante != usuario:
				return Response(
					{'error': 'No tienes permiso para solicitar aprobación de este tratamiento'},
					status=status.HTTP_403_FORBIDDEN
				)
		except Usuarios.DoesNotExist:
			return Response({'error': 'Usuario no encontrado'}, status=status.HTTP_404_NOT_FOUND)
		
		# Verificar que el estado sea 'borrador'
		if tratamiento.estado != 'borrador':
			return Response(
				{'error': f'No se puede solicitar aprobación en estado {tratamiento.estado}'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		# Solicitar aprobación
		tratamiento.solicitar_aprobacion()
		
		serializer = self.get_serializer(tratamiento)
		return Response(serializer.data, status=status.HTTP_200_OK)
	
	@action(detail=True, methods=['post'])
	def aprobar(self, request, pk=None):
		"""Endpoint para que el docente apruebe un tratamiento"""
		tratamiento = self.get_object()
		
		# Verificar que el usuario es docente
		user_roles = get_user_roles(request.user)
		if 'docente' not in user_roles and 'admin' not in user_roles and 'administrador' not in user_roles:
			return Response(
				{'error': 'Solo los docentes pueden aprobar tratamientos'},
				status=status.HTTP_403_FORBIDDEN
			)
		
		# Verificar que el estado sea 'solicitado'
		if tratamiento.estado != 'solicitado':
			return Response(
				{'error': f'No se puede aprobar un tratamiento en estado {tratamiento.estado}'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		# Obtener observaciones opcionales
		observaciones = request.data.get('observaciones', '')
		
		# Aprobar
		try:
			usuario = Usuarios.objects.get(username=request.user.username)
			tratamiento.aprobar(usuario, observaciones)
			
			serializer = self.get_serializer(tratamiento)
			return Response(serializer.data, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def rechazar(self, request, pk=None):
		"""Endpoint para que el docente rechace un tratamiento"""
		tratamiento = self.get_object()
		
		# Verificar que el usuario es docente
		user_roles = get_user_roles(request.user)
		if 'docente' not in user_roles and 'admin' not in user_roles and 'administrador' not in user_roles:
			return Response(
				{'error': 'Solo los docentes pueden rechazar tratamientos'},
				status=status.HTTP_403_FORBIDDEN
			)
		
		# Verificar que el estado sea 'solicitado'
		if tratamiento.estado != 'solicitado':
			return Response(
				{'error': f'No se puede rechazar un tratamiento en estado {tratamiento.estado}'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		# Observaciones son obligatorias al rechazar
		observaciones = request.data.get('observaciones', '')
		if not observaciones:
			return Response(
				{'error': 'Debe proporcionar observaciones al rechazar un tratamiento'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		# Rechazar
		try:
			usuario = Usuarios.objects.get(username=request.user.username)
			tratamiento.rechazar(usuario, observaciones)
			
			serializer = self.get_serializer(tratamiento)
			return Response(serializer.data, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def estadisticas(self, request):
		"""Endpoint para obtener estadísticas de tratamientos por estudiante"""
		# Obtener el usuario actual
		try:
			usuario = Usuarios.objects.get(username=request.user.username)
		except Usuarios.DoesNotExist:
			return Response({'error': 'Usuario no encontrado'}, status=status.HTTP_404_NOT_FOUND)
		
		# Obtener roles
		user_roles = get_user_roles(request.user)
		
		# Solo estudiantes pueden ver sus propias estadísticas
		if 'estudiante' not in user_roles:
			return Response(
				{'error': 'Este endpoint es solo para estudiantes'},
				status=status.HTTP_403_FORBIDDEN
			)
		
		# Obtener estadísticas por materia
		from django.db.models import Count, Q
		
		stats_por_materia = []
		for materia_code, materia_nombre in TratamientoMateria.MATERIAS_CHOICES:
			aprobados = TratamientoMateria.objects.filter(
				estudiante=usuario,
				materia=materia_code,
				estado='aprobado'
			).count()
			
			solicitados = TratamientoMateria.objects.filter(
				estudiante=usuario,
				materia=materia_code,
				estado='solicitado'
			).count()
			
			stats_por_materia.append({
				'materia': materia_code,
				'materia_nombre': materia_nombre,
				'aprobados': aprobados,
				'solicitados': solicitados,
				'total': aprobados + solicitados,
				'meta': 10,
			})
		
		# Estadísticas generales
		total_aprobados = TratamientoMateria.objects.filter(
			estudiante=usuario,
			estado='aprobado'
		).count()
		
		total_solicitados = TratamientoMateria.objects.filter(
			estudiante=usuario,
			estado='solicitado'
		).count()
		
		total_rechazados = TratamientoMateria.objects.filter(
			estudiante=usuario,
			estado='rechazado'
		).count()
		
		return Response({
			'por_materia': stats_por_materia,
			'resumen': {
				'total_aprobados': total_aprobados,
				'total_solicitados': total_solicitados,
				'total_rechazados': total_rechazados,
			}
		}, status=status.HTTP_200_OK)


class PlanTratamientoViewSet(viewsets.ModelViewSet):
	"""
	ViewSet para gestionar Planes de Tratamiento
	"""
	queryset = PlanTratamiento.objects.all()
	serializer_class = PlanTratamientoSerializer
	
	def get_queryset(self):
		queryset = PlanTratamiento.objects.select_related(
			'paciente', 'estudiante', 'aprobado_por'
		).prefetch_related('procedimientos', 'evoluciones').all()
		
		# Filtros
		paciente_id = self.request.query_params.get('paciente_id', None)
		estudiante_id = self.request.query_params.get('estudiante_id', None)
		materia = self.request.query_params.get('materia', None)
		estado = self.request.query_params.get('estado', None)
		
		if paciente_id:
			queryset = queryset.filter(paciente_id=paciente_id)
		if estudiante_id:
			queryset = queryset.filter(estudiante_id=estudiante_id)
		if materia:
			queryset = queryset.filter(materia=materia)
		if estado:
			queryset = queryset.filter(estado=estado)
		
		return queryset.order_by('-fecha_creacion')
	
	@action(detail=True, methods=['post'])
	def aprobar(self, request, pk=None):
		"""Aprobar un plan de tratamiento"""
		plan = self.get_object()
		
		try:
			usuario = Usuarios.objects.get(username=request.user.username)
			plan.aprobar(usuario)
			serializer = self.get_serializer(plan)
			return Response(serializer.data, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def actualizar_estadisticas(self, request, pk=None):
		"""Recalcular estadísticas del plan"""
		plan = self.get_object()
		plan.actualizar_estadisticas()
		serializer = self.get_serializer(plan)
		return Response(serializer.data, status=status.HTTP_200_OK)


class ProcedimientoPlanViewSet(viewsets.ModelViewSet):
	"""ViewSet para procedimientos del plan"""
	queryset = ProcedimientoPlan.objects.all()
	serializer_class = ProcedimientoPlanSerializer
	
	def get_queryset(self):
		queryset = ProcedimientoPlan.objects.select_related('plan').all()
		
		plan_id = self.request.query_params.get('plan_id', None)
		estado = self.request.query_params.get('estado', None)
		
		if plan_id:
			queryset = queryset.filter(plan_id=plan_id)
		if estado:
			queryset = queryset.filter(estado=estado)
		
		return queryset.order_by('plan', 'secuencia')
	
	@action(detail=True, methods=['post'])
	def completar(self, request, pk=None):
		"""Marcar procedimiento como completado"""
		procedimiento = self.get_object()
		costo_real = request.data.get('costo_real', None)
		procedimiento.completar(costo_real)
		serializer = self.get_serializer(procedimiento)
		return Response(serializer.data, status=status.HTTP_200_OK)
	
	@action(detail=True, methods=['post'])
	def iniciar(self, request, pk=None):
		"""Marcar procedimiento como en progreso"""
		procedimiento = self.get_object()
		procedimiento.iniciar()
		serializer = self.get_serializer(procedimiento)
		return Response(serializer.data, status=status.HTTP_200_OK)


class EvolucionClinicaViewSet(viewsets.ModelViewSet):
	"""ViewSet para evoluciones clínicas"""
	queryset = EvolucionClinica.objects.all()
	serializer_class = EvolucionClinicaSerializer
	
	def get_queryset(self):
		queryset = EvolucionClinica.objects.select_related(
			'plan', 'procedimiento', 'estudiante', 'docente_supervisor'
		).all()
		
		plan_id = self.request.query_params.get('plan_id', None)
		procedimiento_id = self.request.query_params.get('procedimiento_id', None)
		
		if plan_id:
			queryset = queryset.filter(plan_id=plan_id)
		if procedimiento_id:
			queryset = queryset.filter(procedimiento_id=procedimiento_id)
		
		return queryset.order_by('plan', '-fecha_sesion')
	
	@action(detail=True, methods=['post'])
	def firmar_estudiante(self, request, pk=None):
		"""Firma de estudiante"""
		evolucion = self.get_object()
		evolucion.firmar_estudiante()
		serializer = self.get_serializer(evolucion)
		return Response(serializer.data, status=status.HTTP_200_OK)
	
	@action(detail=True, methods=['post'])
	def firmar_docente(self, request, pk=None):
		"""Firma de docente"""
		evolucion = self.get_object()
		evolucion.firmar_docente()
		serializer = self.get_serializer(evolucion)
		return Response(serializer.data, status=status.HTTP_200_OK)


class TransferenciaPacienteViewSet(viewsets.ModelViewSet):
	"""ViewSet para transferencias de pacientes a otras materias"""
	queryset = TransferenciaPaciente.objects.all()
	serializer_class = TransferenciaPacienteSerializer
	
	def get_queryset(self):
		queryset = TransferenciaPaciente.objects.select_related(
			'paciente', 'estudiante_origen', 'estudiante_destino', 'docente_aprobador'
		).all()
		
		estado = self.request.query_params.get('estado', None)
		materia_destino = self.request.query_params.get('materia_destino', None)
		estudiante_origen_id = self.request.query_params.get('estudiante_origen_id', None)
		paciente_id = self.request.query_params.get('paciente_id', None)
		
		if estado:
			queryset = queryset.filter(estado=estado)
		if materia_destino:
			queryset = queryset.filter(materia_destino=materia_destino)
		if estudiante_origen_id:
			queryset = queryset.filter(estudiante_origen_id=estudiante_origen_id)
		if paciente_id:
			queryset = queryset.filter(paciente_id=paciente_id)
		
		return queryset.order_by('-fecha_solicitud')
	
	@action(detail=True, methods=['post'])
	def aprobar(self, request, pk=None):
		"""Aprobar transferencia (pendiente de asignar estudiante)"""
		transferencia = self.get_object()
		observaciones = request.data.get('observaciones', '')
		
		try:
			usuario = Usuarios.objects.get(username=request.user.username)
			transferencia.aprobar(usuario, observaciones)
			serializer = self.get_serializer(transferencia)
			return Response(serializer.data, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def asignar_estudiante(self, request, pk=None):
		"""Asignar estudiante específico a la transferencia aprobada"""
		transferencia = self.get_object()
		
		if transferencia.estado != 'aprobada':
			return Response(
				{'error': 'Solo se puede asignar estudiante a transferencias aprobadas'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		estudiante_id = request.data.get('estudiante_id')
		if not estudiante_id:
			return Response(
				{'error': 'Debe proporcionar estudiante_id'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		try:
			estudiante = Usuarios.objects.get(id=estudiante_id)
			usuario_actual = Usuarios.objects.get(username=request.user.username)
			transferencia.asignar_estudiante(estudiante, usuario_actual)
			serializer = self.get_serializer(transferencia)
			return Response(serializer.data, status=status.HTTP_200_OK)
		except Usuarios.DoesNotExist:
			return Response({'error': 'Estudiante no encontrado'}, status=status.HTTP_404_NOT_FOUND)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def rechazar(self, request, pk=None):
		"""Rechazar transferencia"""
		transferencia = self.get_object()
		observaciones = request.data.get('observaciones', '')
		
		if not observaciones:
			return Response(
				{'error': 'Debe proporcionar observaciones al rechazar'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		try:
			usuario = Usuarios.objects.get(username=request.user.username)
			transferencia.rechazar(usuario, observaciones)
			serializer = self.get_serializer(transferencia)
			return Response(serializer.data, status=status.HTTP_200_OK)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class RemisionInterCatedraViewSet(viewsets.ModelViewSet):
	"""ViewSet para remisiones inter-cátedra"""
	queryset = RemisionInterCatedra.objects.all()
	serializer_class = RemisionInterCatedraSerializer
	
	def get_queryset(self):
		queryset = RemisionInterCatedra.objects.select_related(
			'paciente', 'plan_origen', 'estudiante_remite', 'docente_autoriza', 'estudiante_recibe'
		).all()
		
		estado = self.request.query_params.get('estado', None)
		materia_origen = self.request.query_params.get('materia_origen', None)
		materia_destino = self.request.query_params.get('materia_destino', None)
		
		if estado:
			queryset = queryset.filter(estado=estado)
		if materia_origen:
			queryset = queryset.filter(materia_origen=materia_origen)
		if materia_destino:
			queryset = queryset.filter(materia_destino=materia_destino)
		
		return queryset.order_by('-fecha_remision')
	
	@action(detail=True, methods=['post'])
	def completar_atencion(self, request, pk=None):
		"""Registrar atención en cátedra destino"""
		remision = self.get_object()
		
		tratamiento_realizado = request.data.get('tratamiento_realizado', '')
		hallazgos = request.data.get('hallazgos_catedra_destino', '')
		recomendaciones = request.data.get('recomendaciones', '')
		
		if not tratamiento_realizado or not hallazgos:
			return Response(
				{'error': 'Debe proporcionar tratamiento realizado y hallazgos'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		remision.completar_atencion(tratamiento_realizado, hallazgos, recomendaciones)
		serializer = self.get_serializer(remision)
		return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
def obtener_registro_clinico(request, tipo_registro, registro_id):
	"""
	Obtiene un registro clínico específico por tipo y ID.
	Usado para mostrar referencias vinculadas en evoluciones/seguimientos.
	"""
	try:
		# Mapeo de tipos de registro a modelos
		modelos_registro = {
			'periodontograma': RegistroHistoriaClinica,
			'examen_dental': RegistroHistoriaClinica,
			'protocolo_quirurgico': ProtocoloQuirurgico,
			'cirugia_bucal': RegistroCirugiaBucal,
			'operatoria_endodoncia': RegistroOperatoriaEndodoncia,
			'prostodoncia_fija': RegistroProstodonciaFija,
			'prostodoncia_removible': RegistroProstodonciaRemovible,
			'odontopediatria': RegistroOdontopediatria,
			'semiologia': RegistroSemiologia,
			'antecedentes': Antecedentes,
		}
		
		modelo = modelos_registro.get(tipo_registro)
		if not modelo:
			return Response(
				{'error': f'Tipo de registro no válido: {tipo_registro}'},
				status=status.HTTP_400_BAD_REQUEST
			)
		
		# Obtener registro
		if tipo_registro in ['periodontograma', 'examen_dental']:
			# Para RegistroHistoriaClinica, filtrar por tipo
			registro = modelo.objects.filter(
				id=registro_id,
				tipo_registro=tipo_registro
			).first()
		else:
			registro = modelo.objects.filter(id=registro_id).first()
		
		if not registro:
			return Response(
				{'error': 'Registro no encontrado'},
				status=status.HTTP_404_NOT_FOUND
			)
		
		# Serializar según el tipo
		from django.core.serializers import serialize
		import json
		
		# Convertir a dict básico
		data = {
			'id': str(registro.id),
			'tipo': tipo_registro,
			'fecha': str(getattr(registro, 'fecha_registro', getattr(registro, 'fecha', 'N/A'))),
			'paciente_id': str(registro.paciente.id) if hasattr(registro, 'paciente') else None,
			'paciente_nombre': f"{registro.paciente.nombres} {registro.paciente.apellidos}" if hasattr(registro, 'paciente') else None,
		}
		
		# Agregar datos específicos según tipo
		if tipo_registro == 'periodontograma':
			data.update({
				'datos': registro.datos if hasattr(registro, 'datos') else {},
				'observaciones': registro.observaciones if hasattr(registro, 'observaciones') else '',
			})
		elif tipo_registro == 'protocolo_quirurgico':
			data.update({
				'diagnostico_preoperatorio': registro.diagnostico_preoperatorio,
				'diagnostico_postoperatorio': registro.diagnostico_postoperatorio,
				'observaciones': registro.observaciones,
			})
		else:
			# Para otros tipos, incluir todos los campos relevantes
			data.update({
				'datos': registro.datos if hasattr(registro, 'datos') else {},
				'observaciones': registro.observaciones if hasattr(registro, 'observaciones') else '',
			})
		
		return Response(data, status=status.HTTP_200_OK)
		
	except Exception as e:
		return Response(
			{'error': f'Error al obtener registro: {str(e)}'},
			status=status.HTTP_500_INTERNAL_SERVER_ERROR
		)
