import 'package:flutter/material.dart';
import 'api_service.dart';
import 'setting_page.dart';

const _kPurple = Color(0xFF9B59B6);
const _kGreen  = Color(0xFF27AE60);
const _kPink   = Color(0xFFE91E8C);
const _kBlue   = Color(0xFF2980B9);
const _kOrange = Color(0xFFE67E22);
const _kDarkPurple = Color(0xFF6C3483);

class ToolsResources extends StatefulWidget {
  const ToolsResources({super.key});

  @override
  State<ToolsResources> createState() => _ToolsResourcesState();
}

class _ToolsResourcesState extends State<ToolsResources>
    with TickerProviderStateMixin {
  late AnimationController _sharkCtrl;
  late AnimationController _garfieldCtrl;

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  String? _error;

  DateTime get _weekStart {
    final wd = _selectedDate.weekday;
    return _selectedDate.subtract(Duration(days: wd - 1));
  }

  List<DateTime> get _weekDays {
    return List.generate(7, (i) => _weekStart.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    _sharkCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))..repeat();
    _garfieldCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _sharkCtrl.dispose();
    _garfieldCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final bookings = await ApiService().getBookingRequests();
      if (!mounted) return;
      setState(() {
        _bookings = (bookings as List).cast<Map<String, dynamic>>();
        _complaints = [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  List<Map<String, dynamic>> get _filteredBookings {
    return _bookings.where((b) {
      final raw = b['date']?.toString() ?? b['created_at']?.toString() ?? '';
      if (raw.isEmpty) return false;
      try {
        final d = DateTime.parse(raw);
        return d.year == _selectedDate.year &&
            d.month == _selectedDate.month &&
            d.day == _selectedDate.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> _approveBooking(String id) async {
    if (id.isEmpty) { _snack('Invalid booking ID.'); return; }
    try {
      await ApiService().updateBookingRequestStatus(id, 'approved');
      if (mounted) { _snack('Booking approved.'); _loadData(); }
    } catch (e) {
      if (mounted) _snack('Failed to approve: ${e.toString()}');
    }
  }

  Future<void> _rejectBooking(String id) async {
    if (id.isEmpty) { _snack('Invalid booking ID.'); return; }
    try {
      await ApiService().updateBookingRequestStatus(id, 'rejected');
      if (mounted) { _snack('Booking rejected.'); _loadData(); }
    } catch (e) {
      if (mounted) _snack('Failed to reject: ${e.toString()}');
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
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFF0F4FF)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _ScrollingSprites(
                  controller: _sharkCtrl,
                  imagePath: 'assets/images/shark.png',
                  spriteSize: 45,
                  fallbackIcon: Icons.water,
                  fallbackColor: const Color(0xFF1A73E8),
                  rowHeight: 50,
                  count: 8,
                  spacing: 24,
                ),
                _ScrollingSprites(
                  controller: _garfieldCtrl,
                  imagePath: 'assets/images/garfield.png',
                  spriteSize: 32,
                  fallbackIcon: Icons.pets,
                  fallbackColor: Colors.orange,
                  rowHeight: 36,
                  count: 10,
                  spacing: 28,
                ),
                const SizedBox(height: 8),
                _TitleBar(
                  onAccountTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingPage()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? _ErrorRetry(message: _error!, onRetry: _loadData)
                      : _buildBody(),
                ),
                const SizedBox(height: 4),
                const _BottomBackBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final toolRequests = _filteredBookings.where((b) {
      final type = b['tools_resources']?['type']?.toString() ?? '';
      return type == 'tool' && b['status']?.toString() == 'pending';
    }).toList();

    final resourceRequests = _filteredBookings.where((b) {
      final type = b['tools_resources']?['type']?.toString() ?? '';
      return type == 'resource' && b['status']?.toString() == 'pending';
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── WHITE BOX WITH IMAGE INSIDE ──
            Container(
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
                        Text('Tools/Resources',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Text('Management',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/phone.png',
                    height: 48,
                    width: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.phone_enabled,
                      size: 48,
                      color: _kPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _WeeklyDateStrip(
              selectedDate: _selectedDate,
              weekStart: _weekStart,
              weekDays: _weekDays,
              onDateSelected: (d) => setState(() => _selectedDate = d),
              onPreviousWeek: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 7))),
              onNextWeek: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 7))),
            ),
            const SizedBox(height: 18),
            if (toolRequests.isNotEmpty) ...[
              ...toolRequests.map((b) {
                final id = b['id']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _StatusPill(
                    label: 'Tool reserve',
                    status: 'Approve',
                    statusColor: _kGreen,
                    onTap: id.isEmpty ? null : () => _approveBooking(id),
                  ),
                );
              }),
            ] else ...[
              _StatusPill(
                label: 'Tool reserve',
                status: 'Approve',
                statusColor: _kGreen,
                onTap: () => _snack('No pending tool requests for this date.'),
              ),
              const SizedBox(height: 10),
            ],
            if (resourceRequests.isNotEmpty) ...[
              ...resourceRequests.map((b) {
                final id = b['id']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _StatusPill(
                    label: 'Resource reserve',
                    status: 'Disapprove',
                    statusColor: _kPink,
                    onTap: id.isEmpty ? null : () => _rejectBooking(id),
                  ),
                );
              }),
            ] else ...[
              _StatusPill(
                label: 'Resource reserve',
                status: 'Disapprove',
                statusColor: _kPink,
                onTap: () => _snack('No pending resource requests for this date.'),
              ),
              const SizedBox(height: 10),
            ],
            if (_complaints.isNotEmpty) ...[
              ..._complaints.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StatusPill(
                  label: 'Complain',
                  status: 'Not Read',
                  statusColor: _kBlue,
                  onTap: () => _snack('Complaint marked as read.'),
                ),
              )),
            ] else ...[
              _StatusPill(
                label: 'Complain',
                status: 'Not Read',
                statusColor: _kBlue,
                onTap: () => _snack('No complaints for this date.'),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _WeeklyDateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime weekStart;
  final List<DateTime> weekDays;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const _WeeklyDateStrip({
    required this.selectedDate,
    required this.weekStart,
    required this.weekDays,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  static const _monthNames = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December',
  ];
  static const _dayLabels = ['Mo','Tu','We','Th','Fr','Sa','Su'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPurple.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20, color: _kPurple),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onPreviousWeek,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _monthNames[selectedDate.month - 1],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kDarkPurple,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20, color: _kPurple),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onNextWeek,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final date = weekDays[i];
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Column(
                  children: [
                    Text(
                      _dayLabels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? _kPurple : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _kPurple
                            : isToday
                            ? _kPurple.withOpacity(0.2)
                            : Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                        border: isToday && !isSelected
                            ? Border.all(color: _kPurple, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const _StatusPill({
    required this.label,
    required this.status,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: _kDarkPurple,
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: statusColor,
                  alignment: Alignment.center,
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Scrolling Sprites (Forward / Rightward) ──
class _ScrollingSprites extends StatelessWidget {
  final AnimationController controller;
  final String imagePath;
  final double spriteSize;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final double rowHeight;
  final int count;
  final double spacing;
  const _ScrollingSprites({
    required this.controller,
    required this.imagePath,
    required this.spriteSize,
    required this.fallbackIcon,
    required this.fallbackColor,
    required this.rowHeight,
    required this.count,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final step = spriteSize + spacing;
    return SizedBox(
      height: rowHeight,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final totalWidth = count * step;
          final offset = controller.value * totalWidth;

          Widget buildRow() => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(count, (_) => Padding(
              padding: EdgeInsets.only(right: spacing),
              child: Image.asset(
                imagePath,
                height: spriteSize, width: spriteSize, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(fallbackIcon, size: spriteSize, color: fallbackColor),
              ),
            )),
          );

          return Stack(
            children: [
              Positioned(
                left: offset,
                top: 0, bottom: 0,
                child: buildRow(),
              ),
              Positioned(
                left: offset - totalWidth,
                top: 0, bottom: 0,
                child: buildRow(),
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
          color: const Color(0xFF470047).withOpacity(0.18),
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
              onTap: onAccountTap,
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
            child: Image.asset('assets/images/back.png',
                height: 44, width: 44, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.arrow_back, size: 44, color: Colors.black54)),
          ),
          const Expanded(
            child: Center(
              child: Text('back.',
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}