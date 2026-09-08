const adminRoles = <String>{
  'Admin',
  'Chairman',
  'Secretary',
  'Treasurer',
  'Auditor',
  'Kagawad',
  'SK Chairman',
  'Tanod',
  'BHW',
  'Admin Staff',
};

bool isAdminRole(String? role) => role != null && adminRoles.contains(role);
