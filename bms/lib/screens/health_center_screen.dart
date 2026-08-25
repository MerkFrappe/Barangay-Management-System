import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';
import '../widgets/sidebar.dart';

class HealthCenterScreen extends StatefulWidget {
  final bool isAdmin;
  const HealthCenterScreen({super.key, this.isAdmin = false});

  @override
  State<HealthCenterScreen> createState() => _HealthCenterScreenState();
}

class _HealthCenterScreenState extends State<HealthCenterScreen> {
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _serviceType = 'General Medical Consultation';
  String _preferredDate = 'Tomorrow Morning (8:00 AM - 12:00 PM)';
  bool _isSubmitting = false;

  void _showAppointmentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.local_hospital, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('Book Health Appointment'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Patient Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contactCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Number', prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _serviceType,
                  decoration: const InputDecoration(labelText: 'Service Needed'),
                  items: [
                    'General Medical Consultation',
                    'Child Vaccination & Immunization',
                    'Maternal & Prenatal Checkup',
                    'Dental Checkup & Extraction',
                    'Senior Citizen Maintenance Medicines'
                  ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) => setDialogState(() => _serviceType = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _preferredDate,
                  decoration: const InputDecoration(labelText: 'Preferred Time Slot'),
                  items: [
                    'Tomorrow Morning (8:00 AM - 12:00 PM)',
                    'Tomorrow Afternoon (1:00 PM - 4:00 PM)',
                    'Next Available Clinic Schedule'
                  ].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) => setDialogState(() => _preferredDate = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Medical Notes / Symptoms (Optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_nameCtrl.text.isEmpty) return;
                      setDialogState(() => _isSubmitting = true);
                      try {
                        final doc = FirebaseFirestore.instance.collection('health_appointments').doc();
                        await doc.set({
                          'id': doc.id,
                          'patientName': _nameCtrl.text.trim(),
                          'contact': _contactCtrl.text.trim(),
                          'service': _serviceType,
                          'timeSlot': _preferredDate,
                          'notes': _notesCtrl.text.trim(),
                          'status': 'Confirmed',
                          'createdAt': FieldValue.serverTimestamp(),
                          'date': DateTime.now().toString().substring(0, 10),
                        });
                        if (!mounted) return;
                        _nameCtrl.clear();
                        _contactCtrl.clear();
                        _notesCtrl.clear();
                        setDialogState(() => _isSubmitting = false);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment confirmed! Queue number generated.')),
                        );
                      } catch (e) {
                        setDialogState(() => _isSubmitting = false);
                      }
                    },
              child: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;

      final body = SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildServicesGrid(isWide),
              const SizedBox(height: 24),
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildQueueCard()),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: _buildEmergencyHotlineCard()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildQueueCard(),
                        const SizedBox(height: 24),
                        _buildEmergencyHotlineCard(),
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
              SizedBox(width: 256, child: widget.isAdmin ? const SidebarNav(selectedIndex: 5) : const ResidentSidebar()),
              Expanded(child: body),
            ],
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text('Barangay Health Center', style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        ),
        drawer: Drawer(child: widget.isAdmin ? const SidebarNav(selectedIndex: 5) : const ResidentSidebar()),
        body: body,
      );
    });
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barangay Health & Medical Center', style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(
                'Free primary medical consultation, maternal care, child immunization, and emergency response.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showAppointmentDialog,
          icon: const Icon(Icons.add_location_alt),
          label: const Text('Book Appointment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid(bool isWide) {
    final services = [
      _ServiceItem('Free Medical Checkup', 'Daily 8AM-5PM', Icons.medical_services, AppColors.primaryContainer, AppColors.primary),
      _ServiceItem('Child Immunization', 'Wednesdays 9AM', Icons.child_care, AppColors.tertiaryContainer, AppColors.tertiary),
      _ServiceItem('Dental Clinic', 'Tues & Thurs', Icons.clean_hands, AppColors.secondaryContainer, AppColors.secondary),
      _ServiceItem('Free Medicine Supply', 'In Stock', Icons.medication, AppColors.surfaceContainerHighest, AppColors.onSurface),
    ];

    if (isWide) {
      return Row(children: services.map((s) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: s))).toList());
    }
    return Column(children: services.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12), child: s)).toList());
  }

  Widget _buildQueueCard() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today\'s Consultation Queue', style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold)),
                Chip(label: const Text('Live Sync'), backgroundColor: AppColors.primaryContainer),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('health_appointments').snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No active health appointments booked today.')),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text('#${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['patientName'] ?? 'Patient', style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold)),
                                Text('${data['service']} • ${data['timeSlot']}', style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Chip(label: Text(data['status'] ?? 'Confirmed'), backgroundColor: AppColors.primaryContainer),
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

  Widget _buildEmergencyHotlineCard() {
    return Card(
      elevation: 0,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.red[800], size: 28),
                const SizedBox(width: 12),
                Text('Medical Emergency', style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold, color: Colors.red[900])),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Need immediate ambulance dispatch or emergency rescue?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: Colors.red),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ambulance Direct Line', style: AppTextStyles.labelSm.copyWith(color: Colors.grey[600])),
                      Text('+63 917 999 1111', style: AppTextStyles.titleLg.copyWith(color: Colors.red[800], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling Barangay Ambulance Hotline (+63 917 999 1111)...'), backgroundColor: Colors.red),
                  );
                },
                icon: const Icon(Icons.call),
                label: const Text('CALL AMBULANCE NOW'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String name;
  final String schedule;
  final IconData icon;
  final Color bg;
  final Color iconCol;
  const _ServiceItem(this.name, this.schedule, this.icon, this.bg, this.iconCol);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconCol, size: 28),
          const SizedBox(height: 12),
          Text(name, style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold, color: iconCol)),
          const SizedBox(height: 4),
          Text(schedule, style: AppTextStyles.bodySm.copyWith(color: iconCol.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
