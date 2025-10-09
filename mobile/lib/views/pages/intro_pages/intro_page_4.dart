import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/onboarding_button_widget.dart';

class IntroPage4 extends StatefulWidget {
  const IntroPage4({super.key, required this.pageController});

  final PageController pageController;
  @override
  State<IntroPage4> createState() => _IntroPage4State();
}

class _IntroPage4State extends State<IntroPage4> {
  final List<Map<String, String>> plants = [
    {"icon": "🏠", "label": "Houseplants"},
    {"icon": "🥕", "label": "Vegetables"},
    {"icon": "🌿", "label": "Herbs"},
    {"icon": "🌸", "label": "Flowers"},
    {"icon": "🌵", "label": "Succulents"},
    {"icon": "🌳", "label": "Trees"},
  ];

  Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.green3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "What Plants Interest You?",
            style: AppTheme.titleLarge.copyWith(color: AppTheme.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Select your plant interests to get personalized content and connect with like-minded plant lovers.",
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedIndexes.contains(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedIndexes.remove(index);
                        } else {
                          selectedIndexes.add(index);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.green2 : AppTheme.green5,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            plants[index]["icon"]!,
                            style: AppTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plants[index]["label"]!,
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 32.0),
          OnboardingButtonWidget(
            onTap: ()=> widget.pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOutBack),
            buttonText: 'Back',
            color: AppTheme.green5,
            borderColor: AppTheme.lightGreen1,
            buttonTextColor: AppTheme.white,
          ),
          SizedBox(height: 8.0),
          OnboardingButtonWidget(
            onTap: () => widget.pageController.nextPage(
              duration: Duration(microseconds: 300),
              curve: Curves.easeInOut,
            ),
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
