import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';
import '../widgets/top_navigation_bar.dart';

class CivicHorizonApp extends StatelessWidget {
  const CivicHorizonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommunityEventsScreen();
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class CommunityEventsScreen extends StatefulWidget {
  const CommunityEventsScreen({super.key});

  @override
  State<CommunityEventsScreen> createState() => _CommunityEventsScreenState();
}

class _CommunityEventsScreenState extends State<CommunityEventsScreen> {
  // Real calendar state: which month/year is on screen, and which date
  // the person tapped. Both start on today's actual date.
  late DateTime _displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime? _selectedDate;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Parses dates like "September 11, 2024" or "10/24/2023" without pulling in intl.
  DateTime? _parseEventDate(String dateStr) {
    final slashParts = dateStr.split('/');
    if (slashParts.length == 3) {
      final month = int.tryParse(slashParts[0]);
      final day = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);
      if (month != null &&
          day != null &&
          year != null &&
          month >= 1 &&
          month <= 12 &&
          day >= 1 &&
          day <= 31) {
        return DateTime(year, month, day);
      }
    }

    final parts = dateStr.replaceAll(',', '').split(' ');
    if (parts.length != 3) return null;
    final month = _monthNames.indexOf(parts[0]) + 1;
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == 0 || day == null || year == null) return null;
    return DateTime(year, month, day);
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  bool _isSameDay(DateTime? first, DateTime second) =>
      first != null &&
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  List<_EventData> _prioritized(List<_EventData> events) {
    final today = DateTime.now();
    final priority = events
        .where(
          (event) =>
              event.category == 'Emergency' ||
              _isSameDay(event.publishedAt, today),
        )
        .toList();
    priority.sort((a, b) {
      final emergencyCompare = (b.category == 'Emergency' ? 1 : 0).compareTo(
        a.category == 'Emergency' ? 1 : 0,
      );
      if (emergencyCompare != 0) return emergencyCompare;
      return (b.publishedAt?.millisecondsSinceEpoch ?? 0).compareTo(
        a.publishedAt?.millisecondsSinceEpoch ?? 0,
      );
    });
    return priority;
  }

