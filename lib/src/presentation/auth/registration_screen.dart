import 'package:akshaja_insignia/src/presentation/auth/email_registration_screen.dart';
import 'package:akshaja_insignia/src/presentation/auth/otp_login_screen.dart';
import 'package:akshaja_insignia/src/presentation/auth/phone_registration_screen.dart';
import 'package:akshaja_insignia/src/presentation/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';

enum _AuthMode { login, register }

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  _AuthMode _selectedMode = _AuthMode.register;

  void _openEmailLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
    );
  }

  void _openOtpLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OtpLoginScreen()),
    );
  }

  void _openEmailRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EmailRegistrationScreen()),
    );
  }

  void _openMobileRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PhoneRegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLogin = _selectedMode == _AuthMode.login;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F0FF),
              Color(0xFFF5F7FF),
              Color(0xFFFFFCF8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroPanel(isLogin: isLogin),
                    const SizedBox(height: 16),
                    _ModeSelector(
                      selectedMode: _selectedMode,
                      onModeChanged: (mode) {
                        setState(() {
                          _selectedMode = mode;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _OptionPanel(
                      mode: _selectedMode,
                      onEmailLoginTap: _openEmailLogin,
                      onOtpLoginTap: _openOtpLogin,
                      onEmailRegisterTap: _openEmailRegister,
                      onMobileRegisterTap: _openMobileRegister,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE8E3F2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1ECFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF4A37A8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Secure authentication with separate flows for email, OTP, and registration.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5D5971),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Copyright (c) Ainvnt. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B6B7E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.isLogin});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = isLogin ? 'Welcome back' : 'Create your access';
    final subtitle = isLogin
        ? 'Choose email or OTP sign in to enter Akshaja Insignia.'
        : 'Register with email or mobile and set up your resident access.';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF24125F), Color(0xFF4A2DBA), Color(0xFFEE6C4D)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x221A0F4D),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -38,
            right: -18,
            child: _ShapeBlob(
              width: 130,
              height: 130,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -30,
            child: _ShapeBlob(
              width: 170,
              height: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('logo.png'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Akshaja Insignia',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Resident access hub',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 0.98,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroChip(
                    icon: Icons.alternate_email_rounded,
                    label: isLogin ? 'Email Login' : 'Email Register',
                  ),
                  _HeroChip(
                    icon: Icons.sms_outlined,
                    label: isLogin ? 'OTP Login' : 'Mobile Register',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.onModeChanged,
  });

  final _AuthMode selectedMode;
  final ValueChanged<_AuthMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE4DDF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12101842),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModePill(
              label: 'Register',
              active: selectedMode == _AuthMode.register,
              onTap: () => onModeChanged(_AuthMode.register),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModePill(
              label: 'Login',
              active: selectedMode == _AuthMode.login,
              onTap: () => onModeChanged(_AuthMode.login),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF5F46E6), Color(0xFF2B1F7E)],
                  )
                : null,
            color: active ? null : const Color(0xFFF6F3FB),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF554E69),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionPanel extends StatelessWidget {
  const _OptionPanel({
    required this.mode,
    required this.onEmailLoginTap,
    required this.onOtpLoginTap,
    required this.onEmailRegisterTap,
    required this.onMobileRegisterTap,
  });

  final _AuthMode mode;
  final VoidCallback onEmailLoginTap;
  final VoidCallback onOtpLoginTap;
  final VoidCallback onEmailRegisterTap;
  final VoidCallback onMobileRegisterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLogin = mode == _AuthMode.login;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160F164A),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLogin ? 'Choose how you want to log in' : 'Choose how you want to register',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF2F2845),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLogin
                ? 'Use your existing account with email, or continue with OTP when available.'
                : 'Pick your registration method and continue to the detailed form.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6A637A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          if (isLogin) ...[
            _OptionCard(
              title: 'Login with email',
              subtitle: 'Use your email and password to access your account.',
              icon: Icons.alternate_email_rounded,
              accent: const Color(0xFF4F46E5),
              softColor: const Color(0xFFEEEAFE),
              onTap: onEmailLoginTap,
            ),
            const SizedBox(height: 12),
            _OptionCard(
              title: 'Login with OTP',
              subtitle: 'Sign in with a one-time password sent to your mobile.',
              icon: Icons.sms_rounded,
              accent: const Color(0xFFEF6C3E),
              softColor: const Color(0xFFFFEEE5),
              onTap: onOtpLoginTap,
            ),
          ] else ...[
            _OptionCard(
              title: 'Register with email',
              subtitle: 'Create a new account using email and password.',
              icon: Icons.mark_email_unread_outlined,
              accent: const Color(0xFF4F46E5),
              softColor: const Color(0xFFEEEAFE),
              onTap: onEmailRegisterTap,
            ),
            const SizedBox(height: 12),
            _OptionCard(
              title: 'Register with mobile',
              subtitle: 'Verify your number and complete registration with OTP.',
              icon: Icons.phone_android_rounded,
              accent: const Color(0xFF0E9F6E),
              softColor: const Color(0xFFE5F8F0),
              onTap: onMobileRegisterTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color softColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8E3F2)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFFCFBFF)],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: softColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2F2845),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6A637A),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShapeBlob extends StatelessWidget {
  const _ShapeBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
