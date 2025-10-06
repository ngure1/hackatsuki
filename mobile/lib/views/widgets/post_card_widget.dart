import 'package:flutter/material.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class PostCardWidget extends StatelessWidget {
  const PostCardWidget({
    super.key,
    this.userImageURL,
    required this.displayName,
    required this.timePosted,
    required this.category,
    this.postImageURL,
    required this.question,
    required this.likeCount,
    required this.commentCount,
    required this.commentLiked,
  });

  final String displayName;
  final String timePosted;
  final String category;
  final String? postImageURL;
  final String? userImageURL;
  final String question;
  final String commentCount;
  final String likeCount;
  final bool commentLiked;

  @override
  Widget build(BuildContext context) {
    return CustomContainerWidget(
      color: AppTheme.white,
      horizontalPadding: 8.0,
      verticalPadding: 8.0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  //TODO: Change to Image.network so that you're fetching from backend
                  Image.asset(
                    'assets/images/people_icon.png',
                    height: 30,
                    width: 30,
                  ),
                  SizedBox(width: 4.0),
                  Column(
                    children: [
                      Text(
                        displayName,
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.buttonTextColor,
                        ),
                      ),
                      Text(
                        timePosted,
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.gray2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CustomContainerWidget(
                color: AppTheme.green1,
                horizontalPadding: 2,
                verticalPadding: 2,
                child: Text(category),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            question,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.black),
          ),
          SizedBox(height: 8.0),
          if (postImageURL != null) Image.network(postImageURL!),
          SizedBox(height: 8.0),
          Align(
            alignment: AlignmentGeometry.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //TODO: Implement the like/unlike button
                _postDetails(icon: Icons.message, accompanyingText: commentCount),
                _postDetails(icon: Icons.share, accompanyingText: "Share")
              ],
            ),
          ),
          //TODO: Implement the comment section
        ],
      ),
    );
  }
}

Widget _postDetails({
  required IconData icon, 
  required String accompanyingText}) {
  return Row(
    children: [
      Icon(icon),
      SizedBox(width: 4.0,),
      Text(accompanyingText, style: AppTheme.labelSmall.copyWith(color: AppTheme.gray2),)
    ],
  );
}
