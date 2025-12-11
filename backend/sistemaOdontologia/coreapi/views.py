from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.utils import timezone
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
	RegistroPeriodoncia,
	RegistroHistoriaClinica,
	RegistroProstodonciaFija,
	RegistroProstodonciaRemovible,
	RegistroOdontopediatria,
	RegistroSemiologia,
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
	RegistroPeridonciaSerializer,
	RegistroHistoriaClinicaSerializer,
	RegistroProstodonciaFijaSerializer,
	RegistroProstodonciaRemovibleSerializer,
	RegistroOdontopediatriaSerializer,
	RegistroSemiologiaSerializer,
)


class PacienteViewSet(viewsets.ModelViewSet):
	queryset = Pacientes.objects.all()
	serializer_class = PacienteSerializer
	
	def get_queryset(self):
		"""Filtrar pacientes según el parámetro 'deleted'"""
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			# Mostrar solo pacientes eliminados
			return Pacientes.objects.filter(is_deleted=True)
		else:
			# Mostrar solo pacientes activos (por defecto)
			return Pacientes.objects.filter(is_deleted=False)
	
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
		"""Filtrar usuarios según el parámetro 'deleted'"""
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			# Mostrar solo usuarios eliminados
			return Usuarios.objects.filter(is_deleted=True)
		else:
			# Mostrar solo usuarios activos (por defecto)
			return Usuarios.objects.filter(is_deleted=False)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		"""Eliminación lógica - mover a papelera"""
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
	def restore(self, request, pk=None):
		"""Restaurar usuario de la papelera"""
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
	def hard_delete(self, request, pk=None):
		"""Eliminación física permanente (solo desde papelera)"""
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


class AntecedenteViewSet(viewsets.ModelViewSet):
	"""Vista para la tabla padre Antecedentes"""
	queryset = Antecedentes.objects.select_related('historial__paciente').all()
	serializer_class = AntecedenteSerializer


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


class RegistroPeridonciaViewSet(viewsets.ModelViewSet):
	queryset = RegistroPeriodoncia.objects.all()
	serializer_class = RegistroPeridonciaSerializer
	
	def get_queryset(self):
		deleted = self.request.query_params.get('deleted', 'false')
		if deleted.lower() == 'true':
			return RegistroPeriodoncia.objects.filter(is_deleted=True)
		else:
			return RegistroPeriodoncia.objects.filter(is_deleted=False).select_related(
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
