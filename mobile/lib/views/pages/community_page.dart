import 'package:flutter/material.dart';
import 'package:mobile/data/models/post.dart';
import 'package:mobile/providers/comment_provider.dart';
import 'package:mobile/providers/post_filter_provider.dart';
import 'package:mobile/providers/post_provider.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:mobile/views/widgets/filter_nav_widget.dart';
import 'package:mobile/views/widgets/post_card_widget.dart';
import 'package:mobile/views/widgets/create_post_dialogue_widget.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PostProvider>().loadPosts();
    });
  }

  String? _expandedPostId;

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialogueWidget(),
    );
  }

  void _handleToggleLike(Post post) {
    final postProvider = context.read<PostProvider>();
    postProvider.toggleLikePost(post);

    print('Toggled like status for post: ${post.id}');
  }

  void _toggleComments(String postId) {
    final isExpanding = _expandedPostId != postId;
    setState(() {
      _expandedPostId = isExpanding ? postId : null;
    });

    if (isExpanding) {
      context.read<CommentProvider>().loadPostComments(postId);
    }
  }

  void _handleAddComment(
    String postId,
    String content,
    int? parentCommentId,
  ) async {
    final commentProvider = context.read<CommentProvider>();
    final postProvider = context.read<PostProvider>();
    final result = await commentProvider.addComment(
      postId: postId,
      content: content,
      parentCommentId: parentCommentId,
    );

    if (result['success'] == true && mounted) {
      postProvider.updatePostCommentsCount(postId, 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add comment: ${result['error'] ?? commentProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLoadReplies(String postId, int commentId) async {
    final commentProvider = context.read<CommentProvider>();

    await commentProvider.loadCommentReplies(postId, commentId);
  }

  void _handleDeletePost(String postId) async {
    final postProvider = context.read<PostProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text(
            'Are you sure you want to delete this post? this action cannot be undone.',
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(false),
              icon: Icon(Icons.cancel),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(true),
              icon: Icon(Icons.delete, color: Colors.redAccent),
            ),
          ],
        );
      },
    );
    if (confirmed!) {
      final success = await postProvider.deletePost(postId);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post deleted successfully')));
      } else if(mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete post: ${postProvider.error} ?? An error occurred')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postFilter = context.watch<PostFilterProvider>();


    return Scaffold(
      backgroundColor: AppTheme.green4,
      appBar: AppbarWidget(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: AppTheme.white),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plant Community',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.green1,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showCreatePostDialog(context),
                      child: Text(
                        '+ New Post',
                        style: AppTheme.buttonText.copyWith(
                          color: AppTheme.green3,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                FilterNavWidget(
                  onFilterChange: (filter) =>
                      context.read<PostFilterProvider>().setFilter(filter),
                  selectedFilter: postFilter.selectedFilter,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                if (postProvider.isLoading && postProvider.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.green3),
                        SizedBox(height: 16),
                        Text(
                          'Loading posts...',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.green1,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (postProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          postProvider.error!,
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => postProvider.refresh(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.green3,
                          ),
                          child: Text(
                            'Try Again',
                            style: AppTheme.buttonText.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (postProvider.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: AppTheme.gray3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.green1,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to share your plant questions!',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.gray3,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showCreatePostDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.green3,
                          ),
                          child: Text(
                            'Create First Post',
                            style: AppTheme.buttonText.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => postProvider.refresh(),
                  color: AppTheme.green3,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount:
                        postProvider.posts.length +
                        (postProvider.hasMorePosts ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == postProvider.posts.length) {
                        postProvider.loadPosts();
                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.green3,
                            ),
                          ),
                        );
                      }

                      final post = postProvider.posts[index];
                      final commentProvider = context.watch<CommentProvider>();
                      final postComments = commentProvider.getPostComments(
                        post.id.toString(),
                      );
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: PostCardWidget.fromPost(
                          //TODO: implement deletion, specifically fetching the currently logged in user id
                          post: post,
                          comments: postComments,
                          onLike: () => _handleToggleLike(post),
                          onComment: () => _toggleComments(post.id.toString()),
                          onDelete: () => _handleDeletePost(post.id.toString()),
                          onAddComment: (content, parentCommentId) =>
                              _handleAddComment(
                                post.id.toString(),
                                content,
                                parentCommentId,
                              ),
                          onLoadReplies: (commentId) =>
                              _handleLoadReplies(post.id.toString(), commentId),
                          showComments: _expandedPostId == post.id.toString(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
