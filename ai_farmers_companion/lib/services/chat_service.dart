import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart'; // Import the Message model

// Define a StateNotifier for managing the chat messages
class ChatService extends StateNotifier<List<Message>> {
  ChatService() : super([
    // Initial placeholder messages (can be removed later)
    Message(text: 'Hello! How can I help you today?', sender: MessageSender.ai),
    Message(text: 'What is the best fertilizer for maize?', sender: MessageSender.user),
    Message(text: 'For maize, a balanced fertilizer like NPK 20-10-10 is often recommended...', sender: MessageSender.ai),
  ]);

  // Method to add a new message
  void addMessage(Message message) {
    state = [...state, message];
  }

  // TODO: Add methods for sending messages to backend/AI and receiving responses
}

// Define a StateNotifierProvider for the ChatService
final chatProvider = StateNotifierProvider<ChatService, List<Message>>((ref) {
  return ChatService();
});
