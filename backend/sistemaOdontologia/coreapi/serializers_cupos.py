from rest_framework import serializers
from .models import CupoEstudiante


class CupoEstudianteSerializer(serializers.ModelSerializer):
	"""Serializer para CupoEstudiante"""
	
	estudiante_nombre = serializers.SerializerMethodField()
	materia_display = serializers.CharField(source='get_materia_display', read_only=True)
	
	class Meta:
		model = CupoEstudiante
		fields = [
			'id',
			'estudiante',
			'estudiante_nombre',
			'materia',
			'materia_display',
			'procedimientos_completados',
			'ultimo_procedimiento_fecha',
			'fecha_creacion',
			'fecha_modificacion',
		]
		read_only_fields = ['id', 'fecha_creacion', 'fecha_modificacion']
	
	def get_estudiante_nombre(self, obj):
		"""Retorna nombre completo del estudiante"""
		if obj.estudiante:
			return f"{obj.estudiante.nombres} {obj.estudiante.apellidos}"
		return None
