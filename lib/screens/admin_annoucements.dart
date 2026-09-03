import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

enum AnnouncementStatus { published, draft, scheduled }

enum AnnouncementCategory { news, emergency, event, officialMemo }

class Announcement {
  final String id;
  final String title;
  final String description;
  final String date;
  final AnnouncementCategory category;
  final AnnouncementStatus status;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.status,
  });
}

// ─── Fake Database Service ────────────────────────────────────────────────────
// Simulates network latency. To connect to a real backend:
//   fetchAnnouncements() → replace with: http.get(Uri.parse('$baseUrl/announcements'))
//   saveAnnouncement()   → replace with: http.post(Uri.parse('$baseUrl/announcements'), body: ...)
//   deleteAnnouncement() → replace with: http.delete(Uri.parse('$baseUrl/announcements/$id'))

class AnnouncementService {
  static final _collection = FirebaseFirestore.instance.collection(
    'announcements',
  );

  static AnnouncementCategory _parseCategory(String name) {
    return AnnouncementCategory.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AnnouncementCategory.news,
    );
  }

  static AnnouncementStatus _parseStatus(String name) {
    return AnnouncementStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AnnouncementStatus.published,
    );
  }

  static Stream<List<Announcement>> getAnnouncementsStream() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map((
      snap,
    ) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return Announcement(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: data['date'] ?? '',
          category: _parseCategory(data['category'] ?? 'news'),
          status: _parseStatus(data['status'] ?? 'published'),
        );
      }).toList();
    });
  }

  static Future<List<Announcement>> fetchAnnouncements() async {
    try {
      final snap = await _collection
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((doc) {
        final data = doc.data();
        return Announcement(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: data['date'] ?? '',
          category: _parseCategory(data['category'] ?? 'news'),
          status: _parseStatus(data['status'] ?? 'published'),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
      return [];
    }
  }

  static Future<Announcement> saveAnnouncement(Announcement a) async {
    try {
      if (a.id.isEmpty) {
        final docRef = await _collection.add({
          'title': a.title,
          'description': a.description,
          'date': a.date,
          'category': a.category.name,
          'status': a.status.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return Announcement(
          id: docRef.id,
          title: a.title,
          description: a.description,
          date: a.date,
          category: a.category,
          status: a.status,
        );
      } else {
        await _collection.doc(a.id).set({
          'title': a.title,
          'description': a.description,
          'date': a.date,
          'category': a.category.name,
          'status': a.status.name,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return a;
      }
    } catch (e) {
      debugPrint('Error saving announcement: $e');
      rethrow;
    }
  }

  static Future<void> deleteAnnouncement(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      rethrow;
    }
  }
}

// ─── Main Page ───────────────────────────────────────────────────────────────

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;

        final body = const _MainContent();

        if (isWide) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                const SidebarNav(selectedIndex: 6),
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
            elevation: 1,
            title: Text(
              'Announcements',
              style: AppTextStyles.titleLg.copyWith(color: AppColors.onSurface),
            ),
            iconTheme: IconThemeData(color: AppColors.onSurface),
          ),
          drawer: const Drawer(child: SidebarNav(selectedIndex: 6)),
          body: body,
        );
      },
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFC4C5D5))),
            color: Colors.white,
          ),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Announcement Management',
                    style: TextStyle(
                      color: Color(0xFF002576),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Draft, schedule, and broadcast community updates.',
                    style: TextStyle(color: Color(0xFF444653), fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Preview Mode'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF002576),
                  side: const BorderSide(color: Color(0xFF002576)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 7, child: _LeftColumn()),
                SizedBox(width: 20),
                SizedBox(width: 360, child: _AddEventForm()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Left Column ─────────────────────────────────────────────────────────────

class _LeftColumn extends StatefulWidget {
  const _LeftColumn();

  @override
  State<_LeftColumn> createState() => _LeftColumnState();
}

class _LeftColumnState extends State<_LeftColumn> {
  late Stream<List<Announcement>> _stream;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _stream = AnnouncementService.getAnnouncementsStream();
  }

  List<Announcement> _applyFilter(List<Announcement> all) {
    if (_filter == 'Drafts') {
      return all.where((a) => a.status == AnnouncementStatus.draft).toList();
    }
    if (_filter == 'Published') {
      return all
          .where((a) => a.status == AnnouncementStatus.published)
          .toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC4C5D5)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recent Announcements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const Spacer(),
                    _FilterChip(
                      label: 'All',
                      selected: _filter == 'All',
                      onTap: () => setState(() => _filter = 'All'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Drafts',
                      selected: _filter == 'Drafts',
                      onTap: () => setState(() => _filter = 'Drafts'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Published',
                      selected: _filter == 'Published',
                      onTap: () => setState(() => _filter = 'Published'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Announcement>>(
                  stream: _stream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF002576),
                          ),
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final items = _applyFilter(snap.data ?? []);
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No announcements found.',
                            style: TextStyle(color: Color(0xFF747685)),
                          ),
                        ),
                      );
                    }
                    return _AnnouncementsTable(items: items, onDeleted: () {});
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All History',
                      style: TextStyle(
                        color: Color(0xFF002576),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCard(
                label: 'Total Published',
                value: '128',
                icon: Icons.campaign_outlined,
                dark: true,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Total Reach',
                value: '4.2k',
                icon: Icons.visibility_outlined,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Avg. Engagement',
                value: '82%',
                icon: Icons.trending_up,
                accentColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD3E4FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF002576) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? const Color(0xFF002576) : const Color(0xFF444653),
          ),
        ),
      ),
    );
  }
}

