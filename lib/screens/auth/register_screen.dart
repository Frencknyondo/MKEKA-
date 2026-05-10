import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await AuthService.registerWithEmail(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: _emailCtrl.text),
        ),
      );
    } else {
      showError(context, result.message);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);
    final result = await AuthService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);

    if (result.success) {
      // Auth state stream in main.dart will redirect automatically
    } else {
      showError(context, result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Logo / Brand
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.neonGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.sports_soccer,
                          color: AppColors.neonGreen,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'MKEKA PLUS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neonGreen,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Smart Prediction Hub',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Tengeneza Akaunti',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Jisajili kupata mabao bora ya leo',
                  style: TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 32),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Jina lako',
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppColors.textHint),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Weka jina lako';
                    if (v.trim().length < 2) return 'Jina ni fupi sana';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Anwani ya Email',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: AppColors.textHint),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Weka email yako';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Email si sahihi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Nywila',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.textHint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Weka nywila';
                    if (v.length < 6) return 'Nywila lazima iwe herufi 6+';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Email verification note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.neonGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.neonGreen, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Email yako itathibitishwa kabla ya kuingia. Angalia inbox yako.',
                          style: TextStyle(
                            color: AppColors.neonGreen,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Register button
                NeonButton(
                  label: 'Jisajili',
                  isLoading: _loading,
                  onTap: _register,
                ),

                const SizedBox(height: 20),
                const OrDivider(),
                const SizedBox(height: 20),

                // Google Sign In
                GoogleSignInButton(
                  isLoading: _googleLoading,
                  onTap: _googleSignIn,
                ),

                const SizedBox(height: 32),

                // Login link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                        children: [
                          TextSpan(text: 'Una akaunti tayari? '),
                          TextSpan(
                            text: 'Ingia',
                            style: TextStyle(
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
