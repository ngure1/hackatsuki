import 'package:mobile/data/models/user.dart'; 

class Blog {
  final int? id;
  final String title;
  final String content;
  final int? commentsCount;
  final int? likesCount;
  final User? user;
  final bool? isLikedByCurrentUser;

  Blog({
    this.id,
    required this.title,
    required this.content,
    this.commentsCount,
    this.likesCount,
    this.user,
    this.isLikedByCurrentUser,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      commentsCount: json['comments_count'],
      likesCount: json['likes_count'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      isLikedByCurrentUser: json['is_liked'] as bool?,
    );
  }
}
