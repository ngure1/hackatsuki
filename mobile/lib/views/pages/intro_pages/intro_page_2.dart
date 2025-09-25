import 'package:flutter/material.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';
import 'package:mobile/views/widgets/onboarding_button_widget.dart';
import 'package:mobile/views/widgets/text_input_widget.dart';
import 'package:provider/provider.dart';

class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key, required this.pageController});

  final PageController pageController;
  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptSignup() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      if (mounted) {
        widget.pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
              "Create an account to streamline your AIGROW experience.",
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
                    "What's your first name?",
                    style: AppTheme.labelMedium.copyWith(color: AppTheme.white),
                  ),
                  SizedBox(height: 8.0),
                  TextInputWidget(
                    controller: _firstNameController,
                    textInputType: TextInputType.text,
                    hintText: 'e.g John',
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "What's your last name?",
                    style: AppTheme.labelMedium.copyWith(color: AppTheme.white),
                  ),
                  TextInputWidget(
                    controller: _lastNameController,
                    textInputType: TextInputType.text,
                    hintText: 'e.g Doe',
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "What's your email address?",
                    style: AppTheme.labelMedium.copyWith(color: AppTheme.white),
                  ),
                  TextInputWidget(
                    controller: _emailController,
                    textInputType: TextInputType.emailAddress,
                    hintText: 'e.g. johndoe@gmail.com',
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "What will your password be?",
                    style: AppTheme.labelMedium.copyWith(color: AppTheme.white),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray2),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.lightGray1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.green1),
                      ),
                      hintText: 'e.g John',
                      hintStyle: AppTheme.bodySmall.copyWith(
                        color: AppTheme.lightGray1,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
            SizedBox(height: 16.0),

            OnboardingButtonWidget(
              onTap: () {
                widget.pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOutBack,
                );
              },
              buttonText: 'Back',
              color: AppTheme.green5,
              borderColor: AppTheme.lightGreen1,
              buttonTextColor: AppTheme.white,
            ),
            SizedBox(height: 8.0),
            OnboardingButtonWidget(
              onTap: _isLoading ? null : _attemptSignup,
              buttonText: 'Continue',
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
                  onTap: () {},
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
