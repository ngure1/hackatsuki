import 'package:flutter/material.dart';
import 'package:mobile/data/models/message.dart';
import 'package:mobile/data/services/message_service.dart';
import 'package:mobile/providers/image_provider.dart';

class MessageProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  final MessageService _service = MessageService();

  List<Message> get messages => List.unmodifiable(_messages);

  Future<void> sendUserMessage(String text, {dynamic image}) async {
    final userMessage = Message.userMessage(text, image: image);
    _messages.add(userMessage);
    notifyListeners();

    try {
      final aiMessage = await _service.sendMessage(userMessage);
      _messages.add(aiMessage);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  String getPrefilledMessage(ImageProviderNotifier imageProvider) {
  if (imageProvider.selectedImage == null &&
      imageProvider.getFormattedPlantDetails().isEmpty) {
    return "";
  }

  final buffer = StringBuffer();

  buffer.writeln("Please analyze this plant image for any diseases or issues.");

  final details = imageProvider.getFormattedPlantDetails();
  if (details.isNotEmpty) {
    buffer.writeln();
    buffer.writeln("Additional details:");
    buffer.writeln(details);
  }

  return buffer.toString();
}


  
}
