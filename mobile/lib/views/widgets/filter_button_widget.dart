import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class FilterButtonWidget extends StatelessWidget {
  const FilterButtonWidget({
    super.key,
    required this.onTap,
    required this.buttonText,
    required this.isSelected,
  });

  final Function onTap;
  final String buttonText;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final buttonTextStyle = isSelected ? AppTheme.labelMedium.copyWith(color: AppTheme.white) : AppTheme.labelMedium.copyWith(color: AppTheme.buttonTextColor);
    final buttonBgColor = isSelected ? AppTheme.green3 : AppTheme.lightGray1;
    return GestureDetector(
      onTap: () => onTap(),
      child: CustomContainerWidget(
        color: buttonBgColor,
        horizontalPadding: 10.0,
        verticalPadding: 5.0,
        child: Text(buttonText, style: buttonTextStyle,),
      ),
    );
  }
}
