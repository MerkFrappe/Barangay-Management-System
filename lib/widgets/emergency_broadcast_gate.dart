import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

class _EmergencyBroadcastGateState extends State<EmergencyBroadcastGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForAlert());
  }

  Future<void> _checkForAlert() async {
    if (_checked) return;
    _checked = true;
    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(minutes: 10)),
    );
    try {
      final alerts = await FirebaseFirestore.instance
          .collection('emergency_alerts')
          .where('createdAt', isGreaterThanOrEqualTo: cutoff)
          .get();
      if (!mounted || alerts.docs.isEmpty) return;

      final latest = alerts.docs.reduce((current, candidate) {
        final currentAt = current.data()['createdAt'] as Timestamp?;
        final candidateAt = candidate.data()['createdAt'] as Timestamp?;
        return (candidateAt?.millisecondsSinceEpoch ?? 0) >
                (currentAt?.millisecondsSinceEpoch ?? 0)
            ? candidate
            : current;
      }).data();
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
              if ((latest['location'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Location: ${latest['location']}',
                  style: AppTextStyles.bodySm,
                ),
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
    } catch (_) {
      // A broadcast check must not prevent residents from using the app.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
