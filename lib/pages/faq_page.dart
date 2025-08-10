import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
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
                // Header
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
                              Icons.help_center_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Frequently Asked Questions',
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
                          'Temukan jawaban untuk pertanyaan yang sering ditanyakan tentang aplikasi Fuel Meter.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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

                // General Questions
                _buildSectionTitle(context, 'Umum'),
                const SizedBox(height: 12),

                _buildFaqItem(
                  context,
                  'Apa itu Fuel Meter?',
                  'Fuel Meter adalah aplikasi untuk mencatat dan memantau konsumsi bahan bakar kendaraan Anda. Dengan aplikasi ini, Anda dapat melacak biaya BBM, efisiensi konsumsi, dan statistik kendaraan.',
                ),

                _buildFaqItem(
                  context,
                  'Apakah aplikasi ini gratis?',
                  'Ya, aplikasi Fuel Meter tersedia gratis dengan fitur dasar. Kami juga menyediakan paket premium dengan fitur tambahan seperti analisis mendalam, backup cloud, dan laporan detail.',
                ),

                _buildFaqItem(
                  context,
                  'Bagaimana cara memulai menggunakan aplikasi?',
                  'Daftar akun baru atau masuk dengan akun yang sudah ada, kemudian mulai mencatat pengisian BBM pertama Anda dengan menekan tombol + di halaman utama.',
                ),

                const SizedBox(height: 20),

                // Features Questions
                _buildSectionTitle(context, 'Fitur & Penggunaan'),
                const SizedBox(height: 12),

                _buildFaqItem(
                  context,
                  'Bagaimana cara mencatat pengisian BBM?',
                  'Tekan tombol + (tambah) di bagian bawah aplikasi, kemudian isi informasi seperti jumlah liter, harga per liter, jarak tempuh, dan lokasi SPBU.',
                ),

                _buildFaqItem(
                  context,
                  'Apa itu efisiensi km/L?',
                  'Efisiensi km/L menunjukkan berapa kilometer yang dapat ditempuh dengan 1 liter BBM. Semakin tinggi angkanya, semakin efisien kendaraan Anda.',
                ),

                _buildFaqItem(
                  context,
                  'Bagaimana cara melihat statistik konsumsi?',
                  'Buka halaman "Stats" di menu navigasi bawah untuk melihat grafik konsumsi, total pengeluaran, dan analisis efisiensi kendaraan.',
                ),

                _buildFaqItem(
                  context,
                  'Bisakah saya export data konsumsi?',
                  'Ya, di halaman statistik tersedia fitur export data ke format CSV yang dapat dibuka di Excel atau aplikasi spreadsheet lainnya.',
                ),

                const SizedBox(height: 20),

                // Account & Premium
                _buildSectionTitle(context, 'Akun & Premium'),
                const SizedBox(height: 12),

                _buildFaqItem(
                  context,
                  'Apa keuntungan upgrade ke Premium?',
                  'Dengan Premium, Anda mendapat fitur analisis mendalam, backup otomatis, sinkronisasi multi-device, laporan PDF, dan dukungan prioritas.',
                ),

                _buildFaqItem(
                  context,
                  'Bagaimana cara mengubah password?',
                  'Masuk ke halaman Profile > Ubah Kata Sandi, lalu masukkan password lama dan password baru yang diinginkan.',
                ),

                _buildFaqItem(
                  context,
                  'Bisakah saya menghapus akun?',
                  'Ya, Anda dapat menghapus akun melalui halaman Profile > Hapus Akun. Perhatian: semua data akan terhapus permanen.',
                ),

                const SizedBox(height: 20),

                // Technical Support
                _buildSectionTitle(context, 'Dukungan Teknis'),
                const SizedBox(height: 12),

                _buildFaqItem(
                  context,
                  'Aplikasi tidak bisa sync data?',
                  'Pastikan koneksi internet stabil. Jika masalah berlanjut, coba logout dan login kembali, atau hubungi tim support.',
                ),

                _buildFaqItem(
                  context,
                  'Data saya hilang, bagaimana?',
                  'Data tersimpan di cloud secara otomatis. Pastikan Anda login dengan akun yang benar. Jika masih hilang, hubungi support dengan detail akun Anda.',
                ),

                _buildFaqItem(
                  context,
                  'Bagaimana cara menghubungi support?',
                  'Anda dapat menghubungi kami melalui email: hello.fahmihassan@gmail.com atau melalui halaman Tentang untuk informasi kontak lainnya.',
                ),

                const SizedBox(height: 20),

                // Contact Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.support_agent_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak menemukan jawaban?',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tim support kami siap membantu Anda 24/7',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.go('/about'),
                          icon: const Icon(Icons.contact_support_outlined),
                          label: const Text('Hubungi Support'),
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
        heroTag: 'fab_faq',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
