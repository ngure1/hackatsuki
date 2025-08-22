import 'package:flutter/material.dart';

class CustomContainerWidget extends StatelessWidget {
  const CustomContainerWidget({
    super.key,
    required this.color,
    this.width,
    this.height,
    required this.child,
    required this.horizontalPadding,
    required this.verticalPadding,
    this.border
  });

  final Color color;
  final double? width;
  final double? height;
  final Widget child;
  final double horizontalPadding;
  final double verticalPadding;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25.0),
        border: border,
      ),
      child: child,
    );
  }
}
