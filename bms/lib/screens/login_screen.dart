import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Row(
          children: [
            if (isWide) Expanded(flex: 6, child: _BrandPanel()),
            Expanded(
              flex: isWide ? 5 : 10,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _LoginForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      rememberMe: _rememberMe,
                      isSubmitting: _isSubmitting,
                      isWide: isWide,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleRemember: (v) =>
                          setState(() => _rememberMe = v ?? false),
                      onSubmit: _handleLogin,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Left-hand brand panel shown on wide screens — mirrors the primary-heavy
/// treatment used in the dashboard's Schedule card header.
class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.all(48),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -60,
            child: _GhostCircle(size: 240, opacity: 0.08),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: _GhostCircle(size: 180, opacity: 0.08),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.shield, color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  'Barangay Digital Hub',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLg.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Official portal for barangay administration —\nresidents, requests, and peace & order in one place.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _GhostCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isSubmitting;
  final bool isWide;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isSubmitting,
    required this.isWide,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isWide) ...[
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.shield, color: AppColors.primary, size: 30),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Welcome back, Chairman',
            style: AppTextStyles.headlineLg.copyWith(
              color: AppColors.primary,
              fontSize: isWide ? 32 : 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to access the admin dashboard.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          Text('Email or Username',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyMd,
            decoration: _fieldDecoration(
              hint: 'juan.delacruz@barangay.gov.ph',
              icon: Icons.mail_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email or username';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          Text('Password',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface)),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: AppTextStyles.bodyMd,
            decoration: _fieldDecoration(
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.outline,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: rememberMe,
                      onChanged: onToggleRemember,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Remember me',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text('Forgot password?',
                    style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text('Sign In',
                      style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: Divider(color: AppColors.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR',
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.outline)),
              ),
              Expanded(child: Divider(color: AppColors.outlineVariant)),
            ],
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.badge_outlined, size: 20, color: AppColors.primary),
            label: Text('Sign in with National ID',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.surfaceContainerLowest,
              side: BorderSide(color: AppColors.primaryContainer, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text.rich(
              TextSpan(
                text: "Need access? ",
                style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                children: [
                  TextSpan(
                    text: 'Contact your system administrator',
                    style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.outline, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(AppColors.primary, width: 1.6),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 1.6),
    );
  }
}
