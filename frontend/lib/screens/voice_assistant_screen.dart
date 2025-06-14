import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText _speech;
  bool _listening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _toggleListen() async {
    if (!_listening) {
      final available = await _speech.initialize();
      if (available) {
        setState(() => _listening = true);
        _speech.listen(onResult: (res) {
          if (res.finalResult) {
            setState(() {
              _listening = false;
              _lastWords = res.recognizedWords;
            });
            // TODO: send _lastWords to chat flow
          }
        });
      }
    } else {
      _speech.stop();
      setState(() => _listening = false);
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
            Icon(Icons.mic, size: 80, color: Colors.green.shade700),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice capture coming soon'))),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
