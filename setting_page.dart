// start docker
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'login_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
{

  String _selectedLanguage = 'English';
  static const _languages = ['English', 'Malay'];

  final _flags = {
    'notifications': true,
    'updatingProfile': false,
    'changingPassword': false,
    'obscureOld': true,
    'obscureNew': true,
    'obscureConfirm': true,
  };

  late final List<TextEditingController> _profileCtrls;
  late final List<TextEditingController> _passCtrls;

  TextEditingController get _nameCtrl => _profileCtrls[0];
  TextEditingController get _emailCtrl => _profileCtrls[1];
  TextEditingController get _phoneCtrl => _profileCtrls[2];
  TextEditingController get _oldPassCtrl => _passCtrls[0];
  TextEditingController get _newPassCtrl => _passCtrls[1];
  TextEditingController get _confPassCtrl => _passCtrls[2];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _profileCtrls = [
      TextEditingController(text: user?.name ?? ''),
      TextEditingController(text: user?.email ?? ''),
      TextEditingController(),
    ];
    _passCtrls = List.generate(3, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in [..._profileCtrls, ..._passCtrls]) c.dispose();
    super.dispose();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _runAsync(
      String flagKey,
      Future<void> Function() action,
      String successMsg,
      String errorMsg,
      ) async {
    setState(() => _flags[flagKey] = true);
    try {
      await action();
      if (mounted) _snack(successMsg);
    } catch (_) {
      if (mounted) _snack(errorMsg);
    } finally {
      if (mounted) setState(() => _flags[flagKey] = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      return _snack('Name and email are required.');
    }
    await _runAsync(
      'updatingProfile',
          () => ApiService().updateUserProfile({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      }),
      'Profile updated successfully!',
      'Failed to update profile.',
    );
  }

  Future<void> _changePassword() async {
    if ([_oldPassCtrl, _newPassCtrl, _confPassCtrl].any((c) => c.text.isEmpty)) {
      return _snack('Please fill in all password fields.');
    }
    if (_newPassCtrl.text != _confPassCtrl.text) {
      return _snack('New passwords do not match.');
    }
    if (_newPassCtrl.text.length < 8) {
      return _snack('Password must be at least 8 characters.');
    }
    await _runAsync(
      'changingPassword',
          () => ApiService().changePassword(_oldPassCtrl.text, _newPassCtrl.text),
      'Password changed successfully!',
      'Failed to change password. Check your current password.',
    );
    if (mounted) {
      for (final c in _passCtrls) c.clear();
    }
  }

  void _showActivityLog() {
    const entries = [
      _ActivityItem(icon: Icons.login, action: 'Logged in', time: 'Today, 08:32 AM'),
      _ActivityItem(icon: Icons.chat_bubble_outline, action: 'Used AI Chatbot', time: 'Today, 09:10 AM'),
      _ActivityItem(icon: Icons.book_outlined, action: 'Viewed Report Card', time: 'Yesterday, 03:45 PM'),
      _ActivityItem(icon: Icons.handyman_outlined, action: 'Booked a Tool', time: 'Yesterday, 02:00 PM'),
      _ActivityItem(icon: Icons.logout, action: 'Logged out', time: '2 days ago, 05:00 PM'),
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Activity Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(child: ListView(controller: ctrl, children: entries)),
        ]),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

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
                  const SizedBox(height: 16),

                  // ── Setting title ──
                  const Center(
                    child: Text(
                      'Setting',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Languages ──
                  _buildSettingItem(
                    label: 'Languages',
                    trailing: 'Select',
                    icon: Icons.language,
                    onTap: () => _showLanguagePicker(),
                  ),

                  const SizedBox(height: 12),

                  // ── Password & security ──
                  _buildSettingItem(
                    label: 'password & security',
                    trailing: '',
                    icon: Icons.lock_outline,
                    onTap: () => _showPasswordDialog(),
                  ),

                  const SizedBox(height: 12),

                  // ── Activity log ──
                  _buildSettingItem(
                    label: 'activity log',
                    trailing: '',
                    icon: Icons.history,
                    onTap: _showActivityLog,
                  ),

                  const SizedBox(height: 480),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _confirmSignOut,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'log out > ',
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String label,
    required String trailing,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing.isNotEmpty) ...[
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ],
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._languages.map((lang) => ListTile(
              title: Text(lang),
              trailing: _selectedLanguage == lang
                  ? const Icon(Icons.check, color: Color(0xFF470047))
                  : null,
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
                _snack('Language changed to $lang');
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PasswordField(
              controller: _oldPassCtrl,
              label: 'Current Password',
              obscure: _flags['obscureOld']!,
              onToggle: () => setState(
                      () => _flags['obscureOld'] = !_flags['obscureOld']!),
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _newPassCtrl,
              label: 'New Password',
              obscure: _flags['obscureNew']!,
              onToggle: () => setState(
                      () => _flags['obscureNew'] = !_flags['obscureNew']!),
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _confPassCtrl,
              label: 'Confirm Password',
              obscure: _flags['obscureConfirm']!,
              onToggle: () => setState(
                      () => _flags['obscureConfirm'] = !_flags['obscureConfirm']!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _changePassword();
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(obscure
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined),
        onPressed: onToggle,
      ),
    ),
  );
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String action;
  final String time;

  const _ActivityItem(
      {required this.icon, required this.action, required this.time});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
        backgroundColor: const Color(0xFFE8F0FE),
        child: Icon(icon, color: const Color(0xFF1A73E8), size: 20)),
    title: Text(action,
        style:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    subtitle: Text(time,
        style: const TextStyle(fontSize: 12, color: Colors.grey)),
  );
}