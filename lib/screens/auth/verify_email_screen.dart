import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _checkTimer;
  bool _resending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Poll every 3 seconds to check if email was verified
    _checkTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _checkVerification());
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (refreshedUser?.emailVerified ?? false) {
      _checkTimer?.cancel();
      await AuthService.markEmailVerified(refreshedUser!.uid);
      await refreshedUser.getIdToken(true);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    setState(() => _resending = true);
    final result = await AuthService.resendVerificationEmail();
    if (!mounted) return;
    setState(() {
      _resending = false;
      _resendCooldown = 60;
    });
    if (result.success) {
      showSuccess(context, result.message);
      // Start cooldown timer
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) t.cancel();
        });
      });
    } else {
      showError(context, result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () async {
            await AuthService.signOut();
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation / Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.neonGreen.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: AppColors.neonGreen,
                  size: 50,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Thibitisha Email Yako',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                'Tumeshatuma email ya uthibitisho kwenda:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                widget.email,
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    _Step(number: '1', text: 'Fungua inbox ya email yako'),
                    SizedBox(height: 10),
                    _Step(number: '2', text: 'Bonyeza kiungo cha uthibitisho'),
                    SizedBox(height: 10),
                    _Step(
                        number: '3',
                        text: 'Rudu hapa — utaingia moja kwa moja'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Loading indicator
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.neonGreen,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Inasubiri uthibitisho...',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Resend button
              GestureDetector(
                onTap: _resendCooldown > 0 ? null : _resend,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _resendCooldown > 0
                          ? AppColors.border
                          : AppColors.neonGreen.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _resending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.neonGreen,
                            ),
                          )
                        : Text(
                            _resendCooldown > 0
                                ? 'Tuma tena baada ya ${_resendCooldown}s'
                                : 'Tuma Email Tena',
                            style: TextStyle(
                              color: _resendCooldown > 0
                                  ? AppColors.textHint
                                  : AppColors.neonGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Angalia spam/junk folder kama hupata email',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
