import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../common/theme/app_theme.dart';
import '../../common/widgets/glass_container.dart';
import '../../common/widgets/agent_orb.dart';
import 'home_page.dart';
import '../voice/voice_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const HomePage(),
    const VoicePage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Route guarding: if user is not authenticated, redirect to login
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPrimary),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildGlassNavigationBar(),
    );
  }

  Widget _buildGlassNavigationBar() {
    return GlassContainer(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.mic_none,
            selectedIcon: Icons.mic,
            label: 'Voice',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _animationController.forward(from: 0.0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.glassBorderRadius),
          color: isSelected
              ? AppTheme.accentPrimary.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? AppTheme.accentPrimary
                  : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: isSelected
                    ? AppTheme.accentPrimary
                    : AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      const AgentOrb(state: AgentOrbState.idle, size: 100),
                      const SizedBox(height: AppTheme.spacingXL),
                      Text(
                        'Profile',
                        style: AppTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXXL),
                // Profile Info Card
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
                const SizedBox(height: AppTheme.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
