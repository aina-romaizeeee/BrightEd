import 'package:flutter/material.dart';
import 'api_service.dart';
import 'setting_page.dart';

class ResourcesBooking extends StatefulWidget {
  const ResourcesBooking({super.key});

  @override
  State<ResourcesBooking> createState() => _ResourcesBookingState();
}

class _ResourcesBookingState extends State<ResourcesBooking>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _available = [];
  List<Map<String, dynamic>> _myBookings = [];
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
    _loadData();
  }

  @override
  void dispose() {
    _spriteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getResources();
      if (!mounted) return;
      final all = data.cast<Map<String, dynamic>>();
      setState(() {
        _available = all.where((r) {
          final qty = r['quantity'];
          if (qty == null) return true;
          final qtyNum = qty is int ? qty : int.tryParse(qty.toString()) ?? 0;
          return qtyNum > 0;
        }).toList();
        _myBookings = [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load resources. ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showBookingDialog(Map<String, dynamic> resource) {
    DateTime? selectedDate;
    final timeCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book: ${resource['name'] ?? ''}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today,
                    color: Color(0xFF1A73E8)),
                title: Text(selectedDate == null
                    ? 'Select date'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setLocal(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Time slot (e.g. 09:00 - 11:00)',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null || timeCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select date and time.'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    try {
                      await ApiService().bookResource({
                        'resource_id': resource['id'],
                        'tool_id': resource['id'],
                        'date':
                        '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                        'time_slot': timeCtrl.text.trim(),
                        'notes': noteCtrl.text.trim(),
                        'status': 'pending',
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Resource booking submitted!')),
                        );
                        _loadData();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to book resource.')),
                        );
                      }
                    }
                  },
                  child: const Text('Book'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                                'Resources',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Booking',
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
                          'assets/images/admintr.png',
                          height: 48,
                          width: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.menu_book,
                            size: 48,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Available Resources',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? _buildErrorView()
                      : _available.isEmpty
                      ? const Center(
                    child: Text(
                      'No resources available.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: _loadData,
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _available.length,
                      itemBuilder: (_, i) {
                        final resource = _available[i];
                        return _buildResourceCard(resource);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    final name = resource['name'] ?? 'Resource';
    final imageUrl = resource['image_url']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _showBookingDialog(resource),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                )
                    : _buildPlaceholderImage(),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'BOOK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              'Resource',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
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
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
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