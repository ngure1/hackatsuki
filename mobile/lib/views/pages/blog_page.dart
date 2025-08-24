import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/navbar_widget.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      bottomNavigationBar: NavbarWidget(),
      body: Placeholder(),
    );
  }
}
