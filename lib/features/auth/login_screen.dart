import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login (placeholder)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Email Address')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Entrar (ir a Home)'),
            ),
            TextButton(
              onPressed: () => context.push('/forgot'),
              child: const Text('Forgot password?'),
            ),
            TextButton(
              onPressed: () => context.push('/signup'),
              child: const Text('Not a member? Register now'),
            ),
          ],
        ),
      ),
    );
  }
}
