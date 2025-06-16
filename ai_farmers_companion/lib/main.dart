import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart'; // Import the HomeScreen
import 'screens/ask_ai_screen.dart'; // Import AskAIScreen
import 'screens/crop_guide_screen.dart'; // Import CropGuideScreen
import 'screens/pest_photo_upload_screen.dart'; // Import PestPhotoUploadScreen
import 'screens/settings_screen.dart'; // Import SettingsScreen
import 'localization/locale_provider.dart'; // Import the localeProvider

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider); // Watch the localeProvider
    // Watch the synchronization service to keep it alive and active
    ref.watch(synchronizationServiceProvider);

    return MaterialApp(
      title: AppLocalizations.of(context)!.appTitle, // Use localized app title
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('am', ''), // Amharic
        Locale('om', ''), // Afaan Oromo
        Locale('so', ''), // Somali
      ],
      locale: currentLocale, // Use the locale from the provider
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Define routes for navigation
      routes: {
        '/': (context) => const HomeScreen(),
        '/ask_ai': (context) => const AskAIScreen(), // TODO: Import AskAIScreen
        '/crop_guide': (context) => const CropGuideScreen(), // TODO: Import CropGuideScreen
        '/pest_photo_upload': (context) => const PestPhotoUploadScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/market_intelligence': (context) => const MarketIntelligenceScreen(),
        // TODO: Create WeatherAlertsScreen, LearningLibraryScreen, and CommunityGroupsScreen and add their routes
        '/weather_alerts': (context) => const PlaceholderScreen(title: 'Weather Alerts'), // Placeholder
        '/learning_library': (context) => const PlaceholderScreen(title: 'Learning Library'), // Placeholder
        '/community_groups': (context) => const PlaceholderScreen(title: 'Community & Groups'), // Placeholder
      },
      initialRoute: '/', // Set the initial route
    );
  }
}
