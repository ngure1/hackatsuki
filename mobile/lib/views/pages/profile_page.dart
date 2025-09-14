import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/blog_filter_nav_widget.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      backgroundColor: AppTheme.green4,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Column(
            children: [
              CustomContainerWidget(
                color: AppTheme.white,
                horizontalPadding: 8.0,
                verticalPadding: 16.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: BoxBorder.all(color: AppTheme.green3),
                      ),
                      child: Image.network(
                        'https://imgs.search.brave.com/lRgnt6rYfKVD7enX74ro6bOwFBWb0zqM-Id54BU7orc/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly93d3cu/cHJvZmlsZXBpY3R1/cmUuYWkvX25leHQv/aW1hZ2U_dXJsPS9y/ZXZpZXdzL3BmcF8x/LndlYnAmdz0yNTYm/cT03NSZkcGw9ZHBs/XzhMQldxTXVnWmNl/Y3VLczZ4dXAxejd6/b3pBd0g',
                        width: 75,
                        height: 75,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'John Doe',
                      style: AppTheme.labelLarge.copyWith(
                        color: AppTheme.green1,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '@John Doe',
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textGray,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        UserStatsWidget(stat: 5, statIdentifier: 'POSTS'),
                        SizedBox(width: 5.0),
                        UserStatsWidget(stat: 24, statIdentifier: 'HELPED'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              CustomContainerWidget(
                color: AppTheme.white,
                horizontalPadding: 16.0,
                verticalPadding: 16.0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/plant_leaf.png',
                          height: 20,
                          width: 20,
                        ),

                        Text(
                          'About Me',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.green2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                      textAlign: TextAlign.justify,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.buttonTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              CustomContainerWidget(
                color: AppTheme.white,
                horizontalPadding: 16.0,
                verticalPadding: 16.0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note_add),
                            Text(
                              'My Posts',
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.green1,
                              ),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: BlogFilterNavWidget())
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserStatsWidget extends StatelessWidget {
  const UserStatsWidget({
    super.key,
    required this.stat,
    required this.statIdentifier,
  });

  final int stat;
  final String statIdentifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$stat',
          style: AppTheme.labelLarge.copyWith(color: AppTheme.green1),
        ),
        Text(
          statIdentifier,
          style: AppTheme.labelSmall.copyWith(color: AppTheme.textGray),
        ),
      ],

    );
  }
}
