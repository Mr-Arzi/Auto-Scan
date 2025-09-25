import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class AutoScanApp extends StatelessWidget {
  const AutoScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto-Scan',
      theme: AppTheme.light(),
      home: const _TempHome(), // 👈 pantalla temporal
    );
  }
}

class _TempHome extends StatelessWidget {
  const _TempHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-Scan • Tema OK')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botón del tema funcionando 🚀')),
                );
              },
              child: const Text('Probar tema'),
            ),
          ],
        ),
      ),
    );
  }
}
