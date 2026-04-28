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
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final ok = await context.read<AuthService>().register(_email.text, _password.text, _name.text, _studentId.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created. Sign in next.')));
      context.go('/login?new=true');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed.')));
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
                  'assets/images/logo.png',
                  height: 80,
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
                AuthTextField(controller: _password, label: 'Password', icon: Symbols.lock, obscureText: true),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Register'),
                ),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Back to login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
