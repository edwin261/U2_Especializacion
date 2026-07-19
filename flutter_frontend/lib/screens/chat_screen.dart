import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/chat_message.dart';
import '../services/chat_socket_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.session,
    required this.socketService,
    super.key,
  });

  final AuthSession session;
  final ChatSocketService socketService;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    widget.socketService.connect(
      token: widget.session.token,
      onHistory: (history) {
        setState(() {
          _messages
            ..clear()
            ..addAll(history);
          _error = '';
        });
      },
      onMessage: (message) {
        setState(() {
          _messages.add(message);
        });
      },
      onError: (error) {
        setState(() {
          _error = error;
        });
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    widget.socketService.sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_error.isNotEmpty)
          MaterialBanner(
            content: Text(_error),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _error = '';
                  });
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        Expanded(
          child: Container(
            color: const Color(0xffecf0f1),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: _messages[index],
                  currentUser: widget.session.username,
                );
              },
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Escriba un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _sendMessage,
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
