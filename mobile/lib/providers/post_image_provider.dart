import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/data/services/image_service.dart';

class PostImageProvider extends ChangeNotifier {
  final ImageService _service = ImageService();

  File? _selectedImage;
  String _question = '';
  String _description = '';
  String? _crop;

  File? get selectedImage => _selectedImage;
  String get question => _question;
  String get description => _description;
  String? get crop => _crop;

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

  void setPostDetails({
    String? question,
    String? description,
    String? crop,
  }) {
    _question = question ?? _question;
    _description = description ?? _description;
    _crop = crop ?? _crop;
    notifyListeners();
  }

  void clear() {
    _selectedImage = null;
    _question = '';
    _description = '';
    _crop = null;
    notifyListeners();
  }

  bool get hasData => _selectedImage != null || _question.isNotEmpty || _description.isNotEmpty;

  File? getImageFile() => _selectedImage;
}