import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';

class PlantDetailsDialogueWidget extends StatefulWidget {
  const PlantDetailsDialogueWidget({
    super.key,
    this.initialPlantName,
    this.initialPlantPart,
    this.initialDescription,
    required this.onSave,
  });

  final String? initialPlantName;
  final String? initialPlantPart;
  final String? initialDescription;
  final Function(String? plantName, String? plantPart, String? description)
  onSave;

  @override
  State<PlantDetailsDialogueWidget> createState() =>
      _PlantDetailsDialogueWidgetState();
}

class _PlantDetailsDialogueWidgetState
    extends State<PlantDetailsDialogueWidget> {
  late TextEditingController _plantNameController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();

  final List<String> plantParts = [
    'Leaves',
    'Stem',
    'Roots',
    'Flowers',
    'Fruits',
    'Bark',
    'Branches',
    'Seeds',
    'Whole Plant',
  ];

  String? selectedPlantPart;

  @override
  void initState() {
    super.initState();
    _plantNameController = TextEditingController(text: widget.initialPlantName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _plantNameController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/plant_image.png',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Plant details',
                  style: AppTheme.titleLarge.copyWith(color: AppTheme.green1),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Add optional details to help our AI provide better diagnosis',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray2),
            ),
            SizedBox(height: 20),
            Text(
              'Plant Name (Optional)',
              style: AppTheme.labelMedium.copyWith(color: AppTheme.green1),
            ),
            SizedBox(height: 8),
            DialogueTextField(
              controller: _plantNameController,
              hinttext: 'E.g. Tomato, Rose, Onion',
            ),
            SizedBox(height: 16.0),
            Text(
              'Plant Part (Optional)',
              style: AppTheme.labelMedium.copyWith(color: AppTheme.green1),
            ),
            SizedBox(height: 8.0),
            DropdownButtonFormField(
              value: selectedPlantPart,
              decoration: InputDecoration(
                hintText: 'Select plant part',
                hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.gray3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.gray1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.green2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('Select plant part')),
                ...plantParts.map(
                  (part) => DropdownMenuItem(value: part, child: Text(part)),
                ),
              ],
              onChanged: (value) => setState(() {
                selectedPlantPart = value;
              }),
            ),
            SizedBox(height: 16.0),
            Text(
              'Additional description (Optional)',
              style: AppTheme.labelMedium.copyWith(color: AppTheme.green1),
            ),
            SizedBox(height: 8),
            DialogueTextField(
              controller: _descriptionController,
              hinttext:
                  'Describe what you observe i.e. colors, patterns, timing, etc',
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => widget.onSave(null, null, null),
                  child: Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      _plantNameController.text.trim().isEmpty ? null : _plantNameController.text.trim(),
                      selectedPlantPart,
                      _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                    );
                  },
                  child: Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DialogueTextField extends StatelessWidget {
  const DialogueTextField({
    super.key,
    required this.controller,
    required this.hinttext,
  });
  final TextEditingController controller;
  final String hinttext;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: AppTheme.labelMedium.copyWith(color: AppTheme.gray2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.green2, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.textGray, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}


