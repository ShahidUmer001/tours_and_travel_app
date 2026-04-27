import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/local_auth_service.dart';
import 'services/user_listings_service.dart';
import 'utils/app_theme.dart';

bool firebaseInitialized = false;
bool onboardingSeen = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await LocalAuthService.instance.init();
  await UserListingsService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tours and Travel',
      theme: AppTheme.lightTheme,
      home: AnimatedBuilder(
        animation: LocalAuthService.instance,
        builder: (context, _) {
          if (!onboardingSeen) {
            return const SplashScreen(key: ValueKey('splash'));
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: LocalAuthService.instance.isLoggedIn
                ? const HomeScreen(key: ValueKey('home'))
                : const LoginScreen(key: ValueKey('login')),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
