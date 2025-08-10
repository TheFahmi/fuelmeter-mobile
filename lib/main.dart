import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'supabase.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/add_record_page.dart';
import 'pages/premium_page.dart';
import 'pages/records_page.dart';
import 'pages/record_detail_page.dart';
import 'pages/edit_record_page.dart';
import 'pages/manage_premium_page.dart';
import 'pages/compare_plans_page.dart';
import 'pages/profile_page.dart';
import 'pages/nearby_stations_page.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'pages/stats_page.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  Intl.defaultLocale = 'id';
  await initializeDateFormatting('id');
  await initSupabase();
  runApp(const ProviderScope(child: FuelMeterApp()));
}

class FuelMeterApp extends ConsumerWidget {
  const FuelMeterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Page<T> _fadeScalePage<T>(Widget child) => CustomTransitionPage<T>(
          child: child,
          transitionDuration: const Duration(milliseconds: 240),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final scale = Tween<double>(begin: 0.98, end: 1).animate(curved);
            final slide = Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(curved);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: scale,
                child: SlideTransition(position: slide, child: child),
              ),
            );
          },
        );

    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (c, s) => _fadeScalePage(const SplashPage()),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (c, s) => _fadeScalePage(const OnboardingPage()),
        ),
        GoRoute(
          path: '/auth-gate',
          pageBuilder: (context, state) {
            final session = Supabase.instance.client.auth.currentSession;
            final Widget child =
                session == null ? const LoginPage() : const DashboardPage();
            return _fadeScalePage(child);
          },
        ),
        GoRoute(
          path: '/',
          pageBuilder: (c, s) => _fadeScalePage(const DashboardPage()),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (c, s) => _fadeScalePage(const StatsPage()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (c, s) => _fadeScalePage(const LoginPage()),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (c, s) => _fadeScalePage(const RegisterPage()),
        ),
        GoRoute(
          path: '/add',
          pageBuilder: (c, s) => _fadeScalePage(const AddRecordPage()),
        ),
        GoRoute(
          path: '/premium',
          pageBuilder: (c, s) => _fadeScalePage(const PremiumPage()),
        ),
        GoRoute(
          path: '/premium/manage',
          pageBuilder: (c, s) => _fadeScalePage(const ManagePremiumPage()),
        ),
        GoRoute(
          path: '/premium/compare',
          pageBuilder: (c, s) => _fadeScalePage(const ComparePlansPage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (c, s) => _fadeScalePage(const ProfilePage()),
        ),
        GoRoute(
          path: '/nearby-stations',
          pageBuilder: (c, s) => _fadeScalePage(const NearbyStationsPage()),
        ),
        GoRoute(
          path: '/records',
          pageBuilder: (c, s) => _fadeScalePage(const RecordsPage()),
        ),
        GoRoute(
          path: '/records/:id',
          pageBuilder: (c, s) => _fadeScalePage(
            RecordDetailPage(id: s.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/records/:id/edit',
          pageBuilder: (c, s) => _fadeScalePage(
            EditRecordPage(id: s.pathParameters['id']!),
          ),
        ),
      ],
    );

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FuelMeter',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Background gradient global
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: themeMode == ThemeMode.dark
                  ? const [Color(0xFF0B1220), Color(0xFF111827)]
                  : const [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],
            ),
          ),
          child: child,
        );
      },
    );
  }
}
