import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/data/notifiers.dart';
import 'package:mobile/data/services/image_service.dart';
import 'package:mobile/views/widgets/plant_details_dialogue_widget.dart';

class ImageProviderNotifier extends ChangeNotifier {
  final ImageService _service = ImageService();

  File? _selectedImage;
  String? _plantName;
  String? _plantPart;
  String? _description;

  File? get selectedImage => _selectedImage;
  String? get plantName => _plantName;
  String? get plantPart => _plantPart;
  String? get description => _description;

  Future<void> handleCameraSelection(BuildContext context) async {
    _selectedImage = await _service.pickFromCamera();
    if (_selectedImage != null) {
      _showPlantDetailsDialog(context);
    }
    notifyListeners();
  }

  Future<void> handleGallerySelection(BuildContext context) async {
    _selectedImage = await _service.pickFromGallery();
    if (_selectedImage != null) {
      _showPlantDetailsDialog(context);
    }
    notifyListeners();
  }

  void _showPlantDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlantDetailsDialogueWidget(
        initialPlantName: _plantName,
        initialPlantPart: _plantPart,
        initialDescription: _description,
        onSave: (plantName, plantPart, description) {
          setPlantDetails(
            plantName: plantName,
            plantPart: plantPart,
            description: description,
          );
          Navigator.pop(context);
          selectedPageNotifier.value = 1;
        },
      ),
    );
  }

  void setPlantDetails({
    String? plantName,
    String? plantPart,
    String? description,
  }) {
    _plantName = plantName;
    _plantPart = plantPart;
    _description = description;
    notifyListeners();
  }

  void clearImageDescription() {
    _selectedImage = null;
    _plantName = null;
    _plantPart = null;
    _description = null;
    notifyListeners();
  }

  String getFormattedPlantDetails() {
    final details = <String>[];
    if (_plantName != null) details.add('Plant: $_plantName');
    if (_plantPart != null) details.add('Part: $_plantPart');
    if (_description != null) details.add('Description: $_description');
    return details.join('\n');
  }
}
