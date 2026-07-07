import 'package:flutter/material.dart';
import 'api_service.dart';
import 'setting_page.dart';

class AdminReportSection extends StatefulWidget {
  const AdminReportSection({super.key});

  @override
  State<AdminReportSection> createState() => _AdminReportSectionState();
}

class _AdminReportSectionState extends State<AdminReportSection>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _reportData;
  bool _isLoading = true;
  String? _error;

  late AnimationController _spriteController;

  final List<String> _menuItems = ['File', 'Edit', 'View', 'Insert', 'Format', 'Tools'];
  String _selectedMenu = 'File';

  @override
  void initState() {
    super.initState();
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadReports();
  }

  @override
  void dispose() {
    _spriteController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getAdminReports();
      if (!mounted) return;
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load reports: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

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
                      color: const Color(0xFF470047).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'BrightEd',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF470047),
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
                // ── BIGGER WHITE TITLE BOX WITH IMAGE INSIDE ──
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
                                'Section',
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
                          'assets/images/star.png',
                          height: 48,
                          width: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.star,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF470047),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _menuItems.map((item) {
                      final isSelected = item == _selectedMenu;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMenu = item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6B3A6B)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.8),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.folder,
                            size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'untitled document',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? _buildErrorView()
                      : RefreshIndicator(
                    onRefresh: _loadReports,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 0),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: const Text(
                                    'Weekly Report',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildReportTable(),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bar_chart,
                                          size: 40,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Statistics Chart',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDataTable(),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Generated on ${_getCurrentDate()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic,
                                    ),
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
                      const SizedBox(width: 12),
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
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Report saved successfully')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
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
          ElevatedButton(onPressed: _loadReports, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildReportTable() {
    final totalUsers = _reportData?['total_users']?.toString() ?? '0';
    final totalStudents = _reportData?['total_students']?.toString() ?? '0';
    final totalTeachers = _reportData?['total_teachers']?.toString() ?? '0';
    final activeBookings = _reportData?['active_bookings']?.toString() ?? '0';

    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            _TableHeaderCell('Metric'),
            _TableHeaderCell('Value'),
          ],
        ),
        _buildTableRow('Total Users', totalUsers),
        _buildTableRow('Total Students', totalStudents),
        _buildTableRow('Total Teachers', totalTeachers),
        _buildTableRow('Active Bookings', activeBookings),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        _TableCell(label),
        _TableCell(value, isValue: true),
      ],
    );
  }

  Widget _buildDataTable() {
    final activities = _reportData?['recent_activity'] as List? ?? [];

    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            'No recent activity data',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      );
    }

    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            _TableHeaderCell('Activity'),
            _TableHeaderCell('Date'),
          ],
        ),
        ...activities.take(5).map((a) {
          final activity = a as Map<String, dynamic>;
          return TableRow(
            children: [
              _TableCell(activity['description']?.toString() ?? '-'),
              _TableCell(activity['timestamp']?.toString() ?? '-'),
            ],
          );
        }).toList(),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isValue;
  const _TableCell(this.text, {this.isValue = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isValue ? FontWeight.bold : FontWeight.normal,
          color: isValue ? const Color(0xFF1A73E8) : Colors.black87,
        ),
        textAlign: isValue ? TextAlign.center : TextAlign.left,
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