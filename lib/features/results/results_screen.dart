import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final path = extra?['imagePath'] as String?;

    // Mock de resultados
    const make = 'Lamborghini';
    const model = 'Huracán';
    const type = 'Deportivo';
    const confidence = 0.92;

    Widget image() {
      if (path == null) return const SizedBox.shrink();
      return kIsWeb ? Image.network(path) : Image.file(File(path));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (path != null) ClipRRect(borderRadius: BorderRadius.circular(12), child: image()),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Vehículo detectado'),
                subtitle: Text('$make • $model • $type\nConfianza: ${(confidence * 100).toStringAsFixed(1)}%'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(onPressed: () => context.go('/camera'), child: const Text('Escanear de nuevo')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: () => context.go('/history'), child: const Text('Guardar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
