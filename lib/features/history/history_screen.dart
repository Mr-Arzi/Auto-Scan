import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 🧪 Mock de miniaturas (reemplazar luego por historyService.list())
  final List<String> _thumbs = List.generate(12, (i) => 'thumb-$i');

  void _onNavTap(BuildContext context, int i) {
    switch (i) {
      case 0: context.go('/home'); break;
      case 1: context.go('/history'); break;
      case 2: context.go('/profile'); break;
    }
  }

  Future<void> _downloadAll() async {
    if (_thumbs.isEmpty) return;
    // TODO: integrar descarga real (guardar en galería/compartir).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descargando fotos (mock)…')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Fotos'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // GRID 3 columnas, celdas cuadradas con esquinas redondeadas
              Expanded(
                child: GridView.builder(
                  itemCount: _thumbs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (_, i) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDEDED),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: const [
                            // TODO: reemplazar por Image.memory / Image.file / Image.network
                            // según de dónde vengan las miniaturas
                            Icon(Icons.image, size: 48, color: Colors.black26),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Botón "Descargar fotos"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _thumbs.isEmpty ? null : _downloadAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 246, 143, 59), // azul como en el mock
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Descargar fotos'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // Bottom nav (Home / Photos / Profile)
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1, // 👈 estás en Photos
        onDestinationSelected: (i) => _onNavTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.photo_outlined), selectedIcon: Icon(Icons.photo), label: 'Photos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


