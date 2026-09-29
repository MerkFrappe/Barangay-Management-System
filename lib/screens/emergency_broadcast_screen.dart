import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

class EmergencyBroadcastScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? location;
  final String? reportType;
  final String? reportDetails;

  const EmergencyBroadcastScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.location,
    this.reportType,
    this.reportDetails,
  });

  @override
  State<EmergencyBroadcastScreen> createState() =>
      _EmergencyBroadcastScreenState();
}

class _EmergencyBroadcastScreenState extends State<EmergencyBroadcastScreen> {
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _alertLevel = 'High (Warning)';
  bool _isBroadcasting = false;

  bool get _hasLocation => widget.latitude != null && widget.longitude != null;

  @override
  void initState() {
    super.initState();
    if (widget.reportType != null) {
      _titleCtrl.text = '${widget.reportType} Alert';
    }
    if (widget.reportDetails != null) {
      _msgCtrl.text = widget.reportDetails!;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendBroadcast() async {
    final title = _titleCtrl.text.trim();
    final msg = _msgCtrl.text.trim();
    if (title.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out the alert title and details.'),
        ),
      );
      return;
    }

    setState(() => _isBroadcasting = true);
    try {
      final doc = FirebaseFirestore.instance
          .collection('emergency_alerts')
          .doc();
      await doc.set({
        'id': doc.id,
        'title': title,
        'message': msg,
        'alertLevel': _alertLevel,
        'sender': 'Barangay HQ Dispatch',
        if (_hasLocation) 'latitude': widget.latitude,
        if (_hasLocation) 'longitude': widget.longitude,
        if (widget.location != null) 'location': widget.location,
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().toString().substring(0, 16),
      });

      if (!mounted) return;
      _titleCtrl.clear();
      _msgCtrl.clear();
      setState(() => _isBroadcasting = false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.campaign, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Text('EMERGENCY BROADCAST SENT!'),
            ],
          ),
          content: Text(
            'Emergency alert "$title" has been dispatched to all registered resident devices & SMS gateway.',
            style: AppTextStyles.bodyMd,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBroadcasting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to send the emergency alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final body = SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildDispatchFormCard()),
                          const SizedBox(width: 24),
                          Expanded(flex: 7, child: _buildLiveAlertFeedCard()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildDispatchFormCard(),
                          const SizedBox(height: 24),
                          _buildLiveAlertFeedCard(),
                        ],
                      ),
              ],
            ),
          ),
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                const SidebarNav(selectedIndex: -1, emergencySelected: true),
                Expanded(
                  child: Column(
                    children: [
                      const TopHeader(),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurface,
            elevation: 0,
            title: Text(
              'Emergency Dispatch',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          drawer: const Drawer(
            child: SidebarNav(selectedIndex: -1, emergencySelected: true),
          ),
          body: body,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Alert & Dispatch Center',
          style: AppTextStyles.headlineLg.copyWith(color: Colors.red[800]),
        ),
        const SizedBox(height: 4),
        Text(
          'Issue immediate disaster advisory alerts, evacuation warnings, and public safety announcements.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDispatchFormCard() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.redAccent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Compose Broadcast',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Alert Headline / Title',
                hintText: 'e.g., Flash Flood Warning - Evacuate Zone 2',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            if (_hasLocation) ...[
              const SizedBox(height: 16),
              Text('Reported Emergency Location', style: AppTextStyles.titleSm),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 210,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        widget.latitude!,
                        widget.longitude!,
                      ),
                      initialZoom: 16,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
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
                            point: LatLng(widget.latitude!, widget.longitude!),
                            width: 48,
                            height: 48,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppColors.error,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.location ?? '${widget.latitude}, ${widget.longitude}',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _alertLevel,
              decoration: const InputDecoration(labelText: 'Severity Level'),
              items: [
                'Critical (Immediate Evacuation)',
                'High (Warning)',
                'Moderate (Advisory)',
                'Low (Info)',
              ].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) => setState(() => _alertLevel = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _msgCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Broadcast Instructions & Details',
                hintText: 'Provide detailed instructions for residents...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isBroadcasting ? null : _sendBroadcast,
                icon: _isBroadcasting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.broadcast_on_personal),
                label: Text(
                  _isBroadcasting
                      ? 'DISPATCHING...'
                      : 'DISPATCH EMERGENCY BROADCAST',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAlertFeedCard() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Broadcast History',
              style: AppTextStyles.titleLg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('emergency_alerts')
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No emergency alerts logged.')),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['title'] ?? 'Alert',
                                style: AppTextStyles.titleMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                              ),
                              Chip(
                                label: Text(data['alertLevel'] ?? 'High'),
                                backgroundColor: Colors.red[100],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['message'] ?? '',
                            style: AppTextStyles.bodyMd,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Logged: ${data['date'] ?? 'Now'}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
