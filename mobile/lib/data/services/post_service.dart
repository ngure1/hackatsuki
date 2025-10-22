import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/data/models/comment.dart';
import 'package:mobile/data/models/post.dart';
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/data/utils.dart';

class PostService {
  final AuthService _authService;

  PostService(this._authService);

  Future<Map<String, dynamic>> getPosts({int page = 1}) async {
    try {
      final response = await _authService.get(
        '${ApiEndpoints.getPosts}?page=$page',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final int totalPages = data['total_pages'] ?? 1;

        final int? nextPage = page < totalPages ? page+1 : null;
        final int? previousPage = page > 1 ? page -1 : null;
        return {
          'success': true,
          'posts': (data['posts'] as List)
              .map((post) => Post.fromJson(post))
              .toList(),
          'nextPage': nextPage,
          'previousPage': previousPage,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load posts: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to load posts: $e'};
    }
  }

  Future<Map<String, dynamic>> getPostById(String postId) async {
    try {
      final response = await _authService.get(ApiEndpoints.getPost(postId));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'post': Post.fromJson(json.decode(response.body)),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load post: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to load post: $e'};
    }
  }

  Future<Post> createPost(
    String question,
    String description, {
    String? crop,
    File? image,
  }) async {
    const url = "$baseUrl/posts/";

    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers['Authorization'] = 'Bearer ${_authService.accessToken}';

    request.fields['question'] = question;
    request.fields['description'] = description;

    if (crop != null && crop.isNotEmpty) {
      request.fields['crop'] = crop;
    }

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Post.fromJson(data);
    } else {
      throw Exception(
        'Failed to create post: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> togglePostLikeById(String postId) async {
    try {
      final response = await _authService.post(
        ApiEndpoints.toggleLike(postId),
        {},
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': 'Failed to toggle like: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to toggle like: $e'};
    }
  }

  Future<Map<String, dynamic>> addCommentToPost({
    required String postId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final Map<String, dynamic> body = {'content': content};

      if (parentCommentId != null) {
        body['parent_comment_id'] = parentCommentId;
      }

      final response = await _authService.post(
        ApiEndpoints.addComment(postId),
        body,
      );

      if (response.statusCode == 201) {
        return {'success': true, 'comment': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Failed to add comment: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to add comment: $e'};
    }
  }

  Future<Map<String, dynamic>> getCommentsForPost(
    String postId, {
    int page = 1,
  }) async {
    try {
      final response = await _authService.get(
        '${ApiEndpoints.getPostComments(postId)}?page=$page',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final comments = (data['comments'] as List)
            .map(
              (commentJson) =>
                  Comment.fromJson(commentJson as Map<String, dynamic>),
            )
            .toList();

        return {
          'success': true,
          'comments': comments,
          'nextPage': data['next'] != null ? page + 1 : null,
          'previousPage': data['previous'] != null ? page - 1 : null,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load comments: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to load comments: $e'};
    }
  }

  Future<Map<String, dynamic>> getCommentRepliesById(
    String commentId, {
    int page = 1,
  }) async {
    try {
      final response = await _authService.get(
        '${ApiEndpoints.getCommentReplies(commentId)}?page=$page',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'replies': data['results'],
          'nextPage': data['next'] != null ? page + 1 : null,
          'previousPage': data['previous'] != null ? page - 1 : null,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load replies: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to load replies: $e'};
    }
  }

  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      // Assuming _authService.post handles the POST request with the Authorization header.
      // This is used even for deletion as per your requirement.
      final response = await _authService.post(
        ApiEndpoints.deletePost(postId),
        {}, // Empty body for the POST request
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error':
              'Failed to delete post: ${response.statusCode} ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to delete post: $e'};
    }
  }
}
