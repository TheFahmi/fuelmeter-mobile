import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Kami'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header dengan logo
          Glass(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_gas_station_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FuelMeter',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aplikasi pencatatan BBM yang cerdas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Deskripsi
          Glass(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang Aplikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FuelMeter adalah aplikasi mobile yang dirancang untuk membantu pengguna melacak dan mengelola pengeluaran BBM dengan mudah dan efisien. '
                    'Dengan fitur-fitur canggih seperti OCR struk, analitik pengeluaran, dan integrasi SPBU terdekat.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fitur Utama
          Glass(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitur Utama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    context,
                    Icons.document_scanner_outlined,
                    'OCR Struk BBM',
                    'Scan dan ekstrak data struk secara otomatis',
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(
                    context,
                    Icons.analytics_outlined,
                    'Analitik Cerdas',
                    'Analisis pengeluaran dan efisiensi BBM',
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(
                    context,
                    Icons.location_on_outlined,
                    'SPBU Terdekat',
                    'Temukan SPBU terdekat dengan harga terkini',
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(
                    context,
                    Icons.workspace_premium_outlined,
                    'Fitur Premium',
                    'Akses fitur lanjutan tanpa batas',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Informasi Teknis
          Glass(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Teknis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem('Versi', '1.0.0'),
                  _buildInfoItem('Platform', 'Flutter Web & Mobile'),
                  _buildInfoItem('Database', 'Supabase'),
                  _buildInfoItem('AI/ML', 'Google ML Kit + LLM'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kontak
          Glass(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kontak & Dukungan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    context,
                    Icons.email_outlined,
                    'Email',
                    'support@fuelmeter.app',
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem(
                    context,
                    Icons.web_outlined,
                    'Website',
                    'https://fuelmeter.app',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Copyright
          Text(
            '© 2025 FuelMeter. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
