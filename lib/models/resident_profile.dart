class ResidentProfile {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? suffix;
  final String? sex;
  final String? civilStatus;
  final String? dateOfBirth;
  final String? citizenship;
  final String? contactNumber;
  final Map<String, dynamic>? address;
  final String? occupation;
  final String? employmentStatus;
  final Map<String, dynamic>? validId;
  final bool? isVoter;
  final bool? isPWD;
  final bool? isSeniorCitizen;
  final bool? is4PsBeneficiary;
  final bool? isSoloParent;
  final String? residencyStartDate;

  const ResidentProfile({
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    this.sex,
    this.civilStatus,
    this.dateOfBirth,
    this.citizenship,
    this.contactNumber,
    this.address,
    this.occupation,
    this.employmentStatus,
    this.validId,
    this.isVoter,
    this.isPWD,
    this.isSeniorCitizen,
    this.is4PsBeneficiary,
    this.isSoloParent,
    this.residencyStartDate,
  });

  factory ResidentProfile.fromMap(Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};
    return ResidentProfile(
      firstName: data['firstName'] as String?,
      middleName: data['middleName'] as String?,
      lastName: data['lastName'] as String?,
      suffix: data['suffix'] as String?,
      sex: data['sex'] as String?,
      civilStatus: data['civilStatus'] as String?,
      dateOfBirth: data['dateOfBirth'] as String?,
      citizenship: data['citizenship'] as String?,
      contactNumber: data['contactNumber'] as String?,
      // `address` is already a legacy display string in this project. Keep
      // the structured profile address alongside it under a distinct field.
      address:
          _mapValue(data['residentialAddress']) ?? _mapValue(data['address']),
      occupation: data['occupation'] as String?,
      employmentStatus: data['employmentStatus'] as String?,
      validId: _mapValue(data['validId']),
      isVoter: data['isVoter'] as bool?,
      isPWD: data['isPWD'] as bool?,
      isSeniorCitizen: data['isSeniorCitizen'] as bool?,
      is4PsBeneficiary: data['is4PsBeneficiary'] as bool?,
      isSoloParent: data['isSoloParent'] as bool?,
      residencyStartDate: data['residencyStartDate'] as String?,
    );
  }

  static Map<String, dynamic>? _mapValue(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'suffix': suffix,
    'sex': sex,
    'civilStatus': civilStatus,
    'dateOfBirth': dateOfBirth,
    'citizenship': citizenship,
    'contactNumber': contactNumber,
    'residentialAddress': address,
    'occupation': occupation,
    'employmentStatus': employmentStatus,
    'validId': validId,
    'isVoter': isVoter,
    'isPWD': isPWD,
    'isSeniorCitizen': isSeniorCitizen,
    'is4PsBeneficiary': is4PsBeneficiary,
    'isSoloParent': isSoloParent,
    'residencyStartDate': residencyStartDate,
  };

  String get fullName => [firstName, middleName, lastName, suffix]
      .where((part) => part != null && part.trim().isNotEmpty)
      .map((part) => part!.trim())
      .join(' ');

  String get initials => [firstName, lastName]
      .where((part) => part != null && part.trim().isNotEmpty)
      .map((part) => part!.trim().substring(0, 1).toUpperCase())
      .join();

  String get formattedAddress {
    final data = address ?? const <String, dynamic>{};
    return [
      _string(data['houseNo']),
      _string(data['streetSubdivision']),
      _string(data['purok']),
      _string(data['barangay']),
    ].where((part) => part.isNotEmpty).join(', ');
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  bool get isComplete =>
      (firstName?.trim().isNotEmpty ?? false) &&
      (lastName?.trim().isNotEmpty ?? false) &&
      (contactNumber?.trim().isNotEmpty ?? false) &&
      formattedAddress.isNotEmpty;
}
