import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/otp'),
          child: const Text('Enviar código (ir a OTP)'),
        ),
      ),
    );
  }
}
