import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      'All',
      'Weekly Updates',
      'Plant Care',
      'Diseases',
    ];

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppbarWidget(),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              CustomContainerWidget(
                color: AppTheme.green2,
                horizontalPadding: 50.0,
                verticalPadding: 30.0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/plant_leaf.png',
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Plant Care Blog',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Expert tips, weekly updates, and everything you need to keep your plants thriving',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                isScrollable: true,
                labelStyle: AppTheme.labelLarge,
                labelColor: AppTheme.black,

                tabs: categories
                    .map((category) => Tab(text: category))
                    .toList(),
              ),
              // Expanded(
              //   child: TabBarView(
              //     children: categories.map((category) {
              //       final filteredCategory = category == "All"
              //           ? Placeholder()
              //           : Placeholder();
              //       if (filteredCategory.isEmpty) {
              //         return Center(child: Text('No blogs in this category'));
              //       }
              //       return ListView.builder(
              //         itemBuilder: (context, index) {
              //           return Placeholder();
              //         },
              //       );
              //     }).toList(),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
