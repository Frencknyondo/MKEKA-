import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/cloudinary_service.dart';
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
  final _picker = ImagePicker();
  final List<XFile> _pickedImages = [];

  bool _isVip = false;
  bool _loading = false;
  DateTime? _matchDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _oddsCtrl.dispose();
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

  Future<void> _pickImages() async {
    if (_pickedImages.length >= 3) {
      showError(context, 'Unaweza kuweka picha zisizozidi 3.');
      return;
    }

    final images = await _picker.pickMultiImage(imageQuality: 82);
    if (images.isEmpty) return;

    final remainingSlots = 3 - _pickedImages.length;
    setState(() {
      _pickedImages.addAll(images.take(remainingSlots));
    });

    if (images.length > remainingSlots && mounted) {
      showError(context, 'Tumepokea picha 3 tu kwa mkeka mmoja.');
    }
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  Future<void> _post() async {
    if (_titleCtrl.text.trim().isEmpty) {
      showError(context, 'Weka kichwa cha mkeka wako.');
      return;
    }

    if (_pickedImages.isEmpty) {
      showError(context, 'Chagua angalau picha moja ya mkeka.');
      return;
    }

    setState(() => _loading = true);

    final imageUrls = <String>[];
    for (final image in _pickedImages) {
      try {
        final url = await CloudinaryService.uploadImage(File(image.path));
        if (url == null) {
          throw const CloudinaryUploadException('Cloudinary haijarudisha URL.');
        }
        imageUrls.add(url);
      } on CloudinaryUploadException catch (e) {
        if (!mounted) return;
        setState(() => _loading = false);
        showError(
          context,
          'Upload imeshindikana: ${e.message}',
        );
        return;
      } catch (_) {
        if (!mounted) return;
        setState(() => _loading = false);
        showError(context, 'Upload ya picha imeshindikana. Jaribu tena.');
        return;
      }
    }

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
      setState(() {
        _isVip = false;
        _matchDate = null;
        _pickedImages.clear();
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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Picha za Mkeka',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Text(
                  '${_pickedImages.length}/3',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _loading ? null : _pickImages,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.neonGreen,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chagua picha kutoka gallery',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            if (_pickedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 94,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pickedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_pickedImages[index].path),
                            width: 94,
                            height: 94,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: _loading ? null : () => _removeImage(index),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.62),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
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
                'Picha zita-uploadiwa Cloudinary, kisha Firestore itahifadhi image URLs tu.',
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
