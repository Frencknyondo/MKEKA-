import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MkekaApp());
}

class MkekaApp extends StatelessWidget {
  const MkekaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mkeka Plus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final firebaseUser = authSnap.data;
        if (firebaseUser == null) return const LoginScreen();

        final isGoogleUser =
            firebaseUser.providerData.any((p) => p.providerId == 'google.com');

        if (!firebaseUser.emailVerified && !isGoogleUser) {
          return VerifyEmailScreen(email: firebaseUser.email ?? '');
        }

        return StreamBuilder<AppUser?>(
          stream: AuthService.streamUserData(firebaseUser.uid),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const _SplashScreen();
            }
            final appUser = userSnap.data;
            if (appUser == null) {
              AuthService.signOut();
              return const LoginScreen();
            }
            FirestoreService.checkVipExpiry(appUser.id);
            if (appUser.role == UserRole.admin) {
              return AdminDashboard(admin: appUser);
            }
            return MainShell(user: appUser);
          },
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.neonGreen.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.sports_soccer,
                  color: AppColors.neonGreen, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'MKEKA PLUS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.neonGreen,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            const Text('Smart Prediction Hub',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.neonGreen),
            ),
          ],
        ),
      ),
    );
  }
}
