import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';

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
