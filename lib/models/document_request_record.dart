class DocumentRequestRecord {
  final String? requesterId;
  final Map<String, dynamic>? requesterSnapshot;
  final String? residentId;
  final String? residentName;
  final String? initials;
  final String? documentType;
  final String? purpose;
  final String? status;
  final String? dateSubmitted;
  final String? contactNumber;

  const DocumentRequestRecord({
    this.requesterId,
    this.requesterSnapshot,
    this.residentId,
    this.residentName,
    this.initials,
    this.documentType,
    this.purpose,
    this.status,
    this.dateSubmitted,
    this.contactNumber,
  });

  factory DocumentRequestRecord.fromMap(Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};
    final snapshotValue = data['requesterSnapshot'];
    return DocumentRequestRecord(
      requesterId: data['requesterId'] as String?,
      requesterSnapshot: snapshotValue is Map
          ? Map<String, dynamic>.from(snapshotValue)
          : null,
      residentId: data['residentId'] as String?,
      residentName: data['residentName'] as String?,
      initials: data['initials'] as String?,
      documentType: data['documentType'] as String?,
      purpose: data['purpose'] as String?,
      status: data['status'] as String?,
      dateSubmitted: data['dateSubmitted'] as String?,
      contactNumber: data['contactNumber'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'requesterId': requesterId,
    'requesterSnapshot': requesterSnapshot,
    'residentId': residentId,
    'residentName': residentName,
    'initials': initials,
    'documentType': documentType,
    'purpose': purpose,
    'status': status,
    'dateSubmitted': dateSubmitted,
    'contactNumber': contactNumber,
  };
}
