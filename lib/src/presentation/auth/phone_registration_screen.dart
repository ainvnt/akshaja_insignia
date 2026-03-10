import 'package:akshaja_insignia/src/services/registration_profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneRegistrationScreen extends StatefulWidget {
  const PhoneRegistrationScreen({super.key});

  @override
  State<PhoneRegistrationScreen> createState() =>
      _PhoneRegistrationScreenState();
}

class _PhoneRegistrationScreenState extends State<PhoneRegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RegistrationProfileService _profileService =
      RegistrationProfileService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _loading = false;
  String? _verificationId;
  int? _forceResendingToken;

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _startPhoneVerification() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      forceResendingToken: _forceResendingToken,
      verificationCompleted: (credential) async {
        final result = await _auth.signInWithCredential(credential);
        final user = result.user;
        if (user != null) {
          await user.updateDisplayName(_displayNameController.text.trim());
          await _persistProfile(
            user,
            isNewUser: result.additionalUserInfo?.isNewUser ?? false,
          );
        }
      },
      verificationFailed: (error) {
        _showMessage(_authErrorMessage(error));
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      },
      codeSent: (verificationId, resendToken) {
        if (!mounted) {
          return;
        }
        setState(() {
          _verificationId = verificationId;
          _forceResendingToken = resendToken;
          _loading = false;
        });
        _showMessage('OTP sent to your mobile number.');
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!mounted) {
          return;
        }
        setState(() {
          _verificationId = verificationId;
          _loading = false;
        });
      },
    );
  }

  Future<void> _verifyOtpAndRegister() async {
    if (_verificationId == null) {
      _showMessage('Request OTP first.');
      return;
    }
    if (_otpController.text.trim().length < 6) {
      _showMessage('Enter a valid 6-digit OTP.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user != null) {
        await user.updateDisplayName(_displayNameController.text.trim());
        await _persistProfile(
          user,
          isNewUser: result.additionalUserInfo?.isNewUser ?? false,
        );
      }
      _showMessage('Phone registration successful.');
    } on FirebaseAuthException catch (error) {
      _showMessage(_authErrorMessage(error));
    } catch (_) {
      _showMessage('Phone registration failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _persistProfile(User user, {required bool isNewUser}) async {
    try {
      await _profileService.saveUserProfile(
        user: user,
        registrationMethod: 'phone',
        isNewUser: isNewUser,
        displayName: _displayNameController.text,
        mobile: _phoneController.text,
      );
    } on FirebaseException catch (error) {
      _showMessage(_profileSaveErrorMessage(error));
    } catch (_) {
      _showMessage('Account created, but profile data could not be saved.');
    }
  }

  String _profileSaveErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Account created, but Firestore denied write. Update Firestore rules to allow users to write their own profile.';
      case 'unavailable':
        return 'Account created, but Firestore is currently unavailable. Check internet and try again.';
      case 'failed-precondition':
        return 'Account created, but Firestore database is not set up yet. Create Firestore in Firebase Console.';
      default:
        return 'Account created, but profile data could not be saved (${error.code}).';
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'operation-not-allowed':
        return 'Phone sign-in is disabled in Firebase. Enable it in Firebase Console > Authentication > Sign-in method.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please try again.';
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return error.message ?? 'Phone registration failed.';
    }
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AuthHeroCard(
                      title: 'Mobile Registration',
                      subtitle:
                          'Verify your number with OTP and complete signup',
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Hello!',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF3D3099),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _AuthInputField(
                              controller: _displayNameController,
                              keyboardType: TextInputType.name,
                              labelText: 'Full Name',
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                final text = (value ?? '').trim();
                                if (text.isEmpty) {
                                  return 'Enter full name';
                                }
                                if (text.length < 2) {
                                  return 'Name is too short';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _AuthInputField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              labelText:
                                  'Mobile Number (E.164, e.g. +919876543210)',
                              prefixIcon: Icons.phone_android_outlined,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Enter mobile number';
                                }
                                if (!text.startsWith('+') || text.length < 11) {
                                  return 'Use country code format, for example +919876543210';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: _loading
                                  ? null
                                  : _startPhoneVerification,
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _verificationId == null
                                          ? 'Send OTP'
                                          : 'Resend OTP',
                                    ),
                            ),
                            const SizedBox(height: 12),
                            _AuthInputField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              labelText: 'OTP',
                              prefixIcon: Icons.password_rounded,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: const Color(0xFF3D3099),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: _loading
                                  ? null
                                  : _verifyOtpAndRegister,
                              child: const Text('Verify OTP and Register'),
                            ),
                          ],
                        ),
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

class _AuthHeroCard extends StatelessWidget {
  const _AuthHeroCard({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 236,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4E3DBA), Color(0xFF3A2E9A), Color(0xFF6644D8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -26,
            child: _Blob(
              width: 120,
              height: 90,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BackPillButton(onTap: onBack),
                const SizedBox(height: 14),
                Image.asset('logo.png', width: 52, height: 52),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
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

class _BackPillButton extends StatelessWidget {
  const _BackPillButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthInputField extends StatelessWidget {
  const _AuthInputField({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: const <String>[],
      enableSuggestions: false,
      autocorrect: false,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        filled: true,
        fillColor: const Color(0xFFF7F8FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD3D6E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD3D6E6)),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.width, required this.height, required this.color});

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
