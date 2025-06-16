import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart'; // Import the Message model
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import for JSON encoding/decoding

// Define a StateNotifier for managing the chat messages and loading state
class ChatService extends StateNotifier<List<Message>> {
  ChatService() : super([
    // Initial placeholder messages (can be removed later)
    Message(text: 'Hello! How can I help you today?', sender: MessageSender.ai),
    Message(text: 'What is the best fertilizer for maize?', sender: MessageSender.user),
    Message(text: 'For maize, a balanced fertilizer like NPK 20-10-10 is often recommended...', sender: MessageSender.ai),
  ]);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Method to add a new message
  void addMessage(Message message) {
    state = [...state, message];
  }

  // Method to send message to backend AI and receive response
  Future<void> sendMessageToAI(String messageText) async {
    if (_isLoading) return; // Prevent sending multiple messages while waiting

    // Add user message to the chat
    addMessage(Message(text: messageText, sender: MessageSender.user));

    _setLoading(true); // Set loading state

    // TODO: Replace with your actual backend API URL
    final url = Uri.parse('YOUR_BACKEND_API_URL/chat');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': messageText}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final aiResponseText = responseBody['reply']; // Assuming the backend returns a JSON with a 'reply' field
        addMessage(Message(text: aiResponseText, sender: MessageSender.ai));
      } else {
        // Handle non-200 status codes
        addMessage(Message(text: 'Error: ${response.statusCode}', sender: MessageSender.ai));
      }
    } catch (e) {
      // Handle network or other errors
      addMessage(Message(text: 'Error: ${e.toString()}', sender: MessageSender.ai));
    } finally {
      _setLoading(false); // Reset loading state
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    // Notify listeners about the loading state change if needed in the UI
    // This might require a separate provider for loading state or updating the state object itself
    // For now, we'll rely on the UI watching the chatProvider and potentially checking isLoading
  }
}

// Define a StateNotifierProvider for the ChatService
final chatProvider = StateNotifierProvider<ChatService, List<Message>>((ref) {
  return ChatService();
});
