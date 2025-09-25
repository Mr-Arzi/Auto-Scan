import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _sending = false;
  bool _sentOk = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Ingresa tu correo';
    final emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRx.hasMatch(value)) return 'Correo no válido';
    return null;
  }

  Future<void> _sendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sending = true;
      _sentOk = false;
    });

    // TODO: integrar API real: POST /auth/forgot-password
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _sending = false;
      _sentOk = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Te enviamos un código a tu correo.')),
    );
  }

  void _continueToOTP() {
    if (_sentOk) {
      context.go('/otp'); // pasa a la pantalla de verificación
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero envía el código a tu correo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ingresa tu correo electrónico y te enviaremos un código\n'
                  'para que restablezcas tu contraseña.',
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: _validateEmail,
                ),

                const SizedBox(height: 16),

                // Botón "Enviar/Reservar el código"
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _sending ? null : _sendCode,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.brand, width: 1.2),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _sending
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enviar código'),
                  ),
                ),

                const SizedBox(height: 12),

                // Botón "Continuar" (habilitado cuando ya se envió el código)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sentOk ? _continueToOTP : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Continuar'),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
