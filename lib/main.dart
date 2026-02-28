import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lanka_law/screen_widgets/chat.dart';
import 'package:lanka_law/screen_widgets/splash_screen.dart';
import 'package:lanka_law/screen_widgets/onboarding_screen.dart';
import 'package:lanka_law/screen_widgets/home_screen.dart';
import 'package:lanka_law/screen_widgets/login_screen.dart';
import 'package:lanka_law/screen_widgets/register_screen.dart';
import 'package:lanka_law/screen_widgets/profile_screen.dart';
import 'package:lanka_law/screen_widgets/document_library_screen.dart';
import 'package:lanka_law/screen_widgets/document_templates_screen.dart';
import 'package:lanka_law/screen_widgets/settings_screen.dart';
import 'package:lanka_law/screen_widgets/welcome_screen.dart';
import 'package:lanka_law/theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lanka_law/l10n/app_localizations.dart';
import 'package:lanka_law/services/language_provider.dart';
// import 'firebase_options.dart'; // TODO: Run flutterfire configure to generate this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // For now, if you haven't configured firebase, you can try:
  try {
    await Firebase.initializeApp();
    print("✅ Firebase is successfully connected!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LanguageProvider())],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppTheme.themeNotifier,
        builder: (context, mode, child) {
          return Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return MaterialApp(
                title: 'LankaLAW',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: mode,
                locale: languageProvider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('si'), // Sinhala
                  Locale('ta'), // Tamil
                ],
                initialRoute: '/splash',
                routes: {
                  "/splash": (context) => const SplashScreen(),
                  "/welcome": (context) => const WelcomeScreen(),
                  "/onboarding": (context) => const OnboardingScreen(),
                  "/login": (context) => const LoginScreen(),
                  "/register": (context) => const RegisterScreen(),
                  "/home": (context) => const HomeScreen(),
                  "/chat": (context) => chat(),
                  "/profile": (context) => const ProfileScreen(),
                  "/document_library": (context) =>
                      const DocumentLibraryScreen(),
                  "/document_templates": (context) =>
                      const DocumentTemplatesScreen(),
                  "/settings": (context) => const SettingsScreen(),
                },
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    ),
  );
}
