import 'package:flutter/material.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key, this.leading});

  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Image.asset('assets/images/aigrow_logo.png'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
