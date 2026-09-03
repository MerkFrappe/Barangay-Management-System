import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ViewMode { auto, desktop, mobile }

enum RequestStatus { approved, pending, inReview, rejected }

class DocumentRequestModel {
  final String id;
  final String documentType;
  final String dateSubmitted;
  final String residentName;
  final String initials;
  final RequestStatus status;
  final Color avatarBgColor;
  final Color avatarTextColor;
  final String purpose;
  final String contactNumber;

  DocumentRequestModel({
    required this.id,
    required this.documentType,
    required this.dateSubmitted,
    required this.residentName,
    required this.initials,
    required this.status,
    required this.avatarBgColor,
    required this.avatarTextColor,
    this.purpose = 'Official Use / Employment',
    this.contactNumber = '+63 917 123 4567',
  });
}

// Alias class name so both pascal case and original filename class name work
typedef AdminDocumentRequestScreen = admin_documentRequest;

class admin_documentRequest extends StatefulWidget {
  const admin_documentRequest({super.key});

  @override
  State<admin_documentRequest> createState() =>
      _admin_documentRequestState();
}

class _admin_documentRequestState
    extends State<admin_documentRequest> {
  // View mode switcher: auto (responsive), desktop (forced), mobile (forced)
  ViewMode _viewMode = ViewMode.auto;

  // Search & Filter state
  String _searchQuery = '';
  String _selectedTab = 'All Requests';
  String _selectedStatusFilter = 'All Statuses';
  String? _selectedRowId;
  int _currentPage = 1;

  // Initial Data matching HTML
  final List<DocumentRequestModel> _allRequests = [
    DocumentRequestModel(
      id: '#BRGY-2023-0042',
      documentType: 'Barangay Clearance',
      dateSubmitted: 'Oct 24, 2023',
      residentName: 'Juan Dela Cruz',
      initials: 'JD',
      status: RequestStatus.approved,
      avatarBgColor: AppColors.primaryContainer,
      avatarTextColor: AppColors.onPrimaryContainer,
      purpose: 'Local Employment Application',
    ),
    DocumentRequestModel(
      id: '#BRGY-2023-0045',
      documentType: 'Certificate of Residency',
      dateSubmitted: 'Oct 25, 2023',
      residentName: 'Maria Santos',
      initials: 'MS',
      status: RequestStatus.pending,
      avatarBgColor: AppColors.secondaryContainer,
      avatarTextColor: AppColors.onSecondaryContainer,
      purpose: 'Bank Account Opening',
    ),
    DocumentRequestModel(
      id: '#BRGY-2023-0048',
      documentType: 'Business Permit',
      dateSubmitted: 'Oct 26, 2023',
      residentName: 'Ricardo Bautista',
      initials: 'RB',
      status: RequestStatus.inReview,
      avatarBgColor: AppColors.surfaceVariant,
      avatarTextColor: AppColors.primary,
      purpose: 'Sari-Sari Store Permit Renewal',
    ),
    DocumentRequestModel(
      id: '#BRGY-2023-0051',
      documentType: 'Indigency Certificate',
      dateSubmitted: 'Oct 27, 2023',
      residentName: 'Elena Morales',
      initials: 'EM',
      status: RequestStatus.rejected,
      avatarBgColor: AppColors.errorContainer,
      avatarTextColor: AppColors.onErrorContainer,
      purpose: 'Medical Assistance Claim',
    ),
    DocumentRequestModel(
      id: '#BRGY-2023-0055',
      documentType: 'Barangay ID',
      dateSubmitted: 'Oct 28, 2023',
      residentName: 'Antonio Garcia',
      initials: 'AG',
      status: RequestStatus.approved,
      avatarBgColor: AppColors.tertiaryFixed,
      avatarTextColor: AppColors.onTertiaryFixed,
      purpose: 'Government ID Requirement',
    ),
  ];

  // Helper getters for KPIs
  int get _totalPendingCount => _allRequests
      .where((r) => r.status == RequestStatus.pending)
      .length;
  int get _inReviewCount => _allRequests
      .where((r) => r.status == RequestStatus.inReview)
      .length;
  int get _completedCount => _allRequests
      .where((r) => r.status == RequestStatus.approved)
      .length;
  int get _rejectedCount => _allRequests
      .where((r) => r.status == RequestStatus.rejected)
      .length;

  List<DocumentRequestModel> get _filteredRequests {
    return _allRequests.where((req) {
      // Search query filter
      final matchesSearch = _searchQuery.isEmpty ||
          req.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          req.residentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          req.documentType.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status dropdown filter
      bool matchesStatus = true;
      if (_selectedStatusFilter == 'Approved') {
        matchesStatus = req.status == RequestStatus.approved;
      } else if (_selectedStatusFilter == 'Pending') {
        matchesStatus = req.status == RequestStatus.pending;
      } else if (_selectedStatusFilter == 'In Review') {
        matchesStatus = req.status == RequestStatus.inReview;
      } else if (_selectedStatusFilter == 'Rejected') {
        matchesStatus = req.status == RequestStatus.rejected;
      }

      // Tab filter
      bool matchesTab = true;
      if (_selectedTab == 'Pending Only') {
        matchesTab = req.status == RequestStatus.pending;
      } else if (_selectedTab == 'Today') {
        matchesTab = req.dateSubmitted.contains('Oct 28');
      }

      return matchesSearch && matchesStatus && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenIsWide = constraints.maxWidth >= 900;
        final bool isMobile = _viewMode == ViewMode.mobile ||
            (_viewMode == ViewMode.auto && !screenIsWide);

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: isMobile ? const Drawer(child: _SidebarContent()) : null,
          body: SafeArea(
            child: Row(
              children: [
                // Desktop Sidebar Navigation
                if (!isMobile) const _SidebarContent(),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Top Navigation Header
                      _TopHeader(
                        isMobile: isMobile,
                        viewMode: _viewMode,
                        onViewModeChanged: (mode) {
                          setState(() => _viewMode = mode);
                        },
                        onSearchChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                      ),

                      // Main Scrollable Body
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 16 : 32),
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 1280),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // View Switcher Bar Notice Banner (Interactive control)
                                  _ViewSwitcherBanner(
                                    currentMode: _viewMode,
                                    isMobileActual: isMobile,
                                    onChanged: (mode) {
                                      setState(() => _viewMode = mode);
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Page Header & Action Buttons
                                  _PageHeader(
                                    isMobile: isMobile,
                                    onNewEntryPressed: _showNewEntryModal,
                                    onFiltersPressed: _showFiltersModal,
                                  ),
                                  const SizedBox(height: 24),

                                  // Bento Filter Summary Cards
                                  _BentoFilterGrid(
                                    totalPending: _totalPendingCount,
                                    inReview: _inReviewCount,
                                    completed: _completedCount,
                                    rejected: _rejectedCount,
                                    selectedStatus: _selectedStatusFilter,
                                    onStatusSelected: (statusStr) {
                                      setState(() {
                                        _selectedStatusFilter = statusStr;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Table Controls & Quick Tabs
                                  _TableControls(
                                    selectedTab: _selectedTab,
                                    selectedStatus: _selectedStatusFilter,
                                    onTabSelected: (tab) {
                                      if (tab == 'Export CSV') {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Exporting request tracking report to CSV...'),
                                            backgroundColor: AppColors.primary,
                                          ),
                                        );
                                      } else {
                                        setState(() => _selectedTab = tab);
                                      }
                                    },
                                    onStatusChanged: (status) {
                                      if (status != null) {
                                        setState(
                                            () => _selectedStatusFilter = status);
                                      }
                                    },
                                  ),

                                  // Requests Content: Desktop Table OR Mobile Card List
                                  if (isMobile)
                                    _MobileRequestList(
                                      requests: _filteredRequests,
                                      selectedId: _selectedRowId,
                                      onSelectRow: (id) {
                                        setState(() => _selectedRowId =
                                            _selectedRowId == id ? null : id);
                                      },
                                      onViewDetails: _showDetailsModal,
                                      onDownload: _handleDownload,
                                    )
                                  else
                                    _DesktopRequestTable(
                                      requests: _filteredRequests,
                                      selectedId: _selectedRowId,
                                      onSelectRow: (id) {
                                        setState(() => _selectedRowId =
                                            _selectedRowId == id ? null : id);
                                      },
                                      onViewDetails: _showDetailsModal,
                                      onDownload: _handleDownload,
                                    ),

                                  // Pagination Footer
                                  _PaginationFooter(
                                    currentPage: _currentPage,
                                    totalItems: 199,
                                    showingCount: _filteredRequests.length,
                                    onPageChanged: (p) {
                                      setState(() => _currentPage = p);
                                    },
                                  ),

                                  const SizedBox(height: 32),

                                  // Bento Style Contextual Help / Tips
                                  _BentoHelpCards(isMobile: isMobile),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  void _handleDownload(DocumentRequestModel req) {
    if (req.status == RequestStatus.approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Downloading official PDF for ${req.documentType} (${req.id})...'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Download unavailable. Request ${req.id} is currently ${req.status.name.toUpperCase()}.'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDetailsModal(DocumentRequestModel req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RequestDetailsSheet(request: req),
    );
  }

  void _showNewEntryModal() {
    showDialog(
      context: context,
      builder: (ctx) => _NewEntryDialog(
        onAdd: (newReq) {
          setState(() {
            _allRequests.insert(0, newReq);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('New Document Request ${newReq.id} created!'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Options', style: AppTextStyles.headlineSm),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Reset All Filters'),
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedTab = 'All Requests';
                    _selectedStatusFilter = 'All Statuses';
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.pending_actions),
                title: const Text('Show Pending Only'),
                onTap: () {
                  setState(() {
                    _selectedTab = 'Pending Only';
                    _selectedStatusFilter = 'Pending';
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.today),
                title: const Text('Submitted Today'),
                onTap: () {
                  setState(() {
                    _selectedTab = 'Today';
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// VIEW SWITCHER BANNER / TOGGLE CONTROL
// ==========================================
class _ViewSwitcherBanner extends StatelessWidget {
  final ViewMode currentMode;
  final bool isMobileActual;
  final ValueChanged<ViewMode> onChanged;

  const _ViewSwitcherBanner({
    required this.currentMode,
    required this.isMobileActual,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isMobileActual ? Icons.smartphone : Icons.desktop_windows,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Mode: ${currentMode == ViewMode.auto ? (isMobileActual ? "Auto (Mobile Mode)" : "Auto (Desktop Mode)") : (currentMode == ViewMode.mobile ? "Forced Mobile Mode 📱" : "Forced Desktop Mode 💻")}',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Switch layouts instantly to preview responsiveness across devices.',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SegmentedButton<ViewMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<ViewMode>(
                value: ViewMode.auto,
                label: Text('Auto'),
                icon: Icon(Icons.aspect_ratio, size: 16),
              ),
              ButtonSegment<ViewMode>(
                value: ViewMode.desktop,
                label: Text('Desktop'),
                icon: Icon(Icons.computer, size: 16),
              ),
              ButtonSegment<ViewMode>(
                value: ViewMode.mobile,
                label: Text('Mobile'),
                icon: Icon(Icons.smartphone, size: 16),
              ),
            ],
            selected: {currentMode},
            onSelectionChanged: (Set<ViewMode> selected) {
              onChanged(selected.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(
                AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SIDEBAR NAVIGATION CONTENT
// ==========================================
class _SidebarContent extends StatelessWidget {
  const _SidebarContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      height: double.infinity,
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barangay Connect',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Resident Portal',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Navigation Links
          Expanded(
            child: ListView(
              children: const [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isSelected: false,
                ),
                SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.description_outlined,
                  label: 'Document Requests',
                  isSelected: false,
                ),
                SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.assignment_turned_in,
                  label: 'Status Tracker',
                  isSelected: true,
                ),
                SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.campaign_outlined,
                  label: 'Announcements',
                  isSelected: false,
                ),
                SizedBox(height: 4),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: false,
                ),
              ],
            ),
          ),

          // Bottom Section
          const Divider(color: AppColors.outlineVariant),
          const SizedBox(height: 8),
          const _SidebarItem(
            icon: Icons.help_outline,
            label: 'Help Center',
            isSelected: false,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connecting to Barangay Emergency Hotlines...'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              icon: const Icon(Icons.warning_amber_rounded, size: 20),
              label: const Text('Emergency Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.surfaceContainerHigh
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? const Border(
                right: BorderSide(color: AppColors.primary, width: 4),
              )
            : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}

// ==========================================
// TOP NAVIGATION HEADER
// ==========================================
class _TopHeader extends StatelessWidget {
  final bool isMobile;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final ValueChanged<String> onSearchChanged;

  const _TopHeader({
    required this.isMobile,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),

          // Search Field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search requests by ID or name...',
                  hintStyle: AppTextStyles.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.outline,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Right Icons & Profile
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {},
              ),

              const SizedBox(width: 8),
              Container(
                height: 24,
                width: 1,
                color: AppColors.outlineVariant,
              ),
              const SizedBox(width: 12),

              // User Info
              if (!isMobile) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Admin Maria',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Barangay Captain',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
              ],

              // Avatar Circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryContainer,
                    width: 2,
                  ),
                  color: AppColors.primaryFixed,
                ),
                child: const Center(
                  child: Text(
                    'AM',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PAGE HEADER & ACTION BUTTONS
// ==========================================
class _PageHeader extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onNewEntryPressed;
  final VoidCallback onFiltersPressed;

  const _PageHeader({
    required this.isMobile,
    required this.onNewEntryPressed,
    required this.onFiltersPressed,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Request Tracking',
          style: (isMobile
                  ? AppTextStyles.headlineMd
                  : AppTextStyles.headlineLg)
              .copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage and monitor document applications from residents.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: onFiltersPressed,
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filters'),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerHigh,
            foregroundColor: AppColors.primary,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: onNewEntryPressed,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Entry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 0,
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 16),
          actionButtons,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titleWidget),
        actionButtons,
      ],
    );
  }
}

// ==========================================
// BENTO FILTER SUMMARY CARDS (KPIs)
// ==========================================
class _BentoFilterGrid extends StatelessWidget {
  final int totalPending;
  final int inReview;
  final int completed;
  final int rejected;
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;

  const _BentoFilterGrid({
    required this.totalPending,
    required this.inReview,
    required this.completed,
    required this.rejected,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      final int crossAxisCount = width > 700 ? 4 : 2;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        childAspectRatio: crossAxisCount == 4 ? 2.3 : 2.0,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _BentoCard(
            title: 'Total Pending',
            count: totalPending.toString().padLeft(2, '0'),
            icon: Icons.pending_actions,
            iconBg: AppColors.surfaceContainerHigh,
            iconColor: AppColors.primary,
            isSelected: selectedStatus == 'Pending',
            onTap: () => onStatusSelected(
                selectedStatus == 'Pending' ? 'All Statuses' : 'Pending'),
          ),
          _BentoCard(
            title: 'In Review',
            count: inReview.toString().padLeft(2, '0'),
            icon: Icons.hourglass_top,
            iconBg: AppColors.secondaryContainer,
            iconColor: AppColors.onSecondaryContainer,
            isSelected: selectedStatus == 'In Review',
            onTap: () => onStatusSelected(
                selectedStatus == 'In Review' ? 'All Statuses' : 'In Review'),
          ),
          _BentoCard(
            title: 'Completed',
            count: completed.toString().padLeft(2, '0'),
            icon: Icons.check_circle,
            iconBg: AppColors.successGreenBg,
            iconColor: AppColors.successGreen,
            isSelected: selectedStatus == 'Approved',
            onTap: () => onStatusSelected(
                selectedStatus == 'Approved' ? 'All Statuses' : 'Approved'),
          ),
          _BentoCard(
            title: 'Rejected',
            count: rejected.toString().padLeft(2, '0'),
            icon: Icons.cancel,
            iconBg: AppColors.errorContainer,
            iconColor: AppColors.onErrorContainer,
            isSelected: selectedStatus == 'Rejected',
            onTap: () => onStatusSelected(
                selectedStatus == 'Rejected' ? 'All Statuses' : 'Rejected'),
          ),
        ],
      );
    });
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _BentoCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  const BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
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
}

// ==========================================
// TABLE CONTROLS & STATUS FILTER
// ==========================================
class _TableControls extends StatelessWidget {
  final String selectedTab;
  final String selectedStatus;
  final ValueChanged<String> onTabSelected;
  final ValueChanged<String?> onStatusChanged;

  const _TableControls({
    required this.selectedTab,
    required this.selectedStatus,
    required this.onTabSelected,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['All Requests', 'Today', 'Pending Only', 'Export CSV'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant),
          left: BorderSide(color: AppColors.outlineVariant),
          right: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs.map((tab) {
                final isSelected = selectedTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: isSelected,
                    onSelected: (_) => onTabSelected(tab),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    labelStyle: AppTextStyles.labelMd.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: isSelected
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.outlineVariant),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // Dropdown Status Filter
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Status: ',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    isDense: true,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurface,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'All Statuses',
                        child: Text('All Statuses'),
                      ),
                      DropdownMenuItem(
                        value: 'Approved',
                        child: Text('Approved'),
                      ),
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'In Review',
                        child: Text('In Review'),
                      ),
                      DropdownMenuItem(
                        value: 'Rejected',
                        child: Text('Rejected'),
                      ),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// DESKTOP HIGH FIDELITY DATA TABLE
// ==========================================
class _DesktopRequestTable extends StatelessWidget {
  final List<DocumentRequestModel> requests;
  final String? selectedId;
  final ValueChanged<String> onSelectRow;
  final ValueChanged<DocumentRequestModel> onViewDetails;
  final ValueChanged<DocumentRequestModel> onDownload;

  const _DesktopRequestTable({
    required this.requests,
    required this.selectedId,
    required this.onSelectRow,
    required this.onViewDetails,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.outline),
            const SizedBox(height: 12),
            Text(
              'No requests found matching your query.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 900),
          child: DataTable(
            showCheckboxColumn: false,
            headingRowColor: WidgetStateProperty.all(
              AppColors.surfaceContainerLow,
            ),
            dataRowMaxHeight: 64,
            columns: const [
              DataColumn(
                label: Text(
                  'REQUEST ID',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'DOCUMENT TYPE',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'DATE SUBMITTED',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'RESIDENT NAME',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'STATUS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
            rows: requests.map((req) {
              final isSelected = selectedId == req.id;

              return DataRow(
                selected: isSelected,
                onSelectChanged: (_) => onSelectRow(req.id),
                color: WidgetStateProperty.resolveWith((states) {
                  if (isSelected) {
                    return AppColors.surfaceContainerHighest;
                  }
                  return null;
                }),
                cells: [
                  DataCell(
                    Text(
                      req.id,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      req.documentType,
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                  DataCell(
                    Text(
                      req.dateSubmitted,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: req.avatarBgColor,
                          child: Text(
                            req.initials,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: req.avatarTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          req.residentName,
                          style: AppTextStyles.labelMd,
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    _StatusChip(status: req.status),
                  ),
                  DataCell(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined,
                              size: 20, color: AppColors.primary),
                          tooltip: 'View Details',
                          onPressed: () => onViewDetails(req),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.download_outlined,
                            size: 20,
                            color: req.status == RequestStatus.approved
                                ? AppColors.primary
                                : AppColors.outline.withValues(alpha: 0.5),
                          ),
                          tooltip: req.status == RequestStatus.approved
                              ? 'Download Document'
                              : 'Download Unavailable',
                          onPressed: () => onDownload(req),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MOBILE TOUCH-OPTIMIZED REQUEST CARDS
// ==========================================
class _MobileRequestList extends StatelessWidget {
  final List<DocumentRequestModel> requests;
  final String? selectedId;
  final ValueChanged<String> onSelectRow;
  final ValueChanged<DocumentRequestModel> onViewDetails;
  final ValueChanged<DocumentRequestModel> onDownload;

  const _MobileRequestList({
    required this.requests,
    required this.selectedId,
    required this.onSelectRow,
    required this.onViewDetails,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Center(
          child: Text('No requests found.'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: requests.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          color: AppColors.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final req = requests[index];
          final isSelected = selectedId == req.id;

          return InkWell(
            onTap: () => onSelectRow(req.id),
            child: Container(
              color: isSelected
                  ? AppColors.surfaceContainerHighest
                  : Colors.transparent,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        req.id,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _StatusChip(status: req.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    req.documentType,
                    style: AppTextStyles.headlineSm.copyWith(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: req.avatarBgColor,
                        child: Text(
                          req.initials,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: req.avatarTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(req.residentName, style: AppTextStyles.bodySm),
                      const Spacer(),
                      Text(
                        req.dateSubmitted,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => onViewDetails(req),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View Details'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => onDownload(req),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: req.status == RequestStatus.approved
                              ? AppColors.primary
                              : AppColors.outline.withValues(alpha: 0.3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// STATUS CHIP BADGE
// ==========================================
class _StatusChip extends StatelessWidget {
  final RequestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color dotColor;
    String label;

    switch (status) {
      case RequestStatus.approved:
        bg = AppColors.successGreenBg;
        fg = AppColors.successGreen;
        dotColor = AppColors.successGreen;
        label = 'Approved';
        break;
      case RequestStatus.pending:
        bg = AppColors.secondaryFixed;
        fg = AppColors.onSecondaryFixedVariant;
        dotColor = AppColors.secondary;
        label = 'Pending';
        break;
      case RequestStatus.inReview:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        dotColor = const Color(0xFF2563EB);
        label = 'In Review';
        break;
      case RequestStatus.rejected:
        bg = AppColors.errorContainer;
        fg = AppColors.onErrorContainer;
        dotColor = AppColors.error;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PAGINATION FOOTER
// ==========================================
class _PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int showingCount;
  final ValueChanged<int> onPageChanged;

  const _PaginationFooter({
    required this.currentPage,
    required this.totalItems,
    required this.showingCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
          left: BorderSide(color: AppColors.outlineVariant),
          right: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Text(
            'Showing 1 to $showingCount of $totalItems requests',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          // Pagination Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                iconSize: 20,
              ),
              _PageButton(
                pageNumber: 1,
                isSelected: currentPage == 1,
                onTap: () => onPageChanged(1),
              ),
              const SizedBox(width: 4),
              _PageButton(
                pageNumber: 2,
                isSelected: currentPage == 2,
                onTap: () => onPageChanged(2),
              ),
              const SizedBox(width: 4),
              _PageButton(
                pageNumber: 3,
                isSelected: currentPage == 3,
                onTap: () => onPageChanged(3),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...'),
              ),
              _PageButton(
                pageNumber: 40,
                isSelected: currentPage == 40,
                onTap: () => onPageChanged(40),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: AppColors.primary,
                onPressed: () => onPageChanged(currentPage + 1),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final int pageNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageButton({
    required this.pageNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: AppTextStyles.labelMd.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// BENTO CONTEXTUAL HELP / TIPS CARDS
// ==========================================
class _BentoHelpCards extends StatelessWidget {
  final bool isMobile;

  const _BentoHelpCards({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final tipCard = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 36, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Efficiency Tip',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Requests marked as "In Review" are prioritized in your daily summary. Try to process these within 48 hours for optimal service delivery scores.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final privacyCard = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.security,
            size: 36,
            color: AppColors.secondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Assurance',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'All resident data is encrypted according to national privacy laws. Only authorized administrative officers can view sensitive personal details.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          tipCard,
          const SizedBox(height: 16),
          privacyCard,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: tipCard),
        const SizedBox(width: 24),
        Expanded(child: privacyCard),
      ],
    );
  }
}

// ==========================================
// MODAL DIALOGS & BOTTOM SHEETS
// ==========================================
class _RequestDetailsSheet extends StatelessWidget {
  final DocumentRequestModel request;

  const _RequestDetailsSheet({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.id,
                style: AppTextStyles.headlineSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _StatusChip(status: request.status),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _DetailRow(label: 'Document Type', value: request.documentType),
          _DetailRow(label: 'Resident Name', value: request.residentName),
          _DetailRow(label: 'Date Submitted', value: request.dateSubmitted),
          _DetailRow(label: 'Purpose', value: request.purpose),
          _DetailRow(label: 'Contact No.', value: request.contactNumber),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Updated status for ${request.id} to APPROVED.'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Approve Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.outline)),
          Text(value,
              style: AppTextStyles.labelMd
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _NewEntryDialog extends StatefulWidget {
  final ValueChanged<DocumentRequestModel> onAdd;

  const _NewEntryDialog({required this.onAdd});

  @override
  State<_NewEntryDialog> createState() => _NewEntryDialogState();
}

class _NewEntryDialogState extends State<_NewEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  String _residentName = '';
  String _documentType = 'Barangay Clearance';
  String _purpose = 'General Purpose';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Document Request'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Resident Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required field' : null,
                onSaved: (val) => _residentName = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _documentType,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Barangay Clearance',
                      child: Text('Barangay Clearance')),
                  DropdownMenuItem(
                      value: 'Certificate of Residency',
                      child: Text('Certificate of Residency')),
                  DropdownMenuItem(
                      value: 'Business Permit',
                      child: Text('Business Permit')),
                  DropdownMenuItem(
                      value: 'Indigency Certificate',
                      child: Text('Indigency Certificate')),
                  DropdownMenuItem(
                      value: 'Barangay ID', child: Text('Barangay ID')),
                ],
                onChanged: (val) => setState(() => _documentType = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Purpose / Remarks',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _purpose = val ?? 'General Purpose',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final initials = _residentName
                  .trim()
                  .split(' ')
                  .map((e) => e.isNotEmpty ? e[0] : '')
                  .take(2)
                  .join()
                  .toUpperCase();

              final newReq = DocumentRequestModel(
                id: '#BRGY-2023-00${100 + (DateTime.now().millisecond % 900)}',
                documentType: _documentType,
                dateSubmitted: 'Oct 29, 2023',
                residentName: _residentName,
                initials: initials.isEmpty ? 'RN' : initials,
                status: RequestStatus.pending,
                avatarBgColor: AppColors.secondaryContainer,
                avatarTextColor: AppColors.onSecondaryContainer,
                purpose: _purpose,
              );

              widget.onAdd(newReq);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
          child: const Text('Create Request'),
        ),
      ],
    );
  }
}
