import 'package:flutter/material.dart';
import 'package:mobile/data/models/chat.dart';
import 'package:mobile/data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service;

  ChatProvider(this._service);

  List<Chat> _chats = [];
  Chat? _activeChat;
  bool _isLoading = false;

  List<Chat> get chats => List.unmodifiable(_chats);
  Chat? get activeChat => _activeChat;
  bool get isLoading => _isLoading;

  Future<void> fetchChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _chats = await _service.fetchChats();
      if (_activeChat == null && _chats.isNotEmpty) {
        _activeChat = _chats.first;
      }
      notifyListeners();
    } catch (e) {
      print("Failed to fetch chats: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Chat?> createNewChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newChat = await _service.createChat();

      _chats.insert(0, newChat);
      _activeChat = newChat;
      notifyListeners();
      return newChat;
    } catch (e) {
      print("Failed to create chat: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveChat(Chat chat) {
    if (_chats.any((c) => c.id == chat.id)) {
      _activeChat = chat;
      notifyListeners();
    } else {
      print("Chat not found in list: ${chat.id}");
    }
  }

  Chat? getChatById(String? chatId) {
    if (chatId == null) return null;

    try {
      return _chats.firstWhere((chat) => chat.id == chatId);
    } catch (_) {
      return null;
    }
  }
}
