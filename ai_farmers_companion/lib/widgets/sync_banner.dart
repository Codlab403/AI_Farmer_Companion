import 'package:flutter/material.dart'; // Ensure Material is imported for AppLocalizations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class SyncBanner extends ConsumerWidget {
  const SyncBanner({
    Key? key,
    // TODO: Add parameters for sync status, last sync time, etc.
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings
    // TODO: Implement logic to display sync status and last sync time
    // TODO: Implement logic to show/hide based on online/offline status

    // Placeholder for last sync time
    const String lastSyncTime = 'Never'; // TODO: Get actual last sync time from state

    return Container(
      color: Colors.yellow[200], // Placeholder color for a warning banner
      padding: const EdgeInsets.all(8.0),
      child: Center( // Removed const because Text widget is no longer const
        child: Text(
          l10n.offlineSyncStatus(lastSyncTime), // Use localized text with placeholder
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
