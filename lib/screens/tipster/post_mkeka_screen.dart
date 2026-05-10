import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PostMkekaScreen extends StatefulWidget {
  final AppUser tipster;

  const PostMkekaScreen({super.key, required this.tipster});

  @override
  State<PostMkekaScreen> createState() => _PostMkekaScreenState();
}

class _PostMkekaScreenState extends State<PostMkekaScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _oddsCtrl = TextEditingController();
  final _imageUrlCtrls = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  bool _isVip = false;
  bool _loading = false;
  DateTime? _matchDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _oddsCtrl.dispose();
    for (final controller in _imageUrlCtrls) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonGreen,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _matchDate = picked);
  }

  Future<void> _post() async {
    if (_titleCtrl.text.trim().isEmpty) {
      showError(context, 'Weka kichwa cha mkeka wako.');
      return;
    }

    final imageUrls = _imageUrlCtrls.map((c) => c.text.trim()).toList();
    if (imageUrls.every((url) => url.isEmpty)) {
      showError(context, 'Weka link angalau moja ya picha ya mkeka.');
      return;
    }

    setState(() => _loading = true);

    final result = await FirestoreService.postMkekaWithImageUrls(
      tipster: widget.tipster,
      title: _titleCtrl.text,
      imageUrls: imageUrls,
      description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
      isVip: _isVip,
      totalOdds: double.tryParse(_oddsCtrl.text),
      matchDate: _matchDate,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      showSuccess(context, result.message);
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _titleCtrl.clear();
      _descCtrl.clear();
      _oddsCtrl.clear();
      for (final controller in _imageUrlCtrls) {
        controller.clear();
      }
      setState(() {
        _isVip = false;
        _matchDate = null;
      });
    } else {
      showError(context, result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Chapisha Mkeka',
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Kichwa cha Mkeka',
                prefixIcon: Icon(Icons.title, color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _oddsCtrl,
              style: const TextStyle(fontSize: 13),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total Odds (optional)',
                prefixIcon:
                    Icon(Icons.calculate_outlined, color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              style: const TextStyle(fontSize: 13),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Maelezo ya ziada (optional)',
                prefixIcon: Icon(Icons.notes, color: AppColors.textHint),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _matchDate == null
                          ? 'Chagua tarehe ya mechi (optional)'
                          : 'Tarehe: ${_matchDate!.day}/${_matchDate!.month}/${_matchDate!.year}',
                      style: TextStyle(
                        color: _matchDate == null
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isVip
                      ? AppColors.vipGold.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: AppColors.vipGold,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIP Mkeka',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'VIP users peke yao wataona mkeka huu',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isVip,
                    onChanged: (value) => setState(() => _isVip = value),
                    activeThumbColor: AppColors.vipGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Image Links za Mkeka',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text(
              'Firestore itahifadhi links tu. Weka direct image URL 1 hadi 3.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 12),
            ...List.generate(_imageUrlCtrls.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _imageUrlCtrls[index],
                  style: const TextStyle(fontSize: 13),
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: index == 0
                        ? 'Image URL ${index + 1} (required)'
                        : 'Image URL ${index + 1} (optional)',
                    prefixIcon: const Icon(
                      Icons.link,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.18),
                ),
              ),
              child: const Text(
                'Note: assets/images ni read-only baada ya app kujengwa. Kama picha za gallery zinahitaji kuonekana kwa users wote, tutatumia Firebase Storage au image hosting.',
                style: TextStyle(color: AppColors.neonGreen, fontSize: 11),
              ),
            ),
            const SizedBox(height: 28),
            NeonButton(
              label: _isVip ? 'Chapisha VIP Mkeka' : 'Chapisha Free Mkeka',
              isLoading: _loading,
              onTap: _post,
            ),
          ],
        ),
      ),
    );
  }
}
