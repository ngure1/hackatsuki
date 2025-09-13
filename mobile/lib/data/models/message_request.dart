import 'dart:io';

class MessageRequest {
  MessageRequest({required this.image, required this.prompt});
  final String prompt;
  final File? image;

  Map<String, dynamic> toJson() {
    return {'prompt': prompt};
  }
}
