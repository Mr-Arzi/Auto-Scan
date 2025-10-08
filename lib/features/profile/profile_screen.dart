import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _onNavTap(BuildContext context, int i) {
    switch (i) {
      case 0: context.go('/home'); break;
      case 1: context.go('/history'); break;
      case 2: context.go('/profile'); break;
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas salir de Auto-Scan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // TODO: limpiar token/sesión real
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🧪 Mock de datos de usuario
    const name = 'Roberto Carlos';
    const username = '@RObertoCarlos';
    const email = 'roberto@gmail.com';

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Avatar + nombre/username + botón editar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44, color: Colors.white)),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.brand, shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                      onPressed: () {
                        // TODO: navegar a editar foto/datos
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Editar foto de perfil (pendiente)')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              name,
              style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            const Text(username, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),

            // Lista de opciones
            const Divider(height: 1),
            ListTile(
              title: const Text('Nombre de usuario:'),
              trailing: const Icon(Icons.chevron_right_rounded),
              subtitle: const Text(username),
              onTap: () {
                // TODO: editar username
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Correo:'),
              trailing: const Icon(Icons.chevron_right_rounded),
              subtitle: const Text(email),
              onTap: () {
                // TODO: editar correo
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Cambiar contraseña:'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                // TODO: navegar a cambiar contraseña
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Cerrar sesión'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _confirmLogout(context),
            ),
            const Divider(height: 1),

            const Spacer(),
          ],
        ),
      ),

      // Bottom nav
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2, // Profile
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

