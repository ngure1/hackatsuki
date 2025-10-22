
import 'package:flutter/material.dart';
import 'package:mobile/data/models/blog.dart';
import 'package:mobile/data/models/blog_comment.dart';
import 'package:mobile/data/models/comment.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/comment_section_widget.dart'; // Reusing Post CommentsSectionWidget
import 'package:mobile/views/widgets/custom_container_widget.dart';

class BlogCardWidget extends StatelessWidget {
  final Blog blog;
  final List<BlogComment> comments;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final Function(String, int?) onAddComment;
  final Function(int) onLoadReplies;
  final bool showComments;

  const BlogCardWidget({
    super.key,
    required this.blog,
    required this.comments,
    this.onLike,
    this.onComment,
    required this.onAddComment,
    required this.onLoadReplies,
    this.showComments = false,
  });

  factory BlogCardWidget.fromBlog({
    required Blog blog,
    required List<BlogComment> comments,
    VoidCallback? onLike,
    VoidCallback? onComment,
    required Function(String, int?) onAddComment,
    required Function(int) onLoadReplies,
    bool showComments = false,
  }) {
    return BlogCardWidget(
      blog: blog,
      comments: comments,
      onLike: onLike,
      onComment: onComment,
      onAddComment: onAddComment,
      onLoadReplies: onLoadReplies,
      showComments: showComments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainerWidget(
      color: AppTheme.white,
      horizontalPadding: 8.0,
      verticalPadding: 8.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildUserAvatar(),
                  SizedBox(width: 4.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${blog.user?.firstName ?? 'Unknown'} ${blog.user?.lastName ?? 'User'}',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.buttonTextColor,
                        ),
                      ),
                      Text(
                        'Posted 2 hours ago',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.gray2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            blog.title,
            style: AppTheme.headingSmall.copyWith(color: AppTheme.green1),
          ),
          SizedBox(height: 8.0),
          Text(
            blog.content,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.black),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLikeButton(),
              _postDetails(
                icon: Icons.message,
                accompanyingText: '${blog.commentsCount ?? 0}',
                onTap: onComment,
              ),
              _postDetails(icon: Icons.share, accompanyingText: "Share"),
            ],
          ),
          if (showComments)
             CommentsSectionWidget(
              comments: comments.cast<Comment>(), 
              onAddComment: onAddComment,
              onLoadReplies: onLoadReplies,
            ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: AppTheme.gray1,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Icon(Icons.person, size: 20, color: AppTheme.gray3),
    );
  }
  
  Widget _buildLikeButton() {
    final bool isLiked = blog.isLikedByCurrentUser == true;

    return GestureDetector(
      onTap: onLike,
      child: Row(
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : AppTheme.gray2,
          ),
          SizedBox(width: 4.0),
          Text(
            '${blog.likesCount ?? 0}',
            style: AppTheme.labelSmall.copyWith(
              color: isLiked ? Colors.red : AppTheme.gray2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _postDetails({
    required IconData icon,
    required String accompanyingText,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gray2),
          SizedBox(width: 4.0),
          Text(
            accompanyingText,
            style: AppTheme.labelSmall.copyWith(color: AppTheme.gray2),
          ),
        ],
      ),
    );
  }
}