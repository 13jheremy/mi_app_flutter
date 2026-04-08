// ----------------------------------------
// lib/screens/login_screen.dart
// Pantalla de inicio de sesión simplificada.
// ----------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '/providers/auth_provider.dart';
import '/widgets/form_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  List<String> _recentEmails = [];
  String? _loginError; // Para almacenar errores del backend

  @override
  void initState() {
    super.initState();
    _loadRecentEmails();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList('recent_emails') ?? [];
    if (!mounted) return;
    setState(() {
      _recentEmails = emails;
    });
  }

  // Guarda el email en la lista de correos recientes (máximo 5)
  Future<void> _saveEmail(String email) async {
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email))
      return;

    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList('recent_emails') ?? [];

    // Remove if already exists and add to beginning
    emails.remove(email);
    emails.insert(0, email);

    // Keep only last 5 emails
    if (emails.length > 5) {
      emails.removeRange(5, emails.length);
    }

    await prefs.setStringList('recent_emails', emails);
    if (!mounted) return;
    setState(() {
      _recentEmails = emails;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _loginError = null; // Limpiar error previo
      });

      try {
        developer.log(
          'Intentando login con email: ${_emailController.text}',
          name: 'LoginScreen',
          level: 800,
        );

        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).login(_emailController.text, _passwordController.text);

        // Save email to recent emails
        await _saveEmail(_emailController.text);

        developer.log(
          'Login exitoso, navegando a dashboard...',
          name: 'LoginScreen',
          level: 800,
        );

        if (!mounted) return;

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      } catch (e) {
        developer.log('Error en login: $e', name: 'LoginScreen', level: 1000);
        if (!mounted) return;
        // Guardar el error para mostrar en el UI de forma persistente
        setState(() {
          _loginError = e.toString().replaceAll('Exception: ', '');
        });
      } finally {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode
                  ? const Color(0xFF1e293b)
                  : const Color(0xFF7f1d1d), // red-900
              isDarkMode
                  ? const Color(0xFF7f1d1d)
                  : const Color(0xFFdc2626), // red-600
              isDarkMode
                  ? const Color(0xFFdc2626)
                  : const Color(0xFFb91c1c), // red-700
              isDarkMode
                  ? const Color(0xFFb91c1c)
                  : const Color(0xFF1e293b), // slate-800
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
                      
                      // Banner de error persistente (como en el frontend)
                      if (_loginError != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red.withOpacity(isDarkMode ? 0.2 : 0.05),
                            border: Border.all(
                              color: Colors.red.withOpacity(isDarkMode ? 0.5 : 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.withOpacity(isDarkMode ? 0.9 : 0.7),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _loginError!,
                                  style: TextStyle(
                                    color: Colors.red.withOpacity(
                                      isDarkMode ? 0.9 : 0.7,
                                    ),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      Text(
                        'Iniciar Sesión',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Campo Correo Electrónico con historial
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Correo Electrónico',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              onChanged: (_) {
                                // Limpiar error cuando el usuario escriba
                                if (_loginError != null) {
                                  setState(() {
                                    _loginError = null;
                                  });
                                }
                              },
                              onEditingComplete: () =>
                                  _saveEmail(_emailController.text),
                              decoration: InputDecoration(
                                hintText: 'tu@ejemplo.com',
                                hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[500],
                                ),
                                filled: true,
                                fillColor: isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[100],
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
                                suffixIcon: _recentEmails.isNotEmpty
                                    ? PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        onSelected: (email) {
                                          if (!mounted) return;
                                          setState(() {
                                            _emailController.text = email;
                                          });
                                        },
                                        itemBuilder: (context) => _recentEmails
                                            .map(
                                              (email) => PopupMenuItem<String>(
                                                value: email,
                                                child: Text(
                                                  email,
                                                  style: TextStyle(
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu correo electrónico';
                                }
                                // RFC 5322 compliant email regex
                                final emailRegex = RegExp(
                                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Ingresa un correo electrónico válido';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo Contraseña
                      FormFieldWidget(
                        controller: _passwordController,
                        label: 'Contraseña',
                        hintText: '••••••••',
                        obscureText: _obscurePassword,
                        onChanged: (_) {
                          // Limpiar error cuando el usuario escriba
                          if (_loginError != null) {
                            setState(() {
                              _loginError = null;
                            });
                          }
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          onPressed: () {
                            if (!mounted) return;
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          if (value.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botón de login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Link olvidé contraseña
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(
                                  context,
                                ).pushNamed('/forgot-password');
                              },
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.red[300]
                                : Colors.red[600],
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Información de desarrollo (solo en modo debug)
                      if (kDebugMode) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.amber.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'Modo Desarrollo - Contacta al administrador para credenciales',
                            style: TextStyle(color: Colors.amber, fontSize: 12),
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
}
