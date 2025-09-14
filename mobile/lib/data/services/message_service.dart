import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/data/models/message.dart';
import 'package:mobile/data/services/chat_service.dart';
import 'package:mobile/data/utils.dart';

class MessageService {
  final ChatService _chatService = ChatService();

  Stream<Message> sendMessageStream(Message message) async* {
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

    if (streamedResponse.statusCode != 200) {
      throw Exception(
        'Failed to send message; ${streamedResponse.statusCode})',
      );
    }

    final stream = streamedResponse.stream.transform(utf8.decoder);

    String buffer = '';
    await for (final chunk in stream) {
      for (final char in chunk.split('')) {
        buffer += char;
        yield Message.aiResponse(buffer);
      }
    }
  }
}
