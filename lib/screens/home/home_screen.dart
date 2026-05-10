import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/mkeka_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../vip/vip_subscription_screen.dart';
import 'mkeka_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MKEKA PLUS',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neonGreen,
                    letterSpacing: 1.5)),
            Text('Habari ${user.name.split(' ').first}!',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          if (user.isSubscriptionActive)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: VipBadge(),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => VipSubscriptionScreen(userId: user.id)),
                ),
                child: const Text('Pata VIP 👑',
                    style: TextStyle(
                        color: AppColors.vipGold, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<Mkeka>>(
        stream: FirestoreService.streamAllMkekas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen),
            );
          }

          final mkekas = snapshot.data ?? [];
          final featured = mkekas.where((m) => m.isFeatured).toList();
          final free = mkekas.where((m) => !m.isVip).toList();
          final vip = mkekas.where((m) => m.isVip).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // VIP Banner (if not subscribed)
              if (!user.isSubscriptionActive) ...[
                _VipPromoCard(
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  VipSubscriptionScreen(userId: user.id)),
                        )),
                const SizedBox(height: 16),
              ],

              // Featured
              if (featured.isNotEmpty) ...[
                const _SectionHeader(title: '🔥 Featured'),
                const SizedBox(height: 10),
                ...featured.map((m) => _MkekaCard(
                    mkeka: m,
                    isVip: user.isSubscriptionActive,
                    context: context)),
                const SizedBox(height: 20),
              ],

              // Free mkekas
              const _SectionHeader(title: '⚽ Free Tips Leo'),
              const SizedBox(height: 10),
              if (free.isEmpty)
                const _EmptyState(
                    message: 'Hakuna tips za bure sasa. Rudi baadaye.')
              else
                ...free.map(
                    (m) => _MkekaCard(mkeka: m, isVip: true, context: context)),

              const SizedBox(height: 20),

              // VIP mkekas
              const _SectionHeader(title: '👑 VIP Predictions'),
              const SizedBox(height: 4),
              if (!user.isSubscriptionActive)
                const Text(
                  'Subscribe kupata access ya mabao ya VIP',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              const SizedBox(height: 10),
              if (vip.isEmpty)
                const _EmptyState(message: 'Hakuna VIP tips kwa sasa.')
              else
                ...vip.map((m) => _MkekaCard(
                      mkeka: m,
                      isVip: user.isSubscriptionActive,
                      context: context,
                      onLockedTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                VipSubscriptionScreen(userId: user.id)),
                      ),
                    )),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

// ─── SECTION HEADER ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

// ─── VIP PROMO CARD ───────────────────────────────────────────────────────────

class _VipPromoCard extends StatelessWidget {
  final VoidCallback onTap;
  const _VipPromoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1400), Color(0xFF2A2000)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.vipGold.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pata VIP Access',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.vipGold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Mabao ya siri ya VIP kuanzia 1,000 TZS/siku',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.vipGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Subscribe',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MKEKA CARD ───────────────────────────────────────────────────────────────

class _MkekaCard extends StatelessWidget {
  final Mkeka mkeka;
  final bool isVip; // user has VIP access
  final BuildContext context;
  final VoidCallback? onLockedTap;

  const _MkekaCard({
    required this.mkeka,
    required this.isVip,
    required this.context,
    this.onLockedTap,
  });

  bool get _canAccess => !mkeka.isVip || isVip;

  @override
  Widget build(BuildContext _) {
    return GestureDetector(
      onTap: () {
        if (_canAccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MkekaDetailScreen(mkeka: mkeka, userHasVip: isVip),
            ),
          );
        } else {
          onLockedTap?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mkeka.isFeatured
                ? AppColors.neonGreen.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Tipster avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.neonGreen.withValues(alpha: 0.2),
                    backgroundImage: mkeka.tipsterPhotoUrl != null
                        ? CachedNetworkImageProvider(mkeka.tipsterPhotoUrl!)
                        : null,
                    child: mkeka.tipsterPhotoUrl == null
                        ? Text(
                            mkeka.tipsterName.isNotEmpty
                                ? mkeka.tipsterName[0].toUpperCase()
                                : 'T',
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mkeka.tipsterName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          mkeka.title,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: mkeka.status.name),
                  if (mkeka.isVip) ...[
                    const SizedBox(width: 6),
                    const VipBadge(),
                  ],
                ],
              ),
            ),

            // Image(s) — blurred if locked
            if (mkeka.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: _canAccess
                    ? _ImageView(imageUrls: mkeka.imageUrls)
                    : _LockedImageView(imageUrls: mkeka.imageUrls),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── IMAGE VIEW (unlocked) ───────────────────────────────────────────────────

class _ImageView extends StatelessWidget {
  final List<String> imageUrls;
  const _ImageView({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: imageUrls.map((url) {
        return CachedNetworkImage(
          imageUrl: url,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            height: 200,
            color: AppColors.surface,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.neonGreen,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 100,
            color: AppColors.surface,
            child: const Icon(Icons.broken_image, color: AppColors.textHint),
          ),
        );
      }).toList(),
    );
  }
}

// ─── LOCKED IMAGE VIEW ────────────────────────────────────────────────────────

class _LockedImageView extends StatelessWidget {
  final List<String> imageUrls;
  const _LockedImageView({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred first image
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black54,
            BlendMode.darken,
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrls.first,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(height: 180, color: AppColors.surface),
          ),
        ),
        // Blur overlay using shader mask effect
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        // Lock icon + CTA
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.vipGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.vipGold.withValues(alpha: 0.5)),
                ),
                child:
                    const Icon(Icons.lock, color: AppColors.vipGold, size: 28),
              ),
              const SizedBox(height: 10),
              const Text(
                'VIP Content',
                style: TextStyle(
                  color: AppColors.vipGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Subscribe kuona mkeka huu',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(message,
          style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
    );
  }
}
