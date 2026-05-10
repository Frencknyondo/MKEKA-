import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _arena1Controller;
  late AnimationController _arena2Controller;
  late AnimationController _dishController;
  late AnimationController _plusController;

  late Animation<Offset> _logoSlide;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _arena1Slide;
  late Animation<double> _arena1Opacity;
  late Animation<Offset> _arena2Slide;
  late Animation<double> _arena2Opacity;
  late Animation<Offset> _dishSlide;
  late Animation<double> _dishOpacity;
  late Animation<Offset> _plusSlide;
  late Animation<double> _plusOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToHome();
  }

  void _setupAnimations() {
    // Logo animation (slower entry)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Arena icons animations (staggered)
    _arena1Controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _arena1Slide = Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _arena1Controller, curve: Curves.easeOut));
    _arena1Opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _arena1Controller, curve: Curves.easeIn));

    _arena2Controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _arena2Slide = Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _arena2Controller, curve: Curves.easeOut));
    _arena2Opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _arena2Controller, curve: Curves.easeIn));

    // Dish animation
    _dishController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _dishSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _dishController, curve: Curves.easeOut));
    _dishOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _dishController, curve: Curves.easeIn));

    // Plus animation (appears last)
    _plusController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _plusSlide = Tween<Offset>(begin: const Offset(0.2, -0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _plusController, curve: Curves.easeOut));
    _plusOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _plusController, curve: Curves.easeIn));

    // Sequential animation start
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _arena1Controller.forward();
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      _arena2Controller.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _dishController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _plusController.forward();
    });
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _arena1Controller.dispose();
    _arena2Controller.dispose();
    _dishController.dispose();
    _plusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade/slide animation
            FadeTransition(
              opacity: _logoOpacity,
              child: SlideTransition(
                position: _logoSlide,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/splash.png',
                    width: 240,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Arena/Dish/Plus elements row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Arena 1 (left)
                FadeTransition(
                  opacity: _arena1Opacity,
                  child: SlideTransition(
                    position: _arena1Slide,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Dish (center)
                FadeTransition(
                  opacity: _dishOpacity,
                  child: SlideTransition(
                    position: _dishSlide,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.vipGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Plus/Arena 2 (right)
                FadeTransition(
                  opacity: _arena2Opacity,
                  child: SlideTransition(
                    position: _arena2Slide,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.lost,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Plus badge (top right corner)
            FadeTransition(
              opacity: _plusOpacity,
              child: SlideTransition(
                position: _plusSlide,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.neonGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
            // App name with fade
            FadeTransition(
              opacity: _logoOpacity,
              child: const BrandLogo(size: 72, dark: true),
            ),
          ],
        ),
      ),
    );
  }
}
