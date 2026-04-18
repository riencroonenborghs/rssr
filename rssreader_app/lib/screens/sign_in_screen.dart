import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'unread_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (ok) {
        final cookie = await _authService.getSessionCookie();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => UnreadScreen(cookie: cookie!)),
        );
      } else {
        setState(() => _error = 'Invalid email or password.');
      }
    } catch (e) {
      setState(() => _error = 'Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2744), Color(0xFF2D4A8A), Color(0xFF4169B8)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.rss_feed_rounded,
                    size: 64,
                    color: Color(0xFFB8CCEE),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'rssr',
                    style: TextStyle(
                      color: Color(0xFFF0F4FC),
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your RSS reader',
                    style: TextStyle(
                      color: Color(0xFF92AACC),
                      fontSize: 14,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FC),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2744),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined, size: 20),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _signIn(),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline, size: 20),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Enter your password' : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9DEDC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Color(0xFFB3261E),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _loading ? null : _signIn,
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFFF0F4FC),
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
