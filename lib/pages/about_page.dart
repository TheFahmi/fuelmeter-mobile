import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/toast.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Info Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // App Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.local_gas_station,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Fuel Meter',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aplikasi pencatat konsumsi BBM',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Versi 1.0.11',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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

                // Description
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
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tentang Aplikasi',
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
                        Text(
                          'Fuel Meter adalah aplikasi mobile yang dirancang untuk membantu Anda mencatat, memantau, dan menganalisis konsumsi bahan bakar kendaraan. '
                          'Dengan interface yang intuitif dan fitur-fitur canggih, aplikasi ini memungkinkan Anda untuk mengelola pengeluaran BBM dengan lebih efisien.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.6,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Features
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
                              Icons.featured_play_list_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fitur Utama',
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
                        _buildFeatureItem(
                            context,
                            Icons.add_circle_outline,
                            'Pencatatan BBM',
                            'Catat setiap pengisian dengan detail lengkap'),
                        _buildFeatureItem(
                            context,
                            Icons.analytics_outlined,
                            'Statistik & Analisis',
                            'Lihat tren konsumsi dan efisiensi kendaraan'),
                        _buildFeatureItem(context, Icons.assessment_outlined,
                            'Laporan Detail', 'Export data dalam format CSV'),
                        _buildFeatureItem(
                            context,
                            Icons.local_offer_outlined,
                            'Harga BBM Terkini',
                            'Cek harga BBM dari berbagai SPBU'),
                        _buildFeatureItem(
                            context,
                            Icons.cloud_sync_outlined,
                            'Sinkronisasi Cloud',
                            'Data tersimpan aman di cloud'),
                        _buildFeatureItem(context, Icons.dark_mode_outlined,
                            'Dark Mode', 'Tema gelap untuk kenyamanan mata'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Developer Info
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
                              Icons.person_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Developer',
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
                        _buildInfoRow(context, 'Nama', 'M Fahmi Hassan'),
                        _buildInfoRow(
                            context, 'Email', 'hello.fahmihassan@gmail.com'),
                        _buildInfoRow(context, 'GitHub', 'github.com/TheFahmi'),
                        _buildInfoRow(context, 'Website', 'fahmihassan.dev'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tech Stack
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
                              Icons.code_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Teknologi',
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
                        _buildTechItem(
                            context, 'Flutter', 'Framework UI cross-platform'),
                        _buildTechItem(context, 'Dart', 'Bahasa pemrograman'),
                        _buildTechItem(
                            context, 'Supabase', 'Backend as a Service'),
                        _buildTechItem(context, 'Riverpod', 'State management'),
                        _buildTechItem(
                            context, 'Material Design 3', 'Design system'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Contact & Support
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
                              Icons.support_agent_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Dukungan & Kontak',
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
                        Text(
                          'Jika Anda memiliki pertanyaan, saran, atau menemukan bug, jangan ragu untuk menghubungi kami:',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(const ClipboardData(
                                      text: 'hello.fahmihassan@gmail.com'));
                                  showAppToast(
                                      context, 'Email disalin ke clipboard',
                                      type: ToastType.info);
                                },
                                icon: const Icon(Icons.email_outlined),
                                label: const Text('Copy Email'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => context.go('/faq'),
                                icon: const Icon(Icons.help_outline),
                                label: const Text('Lihat FAQ'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Copyright
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            '© 2024 Fuel Meter',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Made with ❤️ in Indonesia',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
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
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_about',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(BuildContext context, String tech, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: tech,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: ' - $description',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
