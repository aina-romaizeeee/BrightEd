import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'auth_provider.dart';
import 'setting_page.dart';

class ReportCardPage extends StatefulWidget {
  const ReportCardPage({super.key});

  @override
  State<ReportCardPage> createState() => _ReportCardPageState();
}

class _ReportCardPageState extends State<ReportCardPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _reportCard;
  bool _isLoading = true;
  String? _error;
  String _selectedTerm = 'Term 1';
  final List<String> _terms = ['Term 1', 'Term 2', 'Term 3'];

  late AnimationController _spriteController;

  @override
  void initState() {
    super.initState();
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadReportCard();
  }

  @override
  void dispose() {
    _spriteController.dispose();
    super.dispose();
  }

  Future<void> _loadReportCard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userId = context.read<AuthProvider>().user?.id ?? '';
      final data = await ApiService().getReportCard(userId);
      if (!mounted) return;
      setState(() {
        _reportCard = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load report card: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _currentGrades {
    final terms =
        _reportCard?['terms'] as Map<String, dynamic>? ?? {};
    return (terms[_selectedTerm] as List?) ?? [];
  }

  double get _gpa {
    final grades = _currentGrades;
    if (grades.isEmpty) return 0;
    final total = grades.fold<double>(
      0,
          (sum, g) =>
      sum +
          (double.tryParse(g['score']?.toString() ?? '') ?? 0),
    );
    return total / grades.length;
  }

  Color _gradeColor(double score) {
    if (score >= 80) return const Color(0xFF34A853);
    if (score >= 60) return const Color(0xFFFBBC05);
    return const Color(0xFFEA4335);
  }

  String _gradeLabel(double score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'A';
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().user;

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
            child: Column(
              children: [
                const SizedBox(height: 4),

                // ── Animated sprite grid ──
                _ScrollingSpriteGrid(controller: _spriteController),

                const SizedBox(height: 8),

                // ── Title bar: BrightEd (yellow/gold style) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
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
                                'Report',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Card',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // A+ icon inside white box
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFB6C1)),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'A+',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                              Icon(
                                Icons.menu_book,
                                size: 20,
                                color: Color(0xFFE91E63),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Report card content ──
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? _buildErrorView()
                      : RefreshIndicator(
                    onRefresh: _loadReportCard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Student info card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFFB6C1).withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Student Name: ${student?.name ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Student ID: ${student?.id ?? '-'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Term selector
                          Row(
                            children: _terms.map((term) {
                              final selected = _selectedTerm == term;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: GestureDetector(
                                    onTap: () => setState(
                                            () => _selectedTerm = term),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFF470047)
                                            : Colors.white.withOpacity(0.8),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                          color: selected
                                              ? const Color(0xFF470047)
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          term,
                                          style: TextStyle(
                                            color: selected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          // GPA summary
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                _SummaryItem(
                                  label: 'Average',
                                  value: _gpa.toStringAsFixed(1),
                                  color: _gradeColor(_gpa),
                                ),
                                _SummaryItem(
                                  label: 'Grade',
                                  value: _gradeLabel(_gpa),
                                  color: _gradeColor(_gpa),
                                ),
                                _SummaryItem(
                                  label: 'Subjects',
                                  value: '${_currentGrades.length}',
                                  color: const Color(0xFF34A853),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Subject grades table
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Subject Grades',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_currentGrades.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        'No grades for this term.',
                                        style: TextStyle(
                                            color: Colors.grey),
                                      ),
                                    ),
                                  )
                                else
                                  ..._currentGrades.map((g) {
                                    final grade = g as Map<String, dynamic>;
                                    final score = double.tryParse(
                                        grade['score']?.toString() ?? '') ??
                                        0;
                                    final color = _gradeColor(score);
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  grade['subject'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 4),
                                                Text(
                                                  'Teacher: ${grade['teacher'] ?? '-'}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors
                                                        .grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 6),
                                                ClipRRect(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(4),
                                                  child:
                                                  LinearProgressIndicator(
                                                    value: score / 100,
                                                    backgroundColor:
                                                    color.withOpacity(
                                                        0.15),
                                                    valueColor:
                                                    AlwaysStoppedAnimation(
                                                        color),
                                                    minHeight: 6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            children: [
                                              Text(
                                                '${score.toInt()}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: color,
                                                ),
                                              ),
                                              Text(
                                                _gradeLabel(score),
                                                style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: color,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Remarks section
                          if (_reportCard?['remarks'] != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius:
                                BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFBBDEFB)),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Teacher Remarks',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _reportCard!['remarks'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Plant decoration
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(
                                      Icons.local_florist,
                                      size: 24,
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Bottom bar: back button ──
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
          ElevatedButton(
              onPressed: _loadReportCard, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// ── Scrolling Sprite Grid (Forward / Rightward) ──
class _ScrollingSpriteGrid extends StatelessWidget {
  final AnimationController controller;
  const _ScrollingSpriteGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        const columnCount = 10;
        const spacing = 24.0;
        const columnWidth = 45.0 + spacing;
        final totalWidth = columnCount * columnWidth;
        final offset = controller.value * totalWidth;

        return SizedBox(
          height: 85,
          child: Stack(
            children: [
              Positioned(
                left: offset,
                child: Row(
                  children: List.generate(columnCount + 1, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: spacing),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/shark.png',
                            height: 45,
                            width: 45,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.water,
                              size: 45,
                              color: Color(0xFF1A73E8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Image.asset(
                            'assets/images/garfield.png',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.pets,
                              size: 32,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                left: offset - totalWidth,
                child: Row(
                  children: List.generate(columnCount + 1, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: spacing),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/shark.png',
                            height: 45,
                            width: 45,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.water,
                              size: 45,
                              color: Color(0xFF1A73E8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Image.asset(
                            'assets/images/garfield.png',
                            height: 32,
                            width: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.pets,
                              size: 32,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}