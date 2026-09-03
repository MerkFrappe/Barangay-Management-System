import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/resident_profile.dart';
import '../theme/app_colors.dart';
import 'resident_dashboard_screen.dart';

// This system currently only serves Barangay Apokon, so Barangay is fixed
// rather than user-editable.
const String _kFixedBarangay = 'Apokon';

const List<String> _kSuffixOptions = [
  'None',
  'Jr.',
  'Sr.',
  'II',
  'III',
  'IV',
  'V',
];

const List<String> _kSexOptions = ['Male', 'Female'];

const List<String> _kCivilStatusOptions = [
  'Single',
  'Married',
  'Widowed',
  'Separated',
  'Divorced',
  'Annulled',
];

// Puroks of Barangay Apokon.
const List<String> _kApokonPuroks = [
  'Purok',
  '1-Pagaran',
  '1-B',
  '1-C',
  '1-D',
  '1-E',
  '2-Durian',
  '2-A',
  '3-Unit 1',
  '3-Unit 2',
  '3-Unit 3',
  '3-Unit 4',
  '3-Unit 5',
  '3-Unit 6',
  '3-Unit 7',
  '3-A',
  '3-B',
  '3-C',
  '3-D',
  '3-E',
  '3-F',
  '3-G',
  '3-H',
  '4',
  '4-A',
  '4-B',
  '4-C',
  '4-D',
  '4-E',
  '4-F',
  '4-G',
  '4-H',
  '5',
  '5A',
  '6',
  '6-A',
  '6-B',
  '7',
  'Purok 1',
  'Purok 10',
];

// Primary valid IDs, shown individually. "Others" reveals a second dropdown
// of commonly-accepted secondary IDs.
const List<String> _kPrimaryValidIds = [
  'Philippine National ID (PhilID)',
  'Philippine Passport',
  "Driver's License",
  'UMID / SSS ID / GSIS e-Card',
  'PRC ID',
  'Postal ID',
  "Seafarer's ID Record Book (SIRB)",
  'ACR I-Card',
  'Others',
];

const List<String> _kSecondaryValidIds = [
  "Voter's ID / COMELEC Certification",
  'TIN Card',
  'PhilHealth ID',
  'Pag-IBIG / HDMF Loyalty Card',
  'Senior Citizen ID',
  'PWD ID',
  'Solo Parent ID',
  'NBI / Police Clearance',
  'Barangay ID / Clearance',
  'OWWA / OFW ID',
  'School ID / Company ID',
];

