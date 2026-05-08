import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A0E0C),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('Notifications'),
          _buildToggleItem(
            label: 'Push Notifications',
            icon: Symbols.notifications,
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
          ),
          _buildToggleItem(
            label: 'Email Notifications',
            icon: Symbols.mail,
            value: _emailNotifications,
            onChanged: (v) => setState(() => _emailNotifications = v),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          _buildToggleItem(
            label: 'Dark Mode',
            icon: Symbols.dark_mode,
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Account & Security'),
          _buildActionItem(
            label: 'Change Password',
            icon: Symbols.lock,
            onTap: () => context.push('/forgot-password'),
          ),
          _buildActionItem(
            label: 'Privacy Policy',
            icon: Symbols.privacy_tip,
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('App Info'),
          _buildActionItem(
            label: 'Version',
            icon: Symbols.info,
            trailing: const Text('1.0.0', style: TextStyle(color: Color(0xFF64748B))),
            onTap: null,
          ),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FilledButton.icon(
              onPressed: () {
                auth.logout();
                context.go('/login');
              },
              icon: const Icon(Symbols.logout),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF3D1B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A0E0C)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFFF3D1B),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A0E0C)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing ?? const Icon(Symbols.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