// ─── Table ────────────────────────────────────────────────────────────────────

class _AnnouncementsTable extends StatelessWidget {
  final List<Announcement> items;
  final VoidCallback onDeleted;
  const _AnnouncementsTable({required this.items, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFC4C5D5))),
          ),
          children: ['Title', 'Date', 'Category', 'Status', 'Actions']
              .map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    h,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444653),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...items.map((a) => _buildRow(context, a)),
      ],
    );
  }

  TableRow _buildRow(BuildContext context, Announcement a) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5EEFF))),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF002576),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                a.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF444653)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            a.date,
            style: const TextStyle(fontSize: 12, color: Color(0xFF444653)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: _CategoryBadge(category: a.category),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: _StatusBadge(status: a.status),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: 18,
              color: Color(0xFF444653),
            ),
            onSelected: (value) async {
              if (value == 'delete') {
                await AnnouncementService.deleteAnnouncement(a.id);
                onDeleted();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${a.title}" deleted.'),
                      backgroundColor: const Color(0xFF002576),
                    ),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final AnnouncementCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final map = {
      AnnouncementCategory.event: (
        'Event',
        const Color(0xFFD3E4FE),
        const Color(0xFF002576),
      ),
      AnnouncementCategory.emergency: (
        'Emergency',
        const Color(0xFF8C0014),
        const Color(0xFFFF918B),
      ),
      AnnouncementCategory.news: (
        'News',
        const Color(0xFFD3E4FE),
        const Color(0xFF002576),
      ),
      AnnouncementCategory.officialMemo: (
        'Official Memo',
        const Color(0xFFFFE089),
        const Color(0xFF574500),
      ),
    };
    final (label, bg, fg) = map[category]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AnnouncementStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      AnnouncementStatus.published: (
        'PUBLISHED',
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
      ),
      AnnouncementStatus.draft: (
        'DRAFT',
        const Color(0xFFFECC00),
        const Color(0xFF6E5700),
      ),
      AnnouncementStatus.scheduled: (
        'SCHEDULED',
        const Color(0xFFDBEAFE),
        const Color(0xFF1E40AF),
      ),
    };
    final (label, bg, fg) = map[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool dark;
  final Color? accentColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.dark = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF002576) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC4C5D5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: dark ? const Color(0xFF96ADFF) : const Color(0xFF444653),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : const Color(0xFF002576),
                  ),
                ),
                Icon(
                  icon,
                  size: 32,
                  color:
                      accentColor ??
                      (dark
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFFFECC00)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Event Form ───────────────────────────────────────────────────────────

class _AddEventForm extends StatefulWidget {
  const _AddEventForm();

  @override
  State<_AddEventForm> createState() => _AddEventFormState();
}

class _AddEventFormState extends State<_AddEventForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  AnnouncementCategory _category = AnnouncementCategory.news;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF002576)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit(AnnouncementStatus status) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an event title.')),
      );
      return;
    }
    setState(() => _isSaving = true);

    final a = Announcement(
      id: '',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? 'No description provided.'
          : _descController.text.trim(),
      date: _selectedDate != null
          ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
          : 'No date set',
      category: _category,
      status: status,
    );

    await AnnouncementService.saveAnnouncement(a);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == AnnouncementStatus.published
                ? '"${a.title}" published!'
                : '"${a.title}" saved as draft.',
          ),
          backgroundColor: const Color(0xFF002576),
        ),
      );
      _titleController.clear();
      _descController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _category = AnnouncementCategory.news;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C5D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF002576),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Text(
                  'Add New Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.add_circle_outline, color: Colors.white),
              ],
            ),
          ),

          // Keep the form usable on short browser windows. The header and
          // actions remain available while the fields scroll independently.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormLabel('Event Title'),
                  const SizedBox(height: 6),
                  _FormField(
                    controller: _titleController,
                    hint: 'e.g., Annual Sports Fest 2023',
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel('Date'),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _pickDate,
                              child: _PickerField(
                                icon: Icons.calendar_today,
                                label: _selectedDate != null
                                    ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                                    : 'Pick date',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel('Time'),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _pickTime,
                              child: _PickerField(
                                icon: Icons.access_time,
                                label: _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : 'Pick time',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _FormLabel('Category'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<AnnouncementCategory>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF747685)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF002576),
                          width: 2,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AnnouncementCategory.news,
                        child: Text('News'),
                      ),
                      DropdownMenuItem(
                        value: AnnouncementCategory.emergency,
                        child: Text('Emergency'),
                      ),
                      DropdownMenuItem(
                        value: AnnouncementCategory.event,
                        child: Text('Event'),
                      ),
                      DropdownMenuItem(
                        value: AnnouncementCategory.officialMemo,
                        child: Text('Official Memo'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 16),

                  _FormLabel('Description'),
                  const SizedBox(height: 6),
                  _FormField(
                    controller: _descController,
                    hint: 'Describe the details of the announcement...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  _FormLabel('Cover Image'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFC4C5D5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF8F9FF),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 36,
                          color: Color(0xFF747685),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Drop image here or click to upload',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF444653),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Recommended: 1200x630px',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF747685),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF4FF),
              border: Border(top: BorderSide(color: Color(0xFFC4C5D5))),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _submit(AnnouncementStatus.draft),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF002576),
                      side: const BorderSide(color: Color(0xFF002576)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Draft',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _submit(AnnouncementStatus.published),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002576),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Publish Now',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form helpers ─────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF444653),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF747685), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF747685)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF002576), width: 2),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PickerField({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF747685)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF444653)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF444653)),
          ),
        ],
      ),
    );
  }
}
