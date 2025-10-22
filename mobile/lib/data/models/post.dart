import 'package:mobile/data/utils.dart';

class Post {
  final int? id;
  final String question;
  final String description;
  final String? crop;
  final String? imageUrl;
  final int? commentsCount;
  final int? likesCount;
  final User? user;
  final bool? isLikedByCurrentUser;

  Post({
    this.id,
    required this.question,
    required this.description,
    this.crop,
    this.imageUrl,
    this.commentsCount,
    this.likesCount,
    this.user,
    this.isLikedByCurrentUser
  });

  Map<String, dynamic> toJson() {
    final data = {"question": question, "description": description};
    if (crop != null) {
      data["crop"] = crop!;
    }
    return data;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      question: json['question'],
      description: json['description'],
      crop: json['crop'],
      imageUrl: json['image_url'] != null
          ? 'http://127.0.0.1${json['image_url']}'
          : null,
      commentsCount: json['comments_count'],
      likesCount: json['likes_count'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      isLikedByCurrentUser: json['']
    );
  }
}

class User {
  final int? id;
  final String firstName;
  final String lastName;

  User({this.id, required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}
