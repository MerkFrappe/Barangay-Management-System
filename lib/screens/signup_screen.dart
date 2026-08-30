import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'profile_completion_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// The set of official positions an admin account can be registered under.
/// `firestoreValue` is what gets written to the `role` field in Firestore —
/// keep it stable even if `label` (the display text) changes later.
enum AdminRole {
  chairman('Chairman', Icons.gavel_rounded),
  secretary('Secretary', Icons.description_outlined),
  treasurer('Treasurer', Icons.account_balance_wallet_outlined),
  auditor('Auditor', Icons.fact_check_outlined);

  final String label;
  final IconData icon;
  const AdminRole(this.label, this.icon);

  String get firestoreValue => label;
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isSubmitting = false;
  bool _isAdmin = false;
  AdminRole _adminRole = AdminRole.chairman;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Create Firebase Auth account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // 2. Create user profile document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'accountName': name,
        'email': email,
        'role': _isAdmin ? _adminRole.firestoreValue : 'Resident',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 3. Navigate straight into the right dashboard
      if (_isAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                const ProfileCompletionScreen(launchedAfterSignUp: true),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign up failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sign up failed: ${e.toString().replaceAll('Exception:', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
              if (isWide)
                Expanded(flex: 6, child: _BrandPanel(isAdmin: _isAdmin)),
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
                      child: _SignUpForm(
                        formKey: _formKey,
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        obscurePassword: _obscurePassword,
                        obscureConfirmPassword: _obscureConfirmPassword,
                        agreeToTerms: _agreeToTerms,
                        isSubmitting: _isSubmitting,
                        isAdmin: _isAdmin,
                        adminRole: _adminRole,
                        isWide: isWide,
                        onToggleObscure: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onToggleObscureConfirm: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        onToggleAgree: (v) =>
                            setState(() => _agreeToTerms = v ?? false),
                        onSelectRole: (admin) =>
                            setState(() => _isAdmin = admin),
                        onSelectAdminRole: (role) =>
                            setState(() => _adminRole = role),
                        onSubmit: _handleSignUp,
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

/// Left-hand brand panel shown on wide screens — mirrors the login screen's
/// primary-heavy treatment.
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
                  isAdmin ? 'Join the Admin Hub' : 'Join the Resident Hub',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLg.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAdmin
                      ? 'Create an official account to manage residents,\nrequests, and peace & order in one place.'
                      : 'Create your account to request certificates,\ncheck announcements & file reports online.',
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

class _SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool agreeToTerms;
  final bool isSubmitting;
  final bool isAdmin;
  final AdminRole adminRole;
  final bool isWide;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleObscureConfirm;
  final ValueChanged<bool?> onToggleAgree;
  final ValueChanged<bool> onSelectRole;
  final ValueChanged<AdminRole> onSelectAdminRole;
  final VoidCallback onSubmit;

  const _SignUpForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.agreeToTerms,
    required this.isSubmitting,
    required this.isAdmin,
    required this.adminRole,
    required this.isWide,
    required this.onToggleObscure,
    required this.onToggleObscureConfirm,
    required this.onToggleAgree,
    required this.onSelectRole,
    required this.onSelectAdminRole,
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
                child: Icon(
                  isAdmin ? Icons.shield : Icons.house_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Admin position picker — only relevant once "Admin Portal" is selected.
          if (isAdmin) ...[
            Text(
              'Position',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AdminRole>(
              value: adminRole,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.outline,
              ),
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
              dropdownColor: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              decoration: _fieldDecoration(
                hint: 'Select your position',
                icon: Icons.badge_outlined,
              ),
              items: AdminRole.values
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(role.icon, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(role.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (role) {
                if (role != null) onSelectAdminRole(role);
              },
            ),
            const SizedBox(height: 18),
          ],

          Text(
            isAdmin ? 'Create Admin Account' : 'Create Your Account',
            style: AppTextStyles.headlineLg.copyWith(
              color: AppColors.primary,
              fontSize: isWide ? 30 : 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin
                ? 'Register for access to the barangay admin dashboard.'
                : 'Sign up to access barangay services & announcements.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Full Name',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            keyboardType: TextInputType.name,
            style: AppTextStyles.bodyMd,
            decoration: _fieldDecoration(
              hint: 'Juan Dela Cruz',
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 18),

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
              hint: 'Create a password',
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
          const SizedBox(height: 18),

          Text(
            'Confirm Password',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            style: AppTextStyles.bodyMd,
            decoration: _fieldDecoration(
              hint: 'Re-enter your password',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.outline,
                  size: 20,
                ),
                onPressed: onToggleObscureConfirm,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: agreeToTerms,
                  onChanged: onToggleAgree,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
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
                      isAdmin ? 'Sign Up as Admin' : 'Sign Up as Resident',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign in',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
