import 'package:flutter/material.dart'; // Ensure Material is imported for AppLocalizations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class VoiceButton extends ConsumerWidget {
  const VoiceButton({
    Key? key,
    required this.onPressed,
    // TODO: Add parameters for hold-to-record and animation
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings
    // TODO: Implement hold-to-record functionality and animation
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: l10n.voiceButtonTooltip, // Use localized tooltip
      child: const Icon(Icons.mic),
    );
  }
}
