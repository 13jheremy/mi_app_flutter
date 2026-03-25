// ----------------------------------------
// lib/models/user.dart
// Modelo para la tabla Persona.
// ----------------------------------------
import 'dart:developer' as developer;

class User {
  final int id;
  final String? nombres;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? numeroTelefono;
  final String? direccion;
  final String username;
  final String? correoElectronico;
  final String? ci; // Cédula de identidad
  final bool? isActive;
  final String? lastLogin;
  final String? dateJoined;
  final List<String>? roles;
  final bool? tienePersona;

  User({
    required this.id,
    this.nombres,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.numeroTelefono,
    this.direccion,
    required this.username,
    this.correoElectronico,
    this.ci,
    this.isActive,
    this.lastLogin,
    this.dateJoined,
    this.roles,
    this.tienePersona,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Verificar campos requeridos del usuario
      if (!json.containsKey('id') || !json.containsKey('username')) {
        throw Exception(
          'JSON no contiene campos requeridos del usuario (id o username)',
        );
      }

      // La API devuelve la información de persona en un campo 'persona' anidado
      Map<String, dynamic>? personaData = json['persona'];

      // Extraer datos de persona de manera segura
      String? nombres = personaData?['nombre']?.toString();
      String? apellidoPaterno = personaData?['apellido']?.toString();
      String? apellidoMaterno = personaData?['apellido_materno']?.toString();
      String? numeroTelefono = personaData?['telefono']?.toString();
      String? direccion = personaData?['direccion']?.toString();
      String? ci = personaData?['cedula']?.toString();

      // Si no hay datos de persona, usar valores por defecto
      if (personaData == null) {
        nombres = json['first_name']?.toString() ?? 'N/A';
        apellidoPaterno = json['last_name']?.toString() ?? 'N/A';
      }

      // Extraer roles como lista de strings
      List<String>? roles;
      if (json['roles'] is List) {
        roles = (json['roles'] as List).map((role) => role.toString()).toList();
      }

      return User(
        id: json['id'] as int,
        nombres: nombres,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        numeroTelefono: numeroTelefono,
        direccion: direccion,
        username: json['username']?.toString() ?? '',
        correoElectronico:
            json['correo_electronico']?.toString() ?? json['email']?.toString(),
        ci: ci,
        isActive: json['is_active'] as bool?,
        lastLogin: json['last_login']?.toString(),
        dateJoined: json['date_joined']?.toString(),
        roles: roles,
        tienePersona: json['tiene_persona'] as bool?,
      );
    } catch (e) {
      developer.log('Error al parsear User desde JSON: $e', name: 'User');
      developer.log('JSON recibido: $json', name: 'User');
      rethrow;
    }
  }

  // Método para crear un usuario con datos mínimos (útil para testing o casos de error)
  factory User.minimal({
    required int id,
    required String username,
    String? correoElectronico,
  }) {
    return User(
      id: id,
      nombres: 'No disponible',
      apellidoPaterno: 'No disponible',
      username: username,
      correoElectronico: correoElectronico,
      isActive: true,
      tienePersona: false,
    );
  }

  // Ajustar toJson para que coincida con el formato de actualización de la API
  // El UsuarioSerializer espera 'persona' como un objeto anidado para PUT/PATCH
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // ID no se envía en el body para PUT/PATCH
      'username':
          username, // Puede que no se actualice desde el perfil del cliente
      'correo_electronico': correoElectronico, // Puede que no se actualice
      'persona': {
        'nombre': nombres, // API usa 'nombre' no 'nombres'
        'apellido': apellidoPaterno, // API usa 'apellido' no 'apellido_paterno'
        'telefono': numeroTelefono, // API usa 'telefono' no 'numero_telefono'
        'direccion': direccion,
        'cedula': ci, // API usa 'cedula' no 'ci'
      },
    };
  }

  String get nombreCompleto {
    String nombreCompleto =
        '${nombres ?? 'Sin nombre'} ${apellidoPaterno ?? 'Sin apellido'}';
    if (apellidoMaterno != null && apellidoMaterno!.isNotEmpty) {
      nombreCompleto += ' $apellidoMaterno';
    }
    return nombreCompleto;
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, nombres: ${nombres ?? 'null'}, apellidoPaterno: ${apellidoPaterno ?? 'null'}, correoElectronico: ${correoElectronico ?? 'null'}, roles: ${roles ?? 'null'})';
  }
}
