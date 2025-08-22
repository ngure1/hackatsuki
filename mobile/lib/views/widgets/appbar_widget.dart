import 'package:flutter/material.dart';

 class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Image.asset('assets/images/aigrow_logo.png'), );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
