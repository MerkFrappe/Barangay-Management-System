import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/user_roles.dart';
import '../theme/app_colors.dart';

class JurisdictionMap extends StatelessWidget {
  const JurisdictionMap({super.key});

  @override
  Widget build(BuildContext context) => _PresenceMapCard(
    onExpand: () => showDialog<void>(
      context: context,
      builder: (_) => const _ExpandedPresenceMap(),
    ),
  );
}

class _PresenceMapCard extends StatelessWidget {
  final VoidCallback onExpand;
  const _PresenceMapCard({required this.onExpand});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('live_presence')
          .snapshots(),
      builder: (context, snapshot) {
        final users = _onlineUsers(snapshot.data?.docs ?? const []);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MapHeader(count: users.length, onExpand: onExpand),
                SizedBox(height: 220, child: _LiveMap(users: users)),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Wrap(
                    spacing: 14,
                    children: [
                      _LegendDot(color: Colors.green, label: 'Resident'),
                      _LegendDot(
                        color: AppColors.primary,
                        label: 'Admin / staff',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedPresenceMap extends StatelessWidget {
  const _ExpandedPresenceMap();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 1050,
        height: 700,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('live_presence')
              .snapshots(),
          builder: (context, snapshot) {
            final users = _onlineUsers(snapshot.data?.docs ?? const []);
            return Column(
              children: [
                _MapHeader(
                  count: users.length,
                  expanded: true,
                  onExpand: () => Navigator.of(context).pop(),
                ),
                Expanded(child: _LiveMap(users: users)),
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Only users currently active in Civica with location permission appear here. Hover over a marker to see their name.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onExpand;
  const _MapHeader({
    required this.count,
    required this.onExpand,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
    color: AppColors.surfaceContainerLow,
    child: Row(
      children: [
        Icon(Icons.map_outlined, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          'Live User Map',
          style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.successGreenBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$count ${count == 1 ? 'USER' : 'USERS'} ONLINE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.successGreen,
            ),
          ),
        ),
        IconButton(
          tooltip: expanded ? 'Close expanded map' : 'Expand map',
          onPressed: onExpand,
          icon: Icon(expanded ? Icons.close_fullscreen : Icons.open_in_full),
        ),
      ],
    ),
  );
}

class _LiveMap extends StatelessWidget {
  final List<_LiveUser> users;
  const _LiveMap({required this.users});

  @override
  Widget build(BuildContext context) {
    const fallback = LatLng(7.423816, 125.826013);
    final center = users.isEmpty ? fallback : users.first.location;
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: users.isEmpty ? 14 : 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.barangay.bms',
        ),
        MarkerLayer(
          markers: users
              .map(
                (user) => Marker(
                  point: user.location,
                  width: 38,
                  height: 38,
                  child: Tooltip(
                    message: user.displayName,
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: user.isAdmin
                              ? AppColors.primary
                              : Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Color(0x55000000), blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label, style: AppTextStyles.labelSm),
    ],
  );
}

class _LiveUser {
  final String displayName;
  final String role;
  final LatLng location;
  const _LiveUser({
    required this.displayName,
    required this.role,
    required this.location,
  });
  bool get isAdmin => isAdminRole(role);
}

List<_LiveUser> _onlineUsers(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final cutoff = DateTime.now().subtract(const Duration(minutes: 2));
  return docs
      .map((doc) {
        final data = doc.data();
        final point = data['location'];
        final timestamp = data['lastActiveAt'];
        if (point is! GeoPoint ||
            timestamp is! Timestamp ||
            timestamp.toDate().isBefore(cutoff)) {
          return null;
        }
        return _LiveUser(
          displayName: (data['displayName'] ?? 'Unnamed user').toString(),
          role: (data['role'] ?? 'Resident').toString(),
          location: LatLng(point.latitude, point.longitude),
        );
      })
      .whereType<_LiveUser>()
      .toList();
}
