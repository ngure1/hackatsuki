import 'package:flutter/material.dart';
import 'package:mobile/providers/blog_filter_provider.dart';
import 'package:mobile/views/widgets/blog_filter_button_widget.dart';
import 'package:provider/provider.dart';

class BlogFilterNavWidget extends StatelessWidget {
  const BlogFilterNavWidget({super.key});

  @override
  Widget build(BuildContext context) {

    final blogFilter = context.watch<BlogFilterProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          BlogFilterButtonWidget(
            onTap: () => context.read<BlogFilterProvider>().setFilter('All'),
            buttonText: 'All',
            isSelected: blogFilter.selectedFilter == 'All',
          ),
          SizedBox(width: 10.0),
          BlogFilterButtonWidget(
            onTap: () => context.read<BlogFilterProvider>().setFilter('Diseases'),
            buttonText: 'Diseases',
            isSelected: blogFilter.selectedFilter == 'Diseases',
          ),
          SizedBox(width: 10.0),
          BlogFilterButtonWidget(
            onTap: () => context.read<BlogFilterProvider>().setFilter('Pests'),
            buttonText: 'Pests',
            isSelected: blogFilter.selectedFilter == 'Pests',
          ),
          SizedBox(width: 10.0),
          BlogFilterButtonWidget(
            onTap: () => context.read<BlogFilterProvider>().setFilter('Care Tips'),
            buttonText: 'Care Tips',
            isSelected: blogFilter.selectedFilter == 'Care Tips',
          ),
        ],
      ),
    );
  }
}
