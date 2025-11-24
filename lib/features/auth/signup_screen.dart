import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _agree = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Ingresa tu nombre';
    if (value.length < 2) return 'Nombre muy corto';
    return null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Ingresa tu correo';
    final emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRx.hasMatch(value)) return 'Correo no válido';
    return null;
  }

  String? _validatePass(String? v) {
    final value = (v ?? '');
    if (value.isEmpty) return 'Crea una contraseña';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los Términos y la Privacidad')),
      );
      return;
    }

    setState(() => _submitting = true);
    // TODO: conectar a API real. Por ahora mock:
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _submitting = false);

    // Regresar al login con toast
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta creada. Inicia sesión.')),
    );
    context.go('/login');
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
                const Text(
                  'Sign up',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Create an account to get started'),
                const SizedBox(height: 18),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: _validateName,
                ),
                const SizedBox(height: 12),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure1,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Create a password',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                      icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  validator: _validatePass,
                ),
                const SizedBox(height: 12),

                // Confirm password
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                      icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 16),

                // Terms & Privacy
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      activeColor: AppTheme.brand,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87),
                          children: [
                            const TextSpan(text: "I've read and agree with the "),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: const TextStyle(
                                color: AppTheme.brand,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: navegar a /terms cuando exista la pantalla
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Abrir Terms & Conditions')),
                                  );
                                },
                            ),
                            const TextSpan(text: ' and the '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: AppTheme.brand,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: navegar a /privacy cuando exista la pantalla
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Abrir Privacy Policy')),
                                  );
                                },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shadowColor: AppTheme.brand.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _submitting
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Register'),
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
