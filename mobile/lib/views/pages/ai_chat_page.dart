import 'package:flutter/material.dart';
import 'package:mobile/data/models/chat_message.dart';
import 'package:mobile/providers/image_provider.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/build_message_bubble_widget.dart';
import 'package:mobile/views/widgets/navbar_widget.dart';
import 'package:provider/provider.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareInitialMessage());
  }

  void _prepareInitialMessage() {
    final imageProvider = context.read<ImageProviderNotifier>();

    if (imageProvider.selectedImage != null) {
      final plantDetails = imageProvider.getFormattedPlantDetails();

      String initialMessage =
          "Please analyze this plant image for any diseases or issues.";

      if (plantDetails.isNotEmpty) {
        initialMessage += "\n\nAdditional details:\n$plantDetails";
      }

      _inputController.text = initialMessage;
    }
  }

  void _sendMessage() {
    final imageProvider = context.read<ImageProviderNotifier>();
    final text = _inputController.text.trim();

    if (text.isEmpty && imageProvider.selectedImage == null) {
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          image: imageProvider.selectedImage,
          timestamp: DateTime.now(),
          isUser: true,
        ),
      );
      _inputController.clear();
    });

    imageProvider.clearImageDescription();
  }

  

  Widget _buildInputBar() {
    final imageProvider = context.watch<ImageProviderNotifier>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageProvider.selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    imageProvider.selectedImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      context.read<ImageProviderNotifier>().clearImageDescription();
                    },
                  ),
                ),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.green),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      bottomNavigationBar: NavbarWidget(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return buildMessageBubble(msg);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }
}
