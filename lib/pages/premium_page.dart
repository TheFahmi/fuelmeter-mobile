import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/mock_payment_service.dart';
import '../widgets/bottom_nav.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool loading = false;
  bool isPremium = false;
  String? subscriptionType;
  DateTime? expiresAt;
  final _payment = MockPaymentService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supa = Supabase.instance.client;
    final prof = await supa
        .from('profiles')
        .select('is_premium,premium_expires_at,subscription_type')
        .single();
    setState(() {
      isPremium = (prof['is_premium'] as bool?) ?? false;
      subscriptionType = prof['subscription_type'] as String?;
      final exp = prof['premium_expires_at'] as String?;
      expiresAt = exp != null ? DateTime.tryParse(exp) : null;
    });
  }

  Future<void> _upgrade(String plan) async {
    setState(() => loading = true);
    try {
      final now = DateTime.now();
      final exp = plan == 'monthly'
          ? DateTime(now.year, now.month + 1, now.day)
          : DateTime(now.year + 1, now.month, now.day);
      final amount = plan == 'monthly' ? 49000 : 490000;

      final paid = await _payment.checkout(plan: plan, amountIdr: amount);
      if (!paid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Pembayaran gagal')));
        return;
      }

      final supa = Supabase.instance.client;
      await supa.from('premium_subscriptions').insert({
        'subscription_type': plan,
        'status': 'active',
        'started_at': now.toIso8601String(),
        'expires_at': exp.toIso8601String(),
        'amount': amount,
        'currency': 'IDR',
      });
      await supa.from('profiles').update({
        'is_premium': true,
        'premium_started_at': now.toIso8601String(),
        'premium_expires_at': exp.toIso8601String(),
        'subscription_type': plan,
      }).eq('id', supa.auth.currentUser!.id);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Premium aktif')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final popped = await Navigator.of(context).maybePop();
            if (!popped && mounted) context.go('/');
          },
          tooltip: 'Kembali',
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      body: loading
          ? ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16,
                  16 + 76 + MediaQuery.of(context).viewPadding.bottom),
              children: const [
                SkeletonBox(height: 140, borderRadius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 120, borderRadius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 72, borderRadius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 72, borderRadius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 140, borderRadius: 16),
              ],
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16,
                  16 + 76 + MediaQuery.of(context).viewPadding.bottom),
              children: [
                Glass(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.workspace_premium,
                          color: Color(0xFFB7791F), size: 48),
                      const SizedBox(height: 8),
                      const Text('FuelMeter Premium',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: .9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Analitik cerdas, limit tanpa batas, pengalaman premium',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/premium/manage'),
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Kelola Subscription'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/premium/compare'),
                        icon: const Icon(Icons.compare_arrows_outlined),
                        label: const Text('Bandingkan Paket'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Ringkasan manfaat
                Glass(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _Feature(
                          icon: Icons.bar_chart_rounded,
                          text:
                              'Grafik & analitik lanjutan (7/30 hari, efisiensi, tren harga)'),
                      SizedBox(height: 8),
                      _Feature(
                          icon: Icons.cloud_done_outlined,
                          text: 'Sinkronisasi multi-perangkat & backup cloud'),
                      SizedBox(height: 8),
                      _Feature(
                          icon: Icons.file_download_outlined,
                          text: 'Ekspor CSV tanpa batas'),
                      SizedBox(height: 8),
                      _Feature(
                          icon: Icons.support_agent_outlined,
                          text:
                              'Prioritas dukungan & update fitur lebih cepat'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (isPremium)
                  Glass(
                    child: ListTile(
                      leading: const Icon(Icons.verified, color: Colors.green),
                      title: const Text('Status: Premium Active'),
                      subtitle: Text(
                        'Plan: ${subscriptionType ?? '-'}  •  Exp: ${expiresAt != null ? DateFormat('dd MMM yyyy', 'id_ID').format(expiresAt!) : '-'}',
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Glass(
                        child: _PlanCard(
                          title: 'Monthly',
                          price: 'Rp 49.000/bulan',
                          features: const [
                            'Semua fitur premium',
                            'Pembayaran bulanan fleksibel',
                          ],
                          highlighted: !isPremium,
                          onTap: loading ? null : () => _upgrade('monthly'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Glass(
                        child: _PlanCard(
                          title: 'Yearly',
                          price: 'Rp 490.000/tahun',
                          badge: 'Best Value',
                          features: const [
                            'Hemat 2 bulan',
                            'Semua fitur premium',
                          ],
                          highlighted: !isPremium,
                          onTap: loading ? null : () => _upgrade('yearly'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // FAQ singkat
                Glass(
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('FAQ',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 8),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: Text('Apakah bisa dibatalkan kapan saja?'),
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                  'Ya, Anda bisa berhenti kapan saja. Akses premium berlanjut hingga tanggal kedaluwarsa.'),
                            )
                          ],
                        ),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: Text('Metode pembayaran?'),
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                  'Demo ini menggunakan pembayaran simulasi.'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_premium',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    this.badge,
    this.onTap,
    this.highlighted = false,
    this.features = const [],
  });

  final String title;
  final String price;
  final String? badge;
  final VoidCallback? onTap;
  final bool highlighted;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFFFD166),
                borderRadius: BorderRadius.circular(999)),
            child: Text(
              badge!,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: onSurface)),
        const SizedBox(height: 4),
        Text(price, style: TextStyle(color: onSurface.withValues(alpha: .8))),
        if (features.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(f,
                            style: TextStyle(
                                color: onSurface.withValues(alpha: .9)))),
                  ],
                ),
              )),
        ],
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onTap,
          child: const Text('Pilih Plan'),
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
