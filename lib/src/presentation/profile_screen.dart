import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  bool _loggingOut = false;
  bool _editing = false;
  bool _saving = false;

  User? get _currentUser => _auth.currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  DocumentReference<Map<String, dynamic>> get _profileRef {
    return _firestore.collection('users').doc(_currentUser!.uid);
  }

  Future<void> _logout() async {
    setState(() {
      _loggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final now = FieldValue.serverTimestamp();
      final trimmedName = _nameController.text.trim();
      final trimmedMobile = _mobileController.text.trim();

      final existing = await _profileRef.get();
      final hasCreatedAt = existing.data()?['createdAt'] != null;

      final payload = <String, Object?>{
        'displayName': trimmedName.isEmpty ? null : trimmedName,
        'mobile': trimmedMobile.isEmpty ? null : trimmedMobile,
        'updatedAt': now,
        if (!hasCreatedAt) 'createdAt': now,
      }..removeWhere((_, value) => value == null);

      await _profileRef.set(payload, SetOptions(merge: true));

      if (_currentUser != null && trimmedName.isNotEmpty) {
        await _currentUser!.updateDisplayName(trimmedName);
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _editing = false;
      });
      _showMessage('Profile updated successfully.');
    } on FirebaseException catch (error) {
      _showMessage(error.message ?? 'Profile update failed.');
    } catch (_) {
      _showMessage('Profile update failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _startEditing(Map<String, dynamic> data) {
    _nameController.text = (data['displayName'] as String? ?? '').trim();
    _mobileController.text = (data['mobile'] as String? ?? '').trim();
    setState(() {
      _editing = true;
    });
  }

  void _cancelEditing(Map<String, dynamic> data) {
    _nameController.text = (data['displayName'] as String? ?? '').trim();
    _mobileController.text = (data['mobile'] as String? ?? '').trim();
    setState(() {
      _editing = false;
    });
  }

  String _formatTimestamp(dynamic value) {
    if (value is! Timestamp) {
      return 'Not available';
    }
    return DateFormat('yyyy-MM-dd hh:mm a').format(value.toDate().toLocal());
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyToClipboard(String value, String label) async {
    if (value.trim().isEmpty || value == 'Not set') {
      _showMessage('$label is not available to copy.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: value));
    _showMessage('$label copied.');
  }

  Future<void> _showChangePasswordDialog() async {
    final user = _currentUser;
    if (user == null) {
      _showMessage('No signed-in user found.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    var newPassword = '';
    var confirmPassword = '';
    var saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final form = formKey.currentState;
              if (form == null || !form.validate()) {
                return;
              }

              setDialogState(() {
                saving = true;
              });

              try {
                await user.updatePassword(newPassword.trim());
                await _profileRef.set(<String, Object?>{
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
                if (!mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                _showMessage('Password changed successfully.');
              } on FirebaseAuthException catch (error) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    saving = false;
                  });
                }
                if (error.code == 'weak-password') {
                  _showMessage(
                    'Password is too weak. Use at least 6 characters.',
                  );
                } else if (error.code == 'requires-recent-login') {
                  _showMessage(
                    'For security, please login again and then change password.',
                  );
                } else {
                  _showMessage(error.message ?? 'Password change failed.');
                }
              } catch (_) {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    saving = false;
                  });
                }
                _showMessage('Password change failed. Please try again.');
              }
            }

            return AlertDialog(
              title: const Text('Change Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                      onChanged: (value) {
                        newPassword = value;
                      },
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Enter new password';
                        }
                        if (text.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                      ),
                      onChanged: (value) {
                        confirmPassword = value;
                      },
                      validator: (value) {
                        if (confirmPassword.trim().isEmpty) {
                          return 'Confirm your password';
                        }
                        if (confirmPassword.trim() != newPassword.trim()) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : submit,
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B6B7E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _copyableInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B6B7E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
          IconButton(
            onPressed: () => _copyToClipboard(value, label),
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: 'Copy $label',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No signed-in user found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _profileRef.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Failed to load profile from database.',
                              ),
                            ),
                          );
                        }

                        final data = snapshot.data?.data();

                        if (data == null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Profile not found in database. Please complete registration.',
                              ),
                            ),
                          );
                        }

                        final displayName =
                            (data['displayName'] as String? ?? '').trim();
                        final email = (data['email'] as String? ?? '').trim();
                        final mobile = (data['mobile'] as String? ?? '').trim();
                        final registrationMethod =
                            (data['registrationMethod'] as String? ?? '')
                                .trim();
                        final uid = (data['uid'] as String? ?? user.uid).trim();

                        final primaryIdentity = displayName.isNotEmpty
                            ? displayName
                            : (email.isNotEmpty ? email : 'User');

                        return Container(
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
                                Icon(
                                  Icons.account_circle_rounded,
                                  size: 64,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  primaryIdentity,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF3D3099),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (!_editing) ...[
                                  const SizedBox(height: 12),
                                  _infoRow(
                                    'Method',
                                    registrationMethod.isEmpty
                                        ? 'Not set'
                                        : registrationMethod,
                                    theme,
                                  ),
                                  _infoRow(
                                    'Name',
                                    displayName.isEmpty
                                        ? 'Not set'
                                        : displayName,
                                    theme,
                                  ),
                                  _infoRow(
                                    'Email',
                                    email.isEmpty ? 'Not set' : email,
                                    theme,
                                  ),
                                  _infoRow(
                                    'Mobile',
                                    mobile.isEmpty ? 'Not set' : mobile,
                                    theme,
                                  ),
                                  _infoRow(
                                    'Last Login',
                                    _formatTimestamp(data['lastLoginAt']),
                                    theme,
                                  ),
                                  _infoRow(
                                    'Created At',
                                    _formatTimestamp(data['createdAt']),
                                    theme,
                                  ),
                                  _infoRow(
                                    'Updated At',
                                    _formatTimestamp(data['updatedAt']),
                                    theme,
                                  ),
                                  _copyableInfoRow(
                                    'User ID',
                                    uid.isEmpty ? 'Not set' : uid,
                                    theme,
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () => _startEditing(data),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Edit Profile'),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: _showChangePasswordDialog,
                                    icon: const Icon(Icons.lock_reset_rounded),
                                    label: const Text('Change Password'),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _mobileController,
                                    keyboardType: TextInputType.phone,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      labelText: 'Mobile Number',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _saving
                                              ? null
                                              : () => _cancelEditing(data),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: _saving
                                              ? null
                                              : _saveProfile,
                                          child: _saving
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Text('Save'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 20),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D3099),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  onPressed: _loggingOut ? null : _logout,
                                  icon: _loggingOut
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.logout_rounded),
                                  label: Text(
                                    _loggingOut ? 'Logging out...' : 'Logout',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
