import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await AuthService.sendPasswordReset(_emailCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      setState(() => _sent = true);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Badilisha Nywila'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent ? _sentView() : _formView(),
        ),
      ),
    );
  }

  Widget _formView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.lock_reset, color: AppColors.neonGreen, size: 48),
          const SizedBox(height: 20),
          const Text(
            'Umesahau Nywila?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Weka email yako, tutatumia kiungo cha kubadilisha nywila.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email yako',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Weka email yako';
              if (!v.contains('@')) return 'Email si sahihi';
              return null;
            },
          ),
          const SizedBox(height: 24),
          NeonButton(label: 'Tuma Kiungo', isLoading: _loading, onTap: _send),
        ],
      ),
    );
  }

  Widget _sentView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline,
            color: AppColors.neonGreen, size: 80),
        const SizedBox(height: 24),
        const Text(
          'Email Imetumwa!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Angalia inbox ya ${_emailCtrl.text} na bonyeza kiungo cha kubadilisha nywila.',
          style: const TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        NeonButton(
          label: 'Rudi Login',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
