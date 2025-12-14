import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:passage/models/reel.dart';
import 'package:passage/services/firestore_reels_service.dart';
import 'package:passage/services/firestore_products_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initController();
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

  @override
  void dispose() {
    _controller?.dispose();
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
        
        // Top-right actions
        Positioned(
          top: 16,
          right: 12,
          child: SafeArea(
            child: Column(
              children: [
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
