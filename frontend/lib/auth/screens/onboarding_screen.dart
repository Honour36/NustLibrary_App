import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

// data

class _OnboardingPage {
  final String asset;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardingPage({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

const _pages = [
  _OnboardingPage(
    asset: 'assets/images/Bibliophile-bro.svg',
    title: 'Your Academic Library',
    subtitle:
        'Past papers, notes, project reports, and revision packs — all in one searchable place.',
    accent: Color(0xFFFF3D1B),
  ),
  _OnboardingPage(
    asset: 'assets/images/Learning-bro.svg',
    title: 'Learn at Your Pace',
    subtitle:
        'Read, highlight, and annotate documents tailored to your department and year of study.',
    accent: Color(0xFFFF6B4A),
  ),
  _OnboardingPage(
    asset: 'assets/images/Online learning-bro.svg',
    title: 'Study Offline, Anytime',
    subtitle:
        'Queue downloads and keep your study shelf available without a network round trip.',
    accent: Color(0xFFFF8F78),
  ),
  _OnboardingPage(
    asset: 'assets/images/Collab-bro.svg',
    title: 'Contribute & Collaborate',
    subtitle:
        'Submit documents with metadata so the catalogue stays searchable, clean, and growing.',
    accent: Color(0xFFEA580C), // Keep orange for variety or change to red
  ),
];

// screen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  Future<void> _finish() async {
    await context.read<AuthService>().completeGetStarted();
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _current == _pages.length - 1;
    final page = _pages[_current];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // logo
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Image.asset(
                'assets/images/logo.png',
                height: 48,
              ),
            ),

            // skip row
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedOpacity(
                  opacity: isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: TextButton(
                    onPressed: isLast ? null : _finish,
                    child: const Text('Skip'),
                  ),
                ),
              ),
            ),

            // pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, index) =>
                    _PageView(page: _pages[index]),
              ),
            ),

            // dot indicator
            _DotIndicator(count: _pages.length, current: _current, accent: page.accent),

            const SizedBox(height: 24),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: page.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _next,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        isLast ? 'Get Started' : 'Next',
                        key: ValueKey(isLast),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// single page view

class _PageView extends StatelessWidget {
  final _OnboardingPage page;

  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // illustration
          Expanded(
            flex: 5,
            child: SvgPicture.asset(
              page.asset,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 24),

          // title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A0E0C),
                  height: 1.2,
                ),
          ),

          const SizedBox(height: 14),

          // subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// dot indicator

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color accent;

  const _DotIndicator({
    required this.count,
    required this.current,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? accent : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
