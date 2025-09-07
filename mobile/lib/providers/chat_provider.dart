import 'package:flutter/material.dart';
import 'package:mobile/data/models/chat.dart';
import 'package:mobile/data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  Chat? _activeChat;
  final ChatService _service = ChatService();

  Chat? get activeChat => _activeChat;

  Future<void> createNewChat() async {
    _activeChat = await _service.createChat();
    notifyListeners();
  }
}
