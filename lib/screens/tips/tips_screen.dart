import 'package:flutter/material.dart';
import '../../models/tip_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

class TipsScreen extends StatelessWidget {
  final AppUser user;

  const TipsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tips')),
      body: StreamBuilder<List<AppTip>>(
        stream: FirestoreService.streamTips(),
        builder: (context, snapshot) {
          final allTips = snapshot.data ?? [];
          final visibleTips = allTips
              .where((tip) => !tip.isVip || user.isSubscriptionActive)
              .toList();
          final lockedVipCount = allTips
              .where((tip) => tip.isVip && !user.isSubscriptionActive)
              .length;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            children: [
              if (visibleTips.isEmpty)
                const _EmptyTips()
              else
                ...visibleTips.map((tip) => _TipCard(tip: tip)),
              if (lockedVipCount > 0)
                _LockedVipCard(count: lockedVipCount),
              if (user.role == UserRole.tipster)
                _TipActionCard(
                  icon: Icons.analytics_outlined,
                  title: 'My Tipster Stats',
                  subtitle: 'Hapa tutaweka history na performance zako.',
                  onTap: () {},
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final AppTip tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tip.isVip
                    ? Icons.workspace_premium_outlined
                    : Icons.tips_and_updates_outlined,
                color: tip.isVip ? AppColors.vipGold : AppColors.neonGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (tip.isVip ? AppColors.vipGold : AppColors.neonGreen)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tip.isVip ? 'VIP' : 'Free',
                  style: TextStyle(
                    color: tip.isVip ? AppColors.vipGold : AppColors.neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tip.content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedVipCard extends StatelessWidget {
  final int count;

  const _LockedVipCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return _TipActionCard(
      icon: Icons.lock_outline,
      title: 'VIP Tips zimefungwa',
      subtitle: 'Kuna VIP tips $count. Subscribe ili kuziona.',
      onTap: () {},
    );
  }
}

class _EmptyTips extends StatelessWidget {
  const _EmptyTips();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Hakuna tips kwa sasa. Rudi tena baadaye.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
