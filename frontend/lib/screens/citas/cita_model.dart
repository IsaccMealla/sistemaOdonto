class CitaMedica {
  final String id;
  final String pacienteId;
  final String estudianteId;
  final String docenteId;
  final DateTime fechaHora;
  final String motivo;
  final String estado; // pendiente, aprobada, rechazada, cancelada
  final String? observacionesDocente;
  final String? motivoCancelacion;

  CitaMedica({
    required this.id,
    required this.pacienteId,
    required this.estudianteId,
    required this.docenteId,
    required this.fechaHora,
    required this.motivo,
    required this.estado,
    this.observacionesDocente,
    this.motivoCancelacion,
  });
}
