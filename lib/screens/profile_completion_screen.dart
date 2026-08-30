import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/resident_profile.dart';
import '../theme/app_colors.dart';
import 'resident_dashboard_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final bool launchedAfterSignUp;

  const ProfileCompletionScreen({super.key, this.launchedAfterSignUp = false});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _sexController = TextEditingController();
  final _civilStatusController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _citizenshipController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _streetSubdivisionController = TextEditingController();
  final _purokController = TextEditingController();
  final _barangayController = TextEditingController();
  final _occupationController = TextEditingController();
  final _employmentStatusController = TextEditingController();
  final _validIdTypeController = TextEditingController();
  final _validIdNumberController = TextEditingController();
  final _validIdPhotoUrlController = TextEditingController();
  final _residencyStartDateController = TextEditingController();

  bool _isVoter = false;
  bool _isPWD = false;
  bool _isSeniorCitizen = false;
  bool _is4PsBeneficiary = false;
  bool _isSoloParent = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final profile = ResidentProfile.fromMap(doc.data());
      _firstNameController.text = profile.firstName ?? '';
      _middleNameController.text = profile.middleName ?? '';
      _lastNameController.text = profile.lastName ?? '';
      _suffixController.text = profile.suffix ?? '';
      _sexController.text = profile.sex ?? '';
      _civilStatusController.text = profile.civilStatus ?? '';
      _dateOfBirthController.text = profile.dateOfBirth ?? '';
      _citizenshipController.text = profile.citizenship ?? '';
      _contactNumberController.text = profile.contactNumber ?? '';
      final address = profile.address ?? const <String, dynamic>{};
      _houseNoController.text = address['houseNo']?.toString() ?? '';
      _streetSubdivisionController.text =
          address['streetSubdivision']?.toString() ?? '';
      _purokController.text = address['purok']?.toString() ?? '';
      _barangayController.text = address['barangay']?.toString() ?? '';
      _occupationController.text = profile.occupation ?? '';
      _employmentStatusController.text = profile.employmentStatus ?? '';
      final validId = profile.validId ?? const <String, dynamic>{};
      _validIdTypeController.text = validId['type']?.toString() ?? '';
      _validIdNumberController.text = validId['number']?.toString() ?? '';
      _validIdPhotoUrlController.text = validId['photoUrl']?.toString() ?? '';
      _residencyStartDateController.text = profile.residencyStartDate ?? '';
      _isVoter = profile.isVoter ?? false;
      _isPWD = profile.isPWD ?? false;
      _isSeniorCitizen = profile.isSeniorCitizen ?? false;
      _is4PsBeneficiary = profile.is4PsBeneficiary ?? false;
      _isSoloParent = profile.isSoloParent ?? false;
    } catch (error) {
      debugPrint('Unable to load resident profile: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isSaving = true);

    final profile = ResidentProfile(
      firstName: _firstNameController.text.trim(),
      middleName: _emptyToNull(_middleNameController.text),
      lastName: _lastNameController.text.trim(),
      suffix: _emptyToNull(_suffixController.text),
      sex: _emptyToNull(_sexController.text),
      civilStatus: _emptyToNull(_civilStatusController.text),
      dateOfBirth: _emptyToNull(_dateOfBirthController.text),
      citizenship: _emptyToNull(_citizenshipController.text),
      contactNumber: _contactNumberController.text.trim(),
      address: {
        'houseNo': _emptyToNull(_houseNoController.text),
        'streetSubdivision': _emptyToNull(_streetSubdivisionController.text),
        'purok': _emptyToNull(_purokController.text),
        'barangay': _barangayController.text.trim(),
      },
      occupation: _emptyToNull(_occupationController.text),
      employmentStatus: _emptyToNull(_employmentStatusController.text),
      validId: {
        'type': _emptyToNull(_validIdTypeController.text),
        'number': _emptyToNull(_validIdNumberController.text),
        'photoUrl': _emptyToNull(_validIdPhotoUrlController.text),
      },
      isVoter: _isVoter,
      isPWD: _isPWD,
      isSeniorCitizen: _isSeniorCitizen,
      is4PsBeneficiary: _is4PsBeneficiary,
      isSoloParent: _isSoloParent,
      residencyStartDate: _emptyToNull(_residencyStartDateController.text),
    );

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        ...profile.toMap(),
        // Compatibility fields used by the current resident directory.
        'accountName': profile.fullName,
        'displayName': profile.fullName,
        'address': profile.formattedAddress,
        'phone': profile.contactNumber,
      }, SetOptions(merge: true));
      if (!mounted) return;
      if (widget.launchedAfterSignUp) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResidentDashboardScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to save profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _skipForNow() {
    if (widget.launchedAfterSignUp) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ResidentDashboardScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop(false);
    }
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  String? _isoDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())
        ? null
        : 'Use YYYY-MM-DD.';
  }

  @override
  void dispose() {
    for (final controller in [
      _firstNameController,
      _middleNameController,
      _lastNameController,
      _suffixController,
      _sexController,
      _civilStatusController,
      _dateOfBirthController,
      _citizenshipController,
      _contactNumberController,
      _houseNoController,
      _streetSubdivisionController,
      _purokController,
      _barangayController,
      _occupationController,
      _employmentStatusController,
      _validIdTypeController,
      _validIdNumberController,
      _validIdPhotoUrlController,
      _residencyStartDateController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete your profile'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Resident profile',
                            style: AppTextStyles.headlineLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your saved details will automatically fill future document requests.',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _section('Personal information', [
                            _field(
                              _firstNameController,
                              'First name',
                              icon: Icons.person_outline,
                              required: true,
                            ),
                            _field(
                              _middleNameController,
                              'Middle name',
                              icon: Icons.person_outline,
                            ),
                            _field(
                              _lastNameController,
                              'Last name',
                              icon: Icons.person_outline,
                              required: true,
                            ),
                            _field(
                              _suffixController,
                              'Suffix',
                              icon: Icons.badge_outlined,
                            ),
                            _field(
                              _sexController,
                              'Sex',
                              icon: Icons.person_outline,
                            ),
                            _field(
                              _civilStatusController,
                              'Civil status',
                              icon: Icons.favorite_border,
                            ),
                            _field(
                              _dateOfBirthController,
                              'Date of birth',
                              icon: Icons.cake_outlined,
                              hint: 'YYYY-MM-DD',
                              isIsoDate: true,
                            ),
                            _field(
                              _citizenshipController,
                              'Citizenship',
                              icon: Icons.public_outlined,
                            ),
                            _field(
                              _contactNumberController,
                              'Contact number',
                              icon: Icons.phone_outlined,
                              required: true,
                              keyboardType: TextInputType.phone,
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _section('Address', [
                            _field(
                              _houseNoController,
                              'House no.',
                              icon: Icons.home_outlined,
                            ),
                            _field(
                              _streetSubdivisionController,
                              'Street / subdivision',
                              icon: Icons.signpost_outlined,
                            ),
                            _field(
                              _purokController,
                              'Purok',
                              icon: Icons.location_on_outlined,
                            ),
                            _field(
                              _barangayController,
                              'Barangay',
                              icon: Icons.location_city_outlined,
                              required: true,
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _section('Employment and identification', [
                            _field(
                              _occupationController,
                              'Occupation',
                              icon: Icons.work_outline,
                            ),
                            _field(
                              _employmentStatusController,
                              'Employment status',
                              icon: Icons.business_center_outlined,
                            ),
                            _field(
                              _validIdTypeController,
                              'Valid ID type',
                              icon: Icons.badge_outlined,
                            ),
                            _field(
                              _validIdNumberController,
                              'Valid ID number',
                              icon: Icons.numbers_outlined,
                            ),
                            _field(
                              _validIdPhotoUrlController,
                              'Valid ID photo URL',
                              icon: Icons.image_outlined,
                            ),
                            _field(
                              _residencyStartDateController,
                              'Residency start date',
                              icon: Icons.calendar_today_outlined,
                              hint: 'YYYY-MM-DD',
                              isIsoDate: true,
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _section('Resident indicators', [
                            _toggle(
                              'Registered voter',
                              _isVoter,
                              (value) => setState(() => _isVoter = value),
                            ),
                            _toggle(
                              'Person with disability (PWD)',
                              _isPWD,
                              (value) => setState(() => _isPWD = value),
                            ),
                            _toggle(
                              'Senior citizen',
                              _isSeniorCitizen,
                              (value) =>
                                  setState(() => _isSeniorCitizen = value),
                            ),
                            _toggle(
                              '4Ps beneficiary',
                              _is4PsBeneficiary,
                              (value) =>
                                  setState(() => _is4PsBeneficiary = value),
                            ),
                            _toggle(
                              'Solo parent',
                              _isSoloParent,
                              (value) => setState(() => _isSoloParent = value),
                            ),
                          ]),
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              minimumSize: const Size.fromHeight(52),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: AppColors.primary
                                  .withOpacity(0.6),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          TextButton(
                            onPressed: _isSaving ? null : _skipForNow,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            child: const Text('Complete later'),
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

  Widget _section(String title, List<Widget> children) => Card(
    elevation: 0,
    color: AppColors.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.outlineVariant),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.headlineSm),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    required IconData icon,
    bool required = false,
    String? hint,
    TextInputType? keyboardType,
    bool isIsoDate = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        hintText: hint,
        hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.outline),
        prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        border: _inputBorder(Colors.transparent),
        enabledBorder: _inputBorder(Colors.transparent),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.6),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.6),
      ),
      validator: (value) {
        final requiredError = required ? _required(value, label) : null;
        return requiredError ?? (isIsoDate ? _isoDate(value) : null);
      },
    ),
  );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: AppTextStyles.bodyMd),
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primaryFixedDim,
        value: value,
        onChanged: onChanged,
      );

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
}
