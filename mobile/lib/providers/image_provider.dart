import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/data/services/image_service.dart';

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

  Future<File?> pickFromCamera() async {
    final file = await _service.pickFromCamera();
    if (file != null) {
      _selectedImage = file;
      notifyListeners();
    }
    return file;
  }

  Future<File?> pickFromGallery() async {
    final file = await _service.pickFromGallery();
    if (file != null) {
      _selectedImage = file;
      notifyListeners();
    }
    return file;
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

  void clear() {
    _selectedImage = null;
    _plantName = null;
    _plantPart = null;
    _description = null;
    notifyListeners();
  }

  String getFormattedPlantDetails() {
    final details = <String>[];
    if (_plantName?.isNotEmpty ?? false) details.add('Plant: $_plantName');
    if (_plantPart?.isNotEmpty ?? false) details.add('Part: $_plantPart');
    if (_description?.isNotEmpty ?? false) details.add('Description: $_description');
    return details.join('\n');
  }
}
