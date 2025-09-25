import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara (placeholder)')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/results'),
          child: const Text('Capturar (ir a Resultados)'),
        ),
      ),
    );
  }
}
