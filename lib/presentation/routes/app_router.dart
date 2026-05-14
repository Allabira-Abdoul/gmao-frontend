import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/domain/entities/user.dart';

/// AppRouter handles application routing logic based on user roles and platform,
/// extracting this responsibility from AuthState to adhere to the Single Responsibility Principle (SRP).
class AppRouter {
  /// Map of roles to their corresponding dashboard routes, adhering to the Open/Closed Principle (OCP).
  static const Map<String, String> _roleToDashboard = {
    'Technicien': '/technicien-dashboard',
    'Manager': '/manager-dashboard',
    'Administrateur': '/admin-dashboard',
  };

  /// Check if the user is allowed to access the app based on their role and platform.
  /// Returns a redirect path or null if allowed.
  static String? getPlatformRedirect(User? user) {
    if (user == null) return '/login';

    final role = user.role; // e.g., "Technicien", "Manager", "Administrateur"

    // Platform logic
    if (kIsWeb) {
      // Everyone can access web
      return _getDashboardByRole(role);
    } else if (Platform.isAndroid) {
      // Android is for technicien
      if (role == 'Technicien') {
        return '/technicien-dashboard';
      } else {
        return '/unauthorized-platform';
      }
    } else if (Platform.isWindows) {
      // Windows is for the others (Manager, Administrateur)
      if (role == 'Manager' || role == 'Administrateur') {
        return _getDashboardByRole(role);
      } else {
        return '/unauthorized-platform';
      }
    }

    return null;
  }

  static String _getDashboardByRole(String role) {
    return _roleToDashboard[role] ?? '/login';
  }
}
