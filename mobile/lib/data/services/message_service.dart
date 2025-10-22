import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/data/models/message.dart';
import 'package:mobile/data/utils.dart';

class MessageService {

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
      throw Exception(
        'Failed to send message; ${streamedResponse.headers})',
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
