import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:passage/models/product.dart';
import 'package:passage/models/reel.dart';
import 'package:passage/services/firebase_auth_service.dart';
import 'package:passage/services/firestore_products_service.dart';
import 'package:passage/services/firestore_reels_service.dart';

class SellerProductFormScreen extends StatefulWidget {
  const SellerProductFormScreen({super.key, this.existing});
  final AdminProductModel? existing;

  @override
  State<SellerProductFormScreen> createState() => _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  static const List<String> _categoryOptions = <String>[
    'Electronics',
    'Fashion',
    'Home & Living',
    'Books',
    'Beauty',
    'Sports',
    'Toys',
    'Vehicles',
    'Services',
    'Others',
  ];

  String _category = 'Others';
  final _stockCtrl = TextEditingController(text: '1');
  final _descCtrl = TextEditingController();
  final _campusCtrl = TextEditingController();
  final _pickupLocationCtrl = TextEditingController();

  bool _isActive = true;
  bool _pickupOnly = true;
  bool _negotiable = false;
  String _condition = 'Good';

  final List<String> _images = <String>[]; // data urls
  Uint8List? _selectedVideoBytes;
  String? _selectedVideoName;
  bool _saving = false;

  // ✅ IMPORTANT: match your Firebase Storage bucket shown in Firebase console
  // (yours is: som7ukrvvpx1vwk6dvlufr0fj581om.firebasestorage.app)
  static const String _storageBucket =
      'som7ukrvvpx1vwk6dvlufr0fj581om.firebasestorage.app';

