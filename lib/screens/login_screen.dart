import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'resident_dashboard_screen.dart';
import 'signup_screen.dart';
import 'email_verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_roles.dart';
import '../widgets/legal_documents.dart';
import '../widgets/google_logo.dart';

class LoginScreen extends StatefulWidget {
  final bool initialAdmin;

  const LoginScreen({super.key, this.initialAdmin = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _demoAdminBypassEnabled = bool.fromEnvironment(
    'ENABLE_DEMO_ADMIN_BYPASS',
  );
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSubmitting = false;
  // Default to Resident — this is the primary audience for the app.
  // Admins can switch over via the small "Login as Admin" link.
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.initialAdmin;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.reload();
      final signedInUser = FirebaseAuth.instance.currentUser!;
      if (!signedInUser.emailVerified) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        );
        return;
      }

      final String uid = signedInUser.uid;

      // 2. Fetch User Document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found in database.');
      }

      final data = userDoc.data();
      final String? role = data?['role'];

      if (role == null) {
        throw Exception('User role not configured.');
      }

      // Update last login
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 3. Navigate based on real user role in Firestore
      if (isAdminRole(role)) {
        setState(() => _isAdmin = true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else if (role == 'Resident') {
        setState(() => _isAdmin = false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResidentDashboardScreen()),
        );
      } else {
        throw Exception('Unsupported user role: $role');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed: ${e.toString().replaceAll('Exception:', '')}',
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

  // Kept temporarily only to avoid breaking old debug deep links; it is not
  // reachable from the UI and must not be used for normal access.
  // ignore: unused_element
  Future<void> _handleQuickEntry(bool admin) async {
    _emailController.text = admin
        ? 'admin@barangay.gov.ph'
        : 'resident@gmail.com';
    _passwordController.text = 'Password123';
    await _handleLogin();
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Email address',
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'If an account exists, a password-reset email has been sent.',
                    ),
                  ),
                );
              } on FirebaseAuthException catch (error) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      error.message ?? 'Unable to send reset email.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Send reset email'),
          ),
        ],
      ),
    );
    emailController.dispose();
  }

  void _openDemoAdminDashboard() {
    if (!_demoAdminBypassEnabled) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isSubmitting = true);
    try {
      final provider = GoogleAuthProvider();
      final credential = kIsWeb
          ? await FirebaseAuth.instance.signInWithPopup(provider)
          : await FirebaseAuth.instance.signInWithProvider(provider);
      final user = credential.user!;
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        if (!mounted) return;
        final accepted = await showLegalAgreementDialog(context);
        if (!accepted) {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Google sign-up was cancelled because the policies were not accepted.',
                ),
              ),
            );
          }
          return;
        }
        await userRef.set({
          'accountName': user.displayName ?? user.email ?? 'Resident',
          'email': user.email,
          'role': 'Resident',
          'termsAcceptedAt': FieldValue.serverTimestamp(),
          'privacyAcceptedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.update({'lastLogin': FieldValue.serverTimestamp()});
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ResidentDashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: ${e.message ?? e.code}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ignore: unused_element
  Future<void> _seedDatabase() async {
    setState(() => _isSubmitting = true);
    try {
      // 1. Create or get Admin
      String adminUid = '';
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'admin@barangay.gov.ph',
          password: 'Password123',
        );
        adminUid = cred.user!.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'admin@barangay.gov.ph',
            password: 'Password123',
          );
          adminUid = cred.user!.uid;
        } else {
          rethrow;
        }
      }

      // Update admin users document
      await FirebaseFirestore.instance.collection('users').doc(adminUid).set({
        'accountName': 'Juan Dela Cruz (Chairman)',
        'email': 'admin@barangay.gov.ph',
        'role': 'Chairman',
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // 2. Create or get Resident
      String residentUid = '';
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'resident@gmail.com',
          password: 'Password123',
        );
        residentUid = cred.user!.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'resident@gmail.com',
            password: 'Password123',
          );
          residentUid = cred.user!.uid;
        } else {
          rethrow;
        }
      }

      // Update resident users document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(residentUid)
          .set({
            'accountName': 'Elena Morales',
            'email': 'resident@gmail.com',
            'role': 'Resident',
            'lastLogin': FieldValue.serverTimestamp(),
          });

      // 3. Seed Announcements
      final announcements = FirebaseFirestore.instance.collection(
        'announcements',
      );
      final annDocs = await announcements.limit(1).get();
      if (annDocs.docs.isEmpty) {
        final mockAnnouncements = [
          {
            'title': 'Barangay Clean-up Drive',
            'description':
                'Join us this Saturday for our monthly community clean-up drive.',
            'date': 'September 11, 2024',
            'category': 'event',
            'status': 'published',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'title': 'Free Wellness Checkup',
            'description':
                'Low pressure area detected near the region. Prepare for heavy rains.',
            'date': 'September 15, 2024',
            'category': 'emergency',
            'status': 'published',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'title': 'Quarterly Town Hall Meeting',
            'description': 'Discussion on upcoming community budget plans.',
            'date': 'September 22, 2024',
            'category': 'news',
            'status': 'draft',
            'createdAt': FieldValue.serverTimestamp(),
          },
        ];
        for (final ann in mockAnnouncements) {
          await announcements.add(ann);
        }
      }

      // 4. Seed Document Requests
      final requests = FirebaseFirestore.instance.collection(
        'document_requests',
      );
      final reqDocs = await requests.limit(1).get();
      if (reqDocs.docs.isEmpty) {
        final mockRequests = [
          {
            'residentId': residentUid,
            'residentName': 'Elena Morales',
            'initials': 'EM',
            'documentType': 'Barangay Clearance',
            'dateSubmitted': 'Oct 24, 2023',
            'status': 'approved',
            'purpose': 'Local Employment Application',
            'contactNumber': '+63 917 123 4567',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'residentId': residentUid,
            'residentName': 'Elena Morales',
            'initials': 'EM',
            'documentType': 'Certificate of Residency',
            'dateSubmitted': 'Oct 25, 2023',
            'status': 'pending',
            'purpose': 'Bank Account Opening',
            'contactNumber': '+63 917 123 4567',
            'createdAt': FieldValue.serverTimestamp(),
          },
        ];
        for (final req in mockRequests) {
          await requests.add(req);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firebase seed successful! Users & mock data ready.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seed failed: $e'),
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
                Expanded(
                  flex: 6,
                  child: _BrandPanel(
                    isAdmin: _isAdmin,
                    onDemoAdminAccess: _demoAdminBypassEnabled
                        ? _openDemoAdminDashboard
                        : null,
                  ),
                ),
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
                        onGoogleLogin: _handleGoogleLogin,
                        onForgotPassword: _showForgotPasswordDialog,
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
  final VoidCallback? onDemoAdminAccess;

  const _BrandPanel({required this.isAdmin, this.onDemoAdminAccess});

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
                Semantics(
                  button: onDemoAdminAccess != null,
                  label: onDemoAdminAccess != null
                      ? 'Open demo admin dashboard'
                      : 'Civica',
                  child: InkWell(
                    onTap: onDemoAdminAccess,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
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
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isAdmin ? 'Civica Admin Hub' : 'Civica',
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
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;

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
    required this.onGoogleLogin,
    required this.onForgotPassword,
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

          Text(
            isAdmin ? 'Welcome' : 'Welcome, Resident',
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
            isAdmin ? 'Email or Admin Username' : 'Email Address',
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
                onPressed: onForgotPassword,
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
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.6,
                ),
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
                      isAdmin ? 'Sign In' : 'Sign In',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: isSubmitting ? null : onGoogleLogin,
            icon: const GoogleLogo(),

            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: LegalLinks()),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign up',
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
