import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/skeleton.dart';

class ManagePremiumPage extends StatefulWidget {
  const ManagePremiumPage({super.key});

  @override
  State<ManagePremiumPage> createState() => _ManagePremiumPageState();
}

class _ManagePremiumPageState extends State<ManagePremiumPage> {
  bool loading = true;
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> subs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final supa = Supabase.instance.client;
    final prof = await supa
        .from('profiles')
        .select(
            'is_premium,subscription_type,premium_expires_at,premium_started_at,payment_method,last_payment_at')
        .single();
    final history = await supa
        .from('premium_subscriptions')
        .select()
        .order('started_at', ascending: false)
        .limit(10);
    profile = prof as Map<String, dynamic>;
    subs = (history as List).cast<Map<String, dynamic>>();
    setState(() => loading = false);
  }

  bool get isPremium => (profile?['is_premium'] as bool? ?? false);

  Future<void> _cancelCurrent() async {
    try {
      final supa = Supabase.instance.client;
      await supa.from('profiles').update({
        'is_premium': false,
        'subscription_type': null,
        'premium_expires_at': null,
      });
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription dibatalkan')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal batal: $e')));
    }
  }

  Future<void> _extendMonths(int months) async {
    try {
      setState(() => loading = true);
      final now = DateTime.now();
      final currentExpiryStr = profile?['premium_expires_at'] as String?;
      final currentExpiry =
          currentExpiryStr != null ? DateTime.tryParse(currentExpiryStr) : null;
      final baseDate = (currentExpiry != null && currentExpiry.isAfter(now))
          ? currentExpiry
          : now;
      final newExpiry =
          DateTime(baseDate.year, baseDate.month + months, baseDate.day);
      final startedAt = profile?['premium_started_at'] as String?;

      final supa = Supabase.instance.client;
      await supa.from('profiles').update({
        'is_premium': true,
        'subscription_type': months == 1 ? 'monthly' : 'yearly',
        'premium_expires_at': newExpiry.toIso8601String(),
        'premium_started_at': startedAt ?? now.toIso8601String(),
        'last_payment_at': now.toIso8601String(),
        // optional: simpan metode pembayaran mock
        'payment_method': (months == 1 ? 'monthly_mock' : 'yearly_mock'),
      });
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Diperpanjang ${months == 1 ? '1 bulan' : '1 tahun'}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal perpanjang: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');
    final expiresAtStr = profile?['premium_expires_at'] as String?;
    final expiresAt =
        expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Kelola Premium'),
      ),
      bottomNavigationBar: const BottomNav(),
      body: loading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 120, borderRadius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 220, borderRadius: 16),
              ],
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Glass(
                    child: ListTile(
                      leading: const Icon(Icons.workspace_premium),
                      title: Text(isPremium ? 'Status: Aktif' : 'Status: Free'),
                      subtitle: Text(
                        'Plan: ${profile?['subscription_type'] ?? '-'} • Exp: ${expiresAt != null ? fmt.format(expiresAt) : '-'}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Glass(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Billing',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          _kv('Metode',
                              (profile?['payment_method'] ?? '-') as String),
                          _kv(
                              'Terakhir bayar',
                              profile?['last_payment_at'] != null
                                  ? fmt.format(DateTime.parse(
                                      profile!['last_payment_at']))
                                  : '-'),
                          if (expiresAt != null)
                            _kv('Next billing', fmt.format(expiresAt)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _extendMonths(1),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Perpanjang 1 Bulan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _extendMonths(12),
                          icon: const Icon(Icons.event_available),
                          label: const Text('Perpanjang 1 Tahun'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isPremium)
                    FilledButton.icon(
                      onPressed: _cancelCurrent,
                      icon: const Icon(Icons.cancel),
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
                      label: const Text('Batalkan Subscription'),
                    ),
                  const SizedBox(height: 16),
                  const Text('Riwayat Subscription',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...subs.map((s) => Glass(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${s['subscription_type'] ?? '-'} • ${s['status'] ?? '-'}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${s['started_at'] != null ? fmt.format(DateTime.parse(s['started_at'])) : '-'} → ${s['expires_at'] != null ? fmt.format(DateTime.parse(s['expires_at'])) : '-'}'),
                                ],
                              ),
                            ),
                            Text('Rp ${(s['amount'] ?? 0)}'),
                          ],
                        ),
                      )),
                ],
              ),
            ),
    );
  }

  Widget _kv(String k, String v) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: onSurface.withValues(alpha: .7))),
          Text(v,
              style: TextStyle(fontWeight: FontWeight.w600, color: onSurface)),
        ],
      ),
    );
  }
}
