import 'package:flutter/material.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/providers/image_provider.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/build_message_bubble_widget.dart';
import 'package:mobile/views/widgets/chat_list_drawer.dart';
import 'package:provider/provider.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await WidgetsBinding.instance.endOfFrame;

    final chatProvider = context.read<ChatProvider>();
    final messageProvider = context.read<MessageProvider>();
    final imageProvider = context.read<ImageProviderNotifier>();

    try {
      if (chatProvider.chats.isEmpty) {
        await chatProvider.fetchChats();
      }

      if (chatProvider.activeChat == null) {
        if (chatProvider.chats.isNotEmpty) {
          chatProvider.setActiveChat(chatProvider.chats.first);
        } else {
          final newChat = await chatProvider.createNewChat();
          if (newChat != null) {
            chatProvider.setActiveChat(newChat);
          }
        }
      }

      final activeChat = chatProvider.activeChat;
      if (activeChat != null && activeChat.id != null) {
        await messageProvider.setActiveChat(activeChat.id!);

        final prefilledText = messageProvider.getPrefilledMessage(
          imageProvider,
        );
        if (prefilledText.isNotEmpty && _inputController.text.isEmpty) {
          _inputController.text = prefilledText;
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: _inputController.text.length),
          );
        }
      }
    } catch (e) {
      print("Error initializing chat: $e");
    } finally {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (!_isInitialized) {
      print('DEBUG: Chat not initialized yet');
      return;
    }
    ;

    final imageProvider = context.read<ImageProviderNotifier>();
    final messageProvider = context.read<MessageProvider>();
    final text = _inputController.text.trim();

    print(
      "DEBUG: Send button pressed - text: '$text', image: ${imageProvider.selectedImage != null}",
    );

    if (messageProvider.isLoading && messageProvider.activeChatId != null) {
      messageProvider.cancelStreamForChat(messageProvider.activeChatId!);
      return;
    }

    if (text.isEmpty && imageProvider.selectedImage == null) return;

    messageProvider.sendUserMessage(text, image: imageProvider.selectedImage);

    _inputController.clear();
    imageProvider.clear();
  }

  void _scrollListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
            );
        }
    });
}

@override
void didChangeDependencies() {
    super.didChangeDependencies();
    
    final messageProvider = context.watch<MessageProvider>();
    messageProvider.addListener(_scrollListener);
}

  Widget _buildInputBar() {
    return Consumer2<ImageProviderNotifier, MessageProvider>(
      builder: (context, imageProvider, messageProvider, _) {
        final currentChatId = messageProvider.activeChatId;
        final isCurrentChatLoading = messageProvider.isLoading;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageProvider.selectedImage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Stack(
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
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () => imageProvider.clear(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      enabled: !isCurrentChatLoading,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: (isCurrentChatLoading || currentChatId == null)
                          ? Colors.grey
                          : AppTheme.green1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isCurrentChatLoading ? Icons.stop_circle : Icons.send,
                        color: Colors.white,
                      ),
                      // Adjusted onPressed logic
                      onPressed: currentChatId == null
                          ? null
                          : (isCurrentChatLoading
                                ? () => messageProvider.cancelStreamForChat(
                                    currentChatId,
                                  )
                                : _sendMessage),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.green4,
      drawer: ChatListDrawer(),
      appBar: AppbarWidget(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu),
          ),
        ),
      ),
      body: !_isInitialized
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Consumer<MessageProvider>(
                    builder: (context, provider, _) {
                      if (provider.messages.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Start a conversation with AI',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Upload an image or ask about your plants',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(10),
                        itemCount:
                            provider.messages.length +
                            (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < provider.messages.length) {
                            final msg = provider.messages[index];

                            final contentWidget = provider.buildMessageWidget(
                              msg,
                            );

                            return buildMessageBubble(
                              msg,
                              contentWidget,
                              key: ValueKey(msg.id),
                            );
                          } else {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                key: const ValueKey(
                                  'streaming_loading_indicator',
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "🤖 Working...",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
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
