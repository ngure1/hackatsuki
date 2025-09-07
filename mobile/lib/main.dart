import 'package:flutter/material.dart';
import 'package:mobile/navigation/widget_tree.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/providers/image_provider.dart';
import 'package:mobile/providers/message_provider.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ImageProviderNotifier()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override  
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppTheme.appBarTheme,
      ),
      home: WidgetTree(),
    );
  }
}
