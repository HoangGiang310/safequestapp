import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../welcome/welcome_screen.dart';
import '../../navigation/main_navigation.dart';
import '../profile/create_profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    // Wait until initialized
    while (!provider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;

    if (provider.isLoggedIn) {
      if (provider.isAdmin) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
      } else {
        if (provider.profile != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigation()));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const CreateProfileScreen()));
        }
      }
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomeScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cartoon Hero Badge
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(color: AppColors.cartoonBorder, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryDark,
                        offset: Offset(0, 7),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('🛡️', style: TextStyle(fontSize: 68)),
                ),
                const SizedBox(height: 28),

                // App Brand
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cartoonBorder,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'SAFEQUEST',
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 2.0,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'Học kỹ năng an toàn\nqua những chuyến phiêu lưu diệu kỳ',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // Bubbly Loading Tube
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cartoonBorder, width: 2),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.cartoonYellow),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
