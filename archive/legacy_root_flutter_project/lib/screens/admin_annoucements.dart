import 'package:bms/screens/admin_announcements.dart';
import 'package:bms/screens/admin_documentRequest.dart';
import 'package:bms/widgets/requests_table.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ViewMode {auto, desktop, mobile}

class EventModel {
  final String title;
  final int date;
  final int time;
  final String eventType;
  final String description;
  final AnnouncementStatus;

  announcementsModel({
    required this.title,
    required this.date,
    required this.time,
    required this.eventType,
    required this description,
    required this AnnouncementStatus,

  });
}

typedef AdminannouncementsScreen = admin_announcements;

class admin_announcements extends StatefulWidget {
  const admin_announcements({super.key});

  @override
  State<admin_announcements> createState() =>
      _admin_announcementsState();
}

class _admin_announcementsState
    extends State<admin_announcements> {
  // View mode switcher: auto (responsive), desktop (forced), mobile (forced)
  ViewMode _viewMode = ViewMode.auto;

String _searchQuery = '';
String _selectedTab = 'All Requests';
String _selectedStatusFilter = 'All Statuses';
String? _selectedRowId;
int _currentPage = 1;



@override
Widget build(BuildContext context){
  return LayoutBuilder(builder: (context, constraints) {
      final screenIsWide = constraints.maxWidth >= 900;
        final bool isMobile = _viewMode == ViewMode.mobile ||
            (_viewMode == ViewMode.auto && !screenIsWide);

      return Scaffold(
        backgroundColor: AppColors.background,
        drawer: isMobile ? const Drawer(child: _SidebarContent()) : null,
        body: SafeArea(
          child: Row(
            children: [
            if (!isMobile) const _SidebarContent(),

            Expanded(
              child: Column(
                children: [
                  _TopHeader(
                    isMobile: isMobile,
                    viewMode: _viewMode,
                    onViewModeChanged: (mode){
                      setState(() => _viewMode = mode);
                    },
                    onSearchChanged:(val){
                      setState(() => _searchQuery = val);
                    },
                  ),

                  //scrollable body
                Expanded(child: SingleChildScrollView(
                  padding: EdgeInsets.all(value),
                ))
  ],))
              )
            ],) ,)
      )
  },)
}
    }
