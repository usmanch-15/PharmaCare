import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_user.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _obscure   = true;
  String _role     = UserRole.cashier.name;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final vm    = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _field(_nameCtrl, 'Full name', Icons.person_rounded),
              const SizedBox(height: 14),
              _field(_emailCtrl, 'Email', Icons.email_rounded,
                  type: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _field(_passCtrl, 'Password', Icons.lock_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                        size: 18, color: const Color(0xFF888888)),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),
              const SizedBox(height: 14),

              // Role selector
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: const Icon(Icons.badge_rounded,
                      size: 18, color: Color(0xFF888888)),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                ),
                items: UserRole.values
                    .map((r) => DropdownMenuItem(
                          value: r.name,
                          child: Text(r.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 8),

              if (state.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(state.errorMessage!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFE53935))),
                ),
              const SizedBox(height: 20),

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
                          final ok = await vm.register(
                            email:    _emailCtrl.text.trim(),
                            password: _passCtrl.text,
                            name:     _nameCtrl.text.trim(),
                            role:     _role,
                          );
                          if (ok && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                  child: state.isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Create account',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false, Widget? suffix,
       TextInputType type = TextInputType.text}) =>
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF888888)),
          suffixIcon: suffix,
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF1565C0), width: 1.5)),
        ),
        validator: (v) => v!.isEmpty ? '$label is required' : null,
      );
}