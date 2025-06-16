import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class MarketIntelligenceScreen extends ConsumerWidget {
  const MarketIntelligenceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketIntelligenceButtonLabel), // Use localized title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Market Prices:', // TODO: Use localization
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Maize: 500 ETB/quintal'), // TODO: Use localization and actual data
                  ),
                  ListTile(
                    title: Text('Fertilizer (DAP): 3000 ETB/bag'), // TODO: Use localization and actual data
                  ),
                  ListTile(
                    title: Text('Coffee: 150 ETB/kg'), // TODO: Use localization and actual data
                  ),
                ],
              ),
            ),
            // TODO: Add more detailed market data display (e.g., charts, historical data)
          ],
        ),
      ),
    );
  }
}
