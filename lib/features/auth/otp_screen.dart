import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  final _c4 = TextEditingController();

  final _f1 = FocusNode();
  final _f2 = FocusNode();
  final _f3 = FocusNode();
  final _f4 = FocusNode();

  bool _verifying = false;
  bool _canResend = false;
  int _seconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _canResend = false;
    _seconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c1.dispose(); _c2.dispose(); _c3.dispose(); _c4.dispose();
    _f1.dispose(); _f2.dispose(); _f3.dispose(); _f4.dispose();
    super.dispose();
  }

  String get _code => _c1.text + _c2.text + _c3.text + _c4.text;
  bool get _complete => _code.length == 4;

  void _onChanged(int index, String value) {
    // Soporta pegar "1234" en el primer campo
    if (index == 1 && value.length > 1) {
      final v = value.replaceAll(RegExp(r'\D'), '');
      _c1.text = v.isNotEmpty ? v[0] : '';
      _c2.text = v.length > 1 ? v[1] : '';
      _c3.text = v.length > 2 ? v[2] : '';
      _c4.text = v.length > 3 ? v[3] : '';
      _moveFocus();
      setState(() {});
      return;
    }
    // Solo 1 dígito por campo
    if (value.length > 1) {
      final d = value.substring(value.length - 1);
      _controllerByIndex(index).text = d;
    }
    _moveFocus();
    setState(() {});
  }

  TextEditingController _controllerByIndex(int i) =>
      [ _c1, _c2, _c3, _c4 ][i - 1];

  void _moveFocus() {
    if (_c1.text.isEmpty) { _f1.requestFocus(); return; }
    if (_c2.text.isEmpty) { _f2.requestFocus(); return; }
    if (_c3.text.isEmpty) { _f3.requestFocus(); return; }
    if (_c4.text.isEmpty) { _f4.requestFocus(); return; }
    _f4.unfocus();
  }

  Future<void> _verify() async {
    if (!_complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código completo')),
      );
      return;
    }
    setState(() => _verifying = true);
    // TODO: integrar API real: POST /auth/verify-otp con _code
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _verifying = false);

    // Mock: cualquier código de 4 dígitos pasa
    context.go('/home');
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    // TODO: integrar API real: POST /auth/resend-otp
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código reenviado a tu correo')),
    );
    _startCooldown();
  }

  Widget _otpBox({
    required int index,
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    return SizedBox(
      width: 56, height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(counterText: ''),
        onChanged: (v) => _onChanged(index, v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter confirmation code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'A 4-digit code was sent to your email',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Casillas OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _otpBox(index: 1, controller: _c1, focusNode: _f1),
                  _otpBox(index: 2, controller: _c2, focusNode: _f2),
                  _otpBox(index: 3, controller: _c3, focusNode: _f3),
                  _otpBox(index: 4, controller: _c4, focusNode: _f4),
                ],
              ),

              const SizedBox(height: 16),

              // Reenviar con cooldown
              TextButton(
                onPressed: _canResend ? _resend : null,
                child: Text(
                  _canResend
                      ? 'Reenviar el código'
                      : 'Reenviar en 00:${_seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _canResend ? AppTheme.brand : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_complete && !_verifying) ? _verify : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _verifying
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Continuar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
