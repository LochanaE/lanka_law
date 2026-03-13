import 'package:flutter/material.dart';
import 'package:lanka_law/screen_widgets/chat_list_screen.dart';
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
import 'package:lanka_law/screens/legal_aid/legal_aid_finder_home.dart';
import 'package:lanka_law/screens/legal_aid/legal_aid_results_list.dart';
import 'package:lanka_law/screens/legal_aid/legal_aid_place_detail.dart';
import 'package:lanka_law/screens/legal_aid/legal_aid_wizard.dart';
import 'package:lanka_law/theme.dart';

import 'package:lanka_law/services/auth_service.dart';
import 'package:lanka_law/services/api_client.dart';
import 'package:lanka_law/services/threads_service.dart';
import 'package:lanka_law/services/messages_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lanka_law/l10n/app_localizations.dart';
import 'package:lanka_law/services/language_provider.dart';
import 'package:lanka_law/services/templates_provider.dart';
import 'package:lanka_law/services/daily_tip_api_service.dart';
import 'package:lanka_law/providers/daily_tip_provider.dart';
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
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TemplatesProvider()),
        Provider<DailyTipApiService>(create: (_) => DailyTipApiService()),
        ChangeNotifierProxyProvider<DailyTipApiService, DailyTipProvider>(
          create: (context) => DailyTipProvider(context.read<DailyTipApiService>()),
          update: (_, apiService, previous) => previous ?? DailyTipProvider(apiService),
        ),
        Provider<AuthService>(create: (_) => AuthService()),
        ProxyProvider<AuthService, ApiClient>(
          update: (_, auth, __) => ApiClient(auth: auth),
        ),
        ProxyProvider<ApiClient, ThreadsService>(
          update: (_, api, __) => ThreadsService(api),
        ),
        ProxyProvider<ApiClient, MessagesService>(
          update: (_, api, __) => MessagesService(api),
        ),
      ],
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
                  "/chat_list": (context) => const ChatListScreen(),
                  "/profile": (context) => const ProfileScreen(),
                  "/document_library": (context) =>
                      const DocumentLibraryScreen(),
                  "/document_templates": (context) =>
                      const DocumentTemplatesScreen(),
                  "/settings": (context) => const SettingsScreen(),
                  "/legal_aid_home": (context) => const LegalAidFinderHomeScreen(),
                  "/legal_aid_results": (context) => const LegalAidResultsListScreen(),
                  "/legal_aid_detail": (context) => const LegalAidPlaceDetailScreen(),
                  "/legal_aid_wizard": (context) => const LegalAidWizardScreen(),
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
