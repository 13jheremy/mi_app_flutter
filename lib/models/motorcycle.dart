// En lib/models/motorcycle.dart

class Motorcycle {
  final int id;
  final String marca;
  final String modelo;
  final int anio; // Cambiado de 'anio' a 'año' para coincidir con la API
  final String? placa;
  final int? kilometraje;
  final int? propietarioId; // Nuevo: ID del propietario (Persona)
  final String? numeroChasis; // Nuevo
  final String? numeroMotor; // Nuevo
  final String? color; // Nuevo
  final int? cilindrada; // Nuevo
  // Campos de auditoría y registro
  final String? registradoPorNombre;
  final String? creadoPorNombre;
  final String? actualizadoPorNombre;
  final String? fechaRegistro;
  final String? fechaActualizacion;

  // Constructor PRINCIPAL que requiere el ID (usado para datos de la API)
  Motorcycle({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    this.placa,
    this.kilometraje,
    // Hacer opcional si la API lo infiere, o requerido si se envía
    this.numeroChasis,
    this.numeroMotor,
    this.color,
    this.cilindrada,
    this.propietarioId,
    this.registradoPorNombre,
    this.creadoPorNombre,
    this.actualizadoPorNombre,
    this.fechaRegistro,
    this.fechaActualizacion,
  });

  // Constructor SECUNDARIO para crear NUEVAS motos sin ID
  Motorcycle.create({
    required this.marca,
    required this.modelo,
    required this.anio,
    this.placa,
    this.kilometraje,
    // Parámetros opcionales para nueva moto
    this.numeroChasis,
    this.numeroMotor,
    this.color,
    this.cilindrada,
    this.propietarioId,
    this.registradoPorNombre,
    this.creadoPorNombre,
    this.actualizadoPorNombre,
    this.fechaRegistro,
    this.fechaActualizacion,
  }) : id = 0;

  // Constructor factory para crear una instancia a partir de un mapa JSON
  factory Motorcycle.fromJson(Map<String, dynamic> json) {
    // El backend puede devolver 'propietario' como objeto o 'propietario_id' como int
    int? propietarioId;

    // Handle propietario - puede ser un objeto, un int, o null
    final propietario = json['propietario'];
    if (propietario != null) {
      if (propietario is int) {
        propietarioId = propietario;
      } else if (propietario is Map) {
        // Si es un objeto, extraer el ID
        propietarioId = propietario['id'] as int?;
      }
    } else if (json['propietario_id'] != null) {
      propietarioId = json['propietario_id'] as int?;
    }

    return Motorcycle(
      id: json['id'] ?? 0,
      marca: (json['marca'] as String?) ?? 'Sin marca',
      modelo: (json['modelo'] as String?) ?? 'Sin modelo',
      anio: _parseYear(json),
      placa: json['placa'] as String?,
      kilometraje: _parseInt(json['kilometraje']),
      propietarioId: propietarioId,
      numeroChasis: json['numero_chasis'] as String?,
      numeroMotor: json['numero_motor'] as String?,
      color: json['color'] as String?,
      cilindrada: _parseInt(json['cilindrada']),
      // Campos de auditoría
      registradoPorNombre: json['registrado_por_nombre'] as String?,
      creadoPorNombre: json['creado_por_nombre'] as String?,
      actualizadoPorNombre: json['actualizado_por_nombre'] as String?,
      fechaRegistro: json['fecha_registro'] as String?,
      fechaActualizacion: json['fecha_actualizacion'] as String?,
    );
  }

  // Helper method to safely parse year from JSON
  static int _parseYear(Map<String, dynamic> json) {
    final yearValue = json['año'] ?? json['anio'];
    return _parseInt(yearValue) ?? 2024;
  }

  // Helper method to safely parse int from dynamic value
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Método para convertir la moto a un mapa JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'marca': marca,
      'modelo': modelo,
      'año': anio, // Cambiado de 'anio' a 'año'
      'placa': placa,
      'kilometraje': kilometraje,
      'numero_chasis': numeroChasis,
      'numero_motor': numeroMotor,
      'color': color,
      'cilindrada': cilindrada,
    };

    // Solo incluir propietario si no es null (para otros roles que no sean cliente)
    if (propietarioId != null) {
      json['propietario'] = propietarioId;
    }

    return json;
  }

  // Getters de compatibilidad para la UI (mapea numeroChasis -> chassis)
  String? get chassis {
    return numeroChasis;
  }

  String? get motor {
    return numeroMotor;
  }
}

// En lib/models/motorcycle.dart
