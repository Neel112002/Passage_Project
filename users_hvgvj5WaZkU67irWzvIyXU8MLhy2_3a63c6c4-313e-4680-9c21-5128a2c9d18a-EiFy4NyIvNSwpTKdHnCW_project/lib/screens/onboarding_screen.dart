import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/nav.dart';
import 'package:passage/theme.dart';
import 'package:passage/widgets/page_dots.dart';

/// Three-step onboarding for Passage
/// - Modern, minimal design using brand theme
/// - Smooth page indicator dots
/// - Final CTA navigates to Login screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toLogin(BuildContext context) => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          child: Column(
            children: [
              // Top bar with brand icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(Icons.storefront, color: colors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Pages
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (v) => setState(() => _index = v),
                  children: const [
                    _OnboardingPage(
                      title: 'Campus Marketplace Made Easy',
                      description: 'Discover deals from students near you. Post items in seconds — all in one place.',
                      icon: Icons.shopping_bag_outlined,
                    ),
                    _OnboardingPage(
                      title: 'Buy & Sell Safely',
                      description: 'Verified student access keeps your campus community trusted and secure.',
                      icon: Icons.verified_user_outlined,
                    ),
                    _OnboardingPage(
                      title: 'Chat & Meet Locally',
                      description: 'Message classmates, agree on a spot, and finish the handoff — fast.',
                      icon: Icons.chat_bubble_outline,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Bottom controls: indicator + CTA on last page
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: PageDots(
                        activeIndex: _index,
                        count: 3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _index == 2
                    ? SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const ValueKey('cta'),
                          onPressed: () => _toLogin(context),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Get Started'),
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('spacer'),
                        height: 48,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single onboarding page with illustration placeholder, title, and description
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.title, required this.description, required this.icon});

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.lg),
        // Illustration placeholder
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.primary.withValues(alpha: 0.15), width: 1),
          ),
          child: Icon(icon, color: colors.primary, size: 84),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(title, style: text.headlineSmall?.copyWith(letterSpacing: -0.2), textAlign: TextAlign.center),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            description,
            style: text.bodyMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.7), height: 1.5),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
