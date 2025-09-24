import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/pages/intro_pages/intro_page_1.dart';
import 'package:mobile/views/pages/intro_pages/intro_page_2.dart';
import 'package:mobile/views/pages/intro_pages/intro_page_3.dart';
import 'package:mobile/views/pages/intro_pages/intro_page_4.dart';
import 'package:mobile/views/pages/intro_pages/intro_page_5.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final int totalSteps = 5;
  int currentStep = 0;
  @override
  Widget build(BuildContext context) {
    double progress = (currentStep + 1) / 5;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.green3,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          children: [
            Padding(padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppTheme.green2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
                SizedBox(height: 8,),
                Text('Step ${currentStep + 1} of $totalSteps', style: AppTheme.labelMedium.copyWith(color: AppTheme.white),),
              ],
            ),),
            SizedBox(height: 32.0),
            Expanded(child: PageView(
              scrollBehavior: ScrollBehavior(),
              controller: _pageController,
              onPageChanged: (index) => setState(() {
                currentStep = index;
              }),
              children: [
                IntroPage1(),
                IntroPage2(),
                IntroPage3(),
                IntroPage4(),
                IntroPage5(),
              ],
            ),),
          ],
                ),
        )),
    );
  }
}
