import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _db = Supabase.instance.client;

  // ── Admin client (service role — bypasses RLS and session) ──
  // Uses 10.0.2.2 to match the main Supabase client (Android emulator localhost alias)
  final _adminClient = SupabaseClient(
    'http://10.0.2.2:8000',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaXNzIjoic3VwYWJhc2UtZGVtbyIsImlhdCI6MTY0MTc2OTIwMCwiZXhwIjoxNzk5NTM1NjAwfQ.5z-pJI1qwZg1LE5yavGLqum65WOnnaaI5eZ3V00pLww',
  );

  // ── Auth ──
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _db.auth.signInWithPassword(
      email: username,
      password: password,
    );
    if (response.user == null) throw Exception('Login failed');
    return {'user': response.user, 'session': response.session};
  }

  Future<void> logout() async {
    await _db.auth.signOut();
  }

  Future<void> saveToken(String token) async {}
  Future<void> clearToken() async => logout();
  Future<String?> getToken() async => _db.auth.currentSession?.accessToken;

  // ── Chatbot ──
  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    String? base64Image,
    String? mimeType,
  }) async {
    throw UnimplementedError('Connect chatbot endpoint separately.');
  }

  // ── Admin: Users ──
  Future<List<dynamic>> getUsers() async {
    final response = await _db.from('users').select();
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> createUser(
      Map<String, dynamic> userData) async {
    final response =
    await _db.from('users').insert(userData).select().single();
    return response;
  }

  Future<void> deleteUser(String id) async {
    await _db.from('users').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> data) async {
    final response = await _db
        .from('users')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Update the public.users row by auth UUID.
  /// Filters by [authId] — the UUID from auth.users (stored in public.users.id).
  Future<Map<String, dynamic>> updateUserByAuthId(
      String authId, Map<String, dynamic> data) async {
    final response = await _db
        .from('users')
        .update(data)
        .eq('id', authId)
        .select()
        .single();
    return response;
  }

  /// Creates a new auth user via the service-role Admin API.
  /// The handle_new_user trigger auto-creates the public.users row
  /// with a custom user_id (s-001, t-001, etc.) and the correct enum role.
  Future<bool> adminCreateUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final response = await _adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
          userMetadata: {'name': name, 'role': role},
        ),
      );

      if (response.user == null) throw Exception('Failed to create auth user');
      return true;
    } on AuthException catch (e) {
      if (e.statusCode == 422 || e.code == 'email_exists') {
        throw Exception(
          'Email already registered in Auth. '
              'Run: DELETE FROM auth.users WHERE email = \'$email\'; '
              'then retry, or use a different email.',
        );
      }
      rethrow;
    }
  }

  // ── Admin: Reports ──
  Future<Map<String, dynamic>> getAdminReport() async {
    final users = await _db.from('users').select('id');
    final tools = await _db.from('tools_resources').select('id');
    final bookings = await _db.from('booking_requests').select('id, status');

    final pending =
        (bookings as List).where((b) => b['status'] == 'pending').length;
    final approved =
        (bookings).where((b) => b['status'] == 'approved').length;
    final rejected =
        (bookings).where((b) => b['status'] == 'rejected').length;

    return {
      'total_users': (users as List).length,
      'total_tools_resources': (tools as List).length,
      'total_bookings': bookings.length,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }

  Future<Map<String, dynamic>> getAdminReports() => getAdminReport();

  // ── Admin: Tools & Resources ──
  Future<List<dynamic>> getToolsResources() async {
    final response = await _db
        .from('tools_resources')
        .select()
        .order('created_at', ascending: false);
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> addToolResource(
      Map<String, dynamic> data) async {
    final response = await _db
        .from('tools_resources')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> createToolResource(
      Map<String, dynamic> data) =>
      addToolResource(data);

  Future<Map<String, dynamic>> updateToolResource(
      String id, Map<String, dynamic> data) async {
    final response = await _db
        .from('tools_resources')
        .update({...data, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteToolResource(String id) async {
    await _db.from('tools_resources').delete().eq('id', id);
  }

  // ── Admin: Booking Requests ──
  Future<List<dynamic>> getBookingRequests() async {
    final response = await _db.from('booking_requests').select("""
      *,
      users(name, email),
      tools_resources(name, type)
    """).order('created_at', ascending: false);
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateBookingRequestStatus(
      String id, String status) async {
    final response = await _db
        .from('booking_requests')
        .update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String()
    })
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  // ── Teacher ──
  Future<List<dynamic>> getStudents() async {
    final response =
    await _db.from('users').select().eq('role', 'student');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getStudentById(String id) async {
    final response =
    await _db.from('users').select().eq('id', id).single();
    return response;
  }

  Future<Map<String, dynamic>> getTeacherReport() async {
    final bookings = await _db
        .from('booking_requests')
        .select('*, users(name), tools_resources(name)');
    return {'bookings': bookings};
  }

  Future<List<dynamic>> getResourcesBooking() async {
    final response = await _db
        .from('booking_requests')
        .select('*, tools_resources(name, type)')
        .eq('tools_resources.type', 'resource');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> bookResource(
      Map<String, dynamic> bookingData) async {
    final response = await _db
        .from('booking_requests')
        .insert(bookingData)
        .select()
        .single();
    return response;
  }

  // ── Student ──
  Future<Map<String, dynamic>> getReportCard(String studentId) async {
    final bookings = await _db
        .from('booking_requests')
        .select('*, tools_resources(name, type)')
        .eq('user_id', studentId);
    return {'bookings': bookings, 'student_id': studentId};
  }

  /// Fetch available tools from tools_resources table (type = 'tool')
  Future<List<dynamic>> getTools() async {
    final response = await _db
        .from('tools_resources')
        .select()
        .eq('type', 'tool')
        .order('created_at', ascending: false);
    return response as List<dynamic>;
  }

  /// Fetch available resources from tools_resources table (type = 'resource')
  Future<List<dynamic>> getResources() async {
    final response = await _db
        .from('tools_resources')
        .select()
        .eq('type', 'resource')
        .order('created_at', ascending: false);
    return response as List<dynamic>;
  }

  /// Legacy: kept for backward compatibility (returns booking_requests)
  Future<List<dynamic>> getToolsBooking() async {
    final response = await _db
        .from('booking_requests')
        .select('*, tools_resources(name, type)');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> bookTool(
      Map<String, dynamic> bookingData) async {
    final response = await _db
        .from('booking_requests')
        .insert(bookingData)
        .select()
        .single();
    return response;
  }

  // ── User Profile ──
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response =
    await _db.from('users').select().eq('id', userId).single();
    return response;
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');
    await _db.from('users').update(profileData).eq('id', userId);
  }

  Future<void> changePassword(
      String oldPassword, String newPassword) async {
    await _db.auth.updateUser(UserAttributes(password: newPassword));
  }
}