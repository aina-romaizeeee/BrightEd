import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tools_resources.dart';
import 'user_management.dart';
import 'admin_report_section.dart';
import 'setting_page.dart';
import 'auth_provider.dart';

class AdminMenu extends StatefulWidget {
  const AdminMenu({super.key});

  @override
  State<AdminMenu> createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu>
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
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: Stack(
        children: [
          // Pixel-art background
          Positioned.fill(
            child: Image.asset(
              'assets/images/prfp.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF5F7FA),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // Scrolling shark + cat grid
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
                  const SizedBox(height: 6),
                  // BrightEd title bar
                  _TitleBar(
                    onAccountTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Welcome card
                  Padding(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi Admin',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
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
                              'assets/images/ghost.png',
                              height: 80,
                              width: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.waving_hand,
                                size: 80,
                                color: Color(0xFF1A73E8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Activities label
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
                  const SizedBox(height: 6),
                  // Menu list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _MenuListItem(
                          imagePath: 'assets/images/admintr.png',
                          label: 'Tools/Resources\nManagement',
                          fallbackIcon: Icons.build_circle_rounded,
                          iconColor: Colors.white,
                          imageSize: 80,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ToolsResources(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        _MenuListItemDouble(
                          imagePath1: 'assets/images/boy.png',
                          imagePath2: 'assets/images/girl.png',
                          label: 'Users\nManagement',
                          fallbackIcon: Icons.people_alt_rounded,
                          iconColor: Colors.white,
                          imageSize1: 80,
                          imageSize2: 80,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserManagement(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        _MenuListItem(
                          imagePath: 'assets/images/star.png',
                          label: 'Report\nSection',
                          fallbackIcon: Icons.bar_chart_rounded,
                          iconColor: Colors.white,
                          imageSize: 80,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminReportSection(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _BottomBackBar(),
                  const SizedBox(height: 66),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final IconData fallbackIcon;
  final Color iconColor;
  final double imageSize;
  final VoidCallback onTap;

  const _MenuListItem({
    required this.imagePath,
    required this.label,
    required this.fallbackIcon,
    required this.iconColor,
    this.imageSize = 40,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                height: imageSize,
                width: imageSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(fallbackIcon, color: Colors.grey, size: 24),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuListItemDouble extends StatelessWidget {
  final String imagePath1;
  final String imagePath2;
  final String label;
  final IconData fallbackIcon;
  final Color iconColor;
  final double imageSize1;
  final double imageSize2;
  final VoidCallback onTap;

  const _MenuListItemDouble({
    required this.imagePath1,
    required this.imagePath2,
    required this.label,
    required this.fallbackIcon,
    required this.iconColor,
    this.imageSize1 = 40,
    this.imageSize2 = 40,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Image.asset(
                imagePath1,
                height: imageSize1,
                width: imageSize1,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(fallbackIcon, color: Colors.grey, size: 24),
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                imagePath2,
                height: imageSize2,
                width: imageSize2,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
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

class _TitleBar extends StatelessWidget {
  final VoidCallback onAccountTap;
  const _TitleBar({required this.onAccountTap});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                  children: [
                    const Text(
                      'BrightEd',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF470047),
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
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _BottomBackBar extends StatelessWidget {
  const _BottomBackBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          const SizedBox(width: 46),
        ],
      ),
    );
  }
}