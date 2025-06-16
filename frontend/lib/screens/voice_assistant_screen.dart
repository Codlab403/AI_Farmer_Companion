import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart'; // Import flutter_tts
import 'package:ai_farmers_companion/services/api_service.dart'; // Import ApiService

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts; // FlutterTts instance
  bool _listening = false;
  bool _isSpeaking = false; // State for TTS
  String _lastWords = '';
  String _statusText = 'Press the button to start listening';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
        print("TTS Error: $msg");
        _statusText = "Error speaking: $msg";
      });
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (!_listening) {
      _lastWords = ''; // Clear previous words
      _statusText = 'Initializing speech recognition...';
      setState(() {});

      final available = await _speech.initialize(
        onStatus: (status) => print('STT Status: $status'),
        onError: (errorNotification) {
          print('STT Error: ${errorNotification.errorMsg}');
          setState(() {
            _listening = false;
            _statusText = 'Error: ${errorNotification.errorMsg}';
          });
        },
      );

      if (available) {
        _statusText = 'Listening...';
        setState(() => _listening = true);
        _speech.listen(
          onResult: (res) {
            setState(() {
              _lastWords = res.recognizedWords;
              if (res.finalResult) {
                _listening = false;
                _statusText = 'Processing...';
                _processText(_lastWords); // Process the final result
              }
            });
          },
          listenFor: const Duration(seconds: 30), // Listen for up to 30 seconds
          pauseFor: const Duration(seconds: 5), // Pause if no speech for 5 seconds
          // localeId: 'en_US', // Consider making this dynamic based on user preference
        );
      } else {
        setState(() {
          _listening = false;
          _statusText = 'Speech recognition not available.';
        });
      }
    } else {
      _speech.stop();
      setState(() {
        _listening = false;
        _statusText = 'Stopped listening.';
      });
    }
  }

  Future<void> _processText(String text) async {
    if (text.isEmpty) {
      setState(() {
        _statusText = 'No speech detected.';
      });
      return;
    }

    setState(() {
      _statusText = 'Sending to assistant...';
    });

    try {
      // Call the API service to get AI response
      final response = await ApiService.askAssistant(text);
      final aiResponse = response['response'] ?? 'Sorry, I could not process that.';

      setState(() {
        _statusText = 'Assistant response:';
      });

      // Speak the AI response
      await _speak(aiResponse);

    } catch (e) {
      print('Error processing text with assistant: $e');
      setState(() {
        _statusText = 'Error getting assistant response.';
      });
      await _speak('Sorry, there was an error getting a response.');
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      // Consider setting language dynamically
      // await _flutterTts.setLanguage("en-US"); 
      await _flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _listening ? Icons.mic_on : Icons.mic_none,
              size: 80,
              color: _listening ? Colors.red : Colors.green.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _lastWords,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSpeaking ? null : _toggleListen, // Disable button while speaking
              child: Text(_listening ? 'Stop Listening' : 'Start Listening'),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> REPLACE
