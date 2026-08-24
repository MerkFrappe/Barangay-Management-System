import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
// Color palette pulled straight from the Tailwind config in the HTML file.
// ---------------------------------------------------------------------------
class AppColors {
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);
  static const onBackground = Color(0xFF0B1C30);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const onPrimaryContainer = Color(0xFF96ADFF);
  static const onSecondaryContainer = Color(0xFF6E5700);
  static const onTertiaryContainer = Color(0xFFFF918B);
  static const onSecondary = Color(0xFFFFFFFF);
  static const primary = Color(0xFF002576);
  static const secondaryFixedDim = Color(0xFFF0C100);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiary = Color(0xFF62000A);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const outlineVariant = Color(0xFFC4C5D5);
  static const error = Color(0xFFBA1A1A);
  static const surface = Color(0xFFF8F9FF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const secondary = Color(0xFF735C00);
  static const background = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF0B1C30);
  static const secondaryContainer = Color(0xFFFECC00);
  static const onError = Color(0xFFFFFFFF);
  static const outline = Color(0xFF747685);
  static const primaryContainer = Color(0xFF0038A8);
  static const onSurfaceVariant = Color(0xFF444653);
  static const tertiaryContainer = Color(0xFF8C0014);
  static const surfaceVariant = Color(0xFFD3E4FE);
  static const onPrimary = Color(0xFFFFFFFF);
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
  int _selectedNavIndex = 1; // "Services" tab is active by default

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
      time: desc.length > 80 ? desc.substring(0, 80) + '...' : desc,
    );
  }

  Widget _buildAppContent() {
    return Column(
      children: [
        _buildTopAppBar(),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // Filtering and ordering these two fields together requires a
            // Firestore composite index. Read the collection, then apply the
            // small client-side filter/order so the resident view also works
            // before an index has been deployed.
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
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
                        children:
                            eventsList.map((event) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _EventCard(
                                  data: event,
                                  onViewDetails: () {},
                                ),
                              );
                            }).toList(),
                      ),
                    const SizedBox(height: 8),
                    _buildAnnouncementsLink(),
                  ],
                ),
              );
            },
          ),
        ),
        _buildBottomNavBar(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _buildAppContent(),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // TopAppBar
  // -------------------------------------------------------------------------
  Widget _buildTopAppBar() {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Civic Horizon',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
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
          'Community Events',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Stay updated with the latest happenings in our Barangay.',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
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

    // DateTime.weekday is Monday=1..Sunday=7. Our week starts on Sunday,
    // so Sunday needs 0 leading blanks, Monday needs 1, and so on.
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingBlanks = firstWeekday % 7;

    // Day numbers from the previous month, to fill those leading blanks
    // the way a real calendar does (faded, non-interactive).
    final prevMonthLastDay = DateTime(year, month, 0).day;
    final leadingLabels = List.generate(
      leadingBlanks,
      (i) => prevMonthLastDay - leadingBlanks + 1 + i,
    );

    // Which days in the visible month have an event, so we can show a dot.
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
                      color: AppColors.outlineVariant.withOpacity(0.5),
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
          'UPCOMING EVENTS',
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

  // -------------------------------------------------------------------------
  // Bottom nav bar
  // -------------------------------------------------------------------------
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              isActive: _selectedNavIndex == 0,
              onTap: () => setState(() => _selectedNavIndex = 0),
            ),
            _NavItem(
              icon: Icons.account_balance,
              label: 'Services',
              isActive: _selectedNavIndex == 1,
              onTap: () => setState(() => _selectedNavIndex = 1),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: _selectedNavIndex == 2,
              onTap: () => setState(() => _selectedNavIndex = 2),
            ),
          ],
        ),
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

  const _EventData({
    required this.imageUrl,
    required this.category,
    required this.categoryIcon,
    required this.categoryBg,
    required this.categoryFg,
    required this.title,
    required this.date,
    required this.time,
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
                    fontSize: 20,
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

// ---------------------------------------------------------------------------
// Bottom nav item
// ---------------------------------------------------------------------------
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isActive
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurfaceVariant,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isActive
                        ? AppColors.onSecondaryContainer
                        : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
