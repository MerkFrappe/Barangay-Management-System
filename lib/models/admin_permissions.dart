/// Dashboard areas that may be assigned to an officer account.
///
/// The list is stored on the user document as `adminPermissions`, making the
/// assignment portable and immediately reflected by the admin navigation.
class AdminPermissions {
  static const dashboard = 'dashboard';
  static const residents = 'residents';
  static const requests = 'requests';
  static const peaceOrder = 'peaceOrder';
  static const analytics = 'analytics';
  static const emergencyReports = 'emergencyReports';
  static const announcements = 'announcements';
  static const communityPolls = 'communityPolls';
  static const emergencyBroadcast = 'emergencyBroadcast';
  static const settings = 'settings';
  static const editMonthlyRevenue = 'editMonthlyRevenue';
  static const manageOfficerAccess = 'manageOfficerAccess';

  static const all = <String>{
    dashboard,
    residents,
    requests,
    peaceOrder,
    analytics,
    emergencyReports,
    announcements,
    communityPolls,
    emergencyBroadcast,
    settings,
    editMonthlyRevenue,
    manageOfficerAccess,
  };

  static const labels = <String, String>{
    dashboard: 'Dashboard overview',
    residents: 'Residents directory',
    requests: 'Document requests',
    peaceOrder: 'Peace & Order',
    analytics: 'Analytics and reports',
    emergencyReports: 'Emergency reports',
    announcements: 'Announcements',
    communityPolls: 'Community polls',
    emergencyBroadcast: 'Emergency broadcast',
    settings: 'System settings',
    editMonthlyRevenue: 'Edit monthly revenue',
    manageOfficerAccess: 'Manage officer access',
  };

  static Set<String> fromUser(Map<String, dynamic>? data) {
    final role = data?['role']?.toString();
    // The primary Admin Console account always retains access so it cannot be
    // locked out by a mistaken toggle configuration.
    if (role == 'Admin') return Set<String>.from(all);
    final raw = data?['adminPermissions'];
    if (raw is Iterable) {
      return raw.map((item) => item.toString()).toSet();
    }
    // Existing officers retain their current behavior until an Admin assigns
    // an explicit permission set.
    return Set<String>.from(all.difference({manageOfficerAccess}));
  }

  static bool canEditRevenue(Map<String, dynamic>? data) =>
      fromUser(data).contains(analytics) &&
      fromUser(data).contains(editMonthlyRevenue);
}
