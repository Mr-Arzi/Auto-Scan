import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home (placeholder)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Instrucciones rápidas…'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/camera'),
              child: const Text('Start Scan (ir a Cámara)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/history'),
              child: const Text('Ir a Historial'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/profile'),
              child: const Text('Ir a Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
