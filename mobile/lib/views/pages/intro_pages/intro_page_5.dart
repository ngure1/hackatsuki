import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/navigation/widget_tree.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/onboarding_button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage5 extends StatelessWidget {
  const IntroPage5({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.green3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/check-circle-svgrepo-com.svg',
            width: 100,
            height: 100,
          ),
          SizedBox(height: 32.0),
          Text(
            'Welcome to AIGRO!',
            style: AppTheme.titleLarge.copyWith(color: AppTheme.white),
          ),
          SizedBox(height: 8.0),
          Text(
            "Your profile is reay. Atart diagnosing plants, chatting with our AI, and connecting with the plant community",
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.lightGray2),
          ),
          SizedBox(height: 16.0),

          SizedBox(height: 32.0),
          OnboardingButtonWidget(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('seenOnboarding', true);

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => WidgetTree()),
              );
            },
            buttonText: 'Start using AIGROW',
            color: AppTheme.white,
            borderColor: AppTheme.white,
            buttonTextColor: AppTheme.green1,
          ),
        ],
      ),
    );
  }
}
