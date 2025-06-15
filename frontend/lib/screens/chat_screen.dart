import 'package:flutter/material.dart';
import 'package:ai_farmers_companion/services/api_service.dart';
import 'package:record/record.dart'; // Import the record package
import 'package:path_provider/path_provider.dart'; // Import path_provider for temporary directory
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

// A simple data model for a chat message
class ChatMessage {
  final String id; // Unique identifier for the message
  final String text;
  final bool isUser;

  ChatMessage({required this.id, required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isRecording = false; // State for recording
  final AudioRecorder _audioRecorder = AudioRecorder(); // Audio recorder instance

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose(); // Dispose the audio recorder
    super.dispose();
  }

  Future<void> _handleSendPressed() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      setState(() {
        // Generate a simple ID for user messages (optional, but good for consistency)
        _messages.add(ChatMessage(id: DateTime.now().toIso8601String(), text: text, isUser: true));
        _isLoading = true;
      });

      try {
        final response = await ApiService.askAssistant(text);
        final aiResponse = response['response'] ?? 'Sorry, I could not process that.';
        setState(() {
          // Generate a unique ID for AI messages to associate feedback
          _messages.add(ChatMessage(id: DateTime.now().toIso8601String(), text: aiResponse, isUser: false));
        });
      } catch (e) {
        setState(() {
          // Provide a more user-friendly error message for chat
          _messages.add(ChatMessage(text: 'Error: Could not get a response from the assistant.', isUser: false));
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Implement _sendFeedback method to call ApiService
  void _sendFeedback(String messageId, String feedbackType) async {
    try {
      // Call ApiService.postFeedback to send feedback to the backend
      await ApiService.postFeedback(messageId, feedbackType);
      print('Feedback sent successfully: messageId=$messageId, feedbackType=$feedbackType');
      // TODO: Optionally update UI to show feedback has been submitted (e.g., change icon color)
    } catch (e) {
      print('ERROR - Failed to send feedback: $e');
      // TODO: Optionally show a user-friendly error message
    }
  }

  // Implement voice recording methods (_startRecording, _stopRecording)
  Future<void> _startRecording() async {
    try {
      // Check and request microphone permission
      if (await Permission.microphone.request().isGranted) {
        // Get the application documents directory to save the audio file
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a'; // Example file path

        await _audioRecorder.start(
          path: filePath,
          encoder: AudioEncoder.aac, // Choose an audio encoder
        );

        setState(() {
          _isRecording = true;
        });
        print('Recording started to $filePath');
      } else {
        // Handle permission denied
        print('Microphone permission denied.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied.')),
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: ${e.toString()}')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop(); // Stop recording and get the file path

      setState(() {
        _isRecording = false;
      });
      print('Recording stopped. File saved to $path');

      if (path != null) {
        setState(() {
          _isLoading = true; // Show loading indicator while transcribing
        });
        try {
          final response = await ApiService.uploadAudioForTranscription(path);
          final transcribedText = response['transcribed_text'] ?? '';
          if (transcribedText.isNotEmpty) {
            _textController.text = transcribedText; // Populate text field with transcribed text
            _handleSendPressed(); // Send the transcribed text as a chat message
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No speech detected or transcription failed.')),
            );
          }
        } catch (e) {
          print('Error sending audio for transcription: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error transcribing audio: ${e.toString()}')),
          );
        } finally {
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Column(
                  crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: message.isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(message.text),
                      ),
                    ),
                    // Add feedback buttons below AI messages
                    if (!message.isUser) // Only for AI messages
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up_outlined, size: 20),
                              onPressed: () {
                                _sendFeedback(message.id, 'like');
                                print('Feedback: Liked message ID: ${message.id}');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_down_outlined, size: 20),
                              onPressed: () {
                                _sendFeedback(message.id, 'dislike');
                                print('Feedback: Disliked message ID: ${message.id}');
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // Text input and microphone button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _isLoading ? null : (_) => _handleSendPressed(),
                  ),
                ),
                const SizedBox(width: 8.0),
                // Row for Send and Microphone buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Send button (for text input)
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _isLoading ? null : _handleSendPressed, // Use _handleSendPressed for text
                    ),
                    // Microphone button (for voice input)
                    IconButton(
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic_none), // Change icon based on recording state
                      onPressed: _isLoading ? null : (_isRecording ? _stopRecording : _startRecording), // Call start/stop based on state
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
