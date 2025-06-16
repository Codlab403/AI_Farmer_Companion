import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/message_bubble.dart'; // Import MessageBubble
import '../widgets/voice_button.dart'; // Import VoiceButton
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import '../services/chat_service.dart'; // Import ChatService
import '../models/message.dart'; // Import Message model
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/message_bubble.dart'; // Import MessageBubble
import '../widgets/voice_button.dart'; // Import VoiceButton
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import '../services/chat_service.dart'; // Import ChatService
import '../models/message.dart'; // Import Message model
import 'package:speech_to_text/speech_to_text.dart' as stt; // Import speech_to_text
import 'package:flutter_tts/flutter_tts.dart'; // Import flutter_tts
import '../services/connectivity_service.dart'; // Import ConnectivityService
import '../services/offline_speech_service.dart'; // Import OfflineSpeechService

class AskAIScreen extends ConsumerStatefulWidget {
  const AskAIScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends ConsumerState<AskAIScreen> {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts(); // Initialize FlutterTts
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeechState();
    _initTtsState(); // Initialize TTS
  }

  Future<void> _initSpeechState() async {
    bool hasSpeech = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (errorNotification) => print('Speech error: $errorNotification'),
    );
    if (!hasSpeech) {
      // Handle the case where speech recognition is not available
      print('Online speech recognition not available');
    }
    setState(() {});
  }

  Future<void> _initTtsState() async {
    // Configure TTS settings if needed (e.g., language, pitch, speed)
    await _flutterTts.setLanguage(Localizations.localeOf(context).languageCode); // Use current locale
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    setState(() {});
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    _flutterTts.stop(); // Stop TTS
    super.dispose();
  }

  void _startListening() async {
    _lastWords = '';
    final isConnected = await ref.read(connectivityServiceProvider).isConnected();

    if (isConnected && _speech.isAvailable) {
      // Use online speech recognition when connected and available
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            _textController.text = _lastWords; // Update text field while listening
          });
        },
        localeId: Localizations.localeOf(context).languageCode, // Use current locale
      );
      setState(() {
        _isListening = true;
      });
    } else {
      // Use offline speech recognition when offline or online not available
      // TODO: Implement actual offline recording and send to offline service
      print('Using offline speech recognition (placeholder)');
      setState(() {
        _isListening = true; // Indicate listening even for placeholder
      });
      final offlineSpeechService = ref.read(offlineSpeechServiceProvider);
      final transcribedText = await offlineSpeechService.recognizeSpeechOffline();
       setState(() {
        _lastWords = transcribedText;
        _textController.text = _lastWords;
        _isListening = false; // Stop listening after placeholder
      });
      if (_lastWords.isNotEmpty) {
        _sendMessage(_lastWords); // Send message after offline recognition
      }
    }
  }

  void _stopListening() async {
     final isConnected = await ref.read(connectivityServiceProvider).isConnected();

    if (isConnected && _speech.isAvailable) {
      await _speech.stop();
       setState(() {
        _isListening = false;
      });
      if (_lastWords.isNotEmpty) {
        _sendMessage(_lastWords); // Send message after stopping
      }
    } else {
      // For offline placeholder, listening stops after the simulated delay in _startListening
      // No action needed here for the placeholder
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return; // Don't send empty messages

    final newMessage = Message(text: text.trim(), sender: MessageSender.user);
    ref.read(chatProvider.notifier).addMessage(newMessage); // Add message to provider

    _textController.clear(); // Clear the text field
    _lastWords = ''; // Clear last words after sending

    // Send message to backend/AI and handle response
    ref.read(chatProvider.notifier).sendMessageToAI(text);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get the localized strings
    final messages = ref.watch(chatProvider); // Watch the chat messages
    final isLoading = ref.watch(chatProvider.notifier).isLoading; // Watch the loading state

    // Listen for new messages and speak AI responses
    ref.listen<List<Message>>(chatProvider, (previousMessages, newMessages) {
      if (previousMessages != null && newMessages.length > previousMessages.length) {
        final newMessage = newMessages.last;
        if (newMessage.sender == MessageSender.ai) {
          _speak(newMessage.text);
        }
      }
    });

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
          if (isLoading) // Show loading indicator when loading
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
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
                  onPressed: _speech.isAvailable ? (_isListening ? _stopListening : _startListening) : null, // Toggle listening
                  tooltip: _isListening ? l10n.stopListeningTooltip : l10n.voiceButtonTooltip, // Use localized tooltip
                  isListening: _isListening, // Pass listening state
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
}
