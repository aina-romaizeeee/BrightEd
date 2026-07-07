import 'package:flutter/material.dart';
import 'api_service.dart';

class UserProfile extends StatefulWidget {
  final String userId;
  final String userName;
  final String userIdNo;
  final String? role; // 'teacher', 'student', or 'admin'

  const UserProfile({
    super.key,
    required this.userId,
    required this.userName,
    required this.userIdNo,
    this.role,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  late AnimationController _sharkController;
  late AnimationController _garfieldController;

  String get _role => (widget.role ?? _profileData?['role'] ?? 'student').toString().toLowerCase();
  bool get _isTeacher => _role == 'teacher';
  bool get _isStudent => _role == 'student';
  bool get _isAdmin => _role == 'admin';

  String get _pageTitle {
    if (_isTeacher) return 'Teacher y/n';
    if (_isStudent) return 'Student Profile';
    return 'Admin Profile';
  }

  String get _cardTitle {
    if (_isTeacher) return 'TEACHER';
    if (_isStudent) return 'STUDENT';
    return 'ADMIN';
  }

  String get _welcomeText {
    if (_isTeacher) return 'Welcome To Pre-k';
    if (_isStudent) return 'Welcome To Class';
    return 'Welcome To BrightEd';
  }

  Color get _accentColor {
    if (_isTeacher) return const Color(0xFFFFB6C1); // pink
    if (_isStudent) return const Color(0xFF98D8C8); // mint green
    return const Color(0xFFB8A9C9); // lavender
  }

  Color get _secondaryColor {
    if (_isTeacher) return const Color(0xFF98D8C8); // mint
    if (_isStudent) return const Color(0xFFFFD93D); // yellow
    return const Color(0xFFFFB6C1); // pink
  }

  @override
  void initState() {
    super.initState();
    _sharkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
    _garfieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
    _loadProfile();
  }

  @override
  void dispose() {
    _sharkController.dispose();
    _garfieldController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getUserProfile(widget.userId);
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile.';
        _isLoading = false;
      });
    }
  }

  void _copyEmail() {
    final email = _profileData?['email'] ?? 'teacher@school.edu';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email copied: $email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Pixel-art grid background ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/prfp.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF5F7FA),
              ),
            ),
          ),

          // ── Foreground content ──
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // ── Animated shark row ──
                  _buildSpriteRow(_sharkController, 'shark.png', 45, Icons.water, const Color(0xFF1A73E8)),

                  // ── Animated garfield row ──
                  _buildSpriteRow(_garfieldController, 'garfield.png', 32, Icons.pets, Colors.orange),

                  const SizedBox(height: 8),

                  // ── Title bar: BrightEd + search + acc ──
                  _buildTitleBar(),

                  const SizedBox(height: 20),

                  // ── Page title ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _pageTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87.withOpacity(0.8),
                            ),
                          ),
                        ),
                        Image.asset(
                          _isStudent ? 'assets/images/boy.png' : 'assets/images/girl.png',
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Profile Card ──
                  _buildProfileCard(),

                  const SizedBox(height: 20),

                  // ── Bottom bar: back button ──
                  _buildBottomBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpriteRow(AnimationController controller, String image, double size, IconData fallback, Color fallbackColor) {
    return SizedBox(
      height: size + 5,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          final totalWidth = screenWidth + 6 * 74;
          final offset = controller.value * totalWidth;
          return Stack(
            children: [
              Positioned(
                left: offset - 4 * 74,
                child: Row(
                  children: List.generate(12, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Image.asset(
                        'assets/images/$image',
                        height: size,
                        width: size,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          fallback,
                          size: size,
                          color: fallbackColor,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitleBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF470047).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/search.png',
                height: 28,
                width: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.search,
                  size: 28,
                  color: Color(0xFF470047),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    Text(
                      'BrightEd',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2.5
                          ..color = Colors.white,
                      ),
                    ),
                    const Text(
                      'BrightEd',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF470047),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/acc.png',
                height: 28,
                width: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.account_circle,
                  size: 28,
                  color: Color(0xFF470047),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with smiley
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD93D),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '😊',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Meet the',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _cardTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF470047),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Welcome text
            Text(
              _welcomeText,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 12),

            // Info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Info fields
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // My name is
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'My name is',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Name field
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade300),
                          ),
                          child: Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // About me / Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _secondaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _isStudent ? 'Grade & Class' : 'About me',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // About text area
                        Container(
                          width: double.infinity,
                          height: 80,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade300),
                          ),
                          child: Text(
                            _isStudent
                                ? 'Grade: ${_profileData?['grade'] ?? 'N/A'}\nClass: ${_profileData?['class'] ?? 'N/A'}\nID: ${widget.userIdNo}'
                                : _profileData?['about'] ??
                                'Passionate educator with 5+ years experience...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Contact button
                        GestureDetector(
                          onTap: _copyEmail,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD93D),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Contact',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Contact info
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade300),
                          ),
                          child: Text(
                            _profileData?['email'] ??
                                'teacher@school.edu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right column - Photo + Favorites
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // Photo placeholder
                        Container(
                          width: double.infinity,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A574),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFD4A574),
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_camera_outlined,
                                  size: 28,
                                  color: Colors.white70,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Photo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // My Favorites / Stats
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8A9C9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _isStudent ? 'My Stats' : 'My Favorites',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Favorite items list
                        if (_isStudent) ...[
                          _buildFavoriteItem(Icons.school, 'Courses'),
                          _buildFavoriteItem(Icons.book, 'Books'),
                          _buildFavoriteItem(Icons.emoji_events, 'Awards'),
                          _buildFavoriteItem(Icons.calendar_today, 'Attendance'),
                          _buildFavoriteItem(Icons.grade, 'GPA'),
                          _buildFavoriteItem(Icons.people, 'Clubs'),
                        ] else ...[
                          _buildFavoriteItem(Icons.restaurant, 'Food'),
                          _buildFavoriteItem(Icons.book, 'Book'),
                          _buildFavoriteItem(Icons.pets, 'Animal'),
                          _buildFavoriteItem(Icons.color_lens, 'Color'),
                          _buildFavoriteItem(Icons.sports, 'Activity'),
                          _buildFavoriteItem(Icons.celebration, 'Holiday'),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB8A9C9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7FD4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black26),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    'back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}