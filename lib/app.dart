import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_router.dart';

class AutoScanApp extends StatelessWidget {
  const AutoScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Auto-Scan',
      theme: AppTheme.light(),
      routerConfig: router, // ✅ ahora usamos GoRouter
    );
  }
}
