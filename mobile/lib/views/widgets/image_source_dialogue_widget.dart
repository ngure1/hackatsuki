import 'package:flutter/material.dart';
import 'package:mobile/providers/image_provider.dart';
import 'package:mobile/theme.dart';

class ImageSourceDialogueWidget extends StatelessWidget {
  const ImageSourceDialogueWidget({
    super.key,
    required this.imageProvider,
  });

  final ImageProviderNotifier imageProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select Image Source',
        style: AppTheme.titleMedium.copyWith(color: AppTheme.green1),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Image.asset(
              'assets/images/camera_icon.png',
              width: 24,
              height: 24,
            ),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              imageProvider.handleCameraSelection(
                context,
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/images/folder_icon.png',
              width: 24,
              height: 24,
            ),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              imageProvider.handleGallerySelection(
                context,
              );
            },
          ),
        ],
      ),
    );
  }
}