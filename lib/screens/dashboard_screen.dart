import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';
import '../widgets/overview_cards.dart';
import '../widgets/critical_attention.dart';
import '../widgets/jurisdiction_map.dart';
import '../widgets/quick_actions.dart';
import '../widgets/requests_table.dart';
import '../widgets/performance_chart.dart';
import '../widgets/schedule_panel.dart';
import '../screens/admin_reports_screen.dart';
import '../screens/residents_directory_screen.dart';
import '../screens/peace_and_order_screen.dart';
import '../screens/admin_documentRequest.dart';

/// Breakpoint above which the sidebar is shown permanently (like the
/// original fixed 256px desktop sidebar). Below it, it becomes a Drawer.
const double _wideBreakpoint = 900;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _searchResidents(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResidentsDirectoryScreen(initialSearchQuery: trimmedQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideBreakpoint;

        final body = SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WelcomeHeader(isWide: isWide),
                const SizedBox(height: 32),
                const OverviewCards(),
                const SizedBox(height: 32),
                isWide ? const _MiddleGridWide() : const _MiddleGridNarrow(),
                const SizedBox(height: 32),
                isWide ? const _FooterGridWide() : const _FooterGridNarrow(),
              ],
            ),
          ),
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                const SidebarNav(selectedIndex: 0),
                Expanded(
                  child: Column(
                    children: [
                      TopHeader(onSearchSubmitted: _searchResidents),
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
            foregroundColor: AppColors.onSurface,
            elevation: 0,
            title: Text(
              'Barangay Admin',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          drawer: const Drawer(child: SidebarNav(selectedIndex: 0)),
          body: body,
        );
      },
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final bool isWide;
  const _WelcomeHeader({required this.isWide});

  void _showCreateRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_circle, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Create New Barangay Record'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add, color: AppColors.primary),
              title: const Text('Register Resident Profile'),
              subtitle: const Text('Add a new resident to the directory'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResidentsDirectoryScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.gavel, color: AppColors.tertiary),
              title: const Text('File Peace & Order Incident'),
              subtitle: const Text('Log a new blotter or community dispute'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PeaceAndOrderScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.assignment, color: AppColors.secondary),
              title: const Text('Issue Document Request'),
              subtitle: const Text(
                'Process clearance, residency, or indigency',
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminDocumentRequestScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
          style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          "Good morning, Chairman. Here is what's happening in your Barangay today.",
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
            );
          },
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Export Daily Report'),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerHigh,
            foregroundColor: AppColors.primary,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreateRecordDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Create New Record'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 4,
          ),
        ),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: title),
          actions,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, const SizedBox(height: 16), actions],
    );
  }
}

class _MiddleGridWide extends StatelessWidget {
  const _MiddleGridWide();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                CriticalAttention(),
                SizedBox(height: 32),
                JurisdictionMap(),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                QuickActions(),
                SizedBox(height: 32),
                RequestsTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiddleGridNarrow extends StatelessWidget {
  const _MiddleGridNarrow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        QuickActions(),
        SizedBox(height: 24),
        CriticalAttention(),
        SizedBox(height: 24),
        JurisdictionMap(),
        SizedBox(height: 24),
        RequestsTable(),
      ],
    );
  }
}

class _FooterGridWide extends StatelessWidget {
  const _FooterGridWide();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 8, child: PerformanceChart()),
          SizedBox(width: 32),
          Expanded(flex: 4, child: SchedulePanel()),
        ],
      ),
    );
  }
}

class _FooterGridNarrow extends StatelessWidget {
  const _FooterGridNarrow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        PerformanceChart(),
        SizedBox(height: 24),
        SchedulePanel(),
      ],
    );
  }
}
