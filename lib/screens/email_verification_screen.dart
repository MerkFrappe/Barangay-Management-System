import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_roles.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'resident_dashboard_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !user.emailVerified) {
        _showMessage(
          'Your email has not been verified yet. Open the link in the email, then try again.',
        );
        return;
      }

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final snapshot = await userRef.get();
      final role = snapshot.data()?['role']?.toString() ?? 'Resident';
      await userRef.set({
        'emailVerified': true,
        'emailVerifiedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => isAdminRole(role)
              ? const DashboardScreen()
              : const ResidentDashboardScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Unable to check email verification.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      _showMessage('A new verification email was sent.');
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Unable to resend the verification email.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? 'your email address';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 18),
                  Text('Verify your email', style: AppTextStyles.headlineLg),
                  const SizedBox(height: 12),
                  Text(
                    'We sent a verification link to $email. Open it, then return here and select “I verified my email”.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isChecking ? null : _checkVerification,
                      child: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('I verified my email'),
                    ),
                  ),
                  TextButton(
                    onPressed: _isResending ? null : _resendVerification,
                    child: _isResending
                        ? const Text('Sending verification email...')
                        : const Text('Resend verification email'),
                  ),
                  TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Use a different account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
