import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus
import '../services/connectivity_service.dart'; // Import ConnectivityService
import '../services/synchronization_service.dart'; // Import SynchronizationService

class SyncBanner extends ConsumerWidget {
  const SyncBanner({
    Key? key,
    // TODO: Add parameters for last sync time if needed
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final connectivityService = ref.watch(connectivityServiceProvider);
    final syncStatus = ref.watch(synchronizationServiceProvider); // Watch overall sync status
    final synchronizationService = ref.watch(synchronizationServiceProvider.notifier); // Get the service instance for progress

    return StreamBuilder<ConnectivityResult>(
      stream: connectivityService.connectivityStream,
      builder: (context, snapshot) {
        final connectivityResult = snapshot.data ?? ConnectivityResult.none;
        final isConnected = connectivityResult != ConnectivityResult.none;

        // Determine if the banner should be shown
        final showBanner = !isConnected || syncStatus == OverallSyncStatus.syncing || syncStatus == OverallSyncStatus.error;

        if (!showBanner) {
          return const SizedBox.shrink();
        }

        // Determine the message and color based on sync status
        Color bannerColor = Colors.yellow[200]!;
        String message = l10n.offlineSyncStatus('Never'); // Default offline message

        if (isConnected && syncStatus == OverallSyncStatus.syncing) {
          bannerColor = Colors.blue[200]!;
          message = '${l10n.syncingStatus}... ${synchronizationService.currentSyncItem} (${synchronizationService.itemsSynced}/${synchronizationService.totalItemsToSync})';
        } else if (isConnected && syncStatus == OverallSyncStatus.completed) {
           bannerColor = Colors.green[200]!;
           message = l10n.syncCompletedStatus;
           // TODO: Hide banner after a few seconds when completed
        } else if (isConnected && syncStatus == OverallSyncStatus.error) {
           bannerColor = Colors.red[200]!;
           message = '${l10n.syncErrorStatus}: ${synchronizationService.syncError ?? "Unknown error"}';
        } else if (!isConnected) {
           // Offline status - use default message
           // TODO: Get actual last sync time from state
           const String lastSyncTime = 'Never';
           message = l10n.offlineSyncStatus(lastSyncTime);
        }


        return Container(
          color: bannerColor,
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}
