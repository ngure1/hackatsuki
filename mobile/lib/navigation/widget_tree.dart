import 'package:flutter/material.dart';
import 'package:mobile/data/notifiers.dart';
import 'package:mobile/views/pages/ai_chat_page.dart';
import 'package:mobile/views/pages/blog_page.dart';
import 'package:mobile/views/pages/community_page.dart';
import 'package:mobile/views/pages/home_page.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [HomePage(), AiChatPage(), CommunityPage(), BlogPage()];
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedIndex, child) {
        return pages.elementAt(selectedIndex);
      },
    );
  }
}
