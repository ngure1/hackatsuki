import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/data/models/message.dart';
import 'package:mobile/data/services/chat_service.dart';
import 'package:mobile/data/utils.dart';

class MessageService {
  final ChatService _chatService = ChatService();

  Future<Message> sendMessage(Message message) async {
    String? chatId = message.chatId;

    if (chatId == null || chatId.isEmpty) {
      final chat = await _chatService.createChat();
      chatId = chat.id;
      message = message.copyWith(chatId: chatId);
    }

    final uri = Uri.parse(ApiEndpoints.diagnosis(chatId!));

    final request = http.MultipartRequest('POST', uri);
    request.fields['prompt'] = message.text;

    if (message.image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', message.image!.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("➡️ Multipart fields: ${request.fields}");
    if (message.image != null) {
      print("➡️ Multipart file: ${message.image!.path}");
    }
    print("⬅️ Status: ${response.statusCode}");
    print("⬅️ Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to send message (status ${response.statusCode})');
    }

    final data = jsonDecode(response.body);

    return Message.aiResponse(
      data['text'] ?? "No response",
      imageUrl: data['imageUrl'],
    );
  }
}
