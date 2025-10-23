import 'package:flutter/material.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/pages/login_page.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';
import 'package:mobile/views/widgets/onboarding_button_widget.dart';
import 'package:mobile/views/widgets/text_input_widget.dart';
import 'package:provider/provider.dart';

class IntroPage1 extends StatefulWidget {
  const IntroPage1({super.key, required this.pageController});

  final PageController pageController;

  @override
  State<IntroPage1> createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.green3),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Welcome to AIGRO',
              style: AppTheme.titleLarge.copyWith(color: AppTheme.white),
            ),
            SizedBox(height: 8.0),
            Text(
              "Your AI-powered plant health companion. Let's set up your profile to provide personalized plant care advice.",
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
                    "What's your phone number?",
                    style: AppTheme.labelMedium.copyWith(color: AppTheme.white),
                  ),
                  TextInputWidget(
                    controller: _phoneController,
                    textInputType: TextInputType.phone,
                    hintText: 'e.g +254712345678',
                  ),
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
              onTap: () async {
                try {
                  await context.read<AuthProvider>().loginWithGoogle();
                } catch (e) {
                  print('Google login failed: $e');
                }
              },
              imageString: 'assets/images/google-color-svgrepo-com.svg',
              buttonText: 'Continue with Google',
              color: AppTheme.white,
              borderColor: AppTheme.white,
              buttonTextColor: AppTheme.black,
            ),

            SizedBox(height: 32.0),
            OnboardingButtonWidget(
              onTap: () {
                final phone = _phoneController.text.trim();
                final phoneRegEx = RegExp(r'^\+?\d{9,15}$');

                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter your phone number')),
                  );
                  return;
                }

                if (!phoneRegEx.hasMatch(phone)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid phone number'),
                    ),
                  );
                  return;
                }

                context.read<AuthProvider>().savePhoneNumber(phone);

                widget.pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              buttonText: 'Continue with Email',
              color: AppTheme.white,
              borderColor: AppTheme.white,
              buttonTextColor: AppTheme.green1,
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: AppTheme.labelMedium.copyWith(color: AppTheme.white),
                ),
                SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () async {
                    await context.read<AuthProvider>().markOnboardingCompleted();

                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    }
                  },
                  child: Text(
                    'sign in',
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.white,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
