import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class NavigationContainerWidget extends StatelessWidget {
  const NavigationContainerWidget({
    super.key,
    required this.onTap,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String icon;
  final String title;
  final String description;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap,
      child: CustomContainerWidget(
        color: AppTheme.white,
        horizontalPadding: 10.0,
        verticalPadding: 10.0,
        border: BoxBorder.all(
          color: AppTheme.gray1,

        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 20, height: 20,),
            SizedBox(height: 8.0),
            Text(title, style: AppTheme.titleSmall.copyWith(color: AppTheme.green1)),
            SizedBox(height: 5.0),
            Text(description, textAlign: TextAlign.center, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
