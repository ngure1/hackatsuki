import 'package:flutter/material.dart';
import 'package:mobile/providers/image_provider.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/build_message_bubble_widget.dart';
import 'package:provider/provider.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _inputController = TextEditingController();

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final imageProvider = context.read<ImageProviderNotifier>();
    final messageProvider = context.read<MessageProvider>();

    final initialMessage =
        messageProvider.prepareInitialMessage(imageProvider);

    final details = imageProvider.getFormattedPlantDetails();

    if (initialMessage.isNotEmpty || details.isNotEmpty) {
      _inputController.text = [
        if (initialMessage.isNotEmpty) initialMessage,
        if (details.isNotEmpty) details,
      ].join('\n\n');
    }
  });
}


  void _sendMessage() {
    final imageProvider = context.read<ImageProviderNotifier>();
    final messageProvider = context.read<MessageProvider>();
    final text = _inputController.text.trim();

    if (text.isEmpty && imageProvider.selectedImage == null) {
      return;
    }

    messageProvider.sendUserMessage(
      text,
      image: imageProvider.selectedImage,
    );

    _inputController.clear();
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
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      context
                          .read<ImageProviderNotifier>()
                          .clearImageDescription();
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
                icon: const Icon(Icons.send, color: Colors.green),
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
      appBar: const AppbarWidget(),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, provider, _) {
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = provider.messages[index];
                    return buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }
}
