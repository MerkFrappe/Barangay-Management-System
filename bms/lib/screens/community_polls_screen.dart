import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';

class CommunityPollsScreen extends StatefulWidget {
  const CommunityPollsScreen({super.key});

  @override
  State<CommunityPollsScreen> createState() => _CommunityPollsScreenState();
}

class _CommunityPollsScreenState extends State<CommunityPollsScreen> {
  final Map<String, int> _userVotes = {};

  void _vote(String pollId, int optionIndex) async {
    setState(() => _userVotes[pollId] = optionIndex);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your vote has been submitted successfully!')),
    );
  }

  void _showCreatePollDialog() {
    final titleCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Community Poll'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Poll Question / Title')),
            const SizedBox(height: 12),
            TextField(controller: opt1Ctrl, decoration: const InputDecoration(labelText: 'Option 1')),
            const SizedBox(height: 12),
            TextField(controller: opt2Ctrl, decoration: const InputDecoration(labelText: 'Option 2')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              final doc = FirebaseFirestore.instance.collection('polls').doc();
              await doc.set({
                'id': doc.id,
                'title': titleCtrl.text.trim(),
                'option1': opt1Ctrl.text.trim().isEmpty ? 'Yes' : opt1Ctrl.text.trim(),
                'option2': opt2Ctrl.text.trim().isEmpty ? 'No' : opt2Ctrl.text.trim(),
                'votes1': 12,
                'votes2': 5,
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (!mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Publish Poll'),
          ),
        ],
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
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Community Polls & Feedback', style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('Voice your opinion on upcoming barangay projects and public initiatives.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreatePollDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Poll'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPollList(),
            ],
          ),
        ),
      );

      if (isWide) {
        return Scaffold(
          body: Row(
            children: [
              const SizedBox(width: 256, child: ResidentSidebar()),
              Expanded(child: body),
            ],
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Community Polls')),
        drawer: const Drawer(child: ResidentSidebar()),
        body: body,
      );
    });
  }

  Widget _buildPollList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('polls').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          // Render default sample poll
          return Card(
            elevation: 0,
            color: AppColors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.outlineVariant)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: const Text('Active Community Poll'), backgroundColor: AppColors.primaryContainer),
                  const SizedBox(height: 12),
                  Text('Should the Barangay Covered Court schedule be extended until 10:00 PM on weekends?', style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildOptionBar('Sample1', 0, 'Yes, extend hours', 68, 100),
                  const SizedBox(height: 12),
                  _buildOptionBar('Sample1', 1, 'No, keep current 8:00 PM limit', 32, 100),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final pollId = docs[index].id;
            final opt1 = data['option1'] ?? 'Yes';
            final opt2 = data['option2'] ?? 'No';
            final v1 = (data['votes1'] ?? 10) as int;
            final v2 = (data['votes2'] ?? 5) as int;
            final total = v1 + v2;

            return Card(
              elevation: 0,
              color: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.outlineVariant)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(label: const Text('Community Vote'), backgroundColor: AppColors.secondaryContainer),
                    const SizedBox(height: 12),
                    Text(data['title'] ?? 'Barangay Initiative Poll', style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    _buildOptionBar(pollId, 0, opt1, v1, total),
                    const SizedBox(height: 12),
                    _buildOptionBar(pollId, 1, opt2, v2, total),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionBar(String pollId, int optIdx, String label, int votes, int total) {
    final selected = _userVotes[pollId] == optIdx;
    final percent = total > 0 ? (votes / total) : 0.0;

    return InkWell(
      onTap: () => _vote(pollId, optIdx),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold)),
                Text('${(percent * 100).toStringAsFixed(0)}% ($votes votes)'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: percent, backgroundColor: Colors.grey[300], color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
