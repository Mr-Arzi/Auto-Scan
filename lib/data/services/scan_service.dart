// lib/data/services/scan_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;

import '../models/scan_result.dart';

class ScanService {
  // Endpoint directo de TensorFlow Serving en Render
  static const String _endpoint =
      'https://tf-flower-latest.onrender.com/v1/models/linear-flower:predict';

  final Dio _dio = Dio();

  // Clases en el orden en que entrenaste el modelo en Python
  // (daisy, dandelion, roses, sunflowers, tulips)
  static const List<String> _labels = [
    'daisy',
    'dandelion',
    'roses',
    'sunflowers',
    'tulips',
  ];

  Future<ScanResult> predictFromFile(String imagePath) async {
    final file = File(imagePath);

    // 1. Leer bytes del archivo
    final bytes = await file.readAsBytes();

    // 2. Decodificar imagen
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    // 3. Redimensionar a 64x64 (como en tu entrenamiento)
    final resized = img.copyResize(decoded, width: 64, height: 64);

    // 4. Convertir a [64][64][3] normalizado (0–1)
    final data = List.generate(64, (y) {
      return List.generate(64, (x) {
        final pixel = resized.getPixel(x, y);
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;
        return [r, g, b];
      });
    });

    final payload = {
      'instances': [data], // batch de 1 imagen
    };

    // 5. POST al modelo en Render
    final response = await _dio.post(
      _endpoint,
      data: jsonEncode(payload),
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error HTTP ${response.statusCode}: ${response.data}',
      );
    }

    // 6. Leer predicciones
    final body = response.data as Map<String, dynamic>;
    final predictions = body['predictions'] as List;
    if (predictions.isEmpty) {
      throw Exception('Respuesta sin predicciones');
    }

    final first = (predictions.first as List).cast<num>();

    // Buscar el índice de la probabilidad máxima
    var maxIdx = 0;
    var maxVal = first[0].toDouble();
    for (var i = 1; i < first.length; i++) {
      final val = first[i].toDouble();
      if (val > maxVal) {
        maxVal = val;
        maxIdx = i;
      }
    }

    final label = _labels[maxIdx];

    return ScanResult(
      label: label,
      confidence: maxVal,
      imagePath: imagePath,
      scannedAt: DateTime.now(),
    );
  }
}
