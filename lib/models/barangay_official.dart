import 'dart:convert';

import 'package:flutter/material.dart';

/// Roles ranked for sorting the public officials directory. Anything not
/// listed here (e.g. a future role you add) just sorts to the end,
/// alphabetically by name.
const Map<String, int> kOfficialRoleRank = {
  'Chairman': 0,
  'Secretary': 1,
  'Treasurer': 2,
  'Kagawad': 3,
  'SK Chairman': 4,
  'Tanod': 5,
  'BHW': 6,
  'Admin Staff': 7,
};

/// A read-only view of an admin account, used for the resident-facing
/// "Barangay Officials" directory. Pulled from the same `users` collection —
/// no separate collection needed.
class BarangayOfficial {
  final String id;
  final String name;
  final String role;
  final String? position; // optional display title, falls back to [role]
  final String? photoUrl; // for later, once Firebase Storage is added
  final String? photoBase64; // works today, no Storage required
  final String? officeContact;

  const BarangayOfficial({
    required this.id,
    required this.name,
    required this.role,
    this.position,
    this.photoUrl,
    this.photoBase64,
    this.officeContact,
  });

  factory BarangayOfficial.fromDoc(String id, Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    final name = (map['accountName'] ?? map['displayName'] ?? '')
        .toString()
        .trim();
    final position = (map['position'] as String?)?.trim();
    return BarangayOfficial(
      id: id,
      name: name.isEmpty ? 'Unnamed Official' : name,
      role: (map['role'] ?? 'Official').toString(),
      position: (position == null || position.isEmpty) ? null : position,
      photoUrl: map['photoUrl'] as String?,
      photoBase64: map['photoBase64'] as String?,
      officeContact:
          (map['officeContact'] as String?) ?? (map['contactNumber'] as String?),
    );
  }

  /// What to show under the name — the specific position if set
  /// (e.g. "Barangay Captain"), otherwise just the role.
  String get displayTitle =>
      (position != null && position!.trim().isNotEmpty) ? position! : role;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// Resolves a displayable image, preferring the Storage-free base64 photo,
  /// then falling back to a URL. Returns null if neither is set, in which
  /// case the UI should fall back to an initials avatar.
  ImageProvider? get imageProvider {
    if (photoBase64 != null && photoBase64!.trim().isNotEmpty) {
      try {
        return MemoryImage(base64Decode(photoBase64!.trim()));
      } catch (_) {
        return null;
      }
    }
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      return NetworkImage(photoUrl!.trim());
    }
    return null;
  }

  int get sortRank => kOfficialRoleRank[role] ?? 99;
}
