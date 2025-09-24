import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';
import 'package:mobile/views/widgets/onboarding_button_widget.dart';

class IntroPage3 extends StatefulWidget {
  const IntroPage3({super.key});

  @override
  State<IntroPage3> createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage3> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.green3),
      child: Column(
        children: [
          Text(
            'Where are you located?',
            style: AppTheme.titleLarge.copyWith(color: AppTheme.white),
          ),
          SizedBox(height: 8.0),
          Text(
            "We'll use your location to provide relevant plant care tips, ocal weather considerations, and nearby plant store recommendations",
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.lightGray2),
          ),
          SizedBox(height: 16.0),
          CustomContainerWidget(
            color: AppTheme.green5,
            horizontalPadding: 16.0,
            verticalPadding: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter your city or region",
                  style: AppTheme.labelMedium.copyWith(color: AppTheme.white),
                ),
                TextField(),
              ],
            ),
          ),
          SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Divider(thickness: 1.0)),
              SizedBox(width: 5),
              Text(
                'Continue with',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.lightGreen1,
                ),
              ),
              SizedBox(width: 5),
              Expanded(child: Divider(thickness: 1.0)),
            ],
          ),
          SizedBox(height: 32.0),

          OnboardingButtonWidget(
            onTap: () {},
            buttonText: 'Back',
            color: AppTheme.green5,
            borderColor: AppTheme.lightGreen1,
            buttonTextColor: AppTheme.white,
          ),
          SizedBox(height: 8.0),
          OnboardingButtonWidget(
            onTap: () {},
            buttonText: 'Continue',
            color: AppTheme.white,
            borderColor: AppTheme.white,
            buttonTextColor: AppTheme.green1,
          ),
        ],
      ),
    );
  }
}
