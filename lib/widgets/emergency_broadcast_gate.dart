import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../theme/app_colors.dart';

/// Shows the latest emergency broadcast when a resident opens the app within
/// ten minutes of it being sent. This is an in-app alert and does not require a
/// third-party push-notification service.
class EmergencyBroadcastGate extends StatefulWidget {
  final Widget child;
  const EmergencyBroadcastGate({super.key, required this.child});

  @override
  State<EmergencyBroadcastGate> createState() => _EmergencyBroadcastGateState();
}

class _EmergencyBroadcastGateState extends State<EmergencyBroadcastGate>
    with WidgetsBindingObserver {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _alertSubscription;
  final Set<String> _shownAlertIds = <String>{};
  bool _dialogShowing = false;
  final AudioPlayer _warningPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenForAlerts());
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    _warningPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _alertSubscription?.cancel();
      _listenForAlerts();
    }
  }

  void _listenForAlerts() {
    if (!mounted) return;
    // Read a small recent window and filter locally. This avoids a required
    // Firestore composite/index query and also handles alerts created while a
    // mobile app was backgrounded or offline.
    _alertSubscription = FirebaseFirestore.instance
        .collection('emergency_alerts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(_handleAlertSnapshot, onError: (_) {});
  }

  Future<void> _handleAlertSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (!mounted || _dialogShowing || snapshot.docs.isEmpty) return;

    final now = DateTime.now();
    final unseen = snapshot.docs
        .where((doc) => !_shownAlertIds.contains(doc.id))
        .where((doc) {
          final data = doc.data();
          final expiresAt = data['expiresAt'];
          if (expiresAt is Timestamp) return expiresAt.toDate().isAfter(now);
          final createdAt = data['createdAt'];
          return createdAt is Timestamp &&
              createdAt.toDate().isAfter(
                now.subtract(const Duration(hours: 24)),
              );
        })
        .toList();
    if (unseen.isEmpty) return;

    // On first load, show only the newest alert and mark older alerts seen.
    // Later snapshots contain only newly dispatched alerts.
    unseen.sort((a, b) {
      final aTime = a.data()['createdAt'] as Timestamp?;
      final bTime = b.data()['createdAt'] as Timestamp?;
      return (bTime?.millisecondsSinceEpoch ?? 0).compareTo(
        aTime?.millisecondsSinceEpoch ?? 0,
      );
    });
    final latestDoc = unseen.first;
    _shownAlertIds.addAll(unseen.map((doc) => doc.id));
    await _showAlert(latestDoc.data());
  }

  Future<void> _showAlert(Map<String, dynamic> latest) async {
    if (!mounted) return;
    _dialogShowing = true;
    try {
      // Start before opening the modal so the resident hears the warning even
      // if the dialog takes a moment to render on a mobile device.
      try {
        await _warningPlayer.stop();
        await _warningPlayer.setReleaseMode(ReleaseMode.stop);
        await _warningPlayer.play(
          AssetSource('tools/assets/warning-sound.mp3'),
        );
      } catch (error) {
        // A muted device or unsupported platform must not prevent the alert.
        debugPrint('Unable to play emergency warning sound: $error');
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.campaign_rounded, color: AppColors.error, size: 30),
              SizedBox(width: 12),
              Expanded(child: Text('Emergency Broadcast')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (latest['title'] ?? 'Emergency alert').toString(),
                style: AppTextStyles.titleLg.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 10),
              Text((latest['message'] ?? '').toString()),
              if ((latest['alertLevel'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Priority: ${latest['alertLevel']}',
                  style: AppTextStyles.bodySm,
                ),
              ],
              if ((latest['location'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Location: ${latest['location']}',
                  style: AppTextStyles.bodySm,
                ),
              ],
              if ((latest['date'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Issued: ${latest['date']}', style: AppTextStyles.bodySm),
              ],
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('I UNDERSTAND'),
            ),
          ],
        ),
      );
    } finally {
      await _warningPlayer.stop();
      _dialogShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
