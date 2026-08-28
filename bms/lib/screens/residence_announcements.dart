import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';
import '../widgets/top_navigation_bar.dart';

void main() {
  runApp(const CivicHorizonApp());
}

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
  DateTime? _selectedDate = DateTime.now();

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
      imageUrl: imageUrl,
      category: catLabel,
      categoryIcon: catIcon,
      categoryBg: catBg,
      categoryFg: catFg,
      title: title,
      date: date,
      time: desc.length > 80 ? '${desc.substring(0, 80)}...' : desc,
      fullDescription: desc,
    );
  }

  void _showEventDetailsModal(BuildContext context, _EventData event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: event.categoryBg,
                shape: BoxShape.circle,
              ),
              child: Icon(event.categoryIcon, color: event.categoryFg, size: 20),
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(event.date, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Announcement Details:',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                event.fullDescription,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
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
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: desktop ? null : const Drawer(child: ResidentSidebar()),
      body: SafeArea(
        child: Row(
          children: [
            //-----------------------------------
            // LEFT SIDEBAR (Desktop)
            //-----------------------------------
            if (desktop) const ResidentSidebar(),

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
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
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
                        final docs = snapshot.data?.docs
                                .where((doc) => doc.data()['status'] == 'published')
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
                        final eventsList =
                            docs.map((doc) => _mapAnnouncementToEvent(doc)).toList();

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
                  _buildUpcomingEventsHeader(),
                  const SizedBox(height: 16),
                  if (eventsList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No announcements or events posted.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useGrid = constraints.maxWidth >= 600;
                        if (useGrid) {
                          final itemWidth = (constraints.maxWidth - 16) / 2;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: eventsList.map((event) {
                              return SizedBox(
                                width: itemWidth,
                                child: _EventCard(
                                  data: event,
                                  onViewDetails: () =>
                                      _showEventDetailsModal(context, event),
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          return Column(
                            children: eventsList.map((event) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _EventCard(
                                  data: event,
                                  onViewDetails: () =>
                                      _showEventDetailsModal(context, event),
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 24),
        _buildCalendarCard(eventsList),
        const SizedBox(height: 24),
        _buildUpcomingEventsHeader(),
        const SizedBox(height: 16),
        if (eventsList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No announcements or events posted.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Column(
            children: eventsList.map((event) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _EventCard(
                  data: event,
                  onViewDetails: () => _showEventDetailsModal(context, event),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        _buildAnnouncementsLink(),
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

    final eventDays = <int>{
      for (final event in events)
        if (_parseEventDate(event.date) case final d?)
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
                border:
                    (isToday && !isSelected)
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      (isSelected || isToday)
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
  // Upcoming events header
  // -------------------------------------------------------------------------
  Widget _buildUpcomingEventsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'UPCOMING EVENTS & ANNOUNCEMENTS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
          ),
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
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
  final String imageUrl;
  final String category;
  final IconData categoryIcon;
  final Color categoryBg;
  final Color categoryFg;
  final String title;
  final String date;
  final String time;
  final String fullDescription;

  const _EventData({
    required this.imageUrl,
    required this.category,
    required this.categoryIcon,
    required this.categoryBg,
    required this.categoryFg,
    required this.title,
    required this.date,
    required this.time,
    required this.fullDescription,
  });
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
              const SizedBox(
                height: 160,
                width: double.infinity,
                child: ColoredBox(
                  color: AppColors.surfaceVariant,
                  child: Center(
                    child: Icon(
                      Icons.campaign_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
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
