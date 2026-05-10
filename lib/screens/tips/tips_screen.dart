import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class TipsScreen extends StatelessWidget {
  final AppUser user;

  const TipsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tips')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
        children: [
          _TipActionCard(
            icon: Icons.sports_soccer,
            title: 'Free Tips',
            subtitle: 'Tips za kawaida kwa watumiaji wote.',
            onTap: () {},
          ),
          _TipActionCard(
            icon: Icons.workspace_premium_outlined,
            title: 'VIP Tips',
            subtitle: user.isSubscriptionActive
                ? 'Una access ya VIP tips.'
                : 'Subscribe ili kufungua VIP tips.',
            onTap: () {},
          ),
          if (user.role == UserRole.tipster)
            _TipActionCard(
              icon: Icons.analytics_outlined,
              title: 'My Tipster Stats',
              subtitle: 'Hapa tutaweka history na performance zako.',
              onTap: () {},
            ),
        ],
      ),
    );
  }
}

class _TipActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TipActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.neonGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textHint,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
