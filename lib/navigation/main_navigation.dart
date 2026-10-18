import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/badges/badges_screen.dart';
import '../screens/review/review_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReviewScreen(),
    const BadgesScreen(),
    const ProfileScreen(),
  ];

  final List<String> _tabTitles = [
    'HỌC TẬP',
    'LUYỆN TẬP',
    'HUY HIỆU',
    'HỒ SƠ',
  ];

  final List<Color> _tabColors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.secondary,
    const Color(0xFF8E44AD),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFD6E4FF), width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD0E1FD),
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Color(0x18000000),
                offset: Offset(0, 10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabTitles.length, (index) {
              final isSelected = _currentIndex == index;
              final tabColor = _tabColors[index];
              final hsl = HSLColor.fromColor(tabColor);
              final shadowColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? tabColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: AppColors.cartoonBorder, width: 1.5)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: shadowColor,
                              offset: const Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _tabTitles[index],
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: isSelected ? 13 : 12,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