const List<String> _kMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

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
  final _citizenshipController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _streetSubdivisionController = TextEditingController();
  final _occupationController = TextEditingController();
  final _employmentStatusController = TextEditingController();

  String? _suffix;
  String? _sex;
  String? _civilStatus;
  DateTime? _dateOfBirth;
  String? _purok;
  String? _validIdType; // one of _kPrimaryValidIds
  String? _validIdSecondaryType; // one of _kSecondaryValidIds, if "Others"

  File? _validIdPhotoFile;
  String? _validIdPhotoPath; // existing (saved) path/url, if any

  bool _isVoter = false;
  bool _isPWD = false;
  bool _isSeniorCitizen = false;
  bool _is4PsBeneficiary = false;
  bool _isSoloParent = false;
  bool _isLoading = true;
  bool _isSaving = false;

  final _imagePicker = ImagePicker();

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
      _citizenshipController.text = profile.citizenship ?? '';
      _contactNumberController.text = profile.contactNumber ?? '';

      _suffix = _matchOption(profile.suffix, _kSuffixOptions);
      _sex = _matchOption(profile.sex, _kSexOptions);
      _civilStatus = _matchOption(profile.civilStatus, _kCivilStatusOptions);
      _dateOfBirth = _parseIsoDate(profile.dateOfBirth);

      final address = profile.address ?? const <String, dynamic>{};
      _houseNoController.text = address['houseNo']?.toString() ?? '';
      _streetSubdivisionController.text =
          address['streetSubdivision']?.toString() ?? '';
      _purok = _matchOption(address['purok']?.toString(), _kApokonPuroks);

      _occupationController.text = profile.occupation ?? '';
      _employmentStatusController.text = profile.employmentStatus ?? '';

      final validId = profile.validId ?? const <String, dynamic>{};
      final storedType = validId['type']?.toString();
      if (storedType != null && _kPrimaryValidIds.contains(storedType)) {
        _validIdType = storedType;
      } else if (storedType != null &&
          _kSecondaryValidIds.contains(storedType)) {
        _validIdType = 'Others';
        _validIdSecondaryType = storedType;
      }
      _validIdPhotoPath = validId['photoUrl']?.toString();

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

  String? _matchOption(String? value, List<String> options) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    for (final option in options) {
      if (option.toLowerCase() == trimmed.toLowerCase()) return option;
    }
    return null;
  }

  DateTime? _parseIsoDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) =>
      '${_kMonthNames[d.month - 1]} ${d.day}, ${d.year}';

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickIdPhoto(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() {
        _validIdPhotoFile = File(picked.path);
        _validIdPhotoPath = picked.path;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to get photo: $error')),
        );
      }
    }
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isSaving = true);

    final resolvedValidIdType = _validIdType == 'Others'
        ? _validIdSecondaryType
        : _validIdType;

    final profile = ResidentProfile(
      firstName: _firstNameController.text.trim(),
      middleName: _emptyToNull(_middleNameController.text),
      lastName: _lastNameController.text.trim(),
      suffix: (_suffix == null || _suffix == 'None') ? null : _suffix,
      sex: _sex,
      civilStatus: _civilStatus,
      dateOfBirth: _dateOfBirth == null ? null : _isoDate(_dateOfBirth!),
      citizenship: _emptyToNull(_citizenshipController.text),
      contactNumber: _contactNumberController.text.trim(),
      address: {
        'houseNo': _emptyToNull(_houseNoController.text),
        'streetSubdivision': _emptyToNull(_streetSubdivisionController.text),
        'purok': _purok,
        'barangay': _kFixedBarangay,
      },
      occupation: _emptyToNull(_occupationController.text),
      employmentStatus: _emptyToNull(_employmentStatusController.text),
      validId: {
        'type': resolvedValidIdType,
        'photoUrl': _validIdPhotoPath,
      },
      isVoter: _isVoter,
      isPWD: _isPWD,
      isSeniorCitizen: _isSeniorCitizen,
      is4PsBeneficiary: _is4PsBeneficiary,
      isSoloParent: _isSoloParent,
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

  @override
  void dispose() {
    for (final controller in [
      _firstNameController,
      _middleNameController,
      _lastNameController,
      _citizenshipController,
      _contactNumberController,
      _houseNoController,
      _streetSubdivisionController,
      _occupationController,
      _employmentStatusController,
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
                            _dropdown(
                              value: _suffix,
                              label: 'Suffix',
                              icon: Icons.badge_outlined,
                              options: _kSuffixOptions,
                              onChanged: (v) => setState(() => _suffix = v),
                            ),
                            _dropdown(
                              value: _sex,
                              label: 'Sex',
                              icon: Icons.person_outline,
                              options: _kSexOptions,
                              onChanged: (v) => setState(() => _sex = v),
                            ),
                            _dropdown(
                              value: _civilStatus,
                              label: 'Civil status',
                              icon: Icons.favorite_border,
                              options: _kCivilStatusOptions,
                              onChanged: (v) =>
                                  setState(() => _civilStatus = v),
                            ),
                            _dateField(),
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
                            _dropdown(
                              value: _purok,
                              label: 'Purok',
                              icon: Icons.location_on_outlined,
                              options: _kApokonPuroks,
                              onChanged: (v) => setState(() => _purok = v),
                            ),
                            _fixedField(
                              label: 'Barangay',
                              value: _kFixedBarangay,
                              icon: Icons.location_city_outlined,
                              note: 'This system currently serves Apokon only.',
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
                            _dropdown(
                              value: _validIdType,
                              label: 'Valid ID type',
                              icon: Icons.badge_outlined,
                              options: _kPrimaryValidIds,
                              onChanged: (v) => setState(() {
                                _validIdType = v;
                                if (v != 'Others') {
                                  _validIdSecondaryType = null;
                                }
                              }),
                            ),
                            if (_validIdType == 'Others')
                              _dropdown(
                                value: _validIdSecondaryType,
                                label: 'Specify ID (Others)',
                                icon: Icons.list_alt_outlined,
                                options: _kSecondaryValidIds,
                                onChanged: (v) =>
                                    setState(() => _validIdSecondaryType = v),
                              ),
                            _idPhotoField(),
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
                                  .withValues(alpha: 0.6),
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
      validator: required ? (value) => _required(value, label) : null,
    ),
  );

  Widget _dropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
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
      ),
      hint: Text(
        'Select $label',
        style: AppTextStyles.bodySm.copyWith(color: AppColors.outline),
      ),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option, style: AppTextStyles.bodyMd),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (v) => (v == null || v.isEmpty) ? '$label is required.' : null
          : null,
    ),
  );

  Widget _dateField() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _pickDateOfBirth,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of birth',
          labelStyle: AppTextStyles.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          prefixIcon: const Icon(
            Icons.cake_outlined,
            color: AppColors.outline,
            size: 20,
          ),
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.outline,
            size: 18,
          ),
          filled: true,
          fillColor: AppColors.surfaceContainer,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
          border: _inputBorder(Colors.transparent),
          enabledBorder: _inputBorder(Colors.transparent),
        ),
        child: Text(
          _dateOfBirth == null
              ? 'Select date of birth'
              : _displayDate(_dateOfBirth!),
          style: AppTextStyles.bodyMd.copyWith(
            color: _dateOfBirth == null
                ? AppColors.outline
                : AppColors.onSurface,
          ),
        ),
      ),
    ),
  );

  Widget _fixedField({
    required String label,
    required String value,
    required IconData icon,
    String? note,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            border: _inputBorder(Colors.transparent),
            enabledBorder: _inputBorder(Colors.transparent),
          ),
          child: Text(value, style: AppTextStyles.bodyMd),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(
            note,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.outline),
          ),
        ],
      ],
    ),
  );

  Widget _idPhotoField() {
    final hasImage = _validIdPhotoFile != null;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valid ID photo',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.file(_validIdPhotoFile!, fit: BoxFit.cover)
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: AppColors.outline,
                          size: 32,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No photo added yet',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickIdPhoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Take photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickIdPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.folder_open_outlined, size: 18),
                  label: const Text('Choose file'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
