import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/data/models/chat.dart';
import 'package:mobile/data/utils.dart';

class ChatService {
  Future<Chat> createChat() async {
    final response = await http.post(Uri.parse(ApiEndpoints.chats));
    if (response.statusCode == 201) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create chat');
    }
  }
}
