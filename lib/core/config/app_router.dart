import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens (placeholders)
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/camera/camera_screen.dart';
import '../../features/results/results_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/profile/profile_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',  builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',   builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup',  builder: (_, __) => const SignUpScreen()),
    GoRoute(path: '/forgot',  builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/otp',     builder: (_, __) => const OtpScreen()),
    GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/camera',  builder: (_, __) => const CameraScreen()),
    GoRoute(path: '/results', builder: (_, __) => const ResultsScreen()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
  // (Opcional) logging básico de navegación:
  observers: [
    NavigatorObserver(),
  ],
);
