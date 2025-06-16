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
          // Add Region setting
          Consumer(
            builder: (context, ref, child) {
              final settingsService = ref.watch(settingsServiceProvider);
              return FutureBuilder<String?>(
                future: settingsService.loadUserRegion(),
                builder: (context, snapshot) {
                  final currentRegion = snapshot.data ?? l10n.regionNotSetPlaceholder; // Use localized placeholder
                  return ListTile(
                    title: Text(l10n.regionSettingTitle), // Use localized title
                    trailing: Text(currentRegion),
                    onTap: () async {
                      // Show dialog to edit region
                      final newRegion = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final regionController = TextEditingController(text: snapshot.data);
                          return AlertDialog(
                            title: Text(l10n.editRegionDialogTitle), // Use localized title
                            content: TextField(
                              controller: regionController,
                              decoration: InputDecoration(hintText: l10n.enterRegionHint), // Use localized hint
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancelButtonLabel), // Use localized label
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, regionController.text),
                                child: Text(l10n.saveButtonLabel), // Use localized label
                              ),
                            ],
                          );
                        },
                      );
                      if (newRegion != null && newRegion.isNotEmpty) {
                        await settingsService.saveUserRegion(newRegion);
                        // Manually trigger a rebuild to show the updated region
                        ref.invalidate(settingsServiceProvider);
                      }
                    },
                  );
                },
              );
            },
          ),
          // Add Notification Preferences setting
          Consumer(
            builder: (context, ref, child) {
              final settingsService = ref.watch(settingsServiceProvider);
              return FutureBuilder<bool>(
                future: settingsService.loadNotificationPreferences(),
                builder: (context, snapshot) {
                  final notificationsEnabled = snapshot.data ?? true; // Default to enabled
                  return ListTile(
                    title: Text(l10n.notificationsSettingTitle), // Use localized title
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (bool newValue) async {
                        await settingsService.saveNotificationPreferences(newValue);
                        ref.invalidate(settingsServiceProvider); // Trigger rebuild
                      },
                    ),
                  );
                },
              );
            },
          ),
          // Add Sync Settings
          Consumer(
            builder: (context, ref, child) {
              final settingsService = ref.watch(settingsServiceProvider);
              return FutureBuilder<bool>(
                future: settingsService.loadSyncSettings(),
                builder: (context, snapshot) {
                  final syncOnWifiOnly = snapshot.data ?? false; // Default to sync on all networks
                  return ListTile(
                    title: Text(l10n.syncOnWifiOnlySettingTitle), // Use localized title
                    trailing: Switch(
                      value: syncOnWifiOnly,
                      onChanged: (bool newValue) async {
                        await settingsService.saveSyncSettings(newValue);
                        ref.invalidate(settingsServiceProvider); // Trigger rebuild
                      },
                    ),
                  );
                },
              );
            },
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
