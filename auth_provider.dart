import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { admin, teacher, student }

class AppUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
}

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Signs in with email + password.
  /// Returns true on success, false on failure.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supaUser = response.user;
      if (supaUser == null) {
        _errorMessage = 'Login failed. Please try again.';
        return false;
      }

      // Determine role from user_metadata or app_metadata.
      // Adjust the key name to match whatever you store in Supabase.
      final meta = supaUser.userMetadata ?? {};
      final appMeta = supaUser.appMetadata;
      final rawRole = meta['role'] ?? appMeta['role'] ?? 'student';

      // Read name from user_metadata — falls back to email prefix if not set.
      final rawName = meta['name'] ??
          meta['full_name'] ??
          meta['display_name'] ??
          (supaUser.email ?? email).split('@').first;

      _user = AppUser(
        id: supaUser.id,
        email: supaUser.email ?? email,
        name: rawName.toString(),
        role: _parseRole(rawRole.toString()),
      );

      return true;
    } on AuthException catch (e) {
      _errorMessage = _friendlyError(e.message);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Alias for signOut — used by setting_page.dart
  Future<void> logout() => signOut();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  UserRole _parseRole(String raw) {
    switch (raw.toLowerCase()) {
      case 'admin':
      case 'administration':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      default:
        return UserRole.student;
    }
  }

  String _friendlyError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (lower.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return message;
  }
}