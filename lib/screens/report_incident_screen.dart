import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/resident_profile.dart';
import '../theme/app_colors.dart';

const List<String> _kIncidentTypes = [
  'Noise Complaint',
  'Property Dispute',
  'Theft',
  'Vandalism',
  'Public Disturbance',
  'Domestic Dispute',
  'Animal Complaint',
  'Others',
];

/// A non-urgent blotter / incident report form, distinct from the sidebar's
/// "Report Emergency" quick-dispatch modal. Submissions go to
/// `incident_reports` for barangay staff to follow up on.
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _contactController = TextEditingController();

  String? _incidentType;
  bool _isLoadingProfile = true;
  bool _isSubmitting = false;
  String _reporterName = '';

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  Future<void> _prefillFromProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoadingProfile = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final profile = ResidentProfile.fromMap(doc.data());
      _reporterName = profile.fullName;
      _contactController.text = profile.contactNumber ?? '';
    } catch (_) {
      // Non-fatal — the resident can still fill the form manually.
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('incident_reports').add({
        'residentId': uid,
        'residentName': _reporterName.isEmpty ? 'Resident' : _reporterName,
        'type': _incidentType,
        'location': _locationController.text.trim(),
        'details': _detailsController.text.trim(),
        'contactNumber': _contactController.text.trim(),
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report submitted. Barangay staff will follow up with you.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to submit report: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _detailsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('File Incident / Complaint'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.errorContainer,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'For life-threatening emergencies, use "Report Emergency" instead — this form is for non-urgent blotter reports and complaints.',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Report details',
                            style: AppTextStyles.headlineSm,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _incidentType,
                            isExpanded: true,
                            decoration: _decoration(
                              'Incident type',
                              Icons.report_problem_outlined,
                            ),
                            items: _kIncidentTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _incidentType = v),
                            validator: (v) =>
                                v == null ? 'Please select a type.' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _locationController,
                            decoration: _decoration(
                              'Location',
                              Icons.location_on_outlined,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Location is required.'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _detailsController,
                            maxLines: 5,
                            decoration: _decoration(
                              'Details',
                              Icons.notes_outlined,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please describe what happened.'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _contactController,
                            keyboardType: TextInputType.phone,
                            decoration: _decoration(
                              'Contact number',
                              Icons.phone_outlined,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Contact number is required.'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              minimumSize: const Size.fromHeight(52),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: 0.6),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Submit Report',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
    filled: true,
    fillColor: AppColors.surfaceContainer,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
    ),
  );
}
