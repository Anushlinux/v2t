import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../common/services/auth_repository.dart';
import '../../common/theme/app_theme.dart';
import '../../common/widgets/glass_container.dart';
import '../../common/widgets/glass_button.dart';
import '../../common/widgets/agent_orb.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authRepository = AuthRepository();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spacingXXL),
                // Welcome Section
                Center(
                  child: Column(
                    children: [
                      const AgentOrb(state: AgentOrbState.idle, size: 100),
                      const SizedBox(height: AppTheme.spacingXL),
                      Text(
                        'Welcome!',
                        style: AppTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      if (user != null)
                        Text(
                          user.email ?? 'No email',
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXXL),
                // User Info Card
                if (user != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: AppTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: AppTheme.accentPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Expanded(
                              child: Text(
                                user.email ?? 'No email',
                                style: AppTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppTheme.spacingXL),
                // Action Cards
                GlassContainer(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions', style: AppTheme.headlineSmall),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Get started by using voice transcription',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                // Sign Out Button
                GlassButton(
                  label: 'Sign Out',
                  icon: Icons.logout,
                  onPressed: () async {
                    await authRepository.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  isPrimary: false,
                ),
                const SizedBox(height: AppTheme.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
