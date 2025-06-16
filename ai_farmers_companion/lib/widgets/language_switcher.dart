import 'package:flutter/material.dart'; // Ensure Material is imported for AppLocalizations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/locale_provider.dart'; // Import the localeProvider
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!; // Get the localized strings

    // Define the supported locales and their display names
    final Map<Locale, String> supportedLanguages = {
      const Locale('en', ''): l10n.languageEnglish, // Use localized language name
      const Locale('am', ''): l10n.languageAmharic, // Use localized language name
      const Locale('om', ''): l10n.languageAfaanOromo, // Use localized language name
      const Locale('so', ''): l10n.languageSomali, // Use localized language name
    };

    return DropdownButton<Locale>(
      value: currentLocale,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (Locale? newValue) {
        if (newValue != null) {
          ref.read(localeProvider.notifier).state = newValue;
        }
      },
      items: supportedLanguages.entries.map<DropdownMenuItem<Locale>>((entry) {
        return DropdownMenuItem<Locale>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
    );
  }
}
