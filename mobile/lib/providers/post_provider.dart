import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/post.dart';
import 'package:mobile/data/services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService;

  final List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePosts = true;

  PostProvider(this._postService);

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePosts => _hasMorePosts;

  Future<void> loadPosts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMorePosts = true;
      _posts.clear();
    }

    if (!_hasMorePosts) return;

    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final result = await _postService.getPosts(page: _currentPage);
      _isLoading = false;

      if (result['success'] == true) {
        final newPosts = result['posts'] as List<Post>;
        _posts.addAll(newPosts);
        _hasMorePosts = result['nextPage'] != null;
        _currentPage++;
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load posts: $e';
    }

    notifyListeners();
  }

  Future<Post?> getPostById(String postId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _postService.getPostById(postId);
      _isLoading = false;

      if (result['success'] == true) {
        return result['post'] as Post;
      } else {
        _error = result['error'];
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load post: $e';
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String question,
    required String description,
    String? crop,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPost = await _postService.createPost(
        question,
        description,
        crop: crop,
        image: image,
      );

      _posts.insert(0, newPost);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create post: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      final result = await _postService.likePostById(postId);

      if (result['success'] == true) {
        _updatePostLikes(postId, 1);
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to like post: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unlikePost(String postId) async {
    try {
      final result = await _postService.unlikePostById(postId);

      if (result['success'] == true) {
        _updatePostLikes(postId, -1);
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to unlike post: $e';
      notifyListeners();
      return false;
    }
  }


  void _updatePostLikes(String postId, int change) {
    final index = _posts.indexWhere((post) => post.id.toString() == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = Post(
        id: post.id,
        question: post.question,
        description: post.description,
        crop: post.crop,
        imageUrl: post.imageUrl,
        commentsCount: post.commentsCount,
        likesCount: (post.likesCount ?? 0) + change,
        user: post.user,
      );
      notifyListeners();
    }
  }

  void updatePostCommentsCount(String postId, int change) {
    final index = _posts.indexWhere((post) => post.id.toString() == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = Post(
        id: post.id,
        question: post.question,
        description: post.description,
        crop: post.crop,
        imageUrl: post.imageUrl,
        commentsCount: (post.commentsCount ?? 0) + change,
        likesCount: post.likesCount,
        user: post.user,
      );
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadPosts(refresh: true);
  }
}
