class PlanTratamiento {
  final String id;
  final String pacienteId;
  final String pacienteNombre;
  final String estudianteId;
  final String estudianteNombre;
  final String materia;
  final String materiaNombre;
  final String estado;
  final String? observaciones;
  final DateTime fechaCreacion;
  final DateTime? fechaAprobacion;
  final String? docenteAutorizaId;
  final String? docenteAutorizaNombre;
  final int totalProcedimientos;
  final int procedimientosCompletados;
  final double progresoPorcentaje;
  final List<ProcedimientoPlan>? procedimientos;
  final List<EvolucionClinica>? evoluciones;

  PlanTratamiento({
    required this.id,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.materia,
    required this.materiaNombre,
    required this.estado,
    this.observaciones,
    required this.fechaCreacion,
    this.fechaAprobacion,
    this.docenteAutorizaId,
    this.docenteAutorizaNombre,
    required this.totalProcedimientos,
    required this.procedimientosCompletados,
    required this.progresoPorcentaje,
    this.procedimientos,
    this.evoluciones,
  });

  factory PlanTratamiento.fromJson(Map<String, dynamic> json) {
    // Manejo de paciente (puede venir como string o como objeto)
    String pacienteId = '';
    String pacienteNombre = '';
    if (json['paciente'] is String) {
      pacienteId = json['paciente'];
      pacienteNombre = json['paciente_nombre'] ?? '';
    } else if (json['paciente'] is Map) {
      final paciente = json['paciente'] as Map<String, dynamic>;
      pacienteId = paciente['id'] ?? '';
      pacienteNombre = paciente['nombre_completo'] ??
          '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}'.trim();
    }

    // Manejo de estudiante (puede venir como string o como objeto)
    String estudianteId = '';
    String estudianteNombre = '';
    if (json['estudiante'] is String) {
      estudianteId = json['estudiante'];
      estudianteNombre = json['estudiante_nombre'] ?? '';
    } else if (json['estudiante'] is Map) {
      final estudiante = json['estudiante'] as Map<String, dynamic>;
      estudianteId = estudiante['id'] ?? '';
      estudianteNombre = estudiante['nombre_completo'] ??
          '${estudiante['nombres'] ?? ''} ${estudiante['apellidos'] ?? ''}'
              .trim();
    }

    return PlanTratamiento(
      id: json['id'] ?? '',
      pacienteId: pacienteId,
      pacienteNombre: pacienteNombre,
      estudianteId: estudianteId,
      estudianteNombre: estudianteNombre,
      materia: json['materia'] ?? '',
      materiaNombre: json['materia_display'] ?? json['materia_nombre'] ?? '',
      estado: json['estado'] ?? 'borrador',
      observaciones: json['observaciones'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(),
      fechaAprobacion: json['fecha_aprobacion'] != null
          ? DateTime.parse(json['fecha_aprobacion'])
          : null,
      docenteAutorizaId: json['docente_autoriza'],
      docenteAutorizaNombre: json['docente_autoriza_nombre'],
      totalProcedimientos: json['total_procedimientos'] ?? 0,
      procedimientosCompletados: json['procedimientos_completados'] ?? 0,
      progresoPorcentaje: _toDouble(json['progreso_porcentaje'] ?? 0),
      procedimientos: json['procedimientos'] != null
          ? (json['procedimientos'] as List)
              .map((p) => ProcedimientoPlan.fromJson(p))
              .toList()
          : null,
      evoluciones: json['evoluciones'] != null
          ? (json['evoluciones'] as List)
              .map((e) => EvolucionClinica.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente': pacienteId,
      'estudiante': estudianteId,
      'materia': materia,
      'estado': estado,
      'observaciones': observaciones,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_aprobacion': fechaAprobacion?.toIso8601String(),
      'docente_autoriza': docenteAutorizaId,
    };
  }
}

class ProcedimientoPlan {
  final String id;
  final String planId;
  final int secuencia;
  final String descripcion;
  final String? piezaDental;
  final String prioridad;
  final String prioridadDisplay;
  final String estado;
  final String estadoDisplay;
  final DateTime? fechaProgramada;
  final DateTime? fechaRealizada;
  final double costoEstimado;
  final double? costoReal;
  final String? observaciones;

  ProcedimientoPlan({
    required this.id,
    required this.planId,
    required this.secuencia,
    required this.descripcion,
    this.piezaDental,
    required this.prioridad,
    required this.prioridadDisplay,
    required this.estado,
    required this.estadoDisplay,
    this.fechaProgramada,
    this.fechaRealizada,
    required this.costoEstimado,
    this.costoReal,
    this.observaciones,
  });

  factory ProcedimientoPlan.fromJson(Map<String, dynamic> json) {
    return ProcedimientoPlan(
      id: json['id'] ?? '',
      planId: json['plan'] ?? '',
      secuencia: json['secuencia'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      piezaDental: json['pieza_dental'],
      prioridad: json['prioridad'] ?? 'media',
      prioridadDisplay: json['prioridad_display'] ?? 'Media',
      estado: json['estado'] ?? 'pendiente',
      estadoDisplay: json['estado_display'] ?? 'Pendiente',
      fechaProgramada: json['fecha_programada'] != null
          ? DateTime.parse(json['fecha_programada'])
          : null,
      fechaRealizada: json['fecha_realizada'] != null
          ? DateTime.parse(json['fecha_realizada'])
          : null,
      costoEstimado: _toDouble(json['costo_estimado'] ?? 0),
      costoReal:
          json['costo_real'] != null ? _toDouble(json['costo_real']) : null,
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan': planId,
      'secuencia': secuencia,
      'descripcion': descripcion,
      'pieza_dental': piezaDental,
      'prioridad': prioridad,
      'estado': estado,
      'fecha_programada': fechaProgramada?.toIso8601String(),
      'fecha_realizada': fechaRealizada?.toIso8601String(),
      'costo_estimado': costoEstimado,
      'costo_real': costoReal,
      'observaciones': observaciones,
    };
  }
}

class EvolucionClinica {
  final String id;
  final String planId;
  final String? procedimientoId;
  final DateTime fechaSesion;
  final int numeroSesion;
  final String tratamientoRealizado;
  final String? hallazgosClinica;
  final String? complicaciones;
  final String? proximaSesion;
  final String estudianteId;
  final String estudianteNombre;
  final bool estudianteFirmado;
  final DateTime? estudianteFechaFirma;
  final String? docenteSupervisorId;
  final String? docenteSupervisorNombre;
  final bool docenteFirmado;
  final DateTime? docenteFechaFirma;

  EvolucionClinica({
    required this.id,
    required this.planId,
    this.procedimientoId,
    required this.fechaSesion,
    required this.numeroSesion,
    required this.tratamientoRealizado,
    this.hallazgosClinica,
    this.complicaciones,
    this.proximaSesion,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteFirmado,
    this.estudianteFechaFirma,
    this.docenteSupervisorId,
    this.docenteSupervisorNombre,
    required this.docenteFirmado,
    this.docenteFechaFirma,
  });

  factory EvolucionClinica.fromJson(Map<String, dynamic> json) {
    return EvolucionClinica(
      id: json['id'] ?? '',
      planId: json['plan'] ?? '',
      procedimientoId: json['procedimiento'],
      fechaSesion: json['fecha_sesion'] != null
          ? DateTime.parse(json['fecha_sesion'])
          : DateTime.now(),
      numeroSesion: json['numero_sesion'] ?? 1,
      tratamientoRealizado: json['tratamiento_realizado'] ?? '',
      hallazgosClinica: json['hallazgos_clinica'],
      complicaciones: json['complicaciones'],
      proximaSesion: json['proxima_sesion'],
      estudianteId: json['estudiante'] ?? '',
      estudianteNombre: json['estudiante_nombre'] ?? '',
      estudianteFirmado: json['estudiante_firmado'] ?? false,
      estudianteFechaFirma: json['estudiante_fecha_firma'] != null
          ? DateTime.parse(json['estudiante_fecha_firma'])
          : null,
      docenteSupervisorId: json['docente_supervisor'],
      docenteSupervisorNombre: json['docente_supervisor_nombre'],
      docenteFirmado: json['docente_firmado'] ?? false,
      docenteFechaFirma: json['docente_fecha_firma'] != null
          ? DateTime.parse(json['docente_fecha_firma'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan': planId,
      'procedimiento': procedimientoId,
      'fecha_sesion': fechaSesion.toIso8601String(),
      'numero_sesion': numeroSesion,
      'tratamiento_realizado': tratamientoRealizado,
      'hallazgos_clinica': hallazgosClinica,
      'complicaciones': complicaciones,
      'proxima_sesion': proximaSesion,
      'estudiante': estudianteId,
      'docente_supervisor': docenteSupervisorId,
    };
  }
}

class TransferenciaPaciente {
  final String id;
  final String pacienteId;
  final String pacienteNombre;
  final String estudianteOrigenId;
  final String estudianteOrigenNombre;
  final String materiaOrigen;
  final String materiaOrigenNombre;
  final String materiaDestino;
  final String materiaDestinoNombre;
  final String? estudianteDestinoId;
  final String estudianteDestinoNombre;
  final String? planOriginalId;
  final String motivo;
  final String estado;
  final DateTime fechaSolicitud;
  final DateTime? fechaAprobacion;
  final DateTime? fechaAsignacion;
  final String? docenteAprobadorId;
  final String? docenteAprobadorNombre;
  final String? observaciones;

  TransferenciaPaciente({
    required this.id,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.estudianteOrigenId,
    required this.estudianteOrigenNombre,
    required this.materiaOrigen,
    required this.materiaOrigenNombre,
    required this.materiaDestino,
    required this.materiaDestinoNombre,
    this.estudianteDestinoId,
    required this.estudianteDestinoNombre,
    this.planOriginalId,
    required this.motivo,
    required this.estado,
    required this.fechaSolicitud,
    this.fechaAprobacion,
    this.fechaAsignacion,
    this.docenteAprobadorId,
    this.docenteAprobadorNombre,
    this.observaciones,
  });

  factory TransferenciaPaciente.fromJson(Map<String, dynamic> json) {
    return TransferenciaPaciente(
      id: json['id'] ?? '',
      pacienteId: json['paciente'] ?? '',
      pacienteNombre: json['paciente_nombre'] ?? '',
      estudianteOrigenId: json['estudiante_origen'] ?? '',
      estudianteOrigenNombre: json['estudiante_origen_nombre'] ?? '',
      materiaOrigen: json['materia_origen'] ?? '',
      materiaOrigenNombre: json['materia_origen_nombre'] ?? '',
      materiaDestino: json['materia_destino'] ?? '',
      materiaDestinoNombre: json['materia_destino_nombre'] ?? '',
      estudianteDestinoId: json['estudiante_destino'],
      estudianteDestinoNombre:
          json['estudiante_destino_nombre'] ?? 'Pendiente de Asignación',
      planOriginalId: json['plan_original'],
      motivo: json['motivo'] ?? '',
      estado: json['estado'] ?? 'solicitada',
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.parse(json['fecha_solicitud'])
          : DateTime.now(),
      fechaAprobacion: json['fecha_aprobacion'] != null
          ? DateTime.parse(json['fecha_aprobacion'])
          : null,
      fechaAsignacion: json['fecha_asignacion'] != null
          ? DateTime.parse(json['fecha_asignacion'])
          : null,
      docenteAprobadorId: json['docente_aprobador'],
      docenteAprobadorNombre: json['docente_aprobador_nombre'],
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente': pacienteId,
      'estudiante_origen': estudianteOrigenId,
      'materia_origen': materiaOrigen,
      'materia_destino': materiaDestino,
      'estudiante_destino': estudianteDestinoId,
      'plan_original': planOriginalId,
      'motivo': motivo,
      'estado': estado,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'observaciones': observaciones,
    };
  }
}

class RemisionInterCatedra {
  final String id;
  final String pacienteId;
  final String pacienteNombre;
  final String estudianteSolicitanteId;
  final String estudianteSolicitanteNombre;
  final String materiaOrigen;
  final String materiaOrigenNombre;
  final String materiaDestino;
  final String materiaDestinoNombre;
  final String diagnosticoOrigen;
  final String tratamientoSolicitado;
  final DateTime fechaSolicitud;
  final DateTime? fechaAtencion;
  final String? tratamientoRealizado;
  final String? hallazgos;
  final String? recomendaciones;
  final String estado;

  RemisionInterCatedra({
    required this.id,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.estudianteSolicitanteId,
    required this.estudianteSolicitanteNombre,
    required this.materiaOrigen,
    required this.materiaOrigenNombre,
    required this.materiaDestino,
    required this.materiaDestinoNombre,
    required this.diagnosticoOrigen,
    required this.tratamientoSolicitado,
    required this.fechaSolicitud,
    this.fechaAtencion,
    this.tratamientoRealizado,
    this.hallazgos,
    this.recomendaciones,
    required this.estado,
  });

  factory RemisionInterCatedra.fromJson(Map<String, dynamic> json) {
    return RemisionInterCatedra(
      id: json['id'] ?? '',
      pacienteId: json['paciente'] ?? '',
      pacienteNombre: json['paciente_nombre'] ?? '',
      estudianteSolicitanteId: json['estudiante_solicitante'] ?? '',
      estudianteSolicitanteNombre: json['estudiante_solicitante_nombre'] ?? '',
      materiaOrigen: json['materia_origen'] ?? '',
      materiaOrigenNombre: json['materia_origen_nombre'] ?? '',
      materiaDestino: json['materia_destino'] ?? '',
      materiaDestinoNombre: json['materia_destino_nombre'] ?? '',
      diagnosticoOrigen: json['diagnostico_origen'] ?? '',
      tratamientoSolicitado: json['tratamiento_solicitado'] ?? '',
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.parse(json['fecha_solicitud'])
          : DateTime.now(),
      fechaAtencion: json['fecha_atencion'] != null
          ? DateTime.parse(json['fecha_atencion'])
          : null,
      tratamientoRealizado: json['tratamiento_realizado'],
      hallazgos: json['hallazgos'],
      recomendaciones: json['recomendaciones'],
      estado: json['estado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente': pacienteId,
      'estudiante_solicitante': estudianteSolicitanteId,
      'materia_origen': materiaOrigen,
      'materia_destino': materiaDestino,
      'diagnostico_origen': diagnosticoOrigen,
      'tratamiento_solicitado': tratamientoSolicitado,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'fecha_atencion': fechaAtencion?.toIso8601String(),
      'tratamiento_realizado': tratamientoRealizado,
      'hallazgos': hallazgos,
      'recomendaciones': recomendaciones,
      'estado': estado,
    };
  }
}

// Helper function para convertir valores a double de forma segura
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}
