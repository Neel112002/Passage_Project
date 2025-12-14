import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:passage/models/reel.dart';
import 'package:passage/models/reel_comment.dart';
import 'package:passage/models/product.dart';
import 'package:passage/services/firestore_reels_service.dart';
import 'package:passage/services/firestore_products_service.dart';
import 'package:passage/services/firestore_reel_interactions_service.dart';
import 'package:passage/services/local_saved_reels_service.dart';
import 'package:passage/services/firebase_auth_service.dart';
import 'package:passage/services/firestore_user_profile_service.dart';
import 'package:passage/screens/product_detail_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  StreamSubscription<List<ReelModel>>? _reelsSub;
  List<ReelModel> _reels = [];
  bool _loading = true;
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  @override
  void dispose() {
    _reelsSub?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _loadReels() {
    _reelsSub = FirestoreReelsService.watchAll().listen((reels) {
      if (!mounted) return;
      setState(() {
        _reels = reels;
        _loading = false;
      });
      
      // Initialize page controller after reels are loaded
      if (_pageController == null && reels.isNotEmpty) {
        _pageController = PageController(initialPage: 0);
      }
    });
  }

  Future<void> _openProduct(String productId) async {
    try {
      final product = await FirestoreProductsService.getById(productId);
      if (product == null || !mounted) return;
      
      final data = ProductDetailData(
        id: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        imageUrls: product.imageUrls.isNotEmpty ? product.imageUrls : [product.imageUrl],
        rating: product.rating,
        tag: product.tag,
        description: product.description,
        stock: product.stock,
        condition: product.condition,
        campus: product.campus,
        pickupOnly: product.pickupOnly,
        pickupLocation: product.pickupLocation,
        negotiable: product.negotiable,
        sellerId: product.sellerId,
        updatedAt: product.updatedAt,
      );
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: data)),
      );
    } catch (e) {
      debugPrint('Failed to load product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_reels.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reels'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_library_outlined,
                  size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'No reels yet',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Reels will appear here when sellers add videos to products.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemCount: _reels.length,
        itemBuilder: (context, index) {
          final reel = _reels[index];
          final isActive = index == _currentIndex;
          return _ReelPlayerCard(
            key: ValueKey(reel.id),
            reel: reel,
            isActive: isActive,
            onOpenProduct: () => _openProduct(reel.productId),
          );
        },
      ),
    );
  }
}

class _ReelPlayerCard extends StatefulWidget {
  final ReelModel reel;
  final bool isActive;
  final VoidCallback onOpenProduct;

  const _ReelPlayerCard({
    super.key,
    required this.reel,
    required this.isActive,
    required this.onOpenProduct,
  });

  @override
  State<_ReelPlayerCard> createState() => _ReelPlayerCardState();
}

