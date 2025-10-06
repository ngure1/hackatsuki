import 'package:flutter/material.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/pages/ai_chat_page.dart';
import 'package:provider/provider.dart';

class ChatListDrawer extends StatelessWidget {
  const ChatListDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer2<ChatProvider, MessageProvider>(
        builder: (context, chatProvider, messageProvider, _) {
          final chats = chatProvider.chats;
          return Column(
            children: [
              DrawerHeader(child: Text('Your Chats')),
              chatProvider.isLoading
                  ? LinearProgressIndicator()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          final isActive =
                              chatProvider.activeChat?.id == chat.id;
                          final isLoading = messageProvider.isChatLoading(
                            chat.id ?? '',
                          );
                          final hasMessages = messageProvider
                              .getMessagesForChat(chat.id ?? '')
                              .isNotEmpty;
                          return ListTile(
                            title: Text('Chat ${index + 1}'),
                            subtitle: hasMessages
                                ? Text(
                                    '${messageProvider.getMessagesForChat(chat.id ?? '').length} messages',
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLoading)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(),
                                  ),
                                if (isActive)
                                  Icon(
                                    Icons.check,
                                    color: AppTheme.green2,
                                    size: 20,
                                  ),
                              ],
                            ),
                            onTap: () async {
                              try {
                                chatProvider.setActiveChat(chat);
                                messageProvider.setActiveChat(chat.id!);

                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AiChatPage(),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error switching chat: $e'),
                                  ),
                                );
                              }
                            },
                            onLongPress: isLoading
                                ? () {
                                    messageProvider.cancelStreamForChat(
                                      chat.id!,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cancelled response'),
                                      ),
                                    );
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Chat'),
                onTap: () async {
                  try {
                    final newChat = await chatProvider.createNewChat();
                    if (newChat != null && newChat.id != null) {
                      chatProvider.setActiveChat(newChat);
                      messageProvider.setActiveChat(newChat.id!);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatPage()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create a new chat: $e'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
