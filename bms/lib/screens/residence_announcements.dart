import 'package:flutter/material.dart';

void main() {
  runApp(const CivicHorizonApp());
}

class CivicHorizonApp extends StatelessWidget {
  const CivicHorizonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civic Horizon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const CommunityEventsScreen(),
    );
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

  // Parses dates like "September 11, 2024" without pulling in intl.
  DateTime? _parseEventDate(String dateStr) {
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

  final List<_EventData> _events = const [
    _EventData(
      imageUrl: 'assets/images/cleanup_drive.jpg',
      category: 'Environment',
      categoryIcon: Icons.eco,
      categoryBg: AppColors.secondaryContainer,
      categoryFg: AppColors.onSecondaryContainer,
      title: 'Barangay Clean-up Drive',
      date: 'September 11, 2024',
      time: '07:00 AM - 11:00 AM',
    ),
    _EventData(
      imageUrl: 'assets/images/health_checkup.jpg',
      category: 'Health',
      categoryIcon: Icons.medical_services,
      categoryBg: AppColors.tertiaryContainer,
      categoryFg: AppColors.onTertiary,
      title: 'Free Wellness Checkup',
      date: 'September 15, 2024',
      time: '09:00 AM - 03:00 PM',
    ),
    _EventData(
      imageUrl: 'assets/images/town_hall.jpg',
      category: 'Assembly',
      categoryIcon: Icons.groups,
      categoryBg: AppColors.surfaceContainerHighest,
      categoryFg: AppColors.primary,
      title: 'Quarterly Town Hall',
      date: 'September 22, 2024',
      time: '05:00 PM - 07:00 PM',
    ),
  ];

  Widget _buildAppContent() {
    return Column(
      children: [
        _buildTopAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(),
                const SizedBox(height: 24),
                _buildCalendarCard(),
                const SizedBox(height: 24),
                _buildUpcomingEventsHeader(),
                const SizedBox(height: 16),
                for (final event in _events) ...[
                  _EventCard(data: event, onViewDetails: () {}),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                _buildAnnouncementsLink(),
              ],
            ),
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
          Row(
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
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.account_balance,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Civic Horizon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
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
  Widget _buildCalendarCard() {
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
      for (final event in _events)
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
          Row(
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
              Column(
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
            ],
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
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.asset(
                  data.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.outline,
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
                    Text(
                      data.date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
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
                    Text(
                      data.time,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
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
              color: isActive
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
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
