class Chat {
  final String? id;
  final String? message;

  const Chat({this.id, this.message});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['chat_id']?.toString(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': id,       
      'message': message,
    };
  }
}
