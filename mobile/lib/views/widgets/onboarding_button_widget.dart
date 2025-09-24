import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/theme.dart';

class OnboardingButtonWidget extends StatelessWidget {
  const OnboardingButtonWidget({
    super.key,
    required this.onTap,
    required this.buttonText,
    required this.color,
    required this.borderColor,
    required this.buttonTextColor,
    this.imageString,
  });

  final Function onTap;
  final String buttonText;
  final String? imageString;
  final Color color;
  final Color borderColor;
  final Color buttonTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.all(Radius.circular(16.0),),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(imageString != null) SvgPicture.asset(imageString!, width: 20.0, height: 20.0,),
          SizedBox(width: 5,),
          Text(
            buttonText,
            style: AppTheme.labelMedium.copyWith(color: buttonTextColor),
          ),
        ],
      ),
    );
  }
}
