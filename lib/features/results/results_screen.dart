// lib/features/results/results_screen.dart
import 'dart:io';
import '../../data/services/service_locator.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/scan_result.dart';
import '../../data/services/scan_service.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  Future<ScanResult> _loadResult(String path) {
    final service = ScanService();
    return service.predictFromFile(path);
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final path = extra?['imagePath'] as String?;

    if (path == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultados')),
        body: const Center(
          child: Text('No se recibió ninguna imagen '),
        ),
      );
    }

    Widget image() {
      if (kIsWeb) {
        // En web, podrías recibir una URL; por ahora asumimos que es un path local
        return Image.network(path, fit: BoxFit.cover);
      } else {
        return Image.file(File(path), fit: BoxFit.cover);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: image(),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<ScanResult>(
              future: _loadResult(path),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ocurrió un error al analizar la imagen:\n${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final result = snapshot.data!;
                return Card(
                  child: ListTile(
                    title: const Text('Resultado del modelo'),
                    subtitle: Text(
                      'Etiqueta: ${result.label}\n'
                      'Confianza: ${(result.confidence * 100).toStringAsFixed(1)}%',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/camera'),
                  child: const Text('Escanear de nuevo'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // asumimos que ya cargaste el ScanResult con _loadResult
                      final result = await _loadResult(path); // o donde lo tengas guardado

                      await historyRepository.saveScan(result);

                      if (context.mounted) {
                        context.go('/history');
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al guardar: $e')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
