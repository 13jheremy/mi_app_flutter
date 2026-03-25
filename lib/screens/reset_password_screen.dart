// ----------------------------------------
// lib/screens/reset_password_screen.dart
// Pantalla para confirmar recuperación de contraseña.
// ----------------------------------------
import 'package:flutter/material.dart';
import '/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? uid;
  final String? token;

  const ResetPasswordScreen({
    super.key,
    this.uid,
    this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  String? _error;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordReset = false;

  // Validaciones de contraseña
  bool _hasMinLength = false;
  bool _hasLowercase = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _validateToken();

    // Validar contraseña en tiempo real
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateToken() {
    if (widget.uid == null || widget.token == null ||
        widget.uid!.isEmpty || widget.token!.isEmpty) {
      setState(() {
        _error = 'Enlace de recuperación inválido o expirado';
      });
    }
  }

  void _validatePassword() {
    final password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      _hasNumber = RegExp(r'\d').hasMatch(password);
    });
  }

  bool _isPasswordValid() {
    return _hasMinLength && _hasLowercase && _hasUppercase && _hasNumber;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (widget.uid == null || widget.token == null) {
        setState(() {
          _error = 'Enlace de recuperación inválido';
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _error = null;
        _message = null;
      });

      try {
        final message = await AuthService.confirmResetPassword(
          widget.uid!,
          widget.token!,
          _newPasswordController.text,
        );

        if (!mounted) return;

        setState(() {
          _message = message;
          _passwordReset = true;
        });

        // Redirigir al login después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        });

      } catch (e) {
        if (!mounted) return;

        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_passwordReset) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDarkMode ? const Color(0xFF1e293b) : const Color(0xFF7f1d1d),
                isDarkMode ? const Color(0xFF7f1d1d) : const Color(0xFFdc2626),
                isDarkMode ? const Color(0xFFdc2626) : const Color(0xFFb91c1c),
                isDarkMode ? const Color(0xFFb91c1c) : const Color(0xFF1e293b),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: (isDarkMode ? Colors.grey[800]! : Colors.white)
                        .withAlpha(((isDarkMode ? 0.8 : 0.95) * 255).round()),
                    boxShadow: [
                      BoxShadow(
                        color: (isDarkMode ? Colors.black : Colors.grey[400]!)
                            .withAlpha(((isDarkMode ? 0.5 : 0.3) * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981), // green-600
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¡Contraseña Actualizada!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _message ?? 'Tu contraseña ha sido cambiada exitosamente.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Serás redirigido al login en unos segundos...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Ir al Login Ahora',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? const Color(0xFF1e293b) : const Color(0xFF7f1d1d),
              isDarkMode ? const Color(0xFF7f1d1d) : const Color(0xFFdc2626),
              isDarkMode ? const Color(0xFFdc2626) : const Color(0xFFb91c1c),
              isDarkMode ? const Color(0xFFb91c1c) : const Color(0xFF1e293b),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: (isDarkMode ? Colors.grey[800]! : Colors.white)
                      .withAlpha(((isDarkMode ? 0.8 : 0.95) * 255).round()),
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? Colors.black : Colors.grey[400]!)
                          .withAlpha(((isDarkMode ? 0.5 : 0.3) * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header - Logo JIC
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626), // red-600
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'JIC',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Cambiar Contraseña',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu nueva contraseña para completar la recuperación.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Error de token inválido
                      if (_error != null && !_passwordReset) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Volver al Login',
                            style: TextStyle(
                              color: isDarkMode ? Colors.red[300] : Colors.red[600],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Nueva Contraseña
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nueva Contraseña',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Ingresa tu nueva contraseña',
                                  hintStyle: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNewPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword = !_obscureNewPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La contraseña es requerida';
                                  }
                                  if (value.length < 8) {
                                    return 'Debe tener al menos 8 caracteres';
                                  }
                                  if (!_isPasswordValid()) {
                                    return 'La contraseña no cumple con los requisitos';
                                  }
                                  return null;
                                },
                              ),

                              // Indicadores de validación
                              if (_newPasswordController.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Requisitos de contraseña:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _buildValidationItem('Al menos 8 caracteres', _hasMinLength),
                                      _buildValidationItem('Una letra minúscula', _hasLowercase),
                                      _buildValidationItem('Una letra mayúscula', _hasUppercase),
                                      _buildValidationItem('Un número', _hasNumber),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Confirmar Contraseña
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirmar Nueva Contraseña',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Confirma tu nueva contraseña',
                                  hintStyle: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La confirmación de contraseña es requerida';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                              ),

                              // Indicador de coincidencia
                              if (_confirmPasswordController.text.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _confirmPasswordController.text == _newPasswordController.text
                                      ? 'Las contraseñas coinciden'
                                      : 'Las contraseñas no coinciden',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _confirmPasswordController.text == _newPasswordController.text
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Mensajes de error
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Botón de cambiar contraseña
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading || !_isPasswordValid() ||
                                _newPasswordController.text != _confirmPasswordController.text
                                ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              disabledBackgroundColor: theme.primaryColor
                                  .withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Cambiar Contraseña',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botón volver al login
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                },
                          child: Text(
                            'Volver al Login',
                            style: TextStyle(
                              color: isDarkMode ? Colors.red[300] : Colors.red[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}