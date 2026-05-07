import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _studentId = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _submit() async {
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _loading = true);
    final errorMessage = await context.read<AuthService>().register(_email.text, _password.text, _name.text, _studentId.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created. Sign in next.')));
      context.go('/login?new=true');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/logo1.png',
                  height: 60,
                ),
                const SizedBox(height: 32),
                Text('Create account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                AuthTextField(controller: _name, label: 'Full name', icon: Symbols.person),
                const SizedBox(height: 16),
                AuthTextField(controller: _studentId, label: 'Student ID', icon: Symbols.badge),
                const SizedBox(height: 16),
                AuthTextField(controller: _email, label: 'Email', icon: Symbols.alternate_email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _password, 
                  label: 'Password', 
                  icon: Symbols.lock, 
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Symbols.visibility : Symbols.visibility_off, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmPassword, 
                  label: 'Confirm Password', 
                  icon: Symbols.lock_reset, 
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    icon: Icon(_obscureConfirmPassword ? Symbols.visibility : Symbols.visibility_off, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D1B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Register'),
                ),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Back to login', style: TextStyle(color: Color(0xFF6B7280)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
