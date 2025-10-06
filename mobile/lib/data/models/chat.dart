class Chat {
  final String? id;
  final String? title;

  const Chat({this.id, this.title});

  factory Chat.fromJson(Map<String, dynamic> json) {
    try {
      return Chat(
        id: json['chat_id']?.toString() ?? 
            json['ID']?.toString() ?? 
            json['id']?.toString(),
        title: json['title'] as String? ?? 'New Chat',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  String toString() => 'Chat(id: $id, title: $title)';
}