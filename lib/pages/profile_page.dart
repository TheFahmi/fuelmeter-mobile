import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isPremium = false;
  String _subscriptionType = '';
  DateTime? _premiumExpiresAt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('is_premium, subscription_type, premium_expires_at')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _isPremium = response['is_premium'] ?? false;
            _subscriptionType = response['subscription_type'] ?? '';
            _premiumExpiresAt = response['premium_expires_at'] != null
                ? DateTime.parse(response['premium_expires_at'])
                : null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getPremiumStatusText() {
    if (!_isPremium) return 'FREEMIUM';
    if (_premiumExpiresAt != null) {
      if (_premiumExpiresAt!.isBefore(DateTime.now())) {
        return 'EXPIRED';
      }
      return _subscriptionType.toUpperCase();
    }
    return 'PREMIUM';
  }

  Color _getPremiumStatusColor() {
    if (!_isPremium) return Colors.orange;
    if (_premiumExpiresAt != null &&
        _premiumExpiresAt!.isBefore(DateTime.now())) {
      return Colors.red;
    }
    return Colors.green;
  }

  String _getPremiumStatusDescription() {
    if (!_isPremium) return 'Upgrade ke Premium';
    if (_premiumExpiresAt != null) {
      if (_premiumExpiresAt!.isBefore(DateTime.now())) {
        return 'Premium telah berakhir';
      }
      final daysLeft = _premiumExpiresAt!.difference(DateTime.now()).inDays;
      return 'Berakhir dalam $daysLeft hari';
    }
    return 'Premium aktif';
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Info
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            user?.userMetadata?['full_name'] ?? 'User Name',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            user?.email ?? 'user@example.com',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Subscription Status Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Status Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getPremiumStatusColor(),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isPremium
                                        ? Icons.workspace_premium
                                        : Icons.person,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Status Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Langganan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getPremiumStatusText(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: _getPremiumStatusColor(),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (!_isLoading) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _getPremiumStatusDescription(),
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
                            ],
                          ),
                        ),
                        // Action Button
                        if (!_isLoading) ...[
                          if (!_isPremium ||
                              (_premiumExpiresAt != null &&
                                  _premiumExpiresAt!.isBefore(DateTime.now())))
                            ElevatedButton(
                              onPressed: () => context.go('/premium'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_upward, size: 16),
                                  SizedBox(width: 8),
                                  Text('Upgrade'),
                                ],
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: () => context.go('/premium/manage'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.settings, size: 16),
                                  SizedBox(width: 8),
                                  Text('Kelola'),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Menu Section Header
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Pengaturan Umum',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),

                const SizedBox(height: 16),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Informasi Pribadi',
                  subtitle: 'Edit data profil dan kendaraan',
                  onTap: () => context.go('/personal-info'),
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Ubah Kata Sandi',
                  subtitle: 'Ganti password akun',
                  onTap: () => context.go('/change-password'),
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'FAQ',
                  subtitle: 'Pertanyaan yang sering diajukan',
                  onTap: () => context.go('/faq'),
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Informasi dan versi aplikasi',
                  onTap: () => context.go('/about'),
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Hapus Akun',
                  subtitle: 'Hapus akun secara permanen',
                  onTap: () => context.go('/delete-account'),
                  isDestructive: true,
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        context.go('/auth-gate');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 12),
                        Text(
                          'Keluar dari Aplikasi',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App Version
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'App Version 1.0.11',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
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
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_profile',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
