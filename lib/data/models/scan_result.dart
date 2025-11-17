// lib/data/models/scan_result.dart
class ScanResult {
  final String label;        // etiqueta que regresa el modelo (daisy, tulip, etc.)
  final double confidence;   // probabilidad de la etiqueta
  final String imagePath;    // ruta local de la imagen
  final DateTime scannedAt;  // cuándo se hizo el scan

  ScanResult({
    required this.label,
    required this.confidence,
    required this.imagePath,
    required this.scannedAt,
  });
}
