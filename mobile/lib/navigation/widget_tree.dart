import 'package:flutter/material.dart';
import 'package:mobile/navigation/app_navigator.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/views/pages/home_page.dart';
import 'package:mobile/views/pages/ai_chat_page.dart';
import 'package:mobile/views/pages/community_page.dart';
import 'package:mobile/views/pages/blog_page.dart';
import 'package:mobile/views/pages/profile_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  Route<dynamic> _generateRoute(RouteSettings settings) {
    Widget page;
    
    switch (settings.name) {
      case '/':
      case '/home':
        page = const HomePage();
        break;
      case '/chat':
        page = const AiChatPage();
        break;
      case '/community':
        page = const CommunityPage();
        break;
      case '/blog':
        page = const BlogPage();
        break;
      case '/profile':
        page = const ProfilePage();
        break;
      default:
        page = const HomePage();
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  String _getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/chat';
      case 2:
        return '/community';
      case 3:
        return '/blog';
      case 4:
        return '/profile';
      default:
        return '/home';
    }
  }

  void _onDestinationSelected(int index) {
    final nav = context.read<NavigationProvider>();
    
    if (nav.selectedPage == index) return;
    
    nav.selectPage(index);
    
    final route = _getRouteFromIndex(index);
    AppNavigator.navigatorKey.currentState?.pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, child) {
        return Scaffold(
          body: Navigator(
            key: AppNavigator.navigatorKey,
            initialRoute: '/home',
            onGenerateRoute: _generateRoute,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: nav.selectedPage,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: "Home"),
              NavigationDestination(icon: Icon(Icons.chat_rounded), label: "Chat"),
              NavigationDestination(icon: Icon(Icons.people), label: "Community"),
              NavigationDestination(icon: Icon(Icons.note_add), label: "Blog"),
              NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}