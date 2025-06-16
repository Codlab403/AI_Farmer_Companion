import 'package:flutter/material.dart'; // Ensure Material is imported for AppLocalizations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/language_switcher.dart'; // Import LanguageSwitcher
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
// Import necessary packages for sync info, help guide

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsScreenTitle), // Use localized title
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.languageSettingTitle), // Use localized title
            trailing: const LanguageSwitcher(), // Use the LanguageSwitcher widget
            // onTap is no longer needed here as the DropdownButton handles interaction
          ),
          ListTile(
            title: Text(l10n.lastSyncSettingTitle), // Use localized title
            trailing: Text(l10n.neverSyncPlaceholder), // Use localized placeholder text
          ),
          ListTile(
            title: Text(l10n.helpGuideSettingTitle), // Use localized title
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to Help Guide/FAQ screen
            },
          ),
          // TODO: Add SyncBanner widget if applicable
        ],
      ),
    );
  }
}
