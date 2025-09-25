import 'package:flutter/material.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/views/pages/ai_chat_page.dart';
import 'package:provider/provider.dart';

class ChatListDrawer extends StatelessWidget {
  const ChatListDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          final chats = provider.chats;
          return Column(
            children: [
              DrawerHeader(child: Text('Your Chats')),
              Expanded(
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      title: Text('Chat ${index + 1}'),
                      onTap: () {
                        provider.setActiveChat(chat);
                        context.read<MessageProvider>().setActiveChat(chat.id!);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AiChatPage()),
                        );
                      },
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('New Chat'),
                onTap: () async {
                  await provider.createNewChat();
                  final newChat = provider.activeChat;

                  if (newChat != null) {
                    context.read<MessageProvider>().setActiveChat(newChat.id!);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
