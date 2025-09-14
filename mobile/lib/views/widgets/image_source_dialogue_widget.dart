import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';

class ImageSourceDialogueWidget extends StatelessWidget {
  const ImageSourceDialogueWidget({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

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
            leading: Image.asset('assets/images/camera_icon.png', width: 24, height: 24),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              onCameraSelected();
            },
          ),
          ListTile(
            leading: Image.asset('assets/images/folder_icon.png', width: 24, height: 24),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              onGallerySelected();
            },
          ),
        ],
      ),
    );
  }
}
