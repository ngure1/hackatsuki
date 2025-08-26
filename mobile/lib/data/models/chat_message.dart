import 'dart:io';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.image,
    this.id,
  });

  final String text;
  final bool isUser;
  final File? image;
  final DateTime timestamp;
  final String? id;

  factory ChatMessage.userMessage(String text, {File? image}) {
    return ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      image: image,
    );
  }

  factory ChatMessage.aiResponse(String text, {File? image}) {
    return ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      image: image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'imagePath': image?.path,
      'timestamp': timestamp.toIso8601String(),
      'id': id,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      image: json['imagePath'] != null ? File(json['imagePath']) : null,
      timestamp: DateTime.parse(json['timestamp']),
      id: json['id'],
    );
  }
}
