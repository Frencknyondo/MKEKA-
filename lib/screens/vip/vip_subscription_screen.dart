import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class VipSubscriptionScreen extends StatefulWidget {
  final String userId;
  const VipSubscriptionScreen({super.key, required this.userId});

  @override
  State<VipSubscriptionScreen> createState() => _VipSubscriptionScreenState();
}

class _VipSubscriptionScreenState extends State<VipSubscriptionScreen> {
  String _selectedPlan = 'weekly'; // default
  String _selectedPayment = 'mpesa';
  bool _loading = false;

  final _plans = [
    {
      'id': 'daily',
      'name': 'Daily',
      'price': '1,000',
      'period': 'Siku 1',
      'emoji': '⚡'
    },
    {
      'id': 'weekly',
      'name': 'Weekly',
      'price': '3,000',
      'period': 'Wiki 1',
      'emoji': '🔥',
      'popular': true
    },
    {
      'id': 'monthly',
      'name': 'Monthly',
      'price': '10,000',
      'period': 'Mwezi 1',
      'emoji': '💎'
    },
  ];

  Future<void> _subscribe() async {
    setState(() => _loading = true);
    // In real app: trigger M-Pesa STK push here, then wait for callback
    // For MVP: simulate with manual ref
    await Future.delayed(const Duration(seconds: 2));

    await FirestoreService.grantVip(
      userId: widget.userId,
      plan: _selectedPlan,
      paymentMethod: _selectedPayment,
      transactionRef: 'MANUAL-${DateTime.now().millisecondsSinceEpoch}',
    );

    if (!mounted) return;
    setState(() => _loading = false);
    showSuccess(context, '🎉 Umefanikiwa! VIP imewashwa.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('VIP Subscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            const Center(
              child: Column(
                children: [
                  Text('👑', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 10),
                  Text(
                    'Pata VIP Access',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.vipGold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Fungua mabao ya siri ya VIP',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Benefits
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.vipGold.withValues(alpha: 0.2)),
              ),
              child: const Column(
                children: [
                  _Benefit(icon: '📸', text: 'Mabao ya VIP ya kila siku'),
                  _Benefit(icon: '🎯', text: 'Mabao ya Confidence ya juu'),
                  _Benefit(
                      icon: '🔔',
                      text: 'Notifications za kwanza kabla ya wote'),
                  _Benefit(
                      icon: '📊', text: 'History kamili ya wins za tipsters'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Plan selection
            const Text('Chagua Mpango',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Row(
              children: _plans.map((plan) {
                final selected = _selectedPlan == plan['id'];
                final isPopular = plan['popular'] == true;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedPlan = plan['id'] as String),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.vipGold.withValues(alpha: 0.1)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              selected ? AppColors.vipGold : AppColors.border,
                          width: selected ? 2 : 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.vipGold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Bora',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                            ),
                          if (isPopular) const SizedBox(height: 4),
                          Text(plan['emoji'] as String,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(plan['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            '${plan['price']} TZS',
                            style: TextStyle(
                              color: selected
                                  ? AppColors.vipGold
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            plan['period'] as String,
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Payment method
            const Text('Njia ya Malipo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            _PaymentOption(
              id: 'mpesa',
              label: 'M-Pesa (Vodacom)',
              emoji: '📱',
              selected: _selectedPayment == 'mpesa',
              onTap: () => setState(() => _selectedPayment = 'mpesa'),
            ),
            const SizedBox(height: 8),
            _PaymentOption(
              id: 'airtel',
              label: 'Airtel Money',
              emoji: '📲',
              selected: _selectedPayment == 'airtel',
              onTap: () => setState(() => _selectedPayment = 'airtel'),
            ),

            const SizedBox(height: 32),

            // Subscribe button
            NeonButton(
              label: _loading ? 'Inachakata...' : '👑 Subscribe Sasa',
              isLoading: _loading,
              onTap: _subscribe,
            ),

            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Malipo yanakuwa processed kwa usalama.',
                style: TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final String icon;
  final String text;
  const _Benefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String id;
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.neonGreen : AppColors.border,
            width: selected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.neonGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
