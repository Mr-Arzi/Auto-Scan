import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/service_locator.dart';
import '../../data/models/user.dart' as app_user;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<app_user.User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = authService.getCurrentUser();
  }

  void _onNavTap(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas salir de Auto-Scan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await authService.logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: FutureBuilder<app_user.User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error al cargar perfil: ${snapshot.error}'),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No hay usuario autenticado'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Ir a login'),
                    ),
                  ],
                ),
              );
            }

            final name = user.name.isNotEmpty ? user.name : 'Sin nombre';
            final email = user.email.isNotEmpty ? user.email : 'Sin correo';
            final username = '@${name.replaceAll(' ', '').toLowerCase()}';

            return Column(
              children: [
                const SizedBox(height: 12),

                // Avatar + nombre/username + botón editar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.grey.shade400,
                      backgroundImage: (user.avatarUrl != null &&
                              user.avatarUrl!.isNotEmpty)
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: (user.avatarUrl == null ||
                              user.avatarUrl!.isEmpty)
                          ? const Icon(Icons.person,
                              size: 44, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.brand,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 28,
                            height: 28,
                          ),
                          onPressed: () {
                            // TODO: navegar a editar foto/datos
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Editar foto de perfil (pendiente)',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  username,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),

                // Lista de opciones
                const Divider(height: 1),
                ListTile(
                  title: const Text('Nombre de usuario:'),
                 // trailing: const Icon(Icons.chevron_right_rounded),
                  subtitle: Text(username),
                 // onTap: () {
                    // TODO: editar username
                 // },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Correo:'),
                //  trailing: const Icon(Icons.chevron_right_rounded),
                  subtitle: Text(email),
                 // onTap: () {
                    // TODO: editar correo
                 // },
                ),
                const Divider(height: 1),
               /*ListTile(
                  title: const Text('Cambiar contraseña:'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // TODO: navegar a cambiar contraseña
                  },
                ),*/
                // debajo de "Cambiar contraseña" y antes de "Cerrar sesión"

                ListTile(
                  title: const Text('Acerca de Auto-Scan'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/about'),
                ),
                const Divider(height: 1),

                const Divider(height: 1),
                ListTile(
                  title: const Text('Cerrar sesión'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _confirmLogout(context),
                ),
                const Divider(height: 1),

                const Spacer(),
              ],
            );
          },
        ),
      ),

      // Bottom nav
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2, // Profile
        onDestinationSelected: (i) => _onNavTap(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_outlined),
            selectedIcon: Icon(Icons.photo),
            label: 'Photos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
