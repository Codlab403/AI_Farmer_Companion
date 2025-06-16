import 'package:flutter/material.dart'; // Ensure Material is imported for AppLocalizations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/message_bubble.dart'; // Import MessageBubble
import '../widgets/voice_button.dart'; // Import VoiceButton
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import '../services/chat_service.dart'; // Import ChatService
import '../models/message.dart'; // Import Message model

class AskAIScreen extends ConsumerStatefulWidget {
  const AskAIScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends ConsumerState<AskAIScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings
    final messages = ref.watch(chatProvider); // Watch the chat messages

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.askAiScreenTitle), // Use localized title
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length, // Use messages from the provider
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(
                  text: message.text,
                  sender: message.sender,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController, // Assign the controller
                    decoration: InputDecoration(
                      hintText: l10n.askAiInputHint, // Use localized hint text
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    onSubmitted: (text) {
                      _sendMessage(text); // Send message on Enter
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                VoiceButton(
                  onPressed: () {
                    // TODO: Implement voice input logic
                  },
                  tooltip: l10n.voiceButtonTooltip, // Use localized tooltip
                ),
                IconButton( // Add send button
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_textController.text); // Send message on button press
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return; // Don't send empty messages

    final newMessage = Message(text: text.trim(), sender: MessageSender.user);
    ref.read(chatProvider.notifier).addMessage(newMessage); // Add message to provider

    _textController.clear(); // Clear the text field

    // TODO: Implement sending message to backend/AI and handling response
  }
}