  List<_EventData> _upcomingEvents(List<_EventData> events) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return events.where((event) {
      final eventDate = _parseEventDate(event.date);
      return event.category == 'Event' &&
          eventDate != null &&
          !eventDate.isBefore(today);
    }).toList();
  }

  List<_EventData> _pastItems(List<_EventData> events) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 7));
    return events.where((event) {
      final eventDate = _parseEventDate(event.date);
      final relevantDate = eventDate ?? event.publishedAt;
      return relevantDate != null && relevantDate.isBefore(cutoff);
    }).toList();
  }

  List<_EventData> _excluding(
    List<_EventData> events,
    Iterable<_EventData> excluded,
  ) {
    final excludedIds = excluded.map((event) => event.id).toSet();
    return events.where((event) => !excludedIds.contains(event.id)).toList();
  }

  Future<void> _pickMonthYear(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_displayedMonth.year, _displayedMonth.month),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select month and year',
    );
    if (picked != null) {
      setState(() {
        _displayedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  static _EventData _mapAnnouncementToEvent(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String categoryName = data['category'] ?? 'news';
    final String title = data['title'] ?? '';
    final String date = data['date'] ?? '';
    final String desc = data['description'] ?? 'No description provided.';

    String catLabel = 'News';
    IconData catIcon = Icons.feed;
    Color catBg = AppColors.primaryContainer;
    Color catFg = AppColors.onPrimaryContainer;
    String imageUrl = 'assets/images/town_hall.jpg';
    final imageValues = data['imageBase64List'];
    final encodedImages = imageValues is List
        ? imageValues.map((value) => value.toString()).toList()
        : <String>[
            if (data['coverImageBase64']?.toString().isNotEmpty == true)
              data['coverImageBase64'].toString(),
          ];

    if (categoryName == 'emergency') {
      catLabel = 'Emergency';
      catIcon = Icons.warning;
      catBg = AppColors.errorContainer;
      catFg = AppColors.error;
      imageUrl = 'assets/images/weather_alert.jpg';
    } else if (categoryName == 'event') {
      catLabel = 'Event';
      catIcon = Icons.eco;
      catBg = AppColors.secondaryContainer;
      catFg = AppColors.onSecondaryContainer;
      imageUrl = 'assets/images/cleanup_drive.jpg';
    } else if (categoryName == 'officialMemo') {
      catLabel = 'Official Memo';
      catIcon = Icons.description;
      catBg = AppColors.surfaceVariant;
      catFg = AppColors.primary;
      imageUrl = 'assets/images/announcement.jpg';
    }

    return _EventData(
      id: doc.id,
      imageUrl: imageUrl,
      imageBytesList: encodedImages
          .map(_decodeCoverImage)
          .whereType<Uint8List>()
          .toList(),
      category: catLabel,
      categoryIcon: catIcon,
      categoryBg: catBg,
      categoryFg: catFg,
      title: title,
      date: date,
      time: desc.length > 80 ? '${desc.substring(0, 80)}...' : desc,
      fullDescription: desc,
      viewerIds: List<String>.from(data['viewerIds'] ?? const []),
      likerIds: List<String>.from(data['likerIds'] ?? const []),
      dislikerIds: List<String>.from(data['dislikerIds'] ?? const []),
      publishedAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  static Uint8List? _decodeCoverImage(String value) {
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _showEventDetailsModal(
    BuildContext context,
    _EventData event,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && !event.viewerIds.contains(uid)) {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(event.id)
          .update({
            'viewerIds': FieldValue.arrayUnion([uid]),
          });
    }
    if (!context.mounted) return;
    var liked = uid != null && event.likerIds.contains(uid);
    var disliked = uid != null && event.dislikerIds.contains(uid);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final screen = MediaQuery.sizeOf(ctx);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: math.min(560.0, screen.width * 0.92),
            height: math.min(620.0, screen.height * 0.82),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: event.categoryBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          event.categoryIcon,
                          color: event.categoryFg,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (event.imageBytesList.isNotEmpty) ...[
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: event.imageBytesList.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () => _showImageViewer(
                                    context,
                                    event.imageBytesList,
                                    index,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      event.imageBytesList[index],
                                      width: 240,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap an image to zoom.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                event.date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Announcement Details:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            event.fullDescription,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          StatefulBuilder(
                            builder: (context, setDialogState) =>
                                OutlinedButton.icon(
                                  onPressed: uid == null
                                      ? null
                                      : () async {
                                          final ref = FirebaseFirestore.instance
                                              .collection('announcements')
                                              .doc(event.id);
                                          await ref.update({
                                            'likerIds': liked
                                                ? FieldValue.arrayRemove([uid])
                                                : FieldValue.arrayUnion([uid]),
                                            if (!liked)
                                              'dislikerIds': FieldValue.arrayRemove([uid]),
                                          });
                                          liked = !liked;
                                          if (liked) disliked = false;
                                          setDialogState(() {});
                                        },
                                  icon: Icon(
                                    liked
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                  ),
                                  label: Text(
                                    liked ? 'Liked' : 'Like announcement',
                                  ),
                                ),
                          ),
                          const SizedBox(height: 8),
                          StatefulBuilder(
                            builder: (context, setDialogState) =>
                                OutlinedButton.icon(
                                  onPressed: uid == null
                                      ? null
                                      : () async {
                                          final ref = FirebaseFirestore.instance
                                              .collection('announcements')
                                              .doc(event.id);
                                          await ref.update({
                                            'dislikerIds': disliked
                                                ? FieldValue.arrayRemove([uid])
                                                : FieldValue.arrayUnion([uid]),
                                            if (!disliked)
                                              'likerIds': FieldValue.arrayRemove([uid]),
                                          });
                                          disliked = !disliked;
                                          if (disliked) liked = false;
                                          setDialogState(() {});
                                        },
                                  icon: Icon(
                                    disliked
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                  ),
                                  label: Text(
                                    disliked
                                        ? 'Disliked'
                                        : 'Dislike announcement',
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageViewer(
    BuildContext context,
    List<Uint8List> images,
    int initialIndex,
  ) {
    final controller = PageController(initialPage: initialIndex);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: images.length,
              itemBuilder: (_, index) => InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.memory(images[index], fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: IconButton.filled(
                tooltip: 'Close image viewer',
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: desktop
          ? null
          : const Drawer(child: ResidentSidebar(selectedItem: 'Announcements')),
      bottomNavigationBar: desktop
          ? null
          : const ResidentMobileNavigation(currentIndex: 2),
      body: SafeArea(
        child: Row(
          children: [
            //-----------------------------------
            // LEFT SIDEBAR (Desktop)
            //-----------------------------------
            if (desktop) const ResidentSidebar(selectedItem: 'Announcements'),

            //-----------------------------------
            // MAIN CONTENT
            //-----------------------------------
            Expanded(
              child: Column(
                children: [
                  const TopNavigationBar(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('announcements')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Announcements are temporarily unavailable. Please try again shortly.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        final docs =
                            snapshot.data?.docs
                                .where(
                                  (doc) => doc.data()['status'] == 'published',
                                )
                                .toList() ??
                            [];
                        docs.sort((a, b) {
                          final aCreatedAt = a.data()['createdAt'];
                          final bCreatedAt = b.data()['createdAt'];
                          final aMillis = aCreatedAt is Timestamp
                              ? aCreatedAt.millisecondsSinceEpoch
                              : 0;
                          final bMillis = bCreatedAt is Timestamp
                              ? bCreatedAt.millisecondsSinceEpoch
                              : 0;
                          return bMillis.compareTo(aMillis);
                        });
                        final eventsList = docs
                            .map((doc) => _mapAnnouncementToEvent(doc))
                            .toList();

                        return SingleChildScrollView(
                          padding: EdgeInsets.all(desktop ? 32 : 16),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1400),
                              child: desktop
                                  ? _buildDesktopLayout(eventsList)
                                  : _buildMobileLayout(eventsList),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Desktop Layout
  // -------------------------------------------------------------------------
  Widget _buildDesktopLayout(List<_EventData> eventsList) {
    final selected = _selectedDate == null
        ? null
        : eventsList
              .where((event) => _isSameDay(event.publishedAt, _selectedDate!))
              .toList();
    final priority = _prioritized(eventsList);
    // An event published today may belong in Priority updates and still needs
    // to remain visible in Upcoming events.
    final upcoming = _upcomingEvents(eventsList);
    final past = _excluding(_pastItems(eventsList), priority);
    final recent = _excluding(eventsList, [...priority, ...upcoming, ...past]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Announcements Feed / Cards
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selected != null)
                    _buildFeedSection(
                      'Published on ${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                      selected,
                      onClearDate: () => setState(() => _selectedDate = null),
                    )
                  else ...[
                    _buildFeedSection('Priority updates', priority),
                    const SizedBox(height: 28),
                    _buildFeedSection('Upcoming events', upcoming),
                    const SizedBox(height: 28),
                    _buildFeedSection('Recent announcements', recent),
                    const SizedBox(height: 28),
                    _buildFeedSection('Past announcements & events', past),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Right: Calendar & Quick Links
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildCalendarCard(eventsList),
                  const SizedBox(height: 24),
                  _buildAnnouncementsLink(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Mobile Layout
  // -------------------------------------------------------------------------
  Widget _buildMobileLayout(List<_EventData> eventsList) {
    final selected = _selectedDate == null
        ? null
        : eventsList
              .where((event) => _isSameDay(event.publishedAt, _selectedDate!))
              .toList();
    final priority = _prioritized(eventsList);
    final upcoming = _upcomingEvents(eventsList);
    final past = _excluding(_pastItems(eventsList), priority);
    final recent = _excluding(eventsList, [...priority, ...upcoming, ...past]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 24),
        _buildCalendarCard(eventsList),
        const SizedBox(height: 24),
        if (selected != null)
          _buildFeedSection(
            'Published on ${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
            selected,
            onClearDate: () => setState(() => _selectedDate = null),
          )
        else ...[
          _buildFeedSection('Priority updates', priority),
          const SizedBox(height: 24),
          _buildFeedSection('Upcoming events', upcoming),
          const SizedBox(height: 24),
          _buildFeedSection('Recent announcements', recent),
          const SizedBox(height: 24),
          _buildFeedSection('Past announcements & events', past),
        ],
        const SizedBox(height: 8),
        _buildAnnouncementsLink(),
      ],
    );
  }

  Widget _buildFeedSection(
    String title,
    List<_EventData> events, {
    VoidCallback? onClearDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            if (onClearDate != null)
              TextButton.icon(
                onPressed: onClearDate,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Show all'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          const Text(
            'No announcements to display.',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 600
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: events
                    .map(
                      (event) => SizedBox(
                        width: cardWidth,
                        child: _EventCard(
                          data: event,
                          onViewDetails: () =>
                              _showEventDetailsModal(context, event),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Section header
  // -------------------------------------------------------------------------
  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Community Events & Announcements',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Stay updated with official bulletins and upcoming happenings in our Barangay.',
          style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Calendar
  // -------------------------------------------------------------------------
  Widget _buildCalendarCard(List<_EventData> events) {
    const weekLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingBlanks = firstWeekday % 7;

    final prevMonthLastDay = DateTime(year, month, 0).day;
    final leadingLabels = List.generate(
      leadingBlanks,
      (i) => prevMonthLastDay - leadingBlanks + 1 + i,
    );

    // Calendar filtering is based on the day an announcement was published,
    // not an event's scheduled date. This keeps a selected date exact even
    // when Firestore timestamps include different times of day.
    final eventDays = <int>{
      for (final event in events)
        if (event.publishedAt case final d?)
          if (d.year == year && d.month == month) d.day,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _pickMonthYear(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_monthNames[month - 1]} $year',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.7,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _goToPreviousMonth,
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _goToNextMonth,
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              for (final label in weekLabels)
                Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.outlineVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              for (final label in leadingLabels)
                Center(
                  child: Text(
                    '$label',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              for (var day = 1; day <= daysInMonth; day++)
                _buildDayCell(
                  day,
                  year,
                  month,
                  hasDot: eventDays.contains(day),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day, int year, int month, {required bool hasDot}) {
    final cellDate = DateTime(year, month, day);
    final now = DateTime.now();
    final isToday =
        cellDate.year == now.year &&
        cellDate.month == now.month &&
        cellDate.day == now.day;
    final isSelected =
        _selectedDate != null &&
        cellDate.year == _selectedDate!.year &&
        cellDate.month == _selectedDate!.month &&
        cellDate.day == _selectedDate!.day;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = cellDate),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: (isToday && !isSelected)
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: (isSelected || isToday)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                ),
              ),
            ),
            if (hasDot && !isSelected)
              Positioned(
                bottom: -2,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Announcements quick link
  // -------------------------------------------------------------------------
  Widget _buildAnnouncementsLink() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Official Announcements',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'View past bulletins',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Event data + card widget
// ---------------------------------------------------------------------------
class _EventData {
  final String id;
  final String imageUrl;
  final List<Uint8List> imageBytesList;
  final String category;
  final IconData categoryIcon;
  final Color categoryBg;
  final Color categoryFg;
  final String title;
  final String date;
  final String time;
  final String fullDescription;
  final List<String> viewerIds;
  final List<String> likerIds;
  final List<String> dislikerIds;
  final DateTime? publishedAt;

  const _EventData({
    required this.id,
    required this.imageUrl,
    this.imageBytesList = const [],
    required this.category,
    required this.categoryIcon,
    required this.categoryBg,
    required this.categoryFg,
    required this.title,
    required this.date,
    required this.time,
    required this.fullDescription,
    required this.viewerIds,
    required this.likerIds,
    required this.dislikerIds,
    required this.publishedAt,
  });
}

class _AnnouncementImageFallback extends StatelessWidget {
  const _AnnouncementImageFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.surfaceVariant,
    child: Center(
      child: Icon(Icons.campaign_outlined, size: 48, color: AppColors.primary),
    ),
  );
}

class _EventCard extends StatelessWidget {
  final _EventData data;
  final VoidCallback onViewDetails;

  const _EventCard({required this.data, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: data.imageBytesList.isNotEmpty
                    ? Image.memory(
                        data.imageBytesList.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const _AnnouncementImageFallback(),
                      )
                    : const _AnnouncementImageFallback(),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: data.categoryBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(data.categoryIcon, size: 14, color: data.categoryFg),
                      const SizedBox(width: 4),
                      Text(
                        data.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: data.categoryFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.date,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.time,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
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
