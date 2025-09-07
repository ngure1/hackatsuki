import 'package:flutter/material.dart';
import 'package:mobile/data/models/message.dart';

Widget buildMessageBubble(Message msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.green[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.image != null)   
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Image.file(
                msg.image!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          if (msg.text.isNotEmpty)   
            Text(msg.text),
          ],
        ),
      ),
    );
  }
