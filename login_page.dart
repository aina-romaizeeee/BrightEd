// start docker
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'admin_menu.dart';
import 'teacher_menu.dart';
import 'student_menu.dart';
import 'setting_page.dart';
import 'chatbot_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Flow 2: tap role row → login → dashboard ──
  Future<void> _handleRoleLogin(String role) async {
    setState(() => _selectedRole = role);

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in email and password first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) _navigateByRole(auth.user!.role);
  }

  void _navigateByRole(UserRole role) {
    Widget destination;
    switch (role) {
      case UserRole.admin:
        destination = const AdminMenu();
        break;
      case UserRole.teacher:
        destination = const TeacherMenu();
        break;
      case UserRole.student:
      default:
        destination = const StudentMenu();
        break;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Pixel-art background ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/prfp.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFD6E4F7)),
            ),
          ),

          // ── Foreground content ──
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // ── Header row ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 36),
                          const Column(
                            children: [
                              Text(
                                'BrightEd',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Login to your account',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),

                          // ── Flow 1: settings icon → SettingPage ──
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingPage()),
                            ),
                            child: Image.asset(
                              'assets/images/setting.png',
                              height: 34,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.settings,
                                size: 34,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── Email field ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'email...',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.75),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6)),
                          prefixIcon: Image.asset(
                            'assets/images/mail.png',
                            height: 22,
                            width: 22,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.email_outlined),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter your email'
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Password field ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'password...',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.75),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6)),
                          prefixIcon: Image.asset(
                            'assets/images/lock.png',
                            height: 22,
                            width: 22,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.lock_outline),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Enter your password'
                            : null,
                      ),
                    ),

                    // ── Error banner ──
                    if (auth.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            auth.errorMessage!,
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 12),
                          ),
                        ),
                      ),

                    // ── Forgot password ──
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'FORGOT PASSWORD?',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),

                    // ── WHICH CHARACTER ARE YOU? ──
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'WHICH CHARACTER ARE YOU?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Flow 2: tap role → login → dashboard ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _CharacterRow(
                            imagePath: 'assets/images/character.png',
                            label: 'administration',
                            selected: _selectedRole == 'administration',
                            isLoading: auth.isLoading &&
                                _selectedRole == 'administration',
                            onTap: () => _handleRoleLogin('administration'),
                          ),
                          const SizedBox(height: 18),
                          _CharacterRow(
                            imagePath: 'assets/images/character.png',
                            label: 'teacher',
                            selected: _selectedRole == 'teacher',
                            isLoading:
                            auth.isLoading && _selectedRole == 'teacher',
                            onTap: () => _handleRoleLogin('teacher'),
                          ),
                          const SizedBox(height: 18),
                          _CharacterRow(
                            imagePath: 'assets/images/character.png',
                            label: 'student',
                            selected: _selectedRole == 'student',
                            isLoading:
                            auth.isLoading && _selectedRole == 'student',
                            onTap: () => _handleRoleLogin('student'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 240),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: SizedBox(
                        width: 218,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatbotPage()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "LET'S GET STARTED!!!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Character row widget ──
class _CharacterRow extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool selected;
  final bool isLoading;
  final VoidCallback onTap;

  const _CharacterRow({
    required this.imagePath,
    required this.label,
    required this.selected,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A73E8).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? const Color(0xFF1A73E8) : Colors.black12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.person,
                  size: 32,
                  color: selected ? Colors.white : Colors.black38),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            else if (selected)
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}