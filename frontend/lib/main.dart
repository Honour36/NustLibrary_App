import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin/screens/admin_dashboard_screen.dart';
import 'admin/screens/analytics_screen.dart';
import 'admin/screens/document_management_screen.dart';
import 'admin/screens/user_management_screen.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/onboarding_flow_screen.dart';
import 'auth/screens/onboarding_screen.dart';
import 'auth/screens/register_screen.dart';
import 'catalogue/screens/catalogue_screen.dart';
import 'catalogue/screens/document_detail_screen.dart';
import 'downloads/screens/download_manager_screen.dart';
import 'downloads/screens/offline_library_screen.dart';
import 'home/screens/home_screen.dart';
import 'profile/screens/edit_profile_screen.dart';
import 'profile/screens/my_uploads_screen.dart';
import 'profile/screens/profile_screen.dart';
import 'ratings/screens/ratings_screen.dart';
import 'reader/screens/pdf_reader_screen.dart';
import 'search/screens/explore_screen.dart';
import 'search/screens/search_screen.dart';
import 'services/auth_service.dart';
import 'shared/app_shell.dart';
import 'upload/screens/moderation_queue_screen.dart';
import 'upload/screens/upload_form_screen.dart';
import 'upload/screens/upload_progress_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ibycqyrnpkhsljzifiza.supabase.co',
    anonKey: 'sb_publishable_1_PwHBH0-pN_Jh8QrgQXoQ_gbX3wJ7B',
  );

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      defaultDevice: Devices.ios.iPhone13ProMax,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
        ],
        child: const NustLibraryApp(),
      ),
    ),
  );
}

class NustLibraryApp extends StatelessWidget {
  const NustLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    final router = GoRouter(
      redirect: (context, state) {
        if (!auth.isReady) return '/splash';
        
        final path = state.matchedLocation;
        final authPaths = {'/login', '/register', '/get-started'};

        // 1. Must see Get Started first
        if (!auth.hasSeenGetStarted && path != '/get-started') return '/get-started';
        
        // 2. If not authenticated, must be on an auth path
        if (!auth.isAuthenticated && !authPaths.contains(path)) return '/login';
        
        // 3. If authenticated but hasn't completed onboarding, must be on /onboarding
        if (auth.isAuthenticated && !auth.hasCompletedOnboarding && path != '/onboarding') return '/onboarding';
        
        // 4. If already authenticated and onboarding is done, don't allow auth paths
        if (auth.isAuthenticated && auth.hasCompletedOnboarding && authPaths.contains(path)) return '/';
        
        // 5. Splash redirect
        if (auth.isReady && path == '/splash') {
          if (!auth.hasSeenGetStarted) return '/get-started';
          if (!auth.isAuthenticated) return '/login';
          if (!auth.hasCompletedOnboarding) return '/onboarding';
          return '/';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        GoRoute(path: '/get-started', builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingFlowScreen()),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            GoRoute(path: '/catalogue', builder: (context, state) => const CatalogueScreen()),
            GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
            GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
            GoRoute(path: '/downloads', builder: (context, state) => const OfflineLibraryScreen()),
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
            GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
          ],
        ),
        GoRoute(
          path: '/document/:id',
          builder: (context, state) => DocumentDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/reader',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PdfReaderScreen(
              url: extra['url'].toString(),
              title: extra['title'].toString(),
              documentId: extra['documentId']?.toString(),
            );
          },
        ),
        GoRoute(path: '/upload', builder: (context, state) => const UploadFormScreen()),
        GoRoute(path: '/upload/progress', builder: (context, state) => const UploadProgressScreen()),
        GoRoute(path: '/moderation', builder: (context, state) => const ModerationQueueScreen()),
        GoRoute(path: '/downloads/manager', builder: (context, state) => const DownloadManagerScreen()),
        GoRoute(path: '/profile/uploads', builder: (context, state) => const MyUploadsScreen()),
        GoRoute(path: '/ratings', builder: (context, state) => const RatingsScreen()),
        GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
        GoRoute(path: '/admin/documents', builder: (context, state) => const DocumentManagementScreen()),
        GoRoute(path: '/admin/users', builder: (context, state) => const UserManagementScreen()),
        GoRoute(path: '/admin/analytics', builder: (context, state) => const AnalyticsScreen()),
      ],
      initialLocation: '/splash',
    );

    final baseTheme = ThemeData.light(useMaterial3: true);
    return MaterialApp.router(
      title: 'NUST Library',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: baseTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF3D1B),
          primary: const Color(0xFFFF3D1B),
          secondary: const Color(0xFFFF6B4A),
          surface: const Color(0xFFFFF5F4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
          displaySmall: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A0E0C),
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A0E0C),
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A0E0C),
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A0E0C),
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF8A8A9A),
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF8A8A9A),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
      ),
    );
  }
}
