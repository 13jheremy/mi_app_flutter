// test/widget/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_final/main.dart';
import 'package:flutter_final/providers/auth_provider.dart';
import 'package:flutter_final/screens/login_screen.dart';

void main() {
  testWidgets('Login screen should render correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that the login screen renders
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Login button
  });

  testWidgets('Login screen should show validation errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Find the login button and tap it without filling fields
    final loginButton = find.byType(ElevatedButton);
    await tester.tap(loginButton);
    await tester.pump();

    // Verify that validation errors are shown
    expect(find.text('Por favor ingrese su email'), findsOneWidget);
    expect(find.text('Por favor ingrese su contraseña'), findsOneWidget);
  });
}