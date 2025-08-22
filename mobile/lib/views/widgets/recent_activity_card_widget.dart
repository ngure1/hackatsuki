import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class RecentActivityCardWidget extends StatelessWidget {
  const RecentActivityCardWidget({
    super.key,
    required this.imageUrl,
    required this.plantName,
    required this.diseaseSummary,
    required this.time,
    required this.accuracy,
  });

  final String imageUrl;
  final String plantName;
  final String diseaseSummary;
  final String time;
  final String accuracy;

  @override
  Widget build(BuildContext context) {
    return CustomContainerWidget(
      color: AppTheme.gray1,
      horizontalPadding: 10.0,
      verticalPadding: 10.0,
      child: Row(
        children: [
          Image.asset(imageUrl),
          SizedBox(width: 15.0),
          Column(
            // TODO: Align the text at the start of the parent
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(plantName),
              // SizedBox(height: 5.0),
              Text(diseaseSummary),
              // SizedBox(height: 5.0),
              Text(time),
            ],
          ),
          SizedBox(width: 20.0),
          Text('$accuracy %'),
        ],
      ),
    );
  }
}
