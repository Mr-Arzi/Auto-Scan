// lib/features/camera/camera_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final XFile file = await _controller!.takePicture();

    // Aquí sigues igual: mandas la ruta al ResultsScreen.
    // El recorte real lo hacemos en ScanService (center crop 4:3).
    if (!mounted) return;
    context.go(
      '/results',
      extra: {
        'imagePath': file.path,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toma la foto')),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Stack(
                  children: [
                    // PREVIEW A PANTALLA COMPLETA
                    Positioned.fill(
                      child: CameraPreview(_controller!),
                    ),

                    // OVERLAY CON RECTÁNGULO CENTRAL
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final h = constraints.maxHeight;

                          // Queremos un rectángulo 4:3 centrado
                          const targetAspect = 4 / 3;
                          double frameWidth = w * 0.8;
                          double frameHeight = frameWidth / targetAspect;

                          if (frameHeight > h * 0.7) {
                            frameHeight = h * 0.7;
                            frameWidth = frameHeight * targetAspect;
                          }

                          final left = (w - frameWidth) / 2;
                          final top = (h - frameHeight) / 2;

                          return Stack(
                            children: [
                              // Oscurecer las áreas FUERA del rectángulo
                              // TOP
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 0,
                                height: top,
                                child: Container(color: Colors.black45),
                              ),
                              // BOTTOM
                              Positioned(
                                left: 0,
                                right: 0,
                                top: top + frameHeight,
                                bottom: 0,
                                child: Container(color: Colors.black45),
                              ),
                              // LEFT
                              Positioned(
                                left: 0,
                                top: top,
                                width: left,
                                height: frameHeight,
                                child: Container(color: Colors.black45),
                              ),
                              // RIGHT
                              Positioned(
                                left: left + frameWidth,
                                top: top,
                                right: 0,
                                height: frameHeight,
                                child: Container(color: Colors.black45),
                              ),

                              // RECTÁNGULO CENTRAL (marco)
                              Positioned(
                                left: left,
                                top: top,
                                width: frameWidth,
                                height: frameHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // BOTÓN "Tomar la foto"
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Toma la foto',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _takePicture,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: const Center(
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
