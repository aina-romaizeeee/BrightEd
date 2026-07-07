import 'package:flutter/material.dart';
import 'api_service.dart';
import 'student_profile.dart';
import 'setting_page.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({super.key});

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchCtrl = TextEditingController();

  late AnimationController _spriteController;

  int _currentPage = 1;
  final int _itemsPerPage = 6;

  @override
  void initState() {
    super.initState();
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadStudents();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _spriteController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getStudents();
      if (!mounted) return;
      setState(() {
        _allStudents = data.cast<Map<String, dynamic>>();
        _filtered = _allStudents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load students: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allStudents
          : _allStudents
          .where((s) =>
      (s['name'] ?? '').toString().toLowerCase().contains(q) ||
          (s['student_id'] ?? '').toString().toLowerCase().contains(q))
          .toList();
      _currentPage = 1;
    });
  }

  List<Map<String, dynamic>> get _paginatedStudents {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end.clamp(0, _filtered.length));
  }

  int get _totalPages => (_filtered.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                const SizedBox(height: 4),
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
                              color: Color(0xFF1A237E),
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
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
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
                                'Progress',
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'All users ${_filtered.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Student ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 28),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? _buildErrorView()
                      : _filtered.isEmpty
                      ? const Center(
                    child: Text(
                      'No students found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: _loadStudents,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _paginatedStudents.length,
                      itemBuilder: (_, i) {
                        final student = _paginatedStudents[i];
                        final studentId =
                            student['student_id']?.toString() ??
                                student['id']?.toString() ??
                                '';
                        final name = student['name'] ?? 'Unknown';
                        final date = student['created_at'] ?? '22 May';

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentProfile(
                                studentId:
                                student['id']?.toString() ?? '',
                                studentName: name,
                                studentIdNo: studentId,
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    studentId,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.amber.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages.clamp(1, 4), (index) {
                      final page = index + 1;
                      final isSelected = page == _currentPage;
                      return GestureDetector(
                        onTap: () => setState(() => _currentPage = page),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1A237E)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$page',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadStudents, child: const Text('Retry')),
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