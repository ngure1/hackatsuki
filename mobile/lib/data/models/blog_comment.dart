
import 'package:mobile/data/models/post.dart';

class BlogComment {
  final int? id;
  final int? blogId;       // Matches the blog response
  final String content;
  final int? parentCommentId;
  final int repliesCount;
  final User? user;        // Matches the blog response
  final List<BlogComment> replies;

  String get authorName => '${user?.firstName ?? 'Unknown'} ${user?.lastName ?? 'User'}';
  String get timePosted => '2 hours ago'; // Placeholder

  BlogComment({
    this.id,
    this.blogId,
    required this.content,
    this.parentCommentId,
    required this.repliesCount,
    this.user,
    this.replies = const [],
  });

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    return BlogComment(
      id: json['id'],
      blogId: json['blog_id'],
      content: json['content'],
      parentCommentId: json['parent_comment_id'],
      repliesCount: json['replies_count'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null, 
      replies: (json['replies'] as List?)
          ?.map((r) => BlogComment.fromJson(r))
          .toList() ?? [],
    );
  }

  BlogComment copyWith({List<BlogComment>? replies}) {
    return BlogComment(
      id: id,
      blogId: blogId,
      content: content,
      parentCommentId: parentCommentId,
      repliesCount: repliesCount,
      user: user,
      replies: replies ?? this.replies,
    );
  }
}