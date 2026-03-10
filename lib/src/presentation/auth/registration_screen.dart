import 'package:akshaja_insignia/src/presentation/auth/email_registration_screen.dart';
import 'package:akshaja_insignia/src/presentation/auth/phone_registration_screen.dart';
import 'package:akshaja_insignia/src/presentation/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F1FF), Color(0xFFF2F6FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 14),
                    _TopBrandCard(theme: theme),
                    const SizedBox(height: 14),
                    _ChoicePanel(
                      onEmailTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const EmailRegistrationScreen(),
                          ),
                        );
                      },
                      onPhoneTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PhoneRegistrationScreen(),
                          ),
                        );
                      },
                      onSignInTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
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

class _TopBrandCard extends StatelessWidget {
  const _TopBrandCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4E3DBA), Color(0xFF3A2E9A), Color(0xFF6644D8)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1F1A4A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -46,
            left: -30,
            child: _ShapeBlob(
              width: 180,
              height: 130,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            bottom: 20,
            right: -32,
            child: _ShapeBlob(
              width: 160,
              height: 118,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 34),
                Image.asset('logo.png', width: 84, height: 84),
                const SizedBox(height: 18),
                Text(
                  'Akshaja Insignia',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Get Started',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF3D3099),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your registration method below',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.onEmailTap,
    required this.onPhoneTap,
    required this.onSignInTap,
  });

  final VoidCallback onEmailTap;
  final VoidCallback onPhoneTap;
  final VoidCallback onSignInTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180F164A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Hello!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF3D3099),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ActionButton(
            icon: Icons.email_outlined,
            label: 'Continue with Email Registration',
            onTap: onEmailTap,
            outlined: true,
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.sms_outlined,
            label: 'Continue with Mobile OTP',
            onTap: onPhoneTap,
            outlined: true,
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.login_rounded,
            label: 'Already have an account? Sign In',
            onTap: onSignInTap,
            outlined: false,
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFE1E4F3)),
          const SizedBox(height: 14),
          const Text(
            'Your information is encrypted and protected with Firebase Authentication.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B6B7E)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final buttonColor = const Color(0xFF3D3099);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: outlined ? const Color(0xFFB8B7CC) : Colors.transparent,
            ),
            gradient: outlined
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF5F46E6), Color(0xFF3D3099)],
                  ),
            color: outlined ? Colors.white : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: buttonColor),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: outlined ? const Color(0xFF4B4B63) : Colors.white,
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
