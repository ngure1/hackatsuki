import 'package:flutter/material.dart';
import 'package:mobile/navigation/widget_tree.dart';
import 'package:mobile/theme.dart';

void main() {
  runApp(MyApp());
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
