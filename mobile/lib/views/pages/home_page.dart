import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:mobile/theme.dart";
import "package:mobile/views/widgets/appbar_widget.dart";
import "package:mobile/views/widgets/custom_container_widget.dart";
import "package:mobile/views/widgets/navigation_container_widget.dart";
import "package:mobile/views/widgets/recent_activity_card_widget.dart";
import "package:mobile/views/widgets/stat_card_widget.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.homePageGradient
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomContainerWidget(
                    color: AppTheme.buttonGreen,
                    width: double.infinity,
                    horizontalPadding: 15.0,
                    verticalPadding: 15.0,
                    child: Column(
                      children: [
                        SizedBox(height: 10.0),
                        Image.asset('assets/images/plant_image.png', width: 30, height: 30,),
                        SizedBox(height: 10.0),
                        Text(
                          'Welcome to AIGRO',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: AppTheme.fontSize3XL,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text('Your AI-powered plant health companion'),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.0),
                  GridView.count(
                    primary: false,
                    shrinkWrap: true,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    crossAxisCount: 2,
                    childAspectRatio: 2.0,
                    children: [
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
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //TODO - add a microscope icon
                            Text('AI Plant Diagnosis'),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        DottedBorder(
                          options: CircularDottedBorderOptions(
                            padding: const EdgeInsets.all(10.0),
                            dashPattern: [3, 1],
                          ),
                          child: Icon(Icons.camera_alt),
                        ),
                        SizedBox(height: 10.0),
                        Text('Take or Upload Photo'),
                        SizedBox(height: 10.0),
                        Text('AI will analyze your plant in seconds'),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.camera_alt),
                              label: Text('Camera'),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.image),
                              label: Text('Gallery'),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Divider(thickness: 5.0, height: 20.0),
                            Text('or describe symptoms'),
                            Divider(thickness: 5.0, height: 20.0),
                          ],
                        ),
                        //TODO: Implement the text input
                      ],
                    ),
                  ),
          
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatCardWidget(
                          stat: '10k+',
                          description: 'Plants Diagnosed',
                        ),
                        StatCardWidget(stat: '95%', description: 'Accuracy Rate'),
                        StatCardWidget(
                          stat: '500+',
                          description: 'Plants Diseases',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.insert_chart_outlined_rounded),
                                Text('Your recent activity'),
                              ],
                            ),
                            TextButton(onPressed: () {}, child: Text('view all')),
                          ],
                        ),
                        RecentActivityCardWidget(
                          imageUrl: '',
                          plantName: 'Tomato Plant',
                          diseaseSummary: 'Light blight detected',
                          time: '2 hours ago',
                          accuracy: '95',
                        ),
                        SizedBox(height: 10.0),
                        RecentActivityCardWidget(
                          imageUrl: '',
                          plantName: 'Tomato Plant',
                          diseaseSummary: 'Light blight detected',
                          time: '2 hours ago',
                          accuracy: '95',
                        ),
                        SizedBox(height: 10.0),
                        RecentActivityCardWidget(
                          imageUrl: '',
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



//TODO: Implement the text input



