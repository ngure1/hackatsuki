import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/views/pages/home_page.dart';
import 'package:mobile/views/pages/ai_chat_page.dart';
import 'package:mobile/views/pages/community_page.dart';
import 'package:mobile/views/pages/blog_page.dart';
import 'package:mobile/views/pages/profile_page.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    final pages = const [
      HomePage(),
      AiChatPage(),
      CommunityPage(),
      BlogPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: nav.selectedPage,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.selectedPage,
        onDestinationSelected: (index) =>
            context.read<NavigationProvider>().selectPage(index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.chat_rounded), label: "Chat"),
          NavigationDestination(icon: Icon(Icons.people), label: "Community"),
          NavigationDestination(icon: Icon(Icons.note_add), label: "Blog"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
