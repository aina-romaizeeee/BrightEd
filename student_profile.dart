import 'package:flutter/material.dart';
import 'api_service.dart';
import 'setting_page.dart';

class StudentProfile extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentIdNo;

  const StudentProfile({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentIdNo,
  });

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  late AnimationController _spriteController;

  @override
  void initState() {
    super.initState();
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadProfile();
  }

  @override
  void dispose() {
    _spriteController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getStudentById(widget.studentId);
      if (!mounted) return;
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load student profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendancePercent = _profileData?['attendance'] ?? 67;
    final progressPercent = _profileData?['progress'] ?? 62;
    final gradePercent = _profileData?['average_grade'] ?? 57;
    final achievementsPercent = _profileData?['achievements'] ?? 10;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/prfp.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF5F7FA),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // ── Seamless forward-scrolling sprite grid ──
                  _ScrollingSpriteGrid(
                    controller: _spriteController,
                    topImagePath: 'assets/images/shark.png',
                    bottomImagePath: 'assets/images/garfield.png',
                    topSpriteSize: 45,
                    bottomSpriteSize: 32,
                    topFallbackIcon: Icons.water,
                    bottomFallbackIcon: Icons.pets,
                    topFallbackColor: const Color(0xFF1A73E8),
                    bottomFallbackColor: Colors.orange,
                    spacing: 24,
                    count: 10,
                  ),
                  const SizedBox(height: 8),
                  // ── Title bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'BrightEd',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.search,
                              size: 24,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingPage()),
                            ),
                            child: Image.asset(
                              'assets/images/acc.png',
                              height: 28,
                              width: 28,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.account_circle,
                                size: 28,
                                color: Color(0xFF1A73E8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── WHITE BOX WITH IMAGE INSIDE ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Student',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            'assets/images/boy.png',
                            height: 48,
                            width: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Stats grid ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildStatCard(
                                title: 'Attendance',
                                percent: attendancePercent,
                                subtitle: '$attendancePercent% Present',
                                color: const Color(0xFFE91E63),
                                trackColor: const Color(0xFFFCE4EC),
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                title: 'Average Grade',
                                percent: gradePercent,
                                subtitle: '$gradePercent%',
                                color: const Color(0xFF2196F3),
                                trackColor: const Color(0xFFE3F2FD),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildProgressCard(
                            title: 'Full Progress',
                            percent: progressPercent,
                            subtitle: '$progressPercent% Progress',
                            achievementsPercent: achievementsPercent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 190),
                  // ── Bottom bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Image.asset(
                            'assets/images/back.png',
                            height: 46,
                            width: 46,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.arrow_back,
                              size: 46,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int percent,
    required String subtitle,
    required Color color,
    required Color trackColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB6C1).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF470047),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 8,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required int percent,
    required String subtitle,
    required int achievementsPercent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB6C1).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF470047),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 10,
                  backgroundColor: const Color(0xFFFCE4EC),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BC34A)),
                ),
                Center(
                  child: Text(
                    '$percent',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8BC34A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8BC34A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.orange.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$achievementsPercent% Achievements',
            style: TextStyle(
              fontSize: 10,
              color: Colors.pink.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scrolling Sprite Grid (Forward / Rightward) ──
class _ScrollingSpriteGrid extends StatelessWidget {
  final AnimationController controller;
  final String topImagePath;
  final String bottomImagePath;
  final double topSpriteSize;
  final double bottomSpriteSize;
  final IconData topFallbackIcon;
  final IconData bottomFallbackIcon;
  final Color topFallbackColor;
  final Color bottomFallbackColor;
  final double spacing;
  final int count;

  const _ScrollingSpriteGrid({
    required this.controller,
    required this.topImagePath,
    required this.bottomImagePath,
    required this.topSpriteSize,
    required this.bottomSpriteSize,
    required this.topFallbackIcon,
    required this.bottomFallbackIcon,
    required this.topFallbackColor,
    required this.bottomFallbackColor,
    required this.spacing,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colWidth = topSpriteSize > bottomSpriteSize ? topSpriteSize : bottomSpriteSize;
    final step = colWidth + spacing;
    final totalHeight = topSpriteSize + bottomSpriteSize + (spacing / 2);
    final totalWidth = count * step;

    return SizedBox(
      height: totalHeight,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final offset = controller.value * totalWidth;

          Widget buildRow() => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(count, (_) => Padding(
              padding: EdgeInsets.only(right: spacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    topImagePath,
                    height: topSpriteSize,
                    width: topSpriteSize,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      topFallbackIcon,
                      size: topSpriteSize,
                      color: topFallbackColor,
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  Image.asset(
                    bottomImagePath,
                    height: bottomSpriteSize,
                    width: bottomSpriteSize,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      bottomFallbackIcon,
                      size: bottomSpriteSize,
                      color: bottomFallbackColor,
                    ),
                  ),
                ],
              ),
            )),
          );

          return Stack(
            children: [
              Positioned(
                left: offset,
                top: 0,
                child: buildRow(),
              ),
              Positioned(
                left: offset - totalWidth,
                top: 0,
                child: buildRow(),
              ),
            ],
          );
        },
      ),
    );
  }
}