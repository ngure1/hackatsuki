import 'package:flutter/material.dart';
import 'package:mobile/data/models/comment.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class CommentsSectionWidget extends StatefulWidget {
  final List<Comment> comments;
  final Function(String, int?) onAddComment; 
  final Function(int) onLoadReplies; 

  const CommentsSectionWidget({
    super.key,
    required this.comments,
    required this.onAddComment,
    required this.onLoadReplies,
  });

  @override
  State<CommentsSectionWidget> createState() => _CommentsSectionWidgetState();
}

class _CommentsSectionWidgetState extends State<CommentsSectionWidget> {
  final _commentController = TextEditingController();
  int? _replyingToCommentId;
  String _replyingToAuthor = '';

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _startReply(Comment comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToAuthor = comment.authorName;
      _commentController.clear();
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthor = '';
      _commentController.clear();
    });
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    widget.onAddComment(content, _replyingToCommentId);
    _commentController.clear();
    _cancelReply();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCommentInput(),
        SizedBox(height: 16),
        _buildCommentsList(),
      ],
    );
  }

  Widget _buildCommentInput() {
    return CustomContainerWidget(
      color: AppTheme.white,
      horizontalPadding: 4,
      verticalPadding: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyingToCommentId != null)
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Replying to $_replyingToAuthor',
                    style: AppTheme.labelSmall.copyWith(color: AppTheme.green2),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(Icons.close, size: 16, color: AppTheme.gray3),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: _replyingToCommentId != null 
                        ? 'Write your reply...' 
                        : 'Write a comment...',
                    hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.gray3),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              IconButton(
                onPressed: _submitComment,
                icon: Icon(Icons.send, color: AppTheme.green3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    final topLevelComments = widget.comments.where((c) => c.parentCommentId == null).toList();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: topLevelComments.length,
      itemBuilder: (context, index) {
        return _buildCommentItem(topLevelComments[index], 0);
      },
    );
  }

  Widget _buildCommentItem(Comment comment, int depth) {
  final hasReplies = comment.replies.isNotEmpty || (comment.repliesCount ?? 0) > 0;
  final isTopLevel = depth == 0;

  return Container(
    margin: EdgeInsets.only(
      left: isTopLevel ? 0 : 16.0 * depth,
      bottom: 8,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomContainerWidget(
          color: isTopLevel ? AppTheme.white : AppTheme.lightGreen1,
          horizontalPadding: 12,
          verticalPadding: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDefaultAvatar(),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.authorName,
                              style: AppTheme.labelMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              comment.timePosted,
                              style: AppTheme.labelSmall.copyWith(
                                color: AppTheme.gray2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          comment.content,
                          style: AppTheme.bodySmall,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _startReply(comment),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'Reply',
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.green3,
                                ),
                              ),
                            ),
                            if (hasReplies) ...[
                              SizedBox(width: 16),
                              _buildViewRepliesButton(comment),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (comment.replies.isNotEmpty) ...[
          SizedBox(height: 8),
          ...comment.replies.map((reply) => _buildCommentItem(reply, depth + 1)),
        ],
      ],
    ),
  );
}

Widget _buildViewRepliesButton(Comment comment) {
  final hasLoadedReplies = comment.replies.isNotEmpty;
  final totalReplies = comment.repliesCount ?? 0;

  if (hasLoadedReplies && comment.replies.length >= totalReplies) {
    return SizedBox.shrink();  
  }

  return TextButton(
    onPressed: () {
      if (comment.id != null) {
        widget.onLoadReplies(comment.id!);
      }
    },
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
    ),
    child: Text(
      hasLoadedReplies 
          ? 'View ${totalReplies - comment.replies.length} more replies'
          : 'View $totalReplies ${totalReplies == 1 ? 'reply' : 'replies'}',
      style: AppTheme.labelSmall.copyWith(
        color: AppTheme.green3,
        fontStyle: FontStyle.italic,
      ),
    ),
  );
}

  Widget _buildDefaultAvatar() {
    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        color: AppTheme.gray1,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Icon(Icons.person, size: 16, color: AppTheme.gray3),
    );
  }
}