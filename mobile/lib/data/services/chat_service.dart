import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/data/models/chat.dart';
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/data/utils.dart';

class ChatService {
  final AuthService _authService;

  ChatService(this._authService);

  Future<Chat> createChat() async {
    final response = await http.post(Uri.parse(ApiEndpoints.chats));
    if (response.statusCode == 201) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create chat');
    }
  }

  Future<List<Chat>> fetchChats() async {
    final response = await _authService.get(ApiEndpoints.chats);
    if (response.statusCode == 200) {
      final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      return data.map((json) => Chat.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch chats: ${response.body}');
    }
  }
}
