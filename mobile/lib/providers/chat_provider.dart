import 'package:flutter/material.dart';
import 'package:mobile/data/models/chat.dart';
import 'package:mobile/data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service;

  ChatProvider(this._service);

  List<Chat> _chats = [];
  Chat? _activeChat;

  List<Chat> get chats => List.unmodifiable(_chats);
  Chat? get activeChat => _activeChat;

  Future<void> fetchChats() async {
    try {
      _chats = await _service.fetchChats();
      notifyListeners();
    } catch (e) {
      print("Failed to fetch chats: $e");
      rethrow;
    }
  }

  Future<void> createNewChat() async {
    try {
      final newChat = await _service.createChat();
      _chats.add(newChat);
      _activeChat = newChat;
      notifyListeners();
    } catch (e) {
      print("Failed to create chat: $e");
      rethrow;
    }
  }

  void setActiveChat(Chat chat) {
    _activeChat = chat;
    notifyListeners();
  }
}
