import 'package:flutter/material.dart';

class NavigationContainerWidget extends StatelessWidget {
  const NavigationContainerWidget({
    super.key,
    required this.onTap,
    required this.title,
    required this.description,
    required this.icon,
  });

  final IconData icon;
  final String title;
  final String description;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          //TODO: figure out how to add the unique decoration to the first box
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            SizedBox(height: 10.0),
            Text(title, style: TextStyle(),),
            SizedBox(height: 10.0),
            Text(description, textAlign: TextAlign.center,style: TextStyle(),),
          ],
        ),
      ),
    );
  }
}