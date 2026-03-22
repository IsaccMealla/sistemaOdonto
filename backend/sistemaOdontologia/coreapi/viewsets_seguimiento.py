from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import SeguimientoPaciente, EntradaSeguimiento
from .serializers import SeguimientoPacienteSerializer, EntradaSeguimientoSerializer


class SeguimientoPacienteViewSet(viewsets.ModelViewSet):
	queryset = SeguimientoPaciente.objects.all()
	serializer_class = SeguimientoPacienteSerializer
	
	def get_queryset(self):
		queryset = SeguimientoPaciente.objects.filter(is_deleted=False).select_related(
			'estudiante', 'paciente'
		).prefetch_related('entradas')
		
		# Filtrar por estudiante si se proporciona
		estudiante_id = self.request.query_params.get('estudiante_id', None)
		if estudiante_id:
			queryset = queryset.filter(estudiante_id=estudiante_id)
		
		# Filtrar por paciente si se proporciona
		paciente_id = self.request.query_params.get('paciente_id', None)
		if paciente_id:
			queryset = queryset.filter(paciente_id=paciente_id)
		
		return queryset
	
	@action(detail=False, methods=['get'])
	def mis_seguimientos(self, request):
		"""Obtener seguimientos del estudiante autenticado"""
		estudiante_id = request.query_params.get('estudiante_id')
		if not estudiante_id:
			return Response({'error': 'estudiante_id requerido'}, status=status.HTTP_400_BAD_REQUEST)
		
		seguimientos = SeguimientoPaciente.objects.filter(
			estudiante_id=estudiante_id,
			is_deleted=False
		).select_related('estudiante', 'paciente').prefetch_related('entradas')
		
		serializer = self.get_serializer(seguimientos, many=True)
		return Response(serializer.data)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			seguimiento = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			seguimiento.soft_delete(user)
			return Response({'message': 'Seguimiento movido a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class EntradaSeguimientoViewSet(viewsets.ModelViewSet):
	queryset = EntradaSeguimiento.objects.all()
	serializer_class = EntradaSeguimientoSerializer
	
	def get_queryset(self):
		queryset = EntradaSeguimiento.objects.filter(is_deleted=False).select_related(
			'seguimiento', 'seguimiento__estudiante', 'seguimiento__paciente', 'firmado_por'
		)
		
		# Filtrar por seguimiento si se proporciona
		seguimiento_id = self.request.query_params.get('seguimiento_id', None)
		if seguimiento_id:
			queryset = queryset.filter(seguimiento_id=seguimiento_id)
		
		# Filtrar por estado de firma
		firmado = self.request.query_params.get('firmado', None)
		if firmado is not None:
			queryset = queryset.filter(firmado=firmado.lower() == 'true')
		
		return queryset
	
	@action(detail=True, methods=['post'])
	def firmar(self, request, pk=None):
		"""Firma una entrada de seguimiento"""
		try:
			entrada = self.get_object()
			docente_id = request.data.get('docente_id')
			observaciones = request.data.get('observaciones', '')
			
			if not docente_id:
				return Response({'error': 'docente_id requerido'}, status=status.HTTP_400_BAD_REQUEST)
			
			entrada.firmado = True
			entrada.firmado_por_id = docente_id
			entrada.fecha_firma = timezone.now()
			if observaciones:
				entrada.observaciones = observaciones
			entrada.save()
			
			serializer = self.get_serializer(entrada)
			return Response(serializer.data)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=True, methods=['post'])
	def soft_delete(self, request, pk=None):
		try:
			entrada = self.get_object()
			user = request.user.username if hasattr(request.user, 'username') else 'admin'
			entrada.soft_delete(user)
			return Response({'message': 'Entrada movida a papelera'})
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

class CupoEstudianteViewSet(viewsets.ReadOnlyModelViewSet):
	"""
	ViewSet para consultar cupos de estudiantes.
	Solo lectura - los cupos se actualizan automáticamente al completar procedimientos.
	"""
	from .models import CupoEstudiante
	queryset = CupoEstudiante.objects.all()
	
	def get_serializer_class(self):
		from .serializers import CupoEstudianteSerializer
		return CupoEstudianteSerializer
	
	def get_queryset(self):
		from .models import CupoEstudiante
		queryset = CupoEstudiante.objects.select_related('estudiante')
		
		# Filtrar por estudiante
		estudiante_id = self.request.query_params.get('estudiante_id')
		if estudiante_id:
			queryset = queryset.filter(estudiante_id=estudiante_id)
		
		return queryset.order_by('materia')
	
	@action(detail=False, methods=['get'])
	def mis_cupos(self, request):
		"""Obtener cupos del estudiante autenticado"""
		from .models import CupoEstudiante
		estudiante_id = request.query_params.get('estudiante_id')
		if not estudiante_id:
			return Response({'error': 'estudiante_id requerido'}, status=status.HTTP_400_BAD_REQUEST)
		
		cupos = CupoEstudiante.objects.filter(estudiante_id=estudiante_id)
		
		# Crear datos con todas las materias, incluso si no tienen cupos
		materias = [
			('cirugia_bucal', 'Cirugía Bucal'),
			('operatoria_endodoncia', 'Operatoria y Endodoncia'),
			('periodoncia', 'Periodoncia'),
			('prostodoncia_fija', 'Prostodoncia Fija'),
			('prostodoncia_removible', 'Prostodoncia Removible'),
			('odontopediatria', 'Odontopediatría'),
			('semiologia', 'Semiología'),
		]
		
		result = []
		for materia_code, materia_nombre in materias:
			cupo = cupos.filter(materia=materia_code).first()
			result.append({
				'materia': materia_code,
				'materia_display': materia_nombre,
				'procedimientos_completados': cupo.procedimientos_completados if cupo else 0,
				'ultimo_procedimiento_fecha': cupo.ultimo_procedimiento_fecha if cupo else None,
			})
		
		return Response(result)