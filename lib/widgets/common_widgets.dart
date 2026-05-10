import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final bool dark;
  final BoxFit fit;

  const BrandLogo({
    super.key,
    this.size = 72,
    this.dark = false,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        dark ? 'assets/images/dark_logo.png' : 'assets/images/app_logo.png',
        width: size,
        height: size,
        fit: fit,
      ),
    );
  }
}

// ─── NEON BUTTON ─────────────────────────────────────────────────────────────

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? prefix;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefix != null) ...[prefix!, const SizedBox(width: 10)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

// ─── GOOGLE BUTTON ───────────────────────────────────────────────────────────

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const GoogleSignInButton({super.key, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.neonGreen,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleIcon(),
                  const SizedBox(width: 12),
                  const Text(
                    'Ingia na Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Simple G logo using arcs and paths
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue arc (top)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5,
      3.14,
      true,
      paint,
    );

    // Red arc (bottom right)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.65,
      1.6,
      true,
      paint,
    );

    // Green arc (bottom left)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.25,
      0.8,
      true,
      paint,
    );

    // White center
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);

    // Blue right bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - radius * 0.15,
        radius,
        radius * 0.3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── OR DIVIDER ───────────────────────────────────────────────────────────────

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'AU',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

// ─── VIP BADGE ────────────────────────────────────────────────────────────────

class VipBadge extends StatelessWidget {
  const VipBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.vipGold, AppColors.vipGoldDark],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '👑 VIP',
        style: TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── STATUS BADGE ─────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'won':
        color = AppColors.won;
        label = '✅ WON';
        break;
      case 'lost':
        color = AppColors.lost;
        label = '❌ LOST';
        break;
      case 'void_':
        color = AppColors.void_;
        label = '⚪ VOID';
        break;
      default:
        color = const Color(0xFFFFB800);
        label = '🕐 PENDING';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── SNACKBAR HELPERS ─────────────────────────────────────────────────────────

void showSuccess(BuildContext context, String message) {
  _showCenterAlert(
    context,
    message: message,
    icon: Icons.check_circle,
    color: AppColors.neonGreenDark,
    duration: const Duration(seconds: 3),
  );
}

void showError(BuildContext context, String message) {
  _showCenterAlert(
    context,
    message: message,
    icon: Icons.error_outline,
    color: AppColors.lost,
    duration: const Duration(seconds: 4),
  );
}

void _showCenterAlert(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Color color,
  required Duration duration,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Alert',
    barrierColor: Colors.black.withValues(alpha: 0.38),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.sizeOf(context).width.clamp(0, 360).toDouble(),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );

  Future.delayed(duration, () {
    if (navigator.canPop()) {
      navigator.pop();
    }
  });
}
