import 'dart:io';

class Message {
  final String text;
  final String? chatId;
  final bool isUser;
  final DateTime timestamp;
  final File? image;
  final String? imageUrl;

  Message({
    required this.text,
    this.chatId,
    required this.isUser,
    required this.timestamp,
    this.image,
    this.imageUrl,
  });

  factory Message.userMessage(String text, {File? image, String? chatId}) {
    return Message(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      image: image,
      chatId: chatId,
    );
  }

  factory Message.aiResponse(String text, {String? imageUrl}) {
    return Message(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
  }

  Message copyWith({
    String? text,
    bool? isUser,
    File? image,
    DateTime? timestamp,
    String? id,
    String? chatId,
  }) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      chatId: chatId ?? this.chatId,
    );
  }
}
