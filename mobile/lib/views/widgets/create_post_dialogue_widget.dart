import 'package:flutter/material.dart';
import 'package:mobile/providers/post_image_provider.dart';
import 'package:mobile/providers/post_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/beautified_text_field_widget.dart';
import 'package:mobile/views/widgets/image_source_dialogue_widget.dart';
import 'package:provider/provider.dart';

class CreatePostDialogueWidget extends StatefulWidget {
  const CreatePostDialogueWidget({super.key});

  @override
  State<CreatePostDialogueWidget> createState() =>
      _CreatePostDialogueWidgetState();
}

class _CreatePostDialogueWidgetState extends State<CreatePostDialogueWidget> {
  final _questionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cropController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _questionController.dispose();
    _descriptionController.dispose();
    _cropController.dispose();
    super.dispose();
  }

  Future<void> _handleCameraSelection(BuildContext context) async {
    final imageProvider = context.read<PostImageProvider>();
    await imageProvider.pickFromCamera();
  }

  Future<void> _handleGallerySelection(BuildContext context) async {
    final imageProvider = context.read<PostImageProvider>();
    await imageProvider.pickFromGallery();
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

  Future<void> _createPost(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final imageProvider = context.read<PostImageProvider>();
    final postProvider = context.read<PostProvider>();

    final image = imageProvider.getImageFile();

    final success = await postProvider.createPost(
      question: _questionController.text.trim(),
      description: _descriptionController.text.trim(),
      crop: _cropController.text.trim().isNotEmpty
          ? _cropController.text.trim()
          : null,
      image: image,
    );

    if (success && context.mounted) {
      imageProvider.clear();
      _clearForm();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create post: ${postProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _questionController.clear();
    _descriptionController.clear();
    _cropController.clear();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<PostImageProvider>();

    return Dialog(
      insetPadding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Post',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.green1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.gray3),
                      onPressed: () {
                        // Clear provider when closing without posting
                        imageProvider.clear();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Image Upload Section
                Text(
                  'Add Photo (Optional)',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.green1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showImageSourceOptions(context),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.green2, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: AppTheme.green4,
                    ),
                    child: imageProvider.selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              imageProvider.selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: AppTheme.green2,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add photo',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.green2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 8),
                if (imageProvider.selectedImage != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => imageProvider.clear(),
                      child: Text(
                        'Remove Image',
                        style: AppTheme.buttonText.copyWith(color: Colors.red),
                      ),
                    ),
                  ),

                SizedBox(height: 20),

                // Form Fields
                BeautifiedTextFieldWidget(
                  controller: _questionController,
                  label: 'Question *',
                  hint: 'What would you like to ask?',
                  prefixIcon: Icons.question_mark,
                  validator: _requiredValidator,
                ),
                SizedBox(height: 16),

                BeautifiedTextFieldWidget(
                  controller: _descriptionController,
                  label: 'Description *',
                  hint: 'Describe your issue or question in detail...',
                  prefixIcon: Icons.description,
                  keyboardType: TextInputType.multiline,
                  validator: _requiredValidator,
                ),
                SizedBox(height: 16),

                BeautifiedTextFieldWidget(
                  controller: _cropController,
                  label: 'Crop Type (Optional)',
                  hint: 'e.g., Tomato, Corn, Wheat...',
                  prefixIcon: Icons.eco,
                ),
                SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          imageProvider.clear();
                          _clearForm();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: AppTheme.green2),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTheme.buttonText.copyWith(
                            color: AppTheme.green2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _createPost(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green3,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Create Post',
                          style: AppTheme.buttonText.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
