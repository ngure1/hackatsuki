import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:mobile/providers/image_provider.dart";
import "package:mobile/providers/navigation_provider.dart";
import "package:mobile/theme.dart";
import "package:mobile/views/widgets/appbar_widget.dart";
import "package:mobile/views/widgets/custom_container_widget.dart";
import "package:mobile/views/widgets/custom_text_field_widget.dart";
import "package:mobile/views/widgets/image_source_dialogue_widget.dart";
import "package:mobile/views/widgets/navigation_container_widget.dart";
import "package:mobile/views/widgets/plant_details_dialogue_widget.dart";
import "package:mobile/views/widgets/recent_activity_card_widget.dart";
import "package:mobile/views/widgets/stat_card_widget.dart";
import "package:provider/provider.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _handleCameraSelection(BuildContext context) async {
    final imageProvider = context.read<ImageProviderNotifier>();
    final image = await imageProvider.pickFromCamera();

    if (image != null) {
      _showPlantDetailsDialogue(context, imageProvider);
    }
  }

  Future<void> _handleGallerySelection(BuildContext context) async {
    final imageProvider = context.read<ImageProviderNotifier>();
    final image = await imageProvider.pickFromGallery();

    if (image != null) {
      _showPlantDetailsDialogue(context, imageProvider);
    }
  }

  void _showPlantDetailsDialogue(
    BuildContext context,
    ImageProviderNotifier imageProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => PlantDetailsDialogueWidget(
        initialPlantName: imageProvider.plantName,
        initialPlantPart: imageProvider.plantPart,
        initialDescription: imageProvider.description,
        onSave: (plantName, plantPart, description) {
          imageProvider.setPlantDetails(
            plantName: plantName,
            plantPart: plantPart,
            description: description,
          );
          Navigator.pop(dialogContext);
          context.read<NavigationProvider>().selectPage(1);
          Navigator.of(
            context,
            rootNavigator: false,
          ).pushReplacementNamed('/chat');
        },
      ),
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImageSourceDialogueWidget(
        onCameraSelected: () => _handleCameraSelection(context),
        onGallerySelected: () => _handleGallerySelection(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(gradient: AppTheme.homePageGradient),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
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
                    childAspectRatio: 1.7,
                    children: [
                      //TODO: Refactor the first child of this grid
                      NavigationContainerWidget(
                        onTap: () => _handleCameraSelection(context),
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
                        onTap: () =>
                            context.read<NavigationProvider>().selectPage(1),
                        icon: 'assets/images/message_icon.png',
                        title: 'Ask Expert',
                        description: 'Chat with AI plant specialist',
                      ),
                      NavigationContainerWidget(
                        onTap: () =>
                            context.read<NavigationProvider>().selectPage(2),
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

                        GestureDetector(
                          onTap: () => _showImageSourceOptions(context),
                          child: DottedBorder(
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
                              onPressed: () => _handleCameraSelection(context),
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
                              onPressed: () => _handleGallerySelection(context),
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
                        SizedBox(height: 5),
                        CustomTextFieldWidget(
                          liveSearch: false,
                          //TODO: Implement the onSearch feature and make it required
                          hinttext: 'E.g yellow leaves with brown spots',
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
