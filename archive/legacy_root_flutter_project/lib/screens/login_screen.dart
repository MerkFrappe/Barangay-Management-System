import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'resident_dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isAdmin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isSubmitting = true);

    try {
      // 1. Optional Firebase authentication attempt (fails silently if unconfigured/offline)
      if (_emailController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );

          final String uid = userCredential.user!.uid;

          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'accountName': _emailController.text.split('@').first,
            'email': _emailController.text.trim(),
            'role': _isAdmin ? 'Chairman' : 'Resident',
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (fbError) {
          debugPrint('Firebase auth optional / bypassed: $fbError');
        }
      }
    } catch (e) {
      debugPrint('Login exception handled: $e');
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // 2. Direct Frontend Navigation based on selected role
    _navigateToSelectedDashboard();
  }

  void _navigateToSelectedDashboard() {
    Widget targetScreen =
        _isAdmin ? const DashboardScreen() : const ResidentDashboardScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Row(
            children: [
              if (isWide) Expanded(flex: 6, child: _BrandPanel(isAdmin: _isAdmin)),
              Expanded(
                flex: isWide ? 5 : 10,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 48,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _LoginForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        rememberMe: _rememberMe,
                        isSubmitting: _isSubmitting,
                        isAdmin: _isAdmin,
                        isWide: isWide,
                        onToggleObscure: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onToggleRemember: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        onSelectRole: (admin) =>
                            setState(() => _isAdmin = admin),
                        onSubmit: _handleLogin,
                        onDemoLogin: (admin) {
                          setState(() => _isAdmin = admin);
                          _navigateToSelectedDashboard();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Left-hand brand panel shown on wide screens — mirrors the primary-heavy
/// treatment used in the dashboard's Schedule card header.
class _BrandPanel extends StatelessWidget {
  final bool isAdmin;
  const _BrandPanel({required this.isAdmin});

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
            child: const _GhostCircle(size: 240, opacity: 0.08),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: const _GhostCircle(size: 180, opacity: 0.08),
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
                  child: Icon(
                    isAdmin ? Icons.shield : Icons.house_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isAdmin ? 'Barangay Admin Hub' : 'Barangay Resident Hub',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLg.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAdmin
                      ? 'Official portal for barangay administration —\nresidents, requests, and peace & order in one place.'
                      : 'Official community portal for residents —\nrequest certificates, check announcements & file reports.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.85),
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
        color: Colors.white.withValues(alpha: opacity),
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
  final bool isAdmin;
  final bool isWide;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleRemember;
  final ValueChanged<bool> onSelectRole;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onDemoLogin;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isSubmitting,
    required this.isAdmin,
    required this.isWide,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onSelectRole,
    required this.onSubmit,
    required this.onDemoLogin,
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
                child: Icon(
                  isAdmin ? Icons.shield : Icons.house_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Portal Mode Switcher Tabs
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onSelectRole(true),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isAdmin ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isAdmin
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 18,
                            color: isAdmin
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Admin Portal',
                            style: AppTextStyles.labelMd.copyWith(
                              color: isAdmin
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                              fontWeight:
                                  isAdmin ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onSelectRole(false),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            !isAdmin ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !isAdmin
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: !isAdmin
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Resident Portal',
                            style: AppTextStyles.labelMd.copyWith(
                              color: !isAdmin
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                              fontWeight:
                                  !isAdmin ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            isAdmin ? 'Welcome back, Chairman' : 'Welcome, Resident',
            style: AppTextStyles.headlineLg.copyWith(
              color: AppColors.primary,
              fontSize: isWide ? 30 : 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin
                ? 'Sign in to access the barangay admin dashboard.'
                : 'Sign in to access barangay services & announcements.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            isAdmin ? 'Email or Admin Username' : 'Email or Resident ID',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyMd,
            decoration: _fieldDecoration(
              hint: isAdmin
                  ? 'juan.delacruz@barangay.gov.ph'
                  : 'juan.delacruz@gmail.com',
              icon: Icons.mail_outline,
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Password',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
          ),
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
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.outline,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
            ),
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
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isAdmin ? 'Sign In as Admin' : 'Sign In as Resident',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Frontend Testing Direct Login Buttons
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Frontend Quick Entry (Bypass Firebase)',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onDemoLogin(true),
                        icon: const Icon(Icons.admin_panel_settings, size: 16),
                        label: const Text('Enter Admin'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onDemoLogin(false),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('Enter Resident'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text.rich(
              TextSpan(
                text: "Need access? ",
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: 'Contact your system administrator',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
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
