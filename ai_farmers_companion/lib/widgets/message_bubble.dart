import 'package:flutter/material.dart';

enum MessageSender { user, ai }

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.text,
    required this.sender,
  }) : super(key: key);

  final String text;
  final MessageSender sender;

  @override
  Widget build(BuildContext context) {
    final bool isUser = sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12.0),
            topRight: const Radius.circular(12.0),
            bottomLeft: isUser ? const Radius.circular(12.0) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(12.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
