import 'package:flutter/material.dart';
import 'package:mobile/providers/post_filter_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/filter_nav_widget.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {

    final postFilter = context.watch<PostFilterProvider>();

    return Scaffold(
      backgroundColor: AppTheme.green4,
      appBar: AppbarWidget(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: AppTheme.white),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plant Community',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.green1,
                      ),
                    ),
                    //TODO: Change this button
                    TextButton(onPressed: () {}, child: Text('+ New Post')),
                  ],
                ),
                SizedBox(height: 8.0),
                FilterNavWidget(
                  onFilterChange: (filter) =>
                      context.read<PostFilterProvider>().setFilter(filter),
                  selectedFilter: postFilter.selectedFilter,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
