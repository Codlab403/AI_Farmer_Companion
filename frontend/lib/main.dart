import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import 'constants.dart';
import 'l10n/app_localizations.dart';
import 'screens/language_selection_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
  await AuthService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _languageCode;
  bool _authChecked = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await AuthService.getToken();
    setState(() {
      _isLoggedIn = token != null;
      _authChecked = true;
    });
  }

  void _onLoggedIn() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  Future<void> _onLoggedOut() async {
    await AuthService.logout();
    setState(() {
      _isLoggedIn = false;
      _languageCode = null; // Reset language selection on logout
    });
  }

  void _onLanguageSelected(String code) {
    setState(() {
      _languageCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (!_authChecked) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (!_isLoggedIn) {
      home = LoginScreen(onLoggedIn: _onLoggedIn);
    } else if (_languageCode == null) {
      home = LanguageSelectionScreen(onLanguageSelected: _onLanguageSelected);
    } else {
      home = MainMenuScreen(
        languageCode: _languageCode!,
        onLoggedOut: _onLoggedOut,
      );
    }

    return MaterialApp(
      title: "AI Farmer's Companion",
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: _languageCode != null ? Locale(_languageCode!) : null,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }
}
