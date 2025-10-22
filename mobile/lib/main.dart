import 'package:flutter/material.dart';
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/data/services/chat_service.dart';
import 'package:mobile/data/services/message_service.dart';
import 'package:mobile/data/services/post_service.dart';
import 'package:mobile/navigation/widget_tree.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/providers/blog_filter_provider.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/providers/comment_provider.dart';
import 'package:mobile/providers/image_provider.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/providers/post_filter_provider.dart';
import 'package:mobile/providers/post_image_provider.dart';
import 'package:mobile/providers/post_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/pages/login_page.dart';
import 'package:mobile/views/pages/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final authService = AuthService();
  final chatService = ChatService(authService);
  final messageService = MessageService();
  final postService = PostService(authService);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..loadUser(),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ImageProviderNotifier()),
        ChangeNotifierProvider(create: (_) => ChatProvider(chatService)),
        ChangeNotifierProvider(create: (_) => MessageProvider(messageService)),
        ChangeNotifierProvider(create: (_) => BlogFilterProvider()),
        ChangeNotifierProvider(create: (_) => PostFilterProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider(postService)),
        ChangeNotifierProvider(create: (_) => CommentProvider(postService)),
        ChangeNotifierProvider(create: (_)=> PostImageProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _showOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') != true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _showOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final showOnboarding = snapshot.data!;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppTheme.appBarTheme,
            navigationBarTheme: AppTheme.navigationBarTheme,
          ),
          home: showOnboarding
              ? OnboardingScreen()
              : context.watch<AuthProvider>().isLoggedIn
              ? WidgetTree()
              : LoginPage(),
        );
      },
    );
  }
}
