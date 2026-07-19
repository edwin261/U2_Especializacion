import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config.dart';
import '../models/chat_message.dart';

class ChatSocketService {
  io.Socket? _socket;

  void connect({
    required String token,
    required void Function(List<ChatMessage>) onHistory,
    required void Function(ChatMessage) onMessage,
    required void Function(String) onError,
  }) {
    disconnect();

    _socket = io.io(
      AppConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': token,
          })
          .build(),
    );

    _socket!
      ..onConnect((_) {})
      ..onConnectError((error) => onError(error.toString()))
      ..onError((error) => onError(error.toString()))
      ..on('chat-history', (data) {
        if (data is List) {
          onHistory(
            data
                .whereType<Map>()
                .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item)))
                .toList(),
          );
        }
      })
      ..on('receive-message', (data) {
        if (data is Map) {
          onMessage(ChatMessage.fromJson(Map<String, dynamic>.from(data)));
        }
      })
      ..connect();
  }

  void sendMessage(String text) {
    _socket?.emit('new-message', {
      'text': text,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
