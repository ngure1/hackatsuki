import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/data/models/message.dart';
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/data/utils.dart';

class MessageService {
  final AuthService _authService;

  MessageService(this._authService);

  Future<List<Message>> fetchMessageForChat(String chatId) async {
    print('called: $chatId');
    if (_authService.accessToken == null) {
      throw Exception('Not authenicated. Cannot fetch messages');
    }

    final response = await _authService.get(
      ApiEndpoints.getChatMessages(chatId),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> messagesJson = body['messages'] ?? [];

      return messagesJson.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch messages for this chat. Status: ${response.body}',
      );
    }
  }

  Stream<Message> sendMessageStream(Message message) async* {
    if (message.chatId == null || message.chatId!.isEmpty) {
      throw Exception('Message must have a valid chatId');
    }

    final uri = Uri.parse(ApiEndpoints.diagnosis(message.chatId!));

    final request = http.MultipartRequest('POST', uri);
    request.fields['prompt'] = message.text;

    if (message.image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', message.image!.path),
      );
    }

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200) {
      final responseBody = await streamedResponse.stream.bytesToString();
      throw Exception(
        'Failed to send message; ${streamedResponse.statusCode}. Response: $responseBody)',
      );
    }

    final stream = streamedResponse.stream.transform(utf8.decoder);

    String buffer = '';
    await for (final chunk in stream) {
      buffer += chunk;
      yield Message.aiResponse(buffer);
    }
  }
}
