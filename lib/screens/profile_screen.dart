// ----------------------------------------
// lib/screens/profile_screen.dart
// Pantalla para ver y editar el perfil del usuario.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/widgets/form_field_widget.dart'; // Importar el nuevo widget de campo de formulario
import '/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombresController;
  late final TextEditingController _apellidoPaternoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _direccionController;
  late final TextEditingController _ciController; // Cédula (solo lectura)
  late final TextEditingController _emailController; // Nuevo campo para email
  bool _isLoading = false;
  bool _isEditing = false; // Nuevo estado para controlar el modo de edición

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController();
    _apellidoPaternoController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _ciController = TextEditingController(); // Inicializar CI (solo lectura)
    _emailController = TextEditingController(); // Inicializar email
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nombresController.text = user.nombres ?? '';
      _apellidoPaternoController.text = user.apellidoPaterno ?? '';
      _telefonoController.text = user.numeroTelefono ?? '';
      _direccionController.text = user.direccion ?? '';
      _ciController.text = user.ci ?? '';
      _emailController.text = user.correoElectronico ?? '';
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidoPaternoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciController.dispose(); // Disponer CI
    _emailController.dispose(); // Disponer email
    super.dispose();
  }

  // Método para activar/desactivar el modo de edición
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Método para cancelar la edición y restaurar valores originales
  void _cancelEdit() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      setState(() {
        _nombresController.text = user.nombres ?? '';
        _apellidoPaternoController.text = user.apellidoPaterno ?? '';
        _telefonoController.text = user.numeroTelefono ?? '';
        _direccionController.text = user.direccion ?? '';
        _ciController.text = user.ci ?? '';
        _emailController.text = user.correoElectronico ?? '';
        _isEditing = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Construir el mapa de datos para el endpoint PUT /api/personas/{id}/
        final Map<String, dynamic> personaData = {
          'nombre': _nombresController.text, // Campo requerido
          'apellido': _apellidoPaternoController.text, // Campo requerido
          'telefono': _telefonoController.text.isNotEmpty
              ? _telefonoController.text
              : null, // Opcional
          'direccion': _direccionController.text.isNotEmpty
              ? _direccionController.text
              : null, // Opcional
          'cedula':
              _ciController.text, // La cédula no se modifica pero se incluye
          'correo_electronico': _emailController.text, // Campo requerido
        };

        // Actualizar el perfil
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).updateProfile(personaData);

        // Recargar los datos del usuario de forma elegante
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).fetchUserAndSetState();

        // Actualizar los controladores con los datos más recientes
        final updatedUser = Provider.of<AuthProvider>(
          context,
          listen: false,
        ).user;
        if (updatedUser != null) {
          setState(() {
            _nombresController.text = updatedUser.nombres ?? '';
            _apellidoPaternoController.text = updatedUser.apellidoPaterno ?? '';
            _telefonoController.text = updatedUser.numeroTelefono ?? '';
            _direccionController.text = updatedUser.direccion ?? '';
            _ciController.text = updatedUser.ci ?? '';
            _emailController.text = updatedUser.correoElectronico ?? '';
            _isEditing = false; // Salir del modo edición
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito.')),
        );

        // Regresar a la pantalla anterior para reflejar los cambios
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: Center(
          child: Text(
            'No hay datos de usuario',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: _toggleEditMode,
              icon: Icon(Icons.edit, color: theme.colorScheme.onPrimary),
              label: Text(
                'Editar',
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing
            ? _buildEditView(theme)
            : _buildReadOnlyView(theme, user),
      ),
    );
  }

  // Vista de solo lectura
  Widget _buildReadOnlyView(ThemeData theme, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del usuario
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar y nombre
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.primaryColor,
                      child: Text(
                        user.nombres?.isNotEmpty == true
                            ? user.nombres![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nombreCompleto,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.username,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Información personal
                _buildInfoRow('Nombres', user.nombres ?? 'No especificado'),
                const Divider(),
                _buildInfoRow(
                  'Apellido Paterno',
                  user.apellidoPaterno ?? 'No especificado',
                ),
                const Divider(),
                _buildInfoRow(
                  'Teléfono',
                  user.numeroTelefono ?? 'No especificado',
                ),
                const Divider(),
                _buildInfoRow('Dirección', user.direccion ?? 'No especificado'),
                const Divider(),
                _buildInfoRow(
                  'Email',
                  user.correoElectronico ?? 'No especificado',
                ),
                const Divider(),
                _buildInfoRow(
                  'Cédula de Identidad',
                  user.ci ?? 'No especificado',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Vista de edición
  Widget _buildEditView(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campos editables
          FormFieldWidget(
            controller: _nombresController,
            label: 'Nombres',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FormFieldWidget(
            controller: _apellidoPaternoController,
            label: 'Apellido Paterno',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FormFieldWidget(
            controller: _telefonoController,
            label: 'Teléfono (Opcional)',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          FormFieldWidget(
            controller: _direccionController,
            label: 'Dirección (Opcional)',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          FormFieldWidget(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              // Validación básica de email
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Ingrese un email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Cédula (solo lectura)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cédula de Identidad',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        _ciController.text,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper para construir filas de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
