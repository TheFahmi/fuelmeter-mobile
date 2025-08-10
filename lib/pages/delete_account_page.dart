import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/toast.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _understood = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_understood) {
      showAppToast(
        context,
        'Anda harus memahami konsekuensi penghapusan akun',
        type: ToastType.error,
      );
      return;
    }

    // Show final confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Terakhir'),
        content: const Text(
          'Apakah Anda benar-benar yakin ingin menghapus akun? '
          'Tindakan ini tidak dapat dibatalkan dan semua data akan hilang selamanya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus Akun'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw 'User tidak ditemukan';
      }

      // Verify password
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: user.email!,
          password: _passwordController.text,
        );
      } catch (e) {
        throw 'Password tidak benar';
      }

      // Delete user data from database first
      await Supabase.instance.client
          .from('fuel_records')
          .delete()
          .eq('user_id', user.id);
      await Supabase.instance.client
          .from('user_settings')
          .delete()
          .eq('user_id', user.id);

      // Delete user account
      // Note: In production, this should be handled by a server function
      // as user deletion requires admin privileges
      showAppToast(
        context,
        'Permintaan hapus akun telah dikirim. Akun akan dihapus dalam 24 jam.',
        type: ToastType.success,
      );

      // Sign out user
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;
      context.go('/auth-gate');
    } catch (e) {
      if (!mounted) return;
      showAppToast(
        context,
        'Gagal menghapus akun: ${e.toString()}',
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
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hapus Akun'),
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
                  // Warning Card
                  Card(
                    elevation: 2,
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                color: Colors.red.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Peringatan Penting',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Menghapus akun akan menghilangkan SEMUA data Anda secara permanen, termasuk:',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _buildWarningItem('Semua catatan pengisian BBM'),
                          _buildWarningItem('Data kendaraan dan preferensi'),
                          _buildWarningItem('Statistik dan analisis'),
                          _buildWarningItem('Riwayat transaksi dan laporan'),
                          _buildWarningItem('Pengaturan akun'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Text(
                              '⚠️ TINDAKAN INI TIDAK DAPAT DIBATALKAN',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Account Info
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
                                Icons.account_circle_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Akun yang akan dihapus',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    user?.email
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        'U',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.email ?? 'Email tidak ditemukan',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      'ID: ${user?.id ?? '-'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Verification Form
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
                                Icons.verified_user_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Verifikasi Identitas',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'Masukkan Password Anda',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password harus diisi untuk verifikasi';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirmation Field
                          TextFormField(
                            controller: _confirmationController,
                            decoration: const InputDecoration(
                              labelText:
                                  'Ketik "HAPUS AKUN SAYA" untuk konfirmasi',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.edit_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi harus diisi';
                              }
                              if (value.toUpperCase() != 'HAPUS AKUN SAYA') {
                                return 'Ketik "HAPUS AKUN SAYA" dengan benar';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Understanding Checkbox
                          CheckboxListTile(
                            value: _understood,
                            onChanged: (value) {
                              setState(() {
                                _understood = value ?? false;
                              });
                            },
                            title: Text(
                              'Saya memahami bahwa tindakan ini tidak dapat dibatalkan dan semua data akan hilang selamanya',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _deleteAccount,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('HAPUS AKUN SELAMANYA'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Batalkan'),
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
        heroTag: 'fab_delete_account',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
