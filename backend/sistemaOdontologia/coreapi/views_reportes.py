from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Count, Q, Avg, Sum
from django.db.models.functions import TruncMonth, TruncYear
from datetime import datetime, timedelta
from .models import (
	Pacientes, RegistroHistoriaClinica, Asignaciones, Usuarios,
	PlanTratamiento, ProcedimientoPlan, SeguimientoPaciente, EntradaSeguimiento
)
from collections import defaultdict

class ReportesViewSet(viewsets.ViewSet):
	"""ViewSet para generar reportes y estadísticas"""
	
	@action(detail=False, methods=['get'])
	def estadisticas_pacientes(self, request):
		"""Obtener estadísticas generales de pacientes"""
		try:
			# Parámetros de filtro
			fecha_inicio = request.query_params.get('fecha_inicio')
			fecha_fin = request.query_params.get('fecha_fin')
			
			# Query base
			pacientes = Pacientes.objects.filter(is_deleted=False)
			
			if fecha_inicio:
				pacientes = pacientes.filter(creado_en__gte=fecha_inicio)
			if fecha_fin:
				pacientes = pacientes.filter(creado_en__lte=fecha_fin)
			
			# Total de pacientes
			total_pacientes = pacientes.count()
			
			# Pacientes por sexo
			por_sexo = pacientes.values('sexo').annotate(total=Count('id'))
			sexo_stats = {item['sexo'] or 'No especificado': item['total'] for item in por_sexo}
			
			# Pacientes por mes (últimos 12 meses)
			hace_12_meses = datetime.now() - timedelta(days=365)
			pacientes_por_mes = (
				Pacientes.objects
				.filter(is_deleted=False, creado_en__gte=hace_12_meses)
				.annotate(mes=TruncMonth('creado_en'))
				.values('mes')
				.annotate(total=Count('id'))
				.order_by('mes')
			)
			
			meses_data = []
			for item in pacientes_por_mes:
				meses_data.append({
					'mes': item['mes'].strftime('%Y-%m'),
					'total': item['total']
				})
			
			# Pacientes por rango de edad
			from django.db.models import F, Value
			from django.db.models.functions import ExtractYear
			from datetime import date
			
			hoy = date.today()
			rangos_edad = {
				'0-10': 0,
				'11-20': 0,
				'21-30': 0,
				'31-40': 0,
				'41-50': 0,
				'51-60': 0,
				'61+': 0
			}
			
			for paciente in pacientes.exclude(fecha_nacimiento__isnull=True):
				edad = (hoy - paciente.fecha_nacimiento).days // 365
				if edad <= 10:
					rangos_edad['0-10'] += 1
				elif edad <= 20:
					rangos_edad['11-20'] += 1
				elif edad <= 30:
					rangos_edad['21-30'] += 1
				elif edad <= 40:
					rangos_edad['31-40'] += 1
				elif edad <= 50:
					rangos_edad['41-50'] += 1
				elif edad <= 60:
					rangos_edad['51-60'] += 1
				else:
					rangos_edad['61+'] += 1
			
			# Pacientes activos vs eliminados
			estado_stats = {
				'activos': pacientes.filter(is_deleted=False).count(),
				'eliminados': pacientes.filter(is_deleted=True).count()
			}
			
			return Response({
				'total_pacientes': total_pacientes,
				'por_genero': sexo_stats,
				'por_mes': meses_data,
				'por_rango_edad': rangos_edad,
				'por_estado': estado_stats
			})
			
		except Exception as e:
			return Response(
				{'error': str(e)},
				status=status.HTTP_400_BAD_REQUEST
			)
	
	@action(detail=False, methods=['get'])
	def estadisticas_tratamientos(self, request):
		"""Obtener estadísticas de tratamientos"""
		try:
			# Parámetros de filtro
			fecha_inicio = request.query_params.get('fecha_inicio')
			fecha_fin = request.query_params.get('fecha_fin')
			tipo_registro = request.query_params.get('tipo_registro')
			estudiante_id = request.query_params.get('estudiante_id')
			
			# Query base
			registros = RegistroHistoriaClinica.objects.filter(is_deleted=False)
			
			if fecha_inicio:
				registros = registros.filter(fecha_registro__gte=fecha_inicio)
			if fecha_fin:
				registros = registros.filter(fecha_registro__lte=fecha_fin)
			if tipo_registro:
				registros = registros.filter(tipo_registro=tipo_registro)
			if estudiante_id:
				# Filtrar por estudiante a través de asignaciones
				from django.db.models import Q
				registros = registros.filter(
					Q(asignacion__estudiante_id=estudiante_id) |
					Q(paciente__asignaciones_paciente__estudiante_id=estudiante_id)
				).distinct()
			
			# Contar por tipo de registro
			tipos_tratamiento = registros.values('tipo_registro').annotate(
				total=Count('id')
			)
			
			tratamientos_stats = {}
			for item in tipos_tratamiento:
				tipo = item['tipo_registro'] or 'Sin especificar'
				tratamientos_stats[tipo] = item['total']
			
			# Tratamientos por mes
			hace_6_meses = datetime.now() - timedelta(days=180)
			tratamientos_por_mes = (
				registros
				.filter(fecha_registro__gte=hace_6_meses)
				.annotate(mes=TruncMonth('fecha_registro'))
				.values('mes')
				.annotate(total=Count('id'))
				.order_by('mes')
			)
			
			meses_data = []
			for item in tratamientos_por_mes:
				meses_data.append({
					'mes': item['mes'].strftime('%Y-%m'),
					'total': item['total']
				})
			
			# Tratamientos por estado
			estado_stats = {
				'completados': registros.filter(estado='completado').count(),
				'en_progreso': registros.filter(estado='en_progreso').count(),
				'pendientes': registros.filter(estado='pendiente').count(),
			}
			
			# Top pacientes con más tratamientos
			top_pacientes = (
				registros
				.values('paciente__nombres', 'paciente__apellidos')
				.annotate(total=Count('id'))
				.order_by('-total')[:10]
			)
			
			pacientes_data = []
			for item in top_pacientes:
				nombre = f"{item['paciente__nombres']} {item['paciente__apellidos']}"
				pacientes_data.append({
					'nombre': nombre,
					'tratamientos': item['total']
				})
			
			return Response({
				'total_tratamientos': registros.count(),
				'por_tipo': tratamientos_stats,
				'por_mes': meses_data,
				'por_estado': estado_stats,
				'top_pacientes': pacientes_data
			})
			
		except Exception as e:
			return Response(
				{'error': str(e)},
				status=status.HTTP_400_BAD_REQUEST
			)
	
	@action(detail=False, methods=['get'])
	def estadisticas_academicas(self, request):
		"""Obtener estadísticas académicas (estudiantes/docentes)"""
		try:
			# Parámetros de filtro
			fecha_inicio = request.query_params.get('fecha_inicio')
			fecha_fin = request.query_params.get('fecha_fin')
			estado = request.query_params.get('estado')
			estudiante_id = request.query_params.get('estudiante_id')
			docente_id = request.query_params.get('docente_id')
			
			# Query base
			asignaciones = Asignaciones.objects.all()
			
			if fecha_inicio:
				asignaciones = asignaciones.filter(fecha_asignacion__gte=fecha_inicio)
			if fecha_fin:
				asignaciones = asignaciones.filter(fecha_asignacion__lte=fecha_fin)
			if estado:
				asignaciones = asignaciones.filter(estado=estado)
			if estudiante_id:
				asignaciones = asignaciones.filter(estudiante_id=estudiante_id)
			if docente_id:
				asignaciones = asignaciones.filter(docente_id=docente_id)
			
			# Pacientes por estudiante
			por_estudiante = asignaciones.values(
				'estudiante__nombres',
				'estudiante__apellidos',
				'estudiante_id'
			).annotate(total=Count('id')).order_by('-total')[:10]
			
			estudiantes_stats = []
			for item in por_estudiante:
				nombre = f"{item['estudiante__nombres']} {item['estudiante__apellidos']}"
				estudiantes_stats.append({
					'id': item['estudiante_id'],
					'nombre': nombre,
					'pacientes': item['total']
				})
			
			# Pacientes supervisados por docente
			por_docente = asignaciones.values(
				'docente__nombres',
				'docente__apellidos',
				'docente_id'
			).annotate(total=Count('id')).order_by('-total')[:10]
			
			docentes_stats = []
			for item in por_docente:
				nombre = f"{item['docente__nombres']} {item['docente__apellidos']}"
				docentes_stats.append({
					'id': item['docente_id'],
					'nombre': nombre,
					'pacientes': item['total']
				})
			
			# Asignaciones por estado
			por_estado = asignaciones.values('estado').annotate(
				total=Count('id')
			)
			
			estado_stats = {item['estado'] or 'Sin estado': item['total'] for item in por_estado}
			
			# Asignaciones por mes
			hace_12_meses = datetime.now() - timedelta(days=365)
			asignaciones_por_mes = (
				asignaciones
				.filter(fecha_asignacion__gte=hace_12_meses)
				.annotate(mes=TruncMonth('fecha_asignacion'))
				.values('mes')
				.annotate(total=Count('id'))
				.order_by('mes')
			)
			
			meses_data = []
			for item in asignaciones_por_mes:
				meses_data.append({
					'mes': item['mes'].strftime('%Y-%m'),
					'total': item['total']
				})
			
			return Response({
				'total_asignaciones': asignaciones.count(),
				'top_estudiantes': estudiantes_stats,
				'top_docentes': docentes_stats,
				'por_estado': estado_stats,
				'por_mes': meses_data
			})
			
		except Exception as e:
			return Response(
				{'error': str(e)},
				status=status.HTTP_400_BAD_REQUEST
			)
	
	@action(detail=False, methods=['get'])
	def lista_estudiantes(self, request):
		"""Obtener lista de estudiantes para filtros"""
		try:
			from .models import UsuarioRoles
			# Obtener IDs de usuarios con rol Estudiante
			estudiante_ids = UsuarioRoles.objects.filter(
				rol__nombre='Estudiante'
			).values_list('usuario_id', flat=True).distinct()
			
			estudiantes = Usuarios.objects.filter(
				id__in=estudiante_ids
			).values('id', 'nombres', 'apellidos').order_by('apellidos', 'nombres')
			
			result = []
			for est in estudiantes:
				result.append({
					'id': est['id'],
					'nombre': f"{est['nombres']} {est['apellidos']}"
				})
			
			return Response(result)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def lista_docentes(self, request):
		"""Obtener lista de docentes para filtros"""
		try:
			from .models import UsuarioRoles
			# Obtener IDs de usuarios con rol Docente
			docente_ids = UsuarioRoles.objects.filter(
				rol__nombre='Docente'
			).values_list('usuario_id', flat=True).distinct()
			
			docentes = Usuarios.objects.filter(
				id__in=docente_ids
			).values('id', 'nombres', 'apellidos').order_by('apellidos', 'nombres')
			
			result = []
			for doc in docentes:
				result.append({
					'id': doc['id'],
					'nombre': f"{doc['nombres']} {doc['apellidos']}"
				})
			
			return Response(result)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def tipos_tratamiento(self, request):
		"""Obtener lista de tipos de tratamiento disponibles"""
		try:
			# Obtener tipos únicos de tratamiento
			tipos = RegistroHistoriaClinica.objects.filter(
				is_deleted=False
			).values_list('tipo_registro', flat=True).distinct().order_by('tipo_registro')
			
			# Filtrar valores nulos y vacíos
			result = [t for t in tipos if t]
			return Response(result)
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
	
	@action(detail=False, methods=['get'])
	def estadisticas_seguimientos(self, request):
		"""Obtener estadísticas de seguimientos de pacientes"""
		try:
			from .viewsets_seguimiento import SeguimientoPaciente, EntradaSeguimiento
			
			# Parámetros de filtro
			fecha_inicio = request.query_params.get('fecha_inicio')
			fecha_fin = request.query_params.get('fecha_fin')
			estudiante_id = request.query_params.get('estudiante_id')
			
			# Query base
			seguimientos = SeguimientoPaciente.objects.all()
			
			if fecha_inicio:
				seguimientos = seguimientos.filter(fecha_creacion__gte=fecha_inicio)
			if fecha_fin:
				seguimientos = seguimientos.filter(fecha_creacion__lte=fecha_fin)
			if estudiante_id:
				seguimientos = seguimientos.filter(estudiante_id=estudiante_id)
			
			# Total de seguimientos
			total_seguimientos = seguimientos.count()
			
			# Seguimientos por estado (activo/inactivo)
			por_estado = {
				'activos': seguimientos.filter(activo=True).count(),
				'inactivos': seguimientos.filter(activo=False).count()
			}
			
			# Seguimientos por mes
			hace_6_meses = datetime.now() - timedelta(days=180)
			seguimientos_por_mes = (
				seguimientos
				.filter(fecha_creacion__gte=hace_6_meses)
				.annotate(mes=TruncMonth('fecha_creacion'))
				.values('mes')
				.annotate(total=Count('id'))
				.order_by('mes')
			)
			
			meses_data = []
			for item in seguimientos_por_mes:
				meses_data.append({
					'mes': item['mes'].strftime('%Y-%m'),
					'total': item['total']
				})
			
			# Total de entradas
			total_entradas = EntradaSeguimiento.objects.filter(
				seguimiento__in=seguimientos
			).count()
			
			# Promedio de entradas por seguimiento
			promedio_entradas = total_entradas / total_seguimientos if total_seguimientos > 0 else 0
			
			return Response({
				'total_seguimientos': total_seguimientos,
				'total_entradas': total_entradas,
				'promedio_entradas': round(promedio_entradas, 2),
				'por_estado': por_estado,
				'por_mes': meses_data
			})
			
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

	@action(detail=False, methods=['get'])
	def estadisticas_planes_tratamiento(self, request):
		"""Obtener estadísticas de planes de tratamiento"""
		try:
			# Parámetros de filtro
			fecha_inicio = request.query_params.get('fecha_inicio')
			fecha_fin = request.query_params.get('fecha_fin')
			estudiante_id = request.query_params.get('estudiante_id')
			docente_id = request.query_params.get('docente_id')
			
			# Query base
			planes = PlanTratamiento.objects.all()
			
			if fecha_inicio:
				planes = planes.filter(fecha_creacion__gte=fecha_inicio)
			if fecha_fin:
				planes = planes.filter(fecha_creacion__lte=fecha_fin)
			if estudiante_id:
				planes = planes.filter(estudiante_id=estudiante_id)
			if docente_id:
				planes = planes.filter(aprobado_por_id=docente_id)
			
			# Total de planes
			total_planes = planes.count()
			
			# Planes por estado
			por_estado_qs = planes.values('estado').annotate(total=Count('id'))
			por_estado = {}
			for item in por_estado_qs:
				estado_display = dict(PlanTratamiento.ESTADO_CHOICES).get(item['estado'], item['estado'])
				por_estado[estado_display] = item['total']
			
			# Planes por materia
			por_materia_qs = planes.values('materia').annotate(total=Count('id'))
			por_materia = {}
			for item in por_materia_qs:
				materia_display = dict(PlanTratamiento.MATERIAS_CHOICES).get(item['materia'], item['materia'])
				por_materia[materia_display] = item['total']
			
			# Planes por mes (últimos 6 meses)
			hace_6_meses = datetime.now() - timedelta(days=180)
			planes_por_mes = (
				planes
				.filter(fecha_creacion__gte=hace_6_meses)
				.annotate(mes=TruncMonth('fecha_creacion'))
				.values('mes')
				.annotate(total=Count('id'))
				.order_by('mes')
			)
			
			meses_data = []
			for item in planes_por_mes:
				meses_data.append({
					'mes': item['mes'].strftime('%Y-%m'),
					'total': item['total']
				})
			
			# Progreso promedio
			progreso_promedio = planes.aggregate(Avg('progreso_porcentaje'))['progreso_porcentaje__avg'] or 0
			
			# Estadísticas de procedimientos
			total_procedimientos = ProcedimientoPlan.objects.filter(plan__in=planes).count()
			procedimientos_completados = ProcedimientoPlan.objects.filter(
				plan__in=planes,
				estado='completado'
			).count()
			
			# Costo total
			costo_total = ProcedimientoPlan.objects.filter(
				plan__in=planes,
				estado='completado'
			).aggregate(Sum('costo_real'))['costo_real__sum'] or 0
			
			# Top 5 estudiantes con más planes
			top_estudiantes = (
				planes
				.values('estudiante__nombres', 'estudiante__apellidos')
				.annotate(total=Count('id'))
				.order_by('-total')[:5]
			)
			
			top_estudiantes_data = []
			for item in top_estudiantes:
				nombre = f"{item['estudiante__nombres'] or ''} {item['estudiante__apellidos'] or ''}".strip()
				top_estudiantes_data.append({
					'estudiante': nombre or 'Sin nombre',
					'total': item['total']
				})
			
			return Response({
				'total_planes': total_planes,
				'por_estado': por_estado,
				'por_materia': por_materia,
				'por_mes': meses_data,
				'progreso_promedio': round(progreso_promedio, 2),
				'total_procedimientos': total_procedimientos,
				'procedimientos_completados': procedimientos_completados,
				'costo_total': float(costo_total),
				'top_estudiantes': top_estudiantes_data
			})
			
		except Exception as e:
			return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
