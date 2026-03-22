

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
