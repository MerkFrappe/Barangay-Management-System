import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/resident_profile.dart';
import '../theme/app_colors.dart';
import '../screens/dashboard_screen.dart';
import '../screens/resident_dashboard_screen.dart';
import '../screens/resident_request_code.dart';
import '../screens/residence_announcements.dart' as announcements;
import '../screens/community_polls_screen.dart';
import '../screens/health_center_screen.dart';
import '../screens/barangay_officials_screen.dart';
import 'resident_settings_popup.dart';

class ResidentSidebar extends StatelessWidget {
  final String selectedItem;

  const ResidentSidebar({super.key, this.selectedItem = 'My Dashboard'});

  Future<void> _showReportEmergencyModal(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    var reporterName = user?.displayName ?? '';
    var contactNumber = '';

    if (user != null) {
      try {
        final profileDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final profile = ResidentProfile.fromMap(profileDoc.data());
        if (profile.fullName.isNotEmpty) reporterName = profile.fullName;
        contactNumber = profile.contactNumber ?? '';
      } catch (_) {
        // Keep the Firebase Auth identity if the profile cannot be loaded.
      }
    }

    if (!context.mounted) return;

    final location = await _getCurrentLocation(context);
    if (!context.mounted) return;

    reporterName = reporterName.isEmpty
        ? (user?.email ?? 'Resident')
        : reporterName;
    final draft = await showDialog<_EmergencyReportDraft>(
      context: context,
      builder: (ctx) => _EmergencyLocationDialog(
        initialLocation: location,
        reporterName: reporterName,
        contactNumber: contactNumber,
      ),
    );

    if (!context.mounted || draft == null) return;
    await FirebaseFirestore.instance.collection('emergency_reports').add({
      'residentId': user?.uid,
      'residentName': reporterName,
      'contactNumber': contactNumber,
      'type': draft.type,
      'location': draft.locationText,
      'latitude': draft.location.latitude,
      'longitude': draft.location.longitude,
      'details': draft.details,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'EMERGENCY REPORT DISPATCHED TO BARANGAY HQ! Officials have been notified.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<LatLng> _getCurrentLocation(BuildContext context) async {
    const fallback = LatLng(7.423816, 125.826013);
    if (!await Geolocator.isLocationServiceEnabled()) return fallback;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission was not granted. You can choose a point on the map.',
            ),
          ),
        );
      }
      return fallback;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return fallback;
    }
  }

  void _showHelpCenterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Barangay Help Center'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions:',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• How long does a Barangay Clearance take?\n  Typically 1-2 business days.',
            ),
            const SizedBox(height: 6),
            const Text(
              '• What are the office hours?\n  Monday to Friday: 8:00 AM - 5:00 PM',
            ),
            const SizedBox(height: 12),
            Text(
              'Official Contact:',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Hotline: +63 917 123 4567 | Email: help@barangay.gov.ph',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      height: double.infinity,
      color: AppColors.surfaceContainerLow,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOGO
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Barangay Digital",
                            style: AppTextStyles.headlineSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Resident Portal",
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // NAVIGATION
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  title: "My Dashboard",
                  selected: selectedItem == 'My Dashboard',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const ResidentDashboardScreen(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.assignment_outlined,
                  title: "Document Request",
                  selected: selectedItem == 'Document Request',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const DocumentRequest(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.emergency_outlined,
                  title: "Emergency Alerts",
                  selected: selectedItem == 'Emergency Alerts',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const announcements.CivicHorizonApp(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.local_hospital_outlined,
                  title: "Health Center & Services",
                  selected: selectedItem == 'Health Center & Services',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const HealthCenterScreen(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.poll_outlined,
                  title: "Community Polls",
                  selected: selectedItem == 'Community Polls',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const CommunityPollsScreen(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.groups_outlined,
                  title: "Barangay Officials",
                  selected: selectedItem == 'Barangay Officials',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const BarangayOfficialsScreen(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.help_outline,
                  title: "Help Center",
                  onTap: () => _showHelpCenterModal(context),
                ),

                _NavItem(
                  icon: Icons.admin_panel_settings_rounded,
                  title: "Switch to Admin",
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => DashboardScreen()),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // REPORT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _showReportEmergencyModal(context),

                    icon: const Icon(Icons.campaign),

                    label: const Text("Report Emergency"),
                  ),
                ),

                const SizedBox(height: 16),

                Divider(color: AppColors.outlineVariant),

                // Settings now opens a small account popup (Edit profile +
                // Log out) instead of pushing the admin SettingsScreen.
                // The old standalone "Logout" item lives inside that popup.
                _NavItem(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () => showResidentSettingsPopup(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyReportDraft {
  final LatLng location;
  final String type;
  final String details;

  const _EmergencyReportDraft({
    required this.location,
    required this.type,
    required this.details,
  });

  String get locationText =>
      '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
}

class _EmergencyLocationDialog extends StatefulWidget {
  final LatLng initialLocation;
  final String reporterName;
  final String contactNumber;

  const _EmergencyLocationDialog({
    required this.initialLocation,
    required this.reporterName,
    required this.contactNumber,
  });

  @override
  State<_EmergencyLocationDialog> createState() =>
      _EmergencyLocationDialogState();
}

class _EmergencyLocationDialogState extends State<_EmergencyLocationDialog> {
  late LatLng _selectedLocation = widget.initialLocation;
  final _detailsController = TextEditingController();
  String _type = 'Fire Emergency';

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationText =
        '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Report Emergency to HQ',
              style: TextStyle(color: Colors.red[900]),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: widget.contactNumber.isEmpty
                      ? widget.reporterName
                      : '${widget.reporterName} / ${widget.contactNumber}',
                ),
                decoration: const InputDecoration(
                  labelText: 'Your Name / Contact',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tap the map to move the emergency pin',
                  style: AppTextStyles.bodySm,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _selectedLocation,
                      initialZoom: 16,
                      onTap: (_, point) =>
                          setState(() => _selectedLocation = point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.barangay.bms',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation,
                            width: 48,
                            height: 48,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: locationText),
                decoration: const InputDecoration(
                  labelText: 'Exact Incident Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Emergency Category',
                ),
                items:
                    const [
                          'Fire Emergency',
                          'Medical Emergency',
                          'Crime / Theft',
                          'Flood / Disaster',
                          'Accident',
                        ]
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Immediate Details',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(
            context,
            _EmergencyReportDraft(
              location: _selectedLocation,
              type: _type,
              details: _detailsController.text.trim(),
            ),
          ),
          icon: const Icon(Icons.check),
          label: const Text('CONFIRM LOCATION & SUBMIT'),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),

        child: InkWell(
          borderRadius: BorderRadius.circular(12),

          onTap: onTap ?? () {},

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color: selected
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
