import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/home'),
          child: const Text('Verificar (ir a Home)'),
        ),
      ),
    );
  }
}
