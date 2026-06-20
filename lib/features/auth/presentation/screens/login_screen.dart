import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool  _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final vm    = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / Icon
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_pharmacy_rounded,
                        color: Color(0xFF1565C0), size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text('PharmaCare',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E))),
                  const Text('Sign in to continue',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF888888))),
                  const SizedBox(height: 32),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDec('Email', Icons.email_rounded),
                    validator: (v) => v!.isEmpty ? 'Email required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: _inputDec(
                      'Password', Icons.lock_rounded,
                      suffix: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                            size: 18, color: const Color(0xFF888888)),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 8),

                  // Error message
                  if (state.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3F3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFFCDD2), width: 0.8),
                      ),
                      child: Text(state.errorMessage!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFE53935))),
                    ),
                  const SizedBox(height: 20),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              await vm.login(
                                  _emailCtrl.text.trim(),
                                  _passCtrl.text);
                            },
                      child: state.isLoading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Sign in',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF888888))),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, '/register'),
                        child: const Text('Register',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1565C0))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon,
      {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF888888)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
      );
}