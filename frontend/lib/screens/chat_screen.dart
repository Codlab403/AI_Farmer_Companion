import 'package:flutter/material.dart';
import 'package:ai_farmers_companion/services/api_service.dart';

// A simple data model for a chat message
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
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

  Future<void> _handleSendPressed() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      setState(() {
        _messages.add(ChatMessage(text: text, isUser: true));
        _isLoading = true;
      });

      try {
        final response = await ApiService.askAssistant(text);
        final aiResponse = response['response'] ?? 'Sorry, I could not process that.';
        setState(() {
          _messages.add(ChatMessage(text: aiResponse, isUser: false));
        });
      } catch (e) {
        setState(() {
          _messages.add(ChatMessage(text: 'Error: ${e.toString()}', isUser: false));
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
                return Align(
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
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Padding(
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
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _handleSendPressed,
          ),
        ],
      ),
    );
  }
}