class _ReelPlayerCardState extends State<_ReelPlayerCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _muted = true;
  bool _error = false;
  bool _isLiked = false;
  bool _isSaved = false;
  int _likeCount = 0;
  int _commentCount = 0;
  StreamSubscription<bool>? _isLikedSub;
  StreamSubscription<int>? _likeCountSub;
  StreamSubscription<int>? _commentCountSub;

  @override
  void initState() {
    super.initState();
    _initController();
    _loadInteractions();
  }

  Future<void> _initController() async {
    final videoUrl = widget.reel.videoUrl;
    
    if (videoUrl.isEmpty) {
      setState(() => _error = true);
      return;
    }
    
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controller = c;
      
      await c.initialize();
      await c.setLooping(true);
      if (_muted) {
        await c.setVolume(0);
      }
      
      setState(() => _initialized = true);
      
      if (widget.isActive) {
        c.play();
      }
    } catch (e) {
      debugPrint('Video init error: $e');
      setState(() => _error = true);
    }
  }

  @override
  void didUpdateWidget(covariant _ReelPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive &&
        _controller != null &&
        _initialized) {
      if (widget.isActive) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  void _loadInteractions() async {
    // Load saved status
    _isSaved = await LocalSavedReelsStore.isSaved(widget.reel.id);
    if (mounted) setState(() {});

    // Watch like status
    _isLikedSub = FirestoreReelInteractionsService.watchIsLiked(widget.reel.id)
        .listen((liked) {
      if (mounted) setState(() => _isLiked = liked);
    });

    // Watch like count
    _likeCountSub =
        FirestoreReelInteractionsService.watchLikeCount(widget.reel.id)
            .listen((count) {
      if (mounted) setState(() => _likeCount = count);
    });

    // Watch comment count
    _commentCountSub =
        FirestoreReelInteractionsService.watchCommentCount(widget.reel.id)
            .listen((count) {
      if (mounted) setState(() => _commentCount = count);
    });
  }

  Future<void> _toggleLike() async {
    try {
      await FirestoreReelInteractionsService.toggleLike(widget.reel.id);
    } catch (e) {
      debugPrint('Error toggling like: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like')),
        );
      }
    }
  }

  Future<void> _toggleSave() async {
    try {
      await LocalSavedReelsStore.toggle(widget.reel.id);
      _isSaved = await LocalSavedReelsStore.isSaved(widget.reel.id);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Reel saved' : 'Reel removed from saved'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling save: $e');
    }
  }

  Future<void> _showComments() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(reelId: widget.reel.id),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _isLikedSub?.cancel();
    _likeCountSub?.cancel();
    _commentCountSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video or placeholder
        if (_error)
          Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(height: 12),
                  Text(
                    'Video unavailable',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        else if (_initialized && _controller != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          )
        else
          Container(
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator()),
          ),
        
        // Right side actions (like, comment, save, volume)
        Positioned(
          right: 12,
          bottom: 120,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like button
                _actionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _formatCount(_likeCount),
                  color: _isLiked ? Colors.red : Colors.white,
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 16),
                // Comment button
                _actionButton(
                  icon: Icons.comment,
                  label: _formatCount(_commentCount),
                  color: Colors.white,
                  onTap: _showComments,
                ),
                const SizedBox(height: 16),
                // Save button
                _actionButton(
                  icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: '',
                  color: _isSaved ? Colors.amber : Colors.white,
                  onTap: _toggleSave,
                ),
                const SizedBox(height: 16),
                // Volume button
                _roundButton(
                  icon: _muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  bg: Colors.black.withValues(alpha: 0.35),
                  onTap: () async {
                    setState(() => _muted = !_muted);
                    if (_controller != null) {
                      await _controller!.setVolume(_muted ? 0 : 1);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        
        // Bottom gradient + caption and action
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.reel.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.reel.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonalIcon(
                          onPressed: widget.onOpenProduct,
                          icon: const Icon(Icons.shopping_bag, color: Colors.teal),
                          label: const Text('View product'),
                          style: FilledButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count == 0) return '';
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 28),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

// Comments bottom sheet
class _CommentsSheet extends StatefulWidget {
  final String reelId;

  const _CommentsSheet({required this.reelId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  StreamSubscription<List<ReelComment>>? _commentsSub;
  List<ReelComment> _comments = [];
  bool _loading = true;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentsSub?.cancel();
    super.dispose();
  }

  void _loadComments() {
    _commentsSub =
        FirestoreReelInteractionsService.watchComments(widget.reelId)
            .listen((comments) {
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loading = false;
      });
    });
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _posting = true);

    try {
      final userId = FirebaseAuthService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final userProfile =
          await FirestoreUserProfileService.getById(userId);
      final userName = userProfile?.fullName ?? 'Unknown User';
      final userAvatarUrl = userProfile?.avatarUrl ?? '';

      await FirestoreReelInteractionsService.addComment(
        reelId: widget.reelId,
        text: text,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
      );

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint('Error posting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await FirestoreReelInteractionsService.deleteComment(
        reelId: widget.reelId,
        commentId: commentId,
      );
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuthService.currentUserId;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${_comments.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Comments list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.comment_outlined,
                                    size: 64,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  'No comments yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to comment',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _comments.length,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              final isOwner = comment.userId == currentUserId;
                              return _CommentTile(
                                comment: comment,
                                isOwner: isOwner,
                                onDelete: () => _deleteComment(comment.id),
                              );
                            },
                          ),
              ),
              // Input field
              const Divider(height: 1),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _postComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _posting
                          ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: _postComment,
                              icon: const Icon(Icons.send),
                              color: theme.colorScheme.primary,
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ReelComment comment;
  final bool isOwner;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.isOwner,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.userAvatarUrl.isNotEmpty
                ? NetworkImage(comment.userAvatarUrl)
                : null,
            child: comment.userAvatarUrl.isEmpty
                ? Text(
                    comment.userName.isNotEmpty
                        ? comment.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Delete button (only for owner)
          if (isOwner)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete comment'),
                    content: const Text(
                        'Are you sure you want to delete this comment?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              color: theme.colorScheme.error,
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo';
    return '${(difference.inDays / 365).floor()}y';
  }
}
