import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;
  List<CameraDescription> _cameras = [];
  int _camIdx = 0;

  XFile? _shot; // foto capturada (preview)
  bool _noCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          setState(() => _noCamera = true);
          return;
        }
      }
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _noCamera = true);
        return;
      }
      _camIdx = _preferBackCameraIndex(_cameras);
      await _startController(_cameras[_camIdx]);
    } catch (_) {
      setState(() => _noCamera = true);
    }
  }

  int _preferBackCameraIndex(List<CameraDescription> cams) {
    final i = cams.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    return i >= 0 ? i : 0;
  }

  Future<void> _startController(CameraDescription cam) async {
    await _controller?.dispose();
    _controller = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initFuture = _controller!.initialize();
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _camIdx = (_camIdx + 1) % _cameras.length;
    await _startController(_cameras[_camIdx]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startController(_cameras[_camIdx]);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null) return;
    await _initFuture;
    final file = await _controller!.takePicture();
    setState(() => _shot = file);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (x != null) setState(() => _shot = x);
  }

  void _retake() => setState(() => _shot = null);

  void _continue() {
    if (_shot == null) return;
    context.go('/results', extra: {'imagePath': _shot!.path});
  }

  // ---------- UI helpers (overlay esquinas + controles) ----------
  Widget _corner(double size) {
    const thickness = 5.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(children: [
        // vertical
        Positioned(
          left: 0, top: 0,
          child: Container(width: thickness, height: size / 1.5, color: Colors.white),
        ),
        // horizontal
        Positioned(
          left: 0, top: 0,
          child: Container(width: size / 1.5, height: thickness, color: Colors.white),
        ),
      ]),
    );
  }

  Widget _overlayCorners() {
    // Caja “virtual” centrada con 4 esquinas
    return IgnorePointer(
      ignoring: true,
      child: LayoutBuilder(
        builder: (_, c) {
          final boxW = c.maxWidth * 0.8;
          final boxH = c.maxHeight * 0.48;
          final cornerSize = 44.0;
          final borderCenter = 54.0; // el cuadradito del centro del capó

          return Center(
            child: SizedBox(
              width: boxW,
              height: boxH,
              child: Stack(
                children: [
                  // Esquinas
                  Positioned(top: 0, left: 0, child: _corner(cornerSize)),
                  Positioned(top: 0, right: 0, child: Transform.rotate(angle: 1.5708 * 1, child: _corner(cornerSize))),
                  Positioned(bottom: 0, left: 0, child: Transform.rotate(angle: 1.5708 * 3, child: _corner(cornerSize))),
                  Positioned(bottom: 0, right: 0, child: Transform.rotate(angle: 1.5708 * 2, child: _corner(cornerSize))),
                  // Centro (pequeño cuadrado)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: borderCenter,
                      height: borderCenter,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _predictionText() {
    // Mock de texto predicción (luego vendrá del modelo)
    return const Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Text(
        'Lamborghini, Deportivo',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
        ),
      ),
    );
  }

  Widget _bottomControls({required bool hasShot}) {
    // Texto "Tomar la foto" + fila de controles
    if (hasShot) {
      // En preview: Repetir / Continuar
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(onPressed: _retake, child: const Text('Repetir')),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _continue, child: const Text('Continuar')),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tomar la foto',
              style: TextStyle(
                color: AppTheme.brand,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Galería
                IconButton(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo),
                  iconSize: 32,
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.35),
                    shape: const CircleBorder(),
                  ),
                ),
                // Disparador
                GestureDetector(
                  onTap: _capture,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                    ),
                  ),
                ),
                // Cambiar cámara
                IconButton(
                  onPressed: _switchCamera,
                  icon: const Icon(Icons.loop),
                  iconSize: 32,
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.35),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------- BUILD ----------------------------
  @override
  Widget build(BuildContext context) {
    if (_noCamera) {
      return Scaffold(
        appBar: AppBar(title: const Text('Toma la foto')),
        body: Column(
          children: [
            Expanded(
              child: _shot == null
                  ? const Center(
                      child: Text(
                        'No hay cámara disponible.\nSube una foto desde tu galería.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Center(
                      child: kIsWeb
                          ? Image.network(_shot!.path, fit: BoxFit.contain)
                          : Image.file(File(_shot!.path), fit: BoxFit.contain),
                    ),
            ),
            _bottomControls(hasShot: _shot != null),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Toma la foto')),
      backgroundColor: Colors.black,
      body: (_controller == null)
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _initFuture,
              builder: (_, s) {
                if (s.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Preview o imagen tomada
                    _shot == null
                        ? CameraPreview(_controller!)
                        : (kIsWeb
                            ? Image.network(_shot!.path, fit: BoxFit.contain)
                            : Image.file(File(_shot!.path), fit: BoxFit.contain)),

                    if (_shot == null) ...[
                      _overlayCorners(),
                      _predictionText(), // mock del texto encima
                    ],

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _bottomControls(hasShot: _shot != null),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
