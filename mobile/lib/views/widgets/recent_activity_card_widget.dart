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
      color: AppTheme.lightGray1,
      horizontalPadding: 20.0,
      verticalPadding: 5.0,
      child: Row(
        children: [
          CustomContainerWidget(
            color: AppTheme.white,
            horizontalPadding: 5.0,
            verticalPadding: 5.0,
            child: Image.asset(imageUrl),
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: AppTheme.labelLarge.copyWith(color: AppTheme.green1),
                ),
                // SizedBox(height: 5.0),
                Text(
                  diseaseSummary,
                  style: AppTheme.labelMedium.copyWith(color: AppTheme.gray3),
                ),
                SizedBox(height: 10.0),
                Text(
                  time,
                  style: AppTheme.labelSmall.copyWith(color: AppTheme.gray2),
                ),
              ],
            ),
          ),
          CustomContainerWidget(
            color: AppTheme.green3,
            horizontalPadding: 15.0,
            verticalPadding: 7.0,
            child: Text(
              '$accuracy %',
              style: AppTheme.labelMedium.copyWith(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }
}
