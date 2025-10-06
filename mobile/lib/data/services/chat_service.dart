import 'dart:convert';

import 'package:mobile/data/models/chat.dart';
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/data/utils.dart';

class ChatService {
  final AuthService _authService;

  ChatService(this._authService);

  Future<Chat> createChat() async {
    if(_authService.accessToken == null) {
      throw Exception('Not authenticated - cannot create chat');
    }

    final response = await _authService.post(ApiEndpoints.chats, {});
    if (response.statusCode == 201) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create chat');
    }
  }

  Future<List<Chat>> fetchChats() async {

    if (_authService.accessToken == null) {
      throw Exception('Not authenticated - cannot fetch chats');
    }
    
    final response = await _authService.get(ApiEndpoints.chats);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = List<Map<String, dynamic>>.from(body['chats']);
      return data.map((json) => Chat.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch chats: ${response.body}');
    }
  }
}
