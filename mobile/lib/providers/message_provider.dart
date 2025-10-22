import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';
import 'package:mobile/data/models/message.dart';
import 'package:mobile/data/services/message_service.dart';
import 'package:mobile/providers/image_provider.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _service;

  final Map<String, List<Message>> _chatMessages = {};
  final Map<String, StreamSubscription> _activeStreams = {};
  final Map<String, bool> _chatLoadingStates = {};
  final Map<String, String> _streamingMessageIds = {};
  final Map<String, StreamingTextController> _controllers = {};

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
            aiMessage = Message.aiResponse('', chatId: chatId);
            _controllers[aiMessage!.id] = StreamingTextController();
            _chatMessages[chatId]!.add(aiMessage!);
            _streamingMessageIds[chatId] = aiMessage!.id;
          }

          final lastIndex = _chatMessages[chatId]!.length - 1;
          aiMessage = aiMessage!.copyWith(text: partial.text);
          _chatMessages[chatId]![lastIndex] = aiMessage!;

          notifyListeners();
        },
        onError: (error) {
          print('Error in message stream for chat $chatId: $error');
          _cleanupStream(chatId);
        },
        onDone: () {
          _streamingMessageIds.remove(chatId);
          _cleanupStream(chatId);
        },
        cancelOnError: true,
      );

      _activeStreams[chatId] = subscription;
    } catch (e) {
      print("Failed to send message in chat $chatId: $e");
      _cleanupStream(chatId);
    }
  }

  void _cleanupStream(String chatId) {
    _chatLoadingStates[chatId] = false;
    _activeStreams.remove(chatId);

    final messageId = _streamingMessageIds[chatId];
    if (messageId != null) {
      _controllers[messageId]?.dispose();
      _controllers.remove(messageId);
      _streamingMessageIds.remove(chatId);
    }

    notifyListeners();
  }

  Widget buildMessageWidget(Message message) {
    final isStreaming =
        _activeChatId != null &&
        _streamingMessageIds[_activeChatId] == message.id;

    if (message.isUser) {
      return SelectableText(
        message.text,
        style: const TextStyle(fontSize: 16, height: 1.5),
      );
    }

    if (isStreaming) {
      final controller = _controllers[message.id];

      if (controller == null) {
        return StreamingTextMarkdown.instant(
          text: message.text,
          markdownEnabled: true,
          latexEnabled: true,
        );
      }

      return StreamingTextMarkdown.claude(
        text: message.text,
        controller: controller,
        markdownEnabled: true,
        latexEnabled: true,
        onComplete: () => debugPrint('Message ${message.id} streaming complete'),
      );
    }

    return StreamingTextMarkdown.instant(
      text: message.text,
      markdownEnabled: true,
      latexEnabled: true,
    );
  }

  void cancelStreamForChat(String chatId) {
    _activeStreams[chatId]?.cancel();
    _streamingMessageIds.remove(chatId);
    _cleanupStream(chatId);
  }

  bool isChatLoading(String chatId) => _chatLoadingStates[chatId] ?? false;

  List<Message> getMessagesForChat(String chatId) =>
      List.unmodifiable(_chatMessages[chatId] ?? []);

  void clearActiveChat() {
    _activeChatId = null;
    _streamingMessageIds.clear();
    _controllers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _activeStreams.values) {
      subscription.cancel();
    }
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _streamingMessageIds.clear();
    _controllers.clear();
    super.dispose();
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
