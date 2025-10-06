import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/data/models/message.dart';
import 'package:mobile/data/services/message_service.dart';
import 'package:mobile/providers/image_provider.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _service;

  final Map<String, List<Message>> _chatMessages = {};
  final Map<String, StreamSubscription> _activeStreams = {};
  final Map<String, bool> _chatLoadingStates = {};
  String? _activeChatId;

  MessageProvider(this._service);

  List<Message> get messages => _activeChatId != null
      ? List.unmodifiable(_chatMessages[_activeChatId] ?? [])
      : [];

  bool get isLoading => _activeChatId != null
      ? _chatLoadingStates[_activeChatId] ?? false
      : false;

  String? get activeChatId => _activeChatId;

  void setActiveChat(String chatId) {
    _activeChatId = chatId;
    _chatMessages.putIfAbsent(chatId, () => []);

    notifyListeners();
  }

  Future<void> sendUserMessage(String text, {dynamic image}) async {
    if (_activeChatId == null || _activeChatId!.isEmpty) {
      throw Exception("Active chat must be set before sending a message");
    }

    final chatId = _activeChatId!;

    final userMessage = Message.userMessage(text, image: image, chatId: chatId);

    _chatMessages[chatId]!.add(userMessage);
    notifyListeners();

    _chatLoadingStates[chatId] = true;
    notifyListeners();

    try {
      Message? aiMessage;
      final stream = _service.sendMessageStream(userMessage);
      final subscription = stream.listen(
        (partial) {
          if (aiMessage == null) {
            aiMessage = partial;
            _chatMessages[chatId]!.add(aiMessage!);
          } else {
            final lastIndex = _chatMessages[chatId]!.length - 1;
            aiMessage = aiMessage!.copyWith(text: partial.text);
            _chatMessages[chatId]![lastIndex] = aiMessage!;
          }
          notifyListeners();
        },
        onError: (error) {
          print('Error in messsage stream for chat $chatId: $error');
          _chatLoadingStates[chatId] = false;
          _activeStreams.remove(chatId);
          notifyListeners();
        },
        onDone: () {
          _chatLoadingStates[chatId] = false;
          _activeStreams.remove(chatId);
          notifyListeners();
        },
        cancelOnError: true,
      );

      _activeStreams[chatId] = subscription;
    } catch (e) {
      print("Failed to send message in chat $chatId: $e");
      _chatLoadingStates[chatId] = false;
      notifyListeners();
    }
  }

  void cancelStreamForChat(String chatId) {
    _activeStreams[chatId]?.cancel();
    _activeStreams.remove(chatId);
    _chatLoadingStates[chatId] = false;
    notifyListeners();
  }

  bool isChatLoading(String chatId) {
    return _chatLoadingStates[chatId] ?? false;
  }

  List<Message> getMessagesForChat(String chatId) {
    return List.unmodifiable(_chatMessages[chatId] ?? []);
  }

  void clearActiveChat() {
    _activeChatId = null;
    notifyListeners();
  }


  @override
  void dispose() {
    for (final subscription in _activeStreams.values) {
      subscription.cancel();
    }
    _activeStreams.clear();
    super.dispose();
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
