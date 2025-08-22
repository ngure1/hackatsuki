import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:mobile/theme.dart";
import "package:mobile/views/widgets/appbar_widget.dart";
import "package:mobile/views/widgets/custom_container_widget.dart";
import "package:mobile/views/widgets/navbar_widget.dart";
import "package:mobile/views/widgets/navigation_container_widget.dart";
import "package:mobile/views/widgets/recent_activity_card_widget.dart";
import "package:mobile/views/widgets/stat_card_widget.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _diseaseSymptomController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      bottomNavigationBar: NavbarWidget(),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(gradient: AppTheme.homePageGradient),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomContainerWidget(
                    color: AppTheme.green3,
                    width: double.infinity,
                    horizontalPadding: 20.0,
                    verticalPadding: 20.0,
                    child: Column(
                      children: [
                        SizedBox(height: 10.0),
                        Image.asset(
                          'assets/images/plant_image.png',
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Welcome to AIGRO',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Your AI-powered plant health companion',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  GridView.count(
                    primary: false,
                    shrinkWrap: true,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    crossAxisCount: 2,
                    childAspectRatio: 2.0,
                    children: [
                      //TODO: Refactor the first child of this grid
                      NavigationContainerWidget(
                        onTap: () {},
                        icon: 'assets/images/camera_shutter_icon.png',
                        title: 'Scan Plant',
                        description:
                            'Take or upload photo for instant AI diagnosis',
                      ),
                      NavigationContainerWidget(
                        onTap: () {},
                        icon: 'assets/images/search_icon.png',
                        title: 'Search Symptoms',
                        description: 'Describe what you see on your plant',
                      ),
                      NavigationContainerWidget(
                        onTap: () {},
                        icon: 'assets/images/message_icon.png',
                        title: 'Ask Expert',
                        description: 'Chat with AI plant specialist',
                      ),
                      NavigationContainerWidget(
                        onTap: () {},
                        icon: 'assets/images/people_icon.png',
                        title: 'Community',
                        description: 'Get help from plant lovers',
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  CustomContainerWidget(
                    color: AppTheme.white,
                    horizontalPadding: 20.0,
                    verticalPadding: 20.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/microscope_icon.png'),
                            SizedBox(width: 5.0),
                            Text(
                              'AI Plant Diagnosis',
                              style: AppTheme.titleLarge.copyWith(
                                color: AppTheme.green1,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Get instant diagnosis with out advanced plant diagnosis AI',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodySmall,
                        ),
                        SizedBox(height: 15.0),

                        DottedBorder(
                          options: CircularDottedBorderOptions(
                            padding: EdgeInsets.all(0),
                            dashPattern: [7, 4],
                            color: AppTheme.green2,
                            strokeWidth: 2,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: AppTheme.green4,
                            ),
                            child: Image.asset(
                              'assets/images/camera_shutter_icon.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text('Take or Upload Photo'),
                        SizedBox(height: 5.0),
                        Text('AI will analyze your plant in seconds'),
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.green3,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/camera_icon.png',
                                    width: 15.0,
                                    height: 15.0,
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    'Camera',
                                    style: AppTheme.buttonText.copyWith(
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5.0),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.gray1,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/folder_icon.png',
                                    width: 15.0,
                                    height: 15.0,
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    'Gallery',
                                    style: AppTheme.buttonText.copyWith(
                                      color: AppTheme.green1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Divider(thickness: 1.0)),
                            SizedBox(width: 5),
                            Text(
                              'OR DESCRIBE SYMPTOMS',
                              style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.gray3,
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(child: Divider(thickness: 1.0)),
                          ],
                        ),
                        TextField(
                          controller: _diseaseSymptomController,
                          onEditingComplete: () {
                            setState(() {});
                            _diseaseSymptomController.clear();
                          },
                          
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.0),
                  CustomContainerWidget(
                    color: AppTheme.green4,
                    horizontalPadding: 10.0,
                    verticalPadding: 10.0,
                    border: BoxBorder.all(color: AppTheme.lightGray1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatCardWidget(
                          stat: '10k+',
                          description: 'Plants Diagnosed',
                        ),
                        StatCardWidget(
                          stat: '95%',
                          description: 'Accuracy Rate',
                        ),
                        StatCardWidget(
                          stat: '500+',
                          description: 'Plants Diseases',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  CustomContainerWidget(
                    color: AppTheme.white,
                    horizontalPadding: 10.0,
                    verticalPadding: 10.0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/images/chart_icon.png'),
                                SizedBox(width: 5),
                                Text(
                                  'Your recent activity',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: AppTheme.green1,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'View All',
                                style: AppTheme.buttonText.copyWith(
                                  color: AppTheme.green3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        RecentActivityCardWidget(
                          imageUrl: 'assets/images/folder_icon.png',
                          plantName: 'Tomato Plant',
                          diseaseSummary: 'Light blight detected',
                          time: '2 hours ago',
                          accuracy: '95',
                        ),
                        SizedBox(height: 10.0),
                        RecentActivityCardWidget(
                          imageUrl: 'assets/images/folder_icon.png',
                          plantName: 'Tomato Plant',
                          diseaseSummary: 'Light blight detected',
                          time: '2 hours ago',
                          accuracy: '95',
                        ),
                        SizedBox(height: 10.0),
                        RecentActivityCardWidget(
                          imageUrl: 'assets/images/folder_icon.png',
                          plantName: 'Tomato Plant',
                          diseaseSummary: 'Light blight detected',
                          time: '2 hours ago',
                          accuracy: '95',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
