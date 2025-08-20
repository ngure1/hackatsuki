import 'package:flutter/material.dart';
import 'package:mobile/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
          NavigationDestination(icon: Icon(Icons.home,), label: 'Home',),
          NavigationDestination(icon: Icon(Icons.chat_rounded,), label: 'Chat',),
          NavigationDestination(icon: Icon(Icons.people,), label: 'Community',),
          NavigationDestination(icon: Icon(Icons.note_add,), label: 'Blog',),
        ],
        selectedIndex: selectedPage,
        onDestinationSelected: (value) => selectedPageNotifier.value = value,
        );
      }
    );
  }
}
