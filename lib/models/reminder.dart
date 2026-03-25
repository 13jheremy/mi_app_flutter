// ----------------------------------------
// lib/models/reminder.dart
// Modelo para la tabla RecordatorioMantenimiento.
// ----------------------------------------
class Reminder {
  final int id;
  final DateTime fechaRecordatorio;
  final String? mensaje;
  final String? motoPlaca;
  final int? motoId;
  final String? categoria;
  final String? tipo;
  final int? kmProximo;
  final bool alerta;

  Reminder({
    required this.id,
    required this.fechaRecordatorio,
    this.mensaje,
    this.motoPlaca,
    this.motoId,
    this.categoria,
    this.tipo,
    this.kmProximo,
    this.alerta = false,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    DateTime? fecha;

    // La fecha viene como fecha_programada
    if (json['fecha_programada'] != null) {
      if (json['fecha_programada'] is String) {
        fecha = DateTime.tryParse(json['fecha_programada']);
      }
    } else if (json['fecha_recordatorio'] != null) {
      fecha = DateTime.tryParse(json['fecha_recordatorio']);
    }

    // Si no hay fecha, usar la fecha actual
    fecha ??= DateTime.now();

    // La moto puede venir como string (placa) o como objeto
    String? motoPlaca;
    int? motoId;
    if (json['moto'] is String) {
      motoPlaca = json['moto'] as String?;
    } else if (json['moto'] is Map) {
      motoPlaca = (json['moto'] as Map<String, dynamic>?)?['placa'] as String?;
      motoId = (json['moto'] as Map<String, dynamic>?)?['id'] as int?;
    }

    // La categoría puede venir como string o como objeto
    String? categoria;
    if (json['categoria'] is String) {
      categoria = json['categoria'] as String?;
    } else if (json['categoria_servicio'] is Map) {
      categoria =
          (json['categoria_servicio'] as Map<String, dynamic>?)?['nombre']
              as String?;
    } else if (json['categoria'] is Map) {
      categoria =
          (json['categoria'] as Map<String, dynamic>?)?['nombre'] as String?;
    }

    // El mensaje puede venir o estar vacío
    final mensaje = json['mensaje'] as String?;

    final tipo = json['tipo'] as String?;
    final kmProximo = json['km_proximo'] as int?;
    final alerta = json['alerta'] as bool? ?? false;

    return Reminder(
      id: json['id'] ?? 0,
      fechaRecordatorio: fecha,
      mensaje: mensaje,
      motoPlaca: motoPlaca,
      motoId: motoId,
      categoria: categoria,
      tipo: tipo,
      kmProximo: kmProximo,
      alerta: alerta,
    );
  }

  // Verificar si el recordatorio está vencido
  bool get estaVencido {
    return fechaRecordatorio.isBefore(DateTime.now());
  }

  // Verificar si el recordatorio es próximo (dentro de 7 días)
  bool get esProximo {
    final now = DateTime.now();
    final diferencia = fechaRecordatorio.difference(now).inDays;
    return diferencia >= 0 && diferencia <= 7;
  }
}
