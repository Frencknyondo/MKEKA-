import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/mkeka_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class MkekaDetailScreen extends StatelessWidget {
  final Mkeka mkeka;
  final bool userHasVip;

  const MkekaDetailScreen({
    super.key,
    required this.mkeka,
    required this.userHasVip,
  });

  Future<void> _shareToWhatsApp() async {
    final text = '''
🎯 *${mkeka.title}*
👤 Tipster: ${mkeka.tipsterName}
${mkeka.totalOdds != null ? '📊 Total Odds: ${mkeka.totalOdds!.toStringAsFixed(2)}' : ''}
${mkeka.matchDate != null ? '📅 Tarehe: ${DateFormat('dd MMM yyyy').format(mkeka.matchDate!)}' : ''}

⬇️ Pakua app: MKEKA PLUS
_Smart Prediction Hub_
''';

    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(mkeka.title, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.neonGreen),
            onPressed: _shareToWhatsApp,
            tooltip: 'Share WhatsApp',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tipster row
          Row(
            children: [
              CircleAvatar(
                radius: 22,
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
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mkeka.tipsterName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    if (mkeka.matchDate != null)
                      Text(
                        DateFormat('dd MMM yyyy').format(mkeka.matchDate!),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ),
              StatusBadge(status: mkeka.status.name),
              if (mkeka.isVip) ...[const SizedBox(width: 6), const VipBadge()],
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          if (mkeka.totalOdds != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(
                      label: 'Total Odds',
                      value: mkeka.totalOdds!.toStringAsFixed(2)),
                  Container(width: 0.5, height: 32, color: AppColors.border),
                  _Stat(
                    label: 'Picha',
                    value: '${mkeka.imageUrls.length} screenshots',
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Description
          if (mkeka.description != null && mkeka.description!.isNotEmpty) ...[
            const Text('📝 Maelezo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                mkeka.description!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Images
          const Text('📸 Mkeka wa Leo',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),

          ...mkeka.imageUrls.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: entry.value,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(
                    height: 250,
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 100,
                    color: AppColors.surface,
                    child: const Center(
                      child:
                          Icon(Icons.broken_image, color: AppColors.textHint),
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Share button
          ElevatedButton.icon(
            onPressed: _shareToWhatsApp,
            icon: const Icon(Icons.share),
            label: const Text('Share kwa WhatsApp'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neonGreen)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
