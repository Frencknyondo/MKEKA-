import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/app_bottom_nav.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'tips/tips_screen.dart';
import 'tipster/post_mkeka_screen.dart';

class MainShell extends StatefulWidget {
  final AppUser user;

  const MainShell({super.key, required this.user});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  bool get _isTipster => widget.user.role == UserRole.tipster;

  List<Widget> get _pages {
    final pages = <Widget>[
      HomeScreen(user: widget.user),
      TipsScreen(user: widget.user),
    ];

    if (_isTipster) {
      pages.add(PostMkekaScreen(tipster: widget.user));
    }

    pages.add(ProfileScreen(user: widget.user));
    return pages;
  }

  List<AppBottomNavItem> get _navItems {
    final items = <AppBottomNavItem>[
      const AppBottomNavItem(icon: Icons.home_rounded, label: 'Home'),
      const AppBottomNavItem(icon: Icons.tips_and_updates_outlined, label: 'Tips'),
    ];

    if (_isTipster) {
      items.add(
        const AppBottomNavItem(icon: Icons.add_circle_outline, label: 'Post'),
      );
    }

    items.add(
      const AppBottomNavItem(icon: Icons.person_outline, label: 'Profile'),
    );
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNav(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
