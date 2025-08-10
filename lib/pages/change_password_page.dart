import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/toast.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw 'User tidak ditemukan';
      }

      // Verifikasi password lama dengan re-authentication
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: user.email!,
          password: _currentPasswordController.text,
        );
      } catch (e) {
        throw 'Password lama tidak benar';
      }

      // Update password baru
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (!mounted) return;

      showAppToast(
        context,
        'Password berhasil diubah',
        type: ToastType.success,
      );

      // Clear form
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showAppToast(
        context,
        'Gagal mengubah password: ${e.toString()}',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Kata Sandi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.security_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Keamanan Akun',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pastikan password baru Anda kuat dan mudah diingat. Password harus minimal 8 karakter.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Form Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Password
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: !_showCurrentPassword,
                            decoration: InputDecoration(
                              labelText: 'Password Lama',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showCurrentPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showCurrentPassword =
                                        !_showCurrentPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password lama harus diisi';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // New Password
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: !_showNewPassword,
                            decoration: InputDecoration(
                              labelText: 'Password Baru',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showNewPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showNewPassword = !_showNewPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password baru harus diisi';
                              }
                              if (value.length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirm New Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password Baru',
                              border: const OutlineInputBorder(),
                              prefixIcon:
                                  const Icon(Icons.lock_person_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showConfirmPassword =
                                        !_showConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password harus diisi';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Password tidak sama';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _changePassword,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Ubah Password'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Security Tips
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates_outlined,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tips Keamanan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTip(
                              'Gunakan kombinasi huruf besar, kecil, angka, dan simbol'),
                          _buildTip(
                              'Jangan gunakan informasi pribadi yang mudah ditebak'),
                          _buildTip('Ubah password secara berkala'),
                          _buildTip('Jangan bagikan password ke orang lain'),
                        ],
                      ),
                    ),
                  ),

                  // Bottom padding for BottomAppBar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_change_password',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
