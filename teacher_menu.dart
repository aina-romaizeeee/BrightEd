// start docker
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'resources_booking.dart';
import 'student_management.dart';
import 'teacher_report_section.dart';
import 'setting_page.dart';

class TeacherMenu extends StatefulWidget {
  const TeacherMenu({super.key});

  @override
  State<TeacherMenu> createState() => _TeacherMenuState();
}

class _TeacherMenuState extends State<TeacherMenu>
    with TickerProviderStateMixin {
  late AnimationController _spriteController;

  @override
  void initState() {
    super.initState();
    _spriteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _spriteController.dispose();
    super.dispose();
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    topFallbackColor: const Color(0xFF1A237E),
                    bottomFallbackColor: Colors.orange,
                    spacing: 24,
                    count: 10,
                  ),

                  const SizedBox(height: 6),

                  _topBar(),

                  const SizedBox(height: 16),

                  _greetingCard(),

                  const SizedBox(height: 5),

                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  FolderTabStack(
                    items: [
                      FolderItem(
                        label: 'Resources Booking',
                        bodyColor: const Color(0xFF333333),
                        tabColor: const Color(0xFF2C2C2C),
                        tabTextColor: const Color(0xFFCCCCCC),
                        labelColor: Colors.white,
                        imagePath: 'assets/images/book.png',
                        fallbackIcon: Icons.menu_book_outlined,
                        fallbackIconColor: Colors.white70,
                        iconOnRight: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResourcesBooking(),
                          ),
                        ),
                      ),
                      FolderItem(
                        label: 'Student Progress',
                        bodyColor: const Color(0xFFF8BBD0),
                        tabColor: const Color(0xFFF3A8C4),
                        tabTextColor: const Color(0xFF7A3052),
                        labelColor: const Color(0xFF3E1A2E),
                        imagePath: 'assets/images/file.png',
                        fallbackIcon: Icons.folder_open_outlined,
                        fallbackIconColor: Colors.white70,
                        iconOnRight: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentManagement(),
                          ),
                        ),
                      ),
                      FolderItem(
                        label: 'Report Section',
                        bodyColor: const Color(0xFF1A237E),
                        tabColor: const Color(0xFF141C6A),
                        tabTextColor: const Color(0xFF8E9CE8),
                        labelColor: Colors.white,
                        imagePath: 'assets/images/star.png',
                        fallbackIcon: Icons.star_outline,
                        fallbackIconColor: Colors.white70,
                        iconOnRight: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TeacherReportSection(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _backRow(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
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
    );
  }

  Widget _greetingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi Teacher y/n,',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'What are your \nplans for today?',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/girl.png',
                height: 70,
                width: 70,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 80,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const Expanded(
            child: Center(
              child: Text(
                'back,',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FolderItem {
  final String label;
  final Color bodyColor;
  final Color tabColor;
  final Color tabTextColor;
  final Color labelColor;
  final String imagePath;
  final IconData fallbackIcon;
  final Color fallbackIconColor;
  final bool iconOnRight;
  final VoidCallback onTap;

  const FolderItem({
    required this.label,
    required this.bodyColor,
    required this.tabColor,
    required this.tabTextColor,
    required this.labelColor,
    required this.imagePath,
    required this.fallbackIcon,
    required this.fallbackIconColor,
    required this.iconOnRight,
    required this.onTap,
  });
}

class FolderTabStack extends StatelessWidget {
  final List<FolderItem> items;

  static const double _tabHeight = 26;
  static const double _tabWidth = 130;
  static const double _tabRadius = 8;
  static const double _cardRadius = 12;
  static const double _cardMinHeight = 72;
  static const double _verticalGap = 10;
  static const double _tabStep = 16;

  const FolderTabStack({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: _verticalGap),
            _FolderCard(
              item: items[i],
              tabLeftOffset: i * _tabStep,
              tabHeight: _tabHeight,
              tabWidth: _tabWidth,
              tabRadius: _tabRadius,
              cardRadius: _cardRadius,
              cardMinHeight: _cardMinHeight,
              isFirst: i == 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _FolderCard extends StatefulWidget {
  final FolderItem item;
  final double tabLeftOffset;
  final double tabHeight;
  final double tabWidth;
  final double tabRadius;
  final double cardRadius;
  final double cardMinHeight;
  final bool isFirst;

  const _FolderCard({
    required this.item,
    required this.tabLeftOffset,
    required this.tabHeight,
    required this.tabWidth,
    required this.tabRadius,
    required this.cardRadius,
    required this.cardMinHeight,
    required this.isFirst,
  });

  @override
  State<_FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<_FolderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lift;
  late final Animation<double> _liftAnim;

  @override
  void initState() {
    super.initState();
    _lift = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _liftAnim = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _lift, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _lift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final bodyRadius = widget.isFirst
        ? BorderRadius.only(
      topLeft: Radius.zero,
      topRight: Radius.circular(widget.cardRadius),
      bottomLeft: Radius.circular(widget.cardRadius),
      bottomRight: Radius.circular(widget.cardRadius),
    )
        : BorderRadius.circular(widget.cardRadius);

    Widget imageWidget = Image.asset(
      item.imagePath,
      height: 70,
      width: 70,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        item.fallbackIcon,
        size: 42,
        color: item.fallbackIconColor,
      ),
    );

    List<Widget> rowChildren = item.iconOnRight
        ? [
      Expanded(
        child: Text(
          item.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: item.labelColor,
            height: 1.3,
          ),
        ),
      ),
      const SizedBox(width: 16),
      imageWidget,
    ]
        : [
      imageWidget,
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          item.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: item.labelColor,
            height: 1.3,
          ),
        ),
      ),
    ];

    return AnimatedBuilder(
      animation: _liftAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _liftAnim.value),
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _lift.forward(),
        onTapUp: (_) {
          _lift.reverse();
          item.onTap();
        },
        onTapCancel: () => _lift.reverse(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: widget.tabLeftOffset),
              child: CustomPaint(
                painter: _TabPainter(
                  color: item.tabColor,
                  radius: widget.tabRadius,
                ),
                child: SizedBox(
                  width: widget.tabWidth,
                  height: widget.tabHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: item.tabTextColor,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: bodyRadius,
              child: Material(
                color: item.bodyColor,
                child: InkWell(
                  onTap: item.onTap,
                  splashColor: Colors.white.withOpacity(0.12),
                  highlightColor: Colors.white.withOpacity(0.06),
                  child: Container(
                    constraints:
                    BoxConstraints(minHeight: widget.cardMinHeight),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Row(children: rowChildren),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _TabPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TabPainter old) => old.color != color;
}

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

    return SizedBox(
      height: totalHeight,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final screenWidth = MediaQuery.of(context).size.width;
          final totalWidth = screenWidth + count * step;
          final offset = controller.value * totalWidth;
          return Stack(
            children: [
              Positioned(
                left: offset - (count ~/ 2) * step,
                top: 0,
                child: Row(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}