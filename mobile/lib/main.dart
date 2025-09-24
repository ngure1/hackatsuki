import 'package:flutter/material.dart';
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/providers/blog_filter_provider.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/providers/image_provider.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/pages/onboarding_screen.dart';
import 'package:provider/provider.dart';

void main() {
  final authService = AuthService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..loadUser(),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ImageProviderNotifier()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => BlogFilterProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppTheme.appBarTheme,
        navigationBarTheme: AppTheme.navigationBarTheme,
      ),
      //home: WidgetTree(),
      home: OnboardingScreen(),
    );
  }
}
