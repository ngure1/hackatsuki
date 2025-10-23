import 'dart:io';
import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String text;
  final String? chatId;
  final bool isUser;
  final DateTime timestamp;
  final File? image;
  final String? imageUrl;

  Message({
    required this.id,
    required this.text,
    this.chatId,
    required this.isUser,
    required this.timestamp,
    this.image,
    this.imageUrl,
  });

  static bool _mapSenderType(String senderType) {
    return senderType.toLowerCase() == 'user';
  }

  static String _cleanUserPrompt(String fullContent) {
    final imageRegex = RegExp(
      r'Image:\s*[\w\.-]+\s*\([^)]+\)\s*(\n)?',
      caseSensitive: false,
    );
    final detailsRegex = RegExp(
      r'\s*Additional details:[\s\S]*',
      caseSensitive: false,
    );
    final promptPrefixRegex = RegExp(r'Prompt:\s*', caseSensitive: false);

    String cleanedText = fullContent;

    cleanedText = cleanedText.replaceAll(imageRegex, '');

    cleanedText = cleanedText.replaceAll(detailsRegex, '');

    cleanedText = cleanedText.replaceAll(promptPrefixRegex, '');

    cleanedText = cleanedText.trim();

    return cleanedText.isEmpty ? "Image Sent" : cleanedText;
  }

  static String? _extractImageUrl(String content) {
    final regex = RegExp(
      r'Image: ([\w\.-]+)\s*\((?:size|prompt):',
      caseSensitive: false,
    );
    final match = regex.firstMatch(content);

    if (match != null && match.groupCount >= 1) {
      final filename = match.group(1);

      return 'http://127.0.0.1:8080/$filename';
    }
    return null;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    final chatId = json['chat_id']?.toString();
    final fullContent = json['content'] as String? ?? '';
    final senderType = json['sender_type'] as String? ?? 'model';
    final isUser = _mapSenderType(senderType);

    String textForDisplay;
    String? imageUrl;

    if (isUser) {
      imageUrl = _extractImageUrl(fullContent);
      textForDisplay = _cleanUserPrompt(fullContent);
    } else {
      textForDisplay = fullContent.trim();
    }

    return Message(
      id: json['id'] as String,
      text: textForDisplay,
      chatId: chatId,
      isUser: isUser,
      timestamp: DateTime.parse(json['created_at'] as String),
      image: null,
      imageUrl: imageUrl,
    );
  }

  factory Message.userMessage(String text, {File? image, String? chatId}) {
    return Message(
      id: _generateId(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      image: image,
      chatId: chatId,
    );
  }

  factory Message.aiResponse(String text, {String? imageUrl, String? chatId}) {
    return Message(
      id: _generateId(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      chatId: chatId,
    );
  }

  static String _generateId() {
    return const Uuid().v4();
  }

  Message copyWith({
    String? id,
    String? text,
    bool? isUser,
    File? image,
    DateTime? timestamp,
    String? chatId,
    String? imageUrl,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      chatId: chatId ?? this.chatId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