  FirebaseStorage get _storage => FirebaseStorage.instanceFor(bucket: _storageBucket);

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _nameCtrl.text = p.name;
      _priceCtrl.text = p.price.toStringAsFixed(2);
      _category = (p.category.isNotEmpty ? p.category : 'Others');
      _stockCtrl.text = p.stock.toString();
      _descCtrl.text = p.description;
      _isActive = p.isActive;
      _pickupOnly = p.pickupOnly;
      _negotiable = p.negotiable;
      _condition = p.condition.isNotEmpty ? p.condition : 'Good';
      _campusCtrl.text = p.campus;
      _pickupLocationCtrl.text = p.pickupLocation;
      _images.addAll(
        p.imageUrls.isNotEmpty
            ? p.imageUrls
            : (p.imageUrl.isNotEmpty ? [p.imageUrl] : const []),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _campusCtrl.dispose();
    _pickupLocationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Select video from'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final xfile = await picker.pickVideo(source: source);
      if (xfile == null) return;

      final bytes = await xfile.readAsBytes();

      // Check video size (limit to 50MB)
      if (bytes.lengthInBytes > 50 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video too large. Please select a video smaller than 50MB.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() {
        _selectedVideoBytes = bytes;
        _selectedVideoName = xfile.name;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Video selected: ${xfile.name} (${(bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1)}MB)',
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Pick video failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select video: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (xfile == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing image...'), duration: Duration(seconds: 2)),
      );

      final bytes = await xfile.readAsBytes();

      // Base64 adds ~33% overhead, so max allowed is ~750KB
      if (bytes.lengthInBytes > 750 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image too large. Please select a smaller image (max 800x800px).'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final base64Str = base64Encode(bytes);
      final mime = _inferMimeFromExtension(xfile.name.split('.').last) ?? 'image/jpeg';
      final dataUrl = 'data:$mime;base64,$base64Str';

      debugPrint('Image encoded: ${bytes.lengthInBytes} bytes -> ${dataUrl.length} chars');

      setState(() => _images.add(dataUrl));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image added!'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      debugPrint('Pick image failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add image: $e')),
      );
    }
  }

  String? _inferMimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuthService.currentUserId;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be signed in')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final now = DateTime.now();

      // STEP 1: CREATE PRODUCT FIRST (with empty videoUrl)
      String productId = widget.existing?.id ?? '';
      if (productId.isEmpty) {
        productId = FirestoreProductsService.newDocId();
      }

      final product = AdminProductModel(
        id: productId,
        sellerId: uid,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        imageUrl: _images.isNotEmpty ? _images.first : '',
        imageUrls: List<String>.from(_images),
        rating: widget.existing?.rating ?? 0,
        tag: '',
        category: _category.isEmpty ? 'Others' : _category,
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
        isActive: _isActive,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
        condition: _condition,
        campus: _campusCtrl.text.trim(),
        pickupOnly: _pickupOnly,
        pickupLocation: _pickupLocationCtrl.text.trim(),
        negotiable: _negotiable,
        videoUrl: widget.existing?.videoUrl ?? '',
      );

      debugPrint('STEP 1: Creating product document with ID: $productId');
      await FirestoreProductsService.upsert(product);
      debugPrint('✅ Product created successfully');

      // STEP 2: UPLOAD VIDEO (only if selected)
      String? reelVideoUrl;
      if (_selectedVideoBytes != null && _selectedVideoBytes!.isNotEmpty) {
        debugPrint(
          'STEP 2: Uploading video to Storage (${(_selectedVideoBytes!.lengthInBytes / (1024 * 1024)).toStringAsFixed(1)}MB)...',
        );

        try {
          final storageRef = _storage
              .ref()
              .child('reels')
              .child(uid)
              .child('$productId.mp4');

          debugPrint('📤 Starting upload to: ${storageRef.fullPath}');
          debugPrint('📦 Bucket: $_storageBucket');

          final uploadTask = storageRef.putData(
            _selectedVideoBytes!,
            SettableMetadata(
              contentType: 'video/mp4',
              cacheControl: 'public,max-age=3600',
            ),
          );

          StreamSubscription<TaskSnapshot>? sub;
          sub = uploadTask.snapshotEvents.listen(
            (snapshot) {
              final total = snapshot.totalBytes == 0 ? 1 : snapshot.totalBytes;
              final progress = snapshot.bytesTransferred / total;
              debugPrint(
                '📊 Upload: ${(progress * 100).toStringAsFixed(0)}% (${snapshot.bytesTransferred}/$total)',
              );
            },
            onError: (e) {
              debugPrint('❌ snapshotEvents error: $e');
            },
          );

          final snap = await uploadTask.whenComplete(() {});
          await sub?.cancel();

          debugPrint('✅ Upload complete. State=${snap.state} bytes=${snap.bytesTransferred}');
          reelVideoUrl = await snap.ref.getDownloadURL();
          debugPrint('✅ Download URL: $reelVideoUrl');
        } on FirebaseException catch (e, st) {
          debugPrint('❌ Firebase Storage error: code=${e.code} message=${e.message}');
          debugPrint('Stack: $st');

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product created but video upload failed: ${e.code}'),
              duration: const Duration(seconds: 5),
            ),
          );

          setState(() => _saving = false);
          return;
        } catch (e, st) {
          debugPrint('❌ Video upload failed: $e');
          debugPrint('Stack trace: $st');

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product created but video upload failed: $e'),
              duration: const Duration(seconds: 5),
            ),
          );

          setState(() => _saving = false);
          return;
        }
      }

      // STEP 3: UPDATE PRODUCT WITH VIDEO URL (only if video was uploaded)
      if (reelVideoUrl != null && reelVideoUrl.isNotEmpty) {
        debugPrint('STEP 3: Updating product with videoUrl...');
        final updatedProduct = product.copyWith(
          videoUrl: reelVideoUrl,
          updatedAt: DateTime.now(),
        );
        await FirestoreProductsService.upsert(updatedProduct);
        debugPrint('✅ Product updated with videoUrl');

        // STEP 4: CREATE REEL DOCUMENT
        debugPrint('STEP 4: Creating reel document...');
        try {
          final reel = ReelModel(
            id: productId,
            productId: productId,
            sellerId: uid,
            videoUrl: reelVideoUrl,
            caption: _nameCtrl.text.trim(),
            category: _category.isEmpty ? 'Others' : _category,
            isActive: true,
            createdAt: now,
          );
          await FirestoreReelsService.upsert(reel);
          debugPrint('✅ Reel created successfully');
        } catch (e) {
          debugPrint('❌ Failed to create reel: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product saved but reel creation failed: $e')),
          );
        }
      }

      // STEP 5: SUCCESS UI
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product published successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Save product failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.primary,
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionCard(
                          title: 'Basic info',
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Product name',
                                prefixIcon: Icon(Icons.drive_file_rename_outline),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _priceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (v) {
                                final d = double.tryParse((v ?? '').trim());
                                if (d == null || d < 0) return 'Enter a valid price';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _category.isEmpty ? 'Others' : _category,
                              items: _categoryOptions
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) => setState(() => _category = v ?? 'Others'),
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.grid_view_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _stockCtrl,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Stock',
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              validator: (v) {
                                final i = int.tryParse((v ?? '').trim());
                                if (i == null || i < 0) return 'Enter stock';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descCtrl,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                prefixIcon: Icon(Icons.description_outlined),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Media',
                          children: [
                            Text('Photos', style: theme.textTheme.labelLarge),
                            const SizedBox(height: 8),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (int i = 0; i < _images.length; i++) _imageThumb(i),
                                  _addImageTile(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Video (Reel)', style: theme.textTheme.labelLarge),
                            const SizedBox(height: 8),
                            if (_selectedVideoBytes != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.video_library, color: theme.colorScheme.primary, size: 32),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedVideoName ?? 'Video',
                                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '${(_selectedVideoBytes!.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(() {
                                        _selectedVideoBytes = null;
                                        _selectedVideoName = null;
                                      }),
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      tooltip: 'Remove video',
                                    ),
                                  ],
                                ),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.video_library),
                                label: const Text('Add video'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Selling preferences',
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isNarrow = constraints.maxWidth < 400;
                                if (isNarrow) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        value: _condition,
                                        items: const [
                                          DropdownMenuItem(value: 'New', child: Text('New')),
                                          DropdownMenuItem(value: 'Like New', child: Text('Like New')),
                                          DropdownMenuItem(value: 'Good', child: Text('Good')),
                                          DropdownMenuItem(value: 'Fair', child: Text('Fair')),
                                          DropdownMenuItem(value: 'For Parts', child: Text('For Parts')),
                                        ],
                                        onChanged: (v) => setState(() => _condition = v ?? 'Good'),
                                        decoration: const InputDecoration(
                                          labelText: 'Condition',
                                          prefixIcon: Icon(Icons.fact_check_outlined),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _SwitchTile(
                                        title: 'Active',
                                        subtitle: 'Visible in catalog',
                                        value: _isActive,
                                        onChanged: (v) => setState(() => _isActive = v),
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _condition,
                                        items: const [
                                          DropdownMenuItem(value: 'New', child: Text('New')),
                                          DropdownMenuItem(value: 'Like New', child: Text('Like New')),
                                          DropdownMenuItem(value: 'Good', child: Text('Good')),
                                          DropdownMenuItem(value: 'Fair', child: Text('Fair')),
                                          DropdownMenuItem(value: 'For Parts', child: Text('For Parts')),
                                        ],
                                        onChanged: (v) => setState(() => _condition = v ?? 'Good'),
                                        decoration: const InputDecoration(
                                          labelText: 'Condition',
                                          prefixIcon: Icon(Icons.fact_check_outlined),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _SwitchTile(
                                        title: 'Active',
                                        subtitle: 'Visible in catalog',
                                        value: _isActive,
                                        onChanged: (v) => setState(() => _isActive = v),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            _SwitchTile(
                              title: 'Local pickup only',
                              value: _pickupOnly,
                              onChanged: (v) => setState(() => _pickupOnly = v),
                            ),
                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isVeryNarrow = constraints.maxWidth < 380;
                                if (isVeryNarrow) {
                                  return Column(
                                    children: [
                                      TextFormField(
                                        controller: _campusCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Campus / Community',
                                          prefixIcon: Icon(Icons.school_outlined),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _pickupLocationCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Pickup location',
                                          prefixIcon: Icon(Icons.place_outlined),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _campusCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Campus / Community',
                                          prefixIcon: Icon(Icons.school_outlined),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _pickupLocationCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Pickup location',
                                          prefixIcon: Icon(Icons.place_outlined),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            _SwitchTile(
                              title: 'Price negotiable',
                              value: _negotiable,
                              onChanged: (v) => setState(() => _negotiable = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_saving)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.inversePrimary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              onPressed: _saving ? null : _save,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Save changes' : 'Publish product',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addImageTile() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _imageThumb(int index) {
    final src = _images[index];
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 100,
            height: 100,
            child: _AnyImage(url: src),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black.withValues(alpha: 0.4),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => setState(() => _images.removeAt(index)),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: SwitchListTile.adaptive(
        dense: true,
        value: value,
        onChanged: onChanged,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
      ),
    );
  }
}

class _AnyImage extends StatelessWidget {
  final String url;
  const _AnyImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final src = url.trim();

    // ✅ Avoid Image.network('') which can cause URI errors
    if (src.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported, size: 40));
    }

    // Base64 data URLs
    if (src.startsWith('data:image')) {
      try {
        final base64Part = src.split(',').last;
        final bytes = base64Decode(base64Part);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (e) {
        debugPrint('Failed to decode base64 image: $e');
        return const Icon(Icons.broken_image, size: 50);
      }
    }

    // file:// URLs (simulator / local files)
    if (src.startsWith('file://')) {
      try {
        final filePath = Uri.parse(src).toFilePath();
        return Image.file(File(filePath), fit: BoxFit.cover);
      } catch (e) {
        debugPrint('Failed to load file image: $e');
        return const Icon(Icons.broken_image, size: 50);
      }
    }

    // Network URLs
    return Image.network(
      src,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
    );
  }
}
