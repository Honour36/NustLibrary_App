import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class UploadProgressScreen extends StatelessWidget {
  const UploadProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.close, color: Color(0xFF1A0E0C)),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Illustration
              SvgPicture.asset(
                'assets/images/Checklist-bro.svg', // Assuming this exists or using fallback
                height: 280,
                placeholderBuilder: (context) => Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Symbols.check_circle, size: 120, color: Color(0xFF22C55E), fill: 1),
                ),
              ),
              const SizedBox(height: 48),
              
              // Success Message
              const Text(
                'Upload Successful!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A0E0C),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your book has been added to the library and is now available for everyone to read.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: () => context.go('/catalogue'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D1B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Go to Library',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
