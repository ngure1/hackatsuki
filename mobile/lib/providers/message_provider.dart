import 'package:flutter/material.dart';
import 'package:mobile/data/models/message.dart';
import 'package:mobile/data/services/chat_service.dart';
import 'package:mobile/data/services/message_service.dart';
import 'package:mobile/providers/image_provider.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _service;

  final Map<String, List<Message>> _chatMessages = {};
  String? _activeChatId;

  MessageProvider(this._service);

  List<Message> get messages => _activeChatId != null
      ? List.unmodifiable(_chatMessages[_activeChatId] ?? [])
      : [];

  List<String> get chatIds => _chatMessages.keys.toList();

  void setActiveChat(String chatId) {
    _activeChatId = chatId;
    _chatMessages.putIfAbsent(chatId, () => []);

    notifyListeners();
  }

  Future<void> sendUserMessage(String text, {dynamic image}) async {
    if (_activeChatId == null) {
      throw Exception("Active chat must be set before sending a message");
    }

    final userMessage = Message.userMessage(
      text,
      image: image,
      chatId: _activeChatId,
    );
    _chatMessages[_activeChatId]!.add(userMessage);
    notifyListeners();

    try {
      Message? aiMessage;
      await for (final partial in _service.sendMessageStream(userMessage)) {
        if (aiMessage == null) {
          aiMessage = partial;
          _chatMessages[_activeChatId]!.add(aiMessage);
        } else {
          final lastIndex = _chatMessages[_activeChatId]!.length - 1;
          aiMessage = aiMessage.copyWith(text: partial.text);
          _chatMessages[_activeChatId]![lastIndex] = aiMessage;
        }
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      print(e);
    }
  }

  void startNewChat() {
    _activeChatId = null;
    notifyListeners();
  }

  String getPrefilledMessage(ImageProviderNotifier imageProvider) {
    if (imageProvider.selectedImage == null &&
        imageProvider.getFormattedPlantDetails().isEmpty) {
      return "";
    }

    final buffer = StringBuffer();

    buffer.writeln(
      "Please analyze this plant image for any diseases or issues.",
    );

    final details = imageProvider.getFormattedPlantDetails();
    if (details.isNotEmpty) {
      buffer.writeln();
      buffer.writeln("Additional details:");
      buffer.writeln(details);
    }

    return buffer.toString();
  }
}
