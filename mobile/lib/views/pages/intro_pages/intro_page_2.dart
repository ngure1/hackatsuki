import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';
import 'package:mobile/views/widgets/onboarding_button_widget.dart';

class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key});

  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: AppTheme.green3),
        child: Column(
          children: [
            Text(
              'Add your details',
              style: AppTheme.titleLarge.copyWith(color: AppTheme.white),
            ),
            SizedBox(height: 8.0),
            Text(
              "Create an account to streamline your AIGROW experience.", textAlign: TextAlign.center,
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
                  Text("What's your first name?", style: AppTheme.labelMedium.copyWith(color: AppTheme.white),), 
                  TextField(),
                  SizedBox(height: 16.0,),
                  Text("What's your last name?", style: AppTheme.labelMedium.copyWith(color: AppTheme.white),), 
                  TextField(),
                  SizedBox(height: 16.0,),
                  Text("What's your email address?", style: AppTheme.labelMedium.copyWith(color: AppTheme.white),), 
                  TextField(),
                  SizedBox(height: 16.0,),
                  Text("What will your password be?", style: AppTheme.labelMedium.copyWith(color: AppTheme.white),), 
                  TextField(),
                  SizedBox(height: 16.0,),
                  Text("Re-enter your password", style: AppTheme.labelMedium.copyWith(color: AppTheme.white),), 
                  TextField(),
                  SizedBox(height: 16.0,),
                  ],
              ),
            ),
            SizedBox(height: 16.0),
            
        
            OnboardingButtonWidget(
            onTap: () {},
            buttonText: 'Back',
            color: AppTheme.green5,
            borderColor: AppTheme.lightGreen1,
            buttonTextColor: AppTheme.white,
          ),
            SizedBox(height: 8.0,),
            OnboardingButtonWidget(
              onTap: () {},
              buttonText: 'Continue',
              color: AppTheme.white,
              borderColor: AppTheme.white,
              buttonTextColor: AppTheme.green1,
            ),
            SizedBox(height: 24.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?', style: AppTheme.labelMedium.copyWith(color: AppTheme.white),),
                SizedBox(width: 8.0,),
                GestureDetector(
                  onTap: () {},
                  child: Text('sign in', style: AppTheme.labelLarge.copyWith(color: AppTheme.white, decoration: TextDecoration.underline, decorationColor: AppTheme.white),),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
