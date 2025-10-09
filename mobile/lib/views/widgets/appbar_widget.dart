import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key, this.leading});

  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Row(
        children: [
          Image.asset('assets/images/logo.jpeg', width: 30, height: 30,),
          SizedBox(width: 8.0,),
          Text('AIGRO', style: AppTheme.labelMedium.copyWith(color: AppTheme.green1),)
        ],
      ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
