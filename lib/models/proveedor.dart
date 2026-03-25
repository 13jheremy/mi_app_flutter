// ----------------------------------------
// lib/models/proveedor.dart
// Modelo para la tabla Proveedor.
// ----------------------------------------
class Proveedor {
  final int id;
  final String nombre;
  final String? nit;
  final String? telefono;
  final String? correo;
  final String? direccion;
  final String? contactoPrincipal;
  final bool activo;
  final bool eliminado;
  final int productosCount;
  final DateTime? fechaRegistro;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;
  final Map<String, dynamic>? creadoPor;
  final Map<String, dynamic>? actualizadoPor;
  final Map<String, dynamic>? eliminadoPor;

  Proveedor({
    required this.id,
    required this.nombre,
    this.nit,
    this.telefono,
    this.correo,
    this.direccion,
    this.contactoPrincipal,
    this.activo = true,
    this.eliminado = false,
    this.productosCount = 0,
    this.fechaRegistro,
    this.fechaActualizacion,
    this.fechaEliminacion,
    this.creadoPor,
    this.actualizadoPor,
    this.eliminadoPor,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      nit: json['nit'],
      telefono: json['telefono'],
      correo: json['correo'],
      direccion: json['direccion'],
      contactoPrincipal: json['contacto_principal'],
      activo: json['activo'] ?? true,
      eliminado: json['eliminado'] ?? false,
      productosCount: json['productos_count'] ?? 0,
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.tryParse(json['fecha_registro'])
          : null,
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.tryParse(json['fecha_actualizacion'])
          : null,
      fechaEliminacion: json['fecha_eliminacion'] != null
          ? DateTime.tryParse(json['fecha_eliminacion'])
          : null,
      creadoPor: json['creado_por'],
      actualizadoPor: json['actualizado_por'],
      eliminadoPor: json['eliminado_por'],
    );
  }

  /// Obtener el nombre completo del usuario que creó el registro
  String get creadoPorNombre {
    if (creadoPor == null) return 'No registrado';
    return creadoPor!['nombre_completo'] ??
        creadoPor!['username'] ??
        'Desconocido';
  }

  /// Obtener el nombre completo del usuario que actualizó el registro
  String get actualizadoPorNombre {
    if (actualizadoPor == null) return 'Sin actualizaciones';
    return actualizadoPor!['nombre_completo'] ??
        actualizadoPor!['username'] ??
        'Desconocido';
  }

  /// Obtener el nombre completo del usuario que eliminó el registro
  String get eliminadoPorNombre {
    if (eliminadoPor == null) return '';
    return eliminadoPor!['nombre_completo'] ??
        eliminadoPor!['username'] ??
        'Desconocido';
  }

  /// Formatear fecha de registro
  String get fechaRegistroFormateada {
    if (fechaRegistro == null) return 'No disponible';
    return '${fechaRegistro!.day}/${fechaRegistro!.month}/${fechaRegistro!.year} ${fechaRegistro!.hour}:${fechaRegistro!.minute.toString().padLeft(2, '0')}';
  }

  /// Formatear fecha de actualización
  String get fechaActualizacionFormateada {
    if (fechaActualizacion == null) return 'Sin actualizaciones';
    return '${fechaActualizacion!.day}/${fechaActualizacion!.month}/${fechaActualizacion!.year} ${fechaActualizacion!.hour}:${fechaActualizacion!.minute.toString().padLeft(2, '0')}';
  }

  /// Formatear fecha de eliminación
  String get fechaEliminacionFormateada {
    if (fechaEliminacion == null) return '';
    return '${fechaEliminacion!.day}/${fechaEliminacion!.month}/${fechaEliminacion!.year} ${fechaEliminacion!.hour}:${fechaEliminacion!.minute.toString().padLeft(2, '0')}';
  }
}
