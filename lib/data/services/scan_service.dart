// lib/data/services/scan_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;

import '../models/scan_result.dart';

class ScanService {
  // Endpoint de tu modelo en Render
  static const String _endpoint =
      'https://modelo-de-tf-autos.onrender.com/v1/models/reconocimiento-mejorado:predict';

  final Dio _dio = Dio();

  // 👇 Asegúrate que este orden coincide con train_generator.class_indices
  static const List<String> _labels = [
    'Convertible', // 0
    'Coupe',       // 1
    'Hatchback',   // 2
    'Pickup',      // 3
    'SUV',         // 4
    'Sedan',       // 5
    'Van',         // 6
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

    // =====================================================
    // 🔷 3. RECORTE RECTANGULAR CENTRAL (ej. aspecto 4:3)
    // =====================================================
    final originalW = decoded.width;
    final originalH = decoded.height;

    const targetAspect = 4 / 3; // más ancho que alto, típico para un coche
    final currentAspect = originalW / originalH;

    int cropW, cropH, offsetX, offsetY;

    if (currentAspect > targetAspect) {
      // La imagen es "más ancha" de lo que queremos → recortamos lados
      cropH = originalH;
      cropW = (cropH * targetAspect).round();
      offsetX = ((originalW - cropW) / 2).round();
      offsetY = 0;
    } else {
      // La imagen es "más alta" → recortamos arriba y abajo
      cropW = originalW;
      cropH = (cropW / targetAspect).round();
      offsetX = 0;
      offsetY = ((originalH - cropH) / 2).round();
    }

    final cropped = img.copyCrop(
      decoded,
      x: offsetX,
      y: offsetY,
      width: cropW,
      height: cropH,
    );

    // =====================================================
    // 🔳 4. Redimensionar ese rectángulo a 300x300
    //    (lo que espera tu MobileNetV2)
    // =====================================================
    const size = 300;
    final resized = img.copyResize(cropped, width: size, height: size);

    // 5. Convertir a [300][300][3] normalizado (0–1)
    final data = List.generate(size, (y) {
      return List.generate(size, (x) {
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

    // 6. POST al modelo en Render
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

    // 7. Leer predicciones
    final body = response.data as Map<String, dynamic>;
    final predictions = body['predictions'] as List;
    if (predictions.isEmpty) {
      throw Exception('Respuesta sin predicciones');
    }

    final first = (predictions.first as List).cast<num>();

    // DEBUG: ver qué está regresando el modelo
    print('Predicciones crudas: $first');

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

    print('idx=$maxIdx label=${_labels[maxIdx]} conf=$maxVal');

    final label = _labels[maxIdx];

    return ScanResult(
      label: label,
      confidence: maxVal,
      imagePath: imagePath,
      scannedAt: DateTime.now(),
    );
  }
}
