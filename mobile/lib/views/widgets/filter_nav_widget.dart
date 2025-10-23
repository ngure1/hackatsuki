import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/filter_button_widget.dart';

class FilterNavWidget extends StatelessWidget {
  final String selectedFilter;
  final void Function(String) onFilterChange;

  const FilterNavWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterButtonWidget(
          onTap: () => onFilterChange('All'),
          buttonText: 'All',
          isSelected: selectedFilter == 'All',
        ),
        const SizedBox(width: 10.0),
        FilterButtonWidget(
          onTap: () => onFilterChange('Diseases'),
          buttonText: 'Diseases',
          isSelected: selectedFilter == 'Diseases',
        ),
        const SizedBox(width: 10.0),
        FilterButtonWidget(
          onTap: () => onFilterChange('Pests'),
          buttonText: 'Pests',
          isSelected: selectedFilter == 'Pests',
        ),
        const SizedBox(width: 10.0),
        FilterButtonWidget(
          onTap: () => onFilterChange('Care Tips'),
          buttonText: 'Care Tips',
          isSelected: selectedFilter == 'Care Tips',
        ),
      ],
    );
  }
}
