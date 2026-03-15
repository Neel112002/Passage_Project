import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/nav.dart';
import 'package:passage/theme.dart';
import 'package:passage/widgets/profile_header.dart';
import 'package:passage/widgets/profile_listing_card.dart';
import 'package:provider/provider.dart';
import 'package:passage/services/item_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock user data (no backend yet)
  static const String _userName = 'You';
  static const String _university = 'Your Campus';
  static const String _joined = 'Joined Sep 2024';

  int _savedCount(List<ItemModel> all) => all.where((e) => e.isBookmarked).length;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Profile', style: text.titleLarge?.semiBold)),
      body: Consumer<ItemStore>(builder: (context, store, _) {
        final items = store.items;
        final myListings = store.getUserItems();
        final saved = _savedCount(items);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ProfileHeader(
                name: _userName,
                university: _university,
                joinedText: _joined,
                listingsCount: myListings.length,
                soldCount: (myListings.length / 3).floor(),
                savedCount: saved,
              ),

              // Section title
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Listings', style: text.titleLarge?.semiBold),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.grid_view_rounded, size: 18),
                      label: const Text('View All'),
                    )
                  ],
                ),
              ),

              // Listings grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: myListings.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final item = myListings[index];
                    return ProfileListingCard(
                      item: item,
                      onTap: () => context.push(AppRoutes.product, extra: item),
                    );
                  },
                ),
              ),

              // Menu title
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                child: Text('Menu', style: text.titleLarge?.semiBold),
              ),

              // Menu
              _MenuSection(onTap: (type) {
                final label = switch (type) {
                  _MenuType.saved => 'Saved Items',
                  _MenuType.edit => 'Edit Profile',
                  _MenuType.settings => 'Settings',
                  _MenuType.logout => 'Logout',
                };
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label tapped')));
              }),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.onTap});
  final void Function(_MenuType type) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget tile({required IconData icon, required String title, required _MenuType type}) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: colors.secondaryContainer,
            child: Icon(icon, color: colors.onSecondaryContainer),
          ),
          title: Text(title, style: text.titleMedium?.medium),
          trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          onTap: () => onTap(type),
        );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(children: [
        tile(icon: Icons.bookmark_rounded, title: 'Saved Items', type: _MenuType.saved),
        const Divider(height: 1),
        tile(icon: Icons.edit_rounded, title: 'Edit Profile', type: _MenuType.edit),
        const Divider(height: 1),
        tile(icon: Icons.settings_rounded, title: 'Settings', type: _MenuType.settings),
        const Divider(height: 1),
        tile(icon: Icons.logout_rounded, title: 'Logout', type: _MenuType.logout),
      ]),
    );
  }
}

enum _MenuType { saved, edit, settings, logout }
