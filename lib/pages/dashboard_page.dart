import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/mini_bar_chart.dart';
import '../providers/theme_provider.dart';
import '../widgets/bottom_nav.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton.dart';

// Menu overflow untuk merapikan ikon AppBar
enum _DashboardMenu { records, premium, profile, nearby, toggleTheme, logout }

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool loading = true;
  List<Map<String, dynamic>> records = [];
  double totalCost = 0;
  List<double> last7Costs = const [];
  int count30 = 0;
  double total30 = 0;
  double totalDistance30 = 0;
  double totalLiters30 = 0;
  double costPerKm30 = 0;
  double efficiencyKmPerLiter30 = 0;
  final currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final supa = Supabase.instance.client;
    final res = await supa
        .from('fuel_records')
        .select()
        .order('date', ascending: false)
        .limit(5);
    records = (res as List).cast<Map<String, dynamic>>();
    totalCost = records.fold<double>(
        0, (sum, r) => sum + (r['total_cost'] as num).toDouble());
    final reversed = records.reversed.toList();
    last7Costs = [
      for (final r in reversed) (r['total_cost'] as num).toDouble()
    ];

    // Load statistik 30 hari
    final fromDate = DateTime.now().subtract(const Duration(days: 30));
    final res30 = await supa
        .from('fuel_records')
        .select('total_cost,distance_km,quantity')
        .gte('date', fromDate.toIso8601String())
        .order('date');
    final list30 = (res30 as List).cast<Map<String, dynamic>>();
    count30 = list30.length;
    total30 = list30.fold<double>(
        0, (sum, r) => sum + (r['total_cost'] as num).toDouble());
    totalDistance30 = list30.fold<double>(
        0, (sum, r) => sum + ((r['distance_km'] as num?)?.toDouble() ?? 0));
    totalLiters30 = list30.fold<double>(
        0, (sum, r) => sum + ((r['quantity'] as num?)?.toDouble() ?? 0));
    costPerKm30 = totalDistance30 > 0 ? total30 / totalDistance30 : 0;
    efficiencyKmPerLiter30 =
        totalLiters30 > 0 ? totalDistance30 / totalLiters30 : 0;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<_DashboardMenu>(
            tooltip: 'Menu',
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _DashboardMenu.records,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.list_alt_outlined),
                  title: const Text('Records'),
                ),
              ),
              PopupMenuItem(
                value: _DashboardMenu.premium,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: const Text('Premium'),
                  subtitle: const Text('Kelola & bandingkan paket'),
                ),
              ),
              PopupMenuItem(
                value: _DashboardMenu.profile,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profil'),
                ),
              ),
              PopupMenuItem(
                value: _DashboardMenu.nearby,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.local_gas_station_outlined),
                  title: const Text('SPBU Terdekat'),
                ),
              ),
              PopupMenuItem(
                value: _DashboardMenu.toggleTheme,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Toggle tema'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _DashboardMenu.logout,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case _DashboardMenu.records:
                  if (!mounted) return;
                  context.go('/records');
                  break;
                case _DashboardMenu.premium:
                  if (!mounted) return;
                  // Tampilkan submenu sederhana via modal bottom sheet
                  final action = await showModalBottomSheet<String>(
                    context: context,
                    showDragHandle: true,
                    builder: (c) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading:
                                const Icon(Icons.workspace_premium_outlined),
                            title: const Text('Halaman Premium'),
                            onTap: () => Navigator.of(c).pop('/premium'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.settings_outlined),
                            title: const Text('Kelola Subscription'),
                            onTap: () => Navigator.of(c).pop('/premium/manage'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.compare_arrows_outlined),
                            title: const Text('Bandingkan Paket'),
                            onTap: () =>
                                Navigator.of(c).pop('/premium/compare'),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (action != null && mounted) context.go(action);
                  break;
                case _DashboardMenu.profile:
                  if (!mounted) return;
                  context.go('/profile');
                  break;
                case _DashboardMenu.nearby:
                  if (!mounted) return;
                  context.go('/nearby-stations');
                  break;
                case _DashboardMenu.toggleTheme:
                  themeNotifier.toggleLightDark();
                  break;
                case _DashboardMenu.logout:
                  await Supabase.instance.client.auth.signOut();
                  if (!mounted) return;
                  context.go('/login');
                  break;
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
      body: loading
          ? ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16,
                  16 + 76 + MediaQuery.of(context).viewPadding.bottom),
              children: [
                const SkeletonBox(height: 18, width: 120),
                const SizedBox(height: 8),
                const SkeletonBox(
                    height: 160, width: double.infinity, borderRadius: 16),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Expanded(
                      child: SkeletonBox(height: 72, borderRadius: 16),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SkeletonBox(height: 72, borderRadius: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Expanded(
                      child: SkeletonBox(height: 72, borderRadius: 16),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SkeletonBox(height: 72, borderRadius: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SkeletonBox(height: 18, width: 120),
                const SizedBox(height: 8),
                ...List.generate(
                  5,
                  (i) => const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: SkeletonBox(height: 64, borderRadius: 16),
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16,
                    16 + 76 + MediaQuery.of(context).viewPadding.bottom),
                children: [
                  const Text('Ringkasan',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  Glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pengeluaran Terakhir',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Total: ${currency.format(totalCost)}'),
                        const SizedBox(height: 8),
                        MiniBarChart(values: last7Costs),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Glass(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Transaksi (30h)',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text('$count30',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Glass(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total (30h)',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(currency.format(total30),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Glass(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Biaya/km (30h)',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                '${currency.format(costPerKm30)}/km',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Glass(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Efisiensi (km/L)',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                '${efficiencyKmPerLiter30.toStringAsFixed(1)} km/L',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Terbaru',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...records.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Glass(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${r['fuel_type']} • ${currency.format((r['total_cost'] as num).toDouble())}'),
                            subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID')
                                .format(DateTime.parse(r['date']))),
                            onTap: () => context.go('/records/${r['id']}'),
                          ),
                        ),
                      )),
                ],
              ),
            ),
      // FAB di-notch BottomAppBar
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_home',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
