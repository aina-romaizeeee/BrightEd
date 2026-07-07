import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_profile.dart';
import 'setting_page.dart';

const _kPurple = Color(0xFF9B59B6);
const _kGreen = Color(0xFF27AE60);
const _kBlue = Color(0xFF2980B9);
const _kOrange = Color(0xFFE67E22);
const _kDarkPurple = Color(0xFF470047);

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _allUsers = [];
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
    _loadUsers();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _spriteController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getUsers();
      if (!mounted) return;
      setState(() {
        _allUsers = data.cast<Map<String, dynamic>>();
        _filtered = _allUsers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load users: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allUsers
          : _allUsers
          .where((s) =>
      (s['name'] ?? '').toString().toLowerCase().contains(q) ||
          (s['user_id'] ?? '').toString().toLowerCase().contains(q) ||
          (s['email'] ?? '').toString().toLowerCase().contains(q))
          .toList();
      _currentPage = 1;
    });
  }

  List<Map<String, dynamic>> get _paginatedUsers {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end.clamp(0, _filtered.length));
  }

  int get _totalPages => (_filtered.length / _itemsPerPage).ceil();

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'student';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
              const Text('Add User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              Row(
                children: ['student', 'teacher', 'admin'].map((r) {
                  final isSel = role == r;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          r.toUpperCase(),
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: r == 'admin'
                            ? _kPurple
                            : r == 'teacher'
                            ? _kBlue
                            : _kGreen,
                        onSelected: (_) => setLocal(() => role = r),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final password = passCtrl.text;

                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      _snack('Name, email and password are required.');
                      return;
                    }
                    Navigator.pop(ctx);

                    try {
                      await ApiService().adminCreateUser(
                        email: email,
                        password: password,
                        name: name,
                        role: role,
                      );
                      if (mounted) {
                        _snack('User added! ID auto-generated by system.');
                        _loadUsers();
                      }
                    } catch (e) {
                      if (mounted) {
                        _snack('Failed to add user: ${e.toString()}');
                      }
                    }
                  },
                  child: const Text('Add User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Delete ${user['name'] ?? 'this user'} (${user['user_id'] ?? user['id']})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService().deleteUser(user['id'].toString());
      if (mounted) {
        _loadUsers();
        _snack('User deleted successfully');
      }
    } catch (e) {
      if (mounted) _snack('Failed to delete user');
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
                _buildTitleBar(),
                const SizedBox(height: 16),
                // ── BIGGER WHITE TITLE BOX WITH IMAGES INSIDE ──
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
                                'Users',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Management',
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
                          height: 44,
                          width: 44,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                          'assets/images/girl.png',
                          height: 44,
                          width: 44,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by ID or name...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearch();
                          })
                          : null,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _kDarkPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            'Student/Teacher ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(
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
                        GestureDetector(
                          onTap: _showAddUserDialog,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: _kDarkPurple,
                            ),
                          ),
                        ),
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
                      'No users found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      itemCount: _paginatedUsers.length,
                      itemBuilder: (_, i) {
                        final user = _paginatedUsers[i];
                        final userId =
                            user['user_id']?.toString() ??
                                user['id']?.toString() ??
                                '';
                        final name = user['name'] ?? 'Unknown';
                        final date = user['created_at'] != null
                            ? _formatDate(user['created_at'])
                            : '22 May';
                        final role =
                            user['role']?.toString() ?? 'student';

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfile(
                                userId: user['id']?.toString() ?? '',
                                userName: name,
                                userIdNo: userId,
                                role: role,
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(
                                bottom: 6),
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.85),
                              borderRadius:
                              BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                  Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        userId,
                                        style:
                                        const TextStyle(
                                          fontSize: 12,
                                          color: Colors
                                              .black87,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis,
                                      ),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors
                                              .grey.shade500,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _snack('Edit: $userId');
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color:
                                    Colors.amber.shade600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      _confirmDelete(user),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color:
                                    Colors.grey.shade500,
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
                if (_filtered.isNotEmpty && _totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _totalPages.clamp(1, 6),
                            (index) {
                          final page = index + 1;
                          final isSelected = page == _currentPage;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _currentPage = page),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kDarkPurple
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$page',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(vertical: 10),
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

  Widget _buildTitleBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _kDarkPurple.withOpacity(0.2),
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
              onPressed: _loadUsers, child: const Text('Retry')),
        ],
      ),
    );
  }

  String _formatDate(dynamic raw) {
    try {
      final dt = DateTime.parse(raw.toString());
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return raw.toString();
    }
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