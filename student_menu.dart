import 'package:flutter/material.dart';
import 'tools_booking.dart';
import 'report_card.dart';
import 'setting_page.dart';

class StudentMenu extends StatefulWidget {
  const StudentMenu({super.key});

  @override
  State<StudentMenu> createState() => _StudentMenuState();
}

class _StudentMenuState extends State<StudentMenu>
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

                  // ── Animated sprite grid ──
                  _ScrollingSpriteGrid(controller: _spriteController),

                  const SizedBox(height: 8),

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
                              color: Colors.white,
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

                  const SizedBox(height: 20),

                  // ── Greeting card with white box and image inside ──
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi Student y/n',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'What are your',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const Text(
                                  'plans for today?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
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

                  const SizedBox(height: 24),

                  // ── Activities label ──
                  const Center(
                    child: Text(
                      'Activities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Oval menu buttons ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Tools Booking (Blue oval)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ToolsBookingPage()),
                            ),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/admintr.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.menu_book,
                                      size: 40,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Tools',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    'Booking',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Report Card (Pink oval)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ReportCardPage()),
                            ),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB6C1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/star.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.grade,
                                      size: 40,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Report',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    'Card',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 350),

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