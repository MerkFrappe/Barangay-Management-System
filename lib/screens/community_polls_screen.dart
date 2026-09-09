import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';
import '../widgets/sidebar.dart';

class CommunityPollsScreen extends StatefulWidget {
  final bool isAdmin;
  const CommunityPollsScreen({super.key, this.isAdmin = false});

  @override
  State<CommunityPollsScreen> createState() => _CommunityPollsScreenState();
}

class _CommunityPollsScreenState extends State<CommunityPollsScreen> {
  final Map<String, int> _userVotes = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _vote(String pollId, int optionIndex) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final ref = FirebaseFirestore.instance.collection('polls').doc(pollId);
      final poll = await transaction.get(ref);
      final data = poll.data() ?? {};
      final voteRef = ref.collection('votes').doc(uid);
      final oldVote = await transaction.get(voteRef);
      final old = oldVote.data()?['optionIndex'] as int?;
      final counts = List<int>.from(
        (data['voteCounts'] ?? [data['votes1'] ?? 0, data['votes2'] ?? 0]).map(
          (v) => (v as num).toInt(),
        ),
      );
      while (counts.length < 2) {
        counts.add(0);
      }
      if (old != null && old < counts.length) counts[old]--;
      counts[optionIndex]++;
      transaction.set(voteRef, {
        'optionIndex': optionIndex,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(ref, {
        'voteCounts': counts,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    setState(() => _userVotes[pollId] = optionIndex);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your vote has been submitted successfully!'),
      ),
    );
  }

  void _showCreatePollDialog() {
    final titleCtrl = TextEditingController();
    final optionCtrls = [TextEditingController(), TextEditingController()];
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Create Community Poll'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Poll Question / Title',
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                optionCtrls.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: optionCtrls[i],
                          decoration: InputDecoration(
                            labelText: 'Option ${i + 1}',
                          ),
                        ),
                      ),
                      if (optionCtrls.length > 2)
                        IconButton(
                          onPressed: () => setDialogState(
                            () => optionCtrls.removeAt(i).dispose(),
                          ),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => setDialogState(
                  () => optionCtrls.add(TextEditingController()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add choice'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  deadline == null
                      ? 'Set poll end date and time'
                      : 'Ends: ${deadline.toString().substring(0, 16)}',
                ),
                trailing: const Icon(Icons.schedule),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  if (date == null) return;
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null)
                    setDialogState(
                      () => deadline = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final choices = optionCtrls
                    .map((c) => c.text.trim())
                    .where((v) => v.isNotEmpty)
                    .toList();
                if (titleCtrl.text.isEmpty ||
                    choices.length < 2 ||
                    deadline == null)
                  return;
                final doc = FirebaseFirestore.instance
                    .collection('polls')
                    .doc();
                await doc.set({
                  'id': doc.id,
                  'title': titleCtrl.text.trim(),
                  'choices': choices,
                  'voteCounts': List.filled(choices.length, 0),
                  'status': 'open',
                  'endAt': Timestamp.fromDate(deadline!),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (!mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text('Publish Poll'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                        Text(
                          'Community Polls & Feedback',
                          style: AppTextStyles.headlineLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Voice your opinion on upcoming barangay projects and public initiatives.',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (widget.isAdmin)
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
                SizedBox(
                  width: 256,
                  child: widget.isAdmin
                      ? const SidebarNav(selectedIndex: 7)
                      : const ResidentSidebar(selectedItem: 'Community Polls'),
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Community Polls')),
          drawer: Drawer(
            child: widget.isAdmin
                ? const SidebarNav(selectedIndex: 7)
                : const ResidentSidebar(selectedItem: 'Community Polls'),
          ),
          bottomNavigationBar: const ResidentMobileNavigation(currentIndex: 1),
          body: body,
        );
      },
    );
  }

  Widget _buildPollList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('polls').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final now = DateTime.now();
        final open = docs.where((d) {
          final m = d.data() as Map<String, dynamic>;
          final end = (m['endAt'] as Timestamp?)?.toDate();
          return m['status'] != 'closed' && (end == null || end.isAfter(now));
        }).toList();
        final closed = docs.where((d) => !open.contains(d)).toList();
        if (open.isEmpty && !widget.isAdmin) {
          // Render default sample poll
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
                  Chip(
                    label: const Text('Active Community Poll'),
                    backgroundColor: AppColors.primaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Should the Barangay Covered Court schedule be extended until 10:00 PM on weekends?',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionBar('Sample1', 0, 'Yes, extend hours', 68, 100),
                  const SizedBox(height: 12),
                  _buildOptionBar(
                    'Sample1',
                    1,
                    'No, keep current 8:00 PM limit',
                    32,
                    100,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: open.length + (widget.isAdmin ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (widget.isAdmin && index == open.length)
              return SizedBox(
                height: 160,
                child: Card(
                  child: ListView(
                    children: [
                      const ListTile(title: Text('Recent poll history')),
                      ...closed.take(5).map((d) {
                        final m = d.data() as Map<String, dynamic>;
                        return ListTile(
                          dense: true,
                          title: Text(m['title'] ?? 'Poll'),
                          subtitle: Text(
                            'Closed • ${List<int>.from(m['voteCounts'] ?? []).fold(0, (a, b) => a + b)} votes',
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            final data = open[index].data() as Map<String, dynamic>;
            final pollId = open[index].id;
            final choices = List<String>.from(
              data['choices'] ??
                  [data['option1'] ?? 'Yes', data['option2'] ?? 'No'],
            );
            final counts = List<int>.from(
              (data['voteCounts'] ?? [data['votes1'] ?? 0, data['votes2'] ?? 0])
                  .map((v) => (v as num).toInt()),
            );
            while (counts.length < choices.length) {
              counts.add(0);
            }
            final total = counts.fold(0, (a, b) => a + b);

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
                    Chip(
                      label: const Text('Community Vote'),
                      backgroundColor: AppColors.secondaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['title'] ?? 'Barangay Initiative Poll',
                      style: AppTextStyles.titleLg.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (data['endAt'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Ends in ${((data['endAt'] as Timestamp).toDate().difference(now).inMinutes).clamp(0, 999999)} minutes',
                        ),
                      ),
                    const SizedBox(height: 20),
                    ...List.generate(
                      choices.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOptionBar(
                          pollId,
                          i,
                          choices[i],
                          counts[i],
                          total,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionBar(
    String pollId,
    int optIdx,
    String label,
    int votes,
    int total,
  ) {
    final selected = _userVotes[pollId] == optIdx;
    final percent = total > 0 ? (votes / total) : 0.0;

    return InkWell(
      onTap: widget.isAdmin ? null : () => _vote(pollId, optIdx),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${(percent * 100).toStringAsFixed(0)}% ($votes votes)'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey[300],
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
