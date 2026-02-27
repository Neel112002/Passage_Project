import 'package:flutter/material.dart';
import 'package:passage/theme.dart';

/// Placeholder Login screen (no backend wired yet)
/// Users can later connect Firebase/Supabase from Dreamflow's panel.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Login', style: context.textStyles.titleLarge?.semiBold)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(Icons.lock_outline, color: colors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Welcome to Passage', style: text.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text('Sign in to start buying and selling on your campus.', style: text.bodyMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.7)), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),

              // Email button (non-functional placeholder)
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mail_outline),
                label: const Text('Continue with Email'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.school_outlined),
                label: const Text('University SSO (coming soon)'),
              ),

              const Spacer(),
              Text(
                'Note: No backend is connected yet. To add auth, open the Firebase or Supabase panel in Dreamflow and complete setup.',
                style: text.labelSmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
