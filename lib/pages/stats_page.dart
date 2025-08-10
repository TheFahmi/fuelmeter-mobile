import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_bar_chart.dart';
import '../widgets/skeleton.dart';
import '../widgets/bottom_nav.dart';
import 'package:flutter/services.dart';
import '../widgets/toast.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool loading = true;
  List<Map<String, dynamic>> last30 = const [];
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
    final fromDate = DateTime.now().subtract(const Duration(days: 30));
    final res = await supa
        .from('fuel_records')
        .select('date,total_cost,distance_km,quantity')
        .gte('date', fromDate.toIso8601String())
        .order('date');
    final items = (res as List).cast<Map<String, dynamic>>();
    final totals =
        items.map((r) => (r['total_cost'] as num).toDouble()).toList();
    total30 = totals.fold(0.0, (a, b) => a + b);
    totalDistance30 = items.fold<double>(
        0, (sum, r) => sum + ((r['distance_km'] as num?)?.toDouble() ?? 0));
    totalLiters30 = items.fold<double>(
        0, (sum, r) => sum + ((r['quantity'] as num?)?.toDouble() ?? 0));
    costPerKm30 = totalDistance30 > 0 ? total30 / totalDistance30 : 0;
    efficiencyKmPerLiter30 =
        totalLiters30 > 0 ? totalDistance30 / totalLiters30 : 0;
    setState(() {
      last30 = items;
      loading = false;
    });
  }

  Future<void> _exportCsv() async {
    if (last30.isEmpty) return;
    final buffer = StringBuffer();
    buffer
        .writeln('date,fuel_type,quantity,price_per_liter,total_cost,station');
    for (final r in last30) {
      buffer.writeln([
        r['date'] ?? '',
        r['fuel_type'] ?? '',
        r['quantity'] ?? '',
        r['price_per_liter'] ?? '',
        r['total_cost'] ?? '',
        (r['station'] ?? '').toString().replaceAll(',', ' '),
      ].join(','));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      showAppToast(context, 'CSV disalin ke clipboard',
          type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        actions: [
          IconButton(
            onPressed: last30.isEmpty ? null : _exportCsv,
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export CSV (30 hari)',
          )
        ],
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
                SkeletonBox(height: 18, width: 160),
                SizedBox(height: 8),
                SkeletonBox(height: 160, borderRadius: 16),
                SizedBox(height: 8),
                SkeletonBox(height: 72, borderRadius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 18, width: 180),
                SizedBox(height: 8),
                SkeletonBox(height: 220, borderRadius: 16),
              ],
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16,
                    16 + 76 + MediaQuery.of(context).viewPadding.bottom),
                children: [
                  const Text('Ringkasan 30 Hari',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  Glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total: ${currency.format(total30)}'),
                        const SizedBox(height: 12),
                        MiniBarChart(
                          values: last30
                              .map((r) => (r['total_cost'] as num).toDouble())
                              .toList(),
                          height: 180,
                        ),
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
                  Glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rincian (30 hari terakhir)',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ...last30.map((r) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd MMM', 'id_ID').format(
                                          DateTime.tryParse(
                                                  r['date']?.toString() ??
                                                      '') ??
                                              DateTime.now()),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(currency.format(
                                      (r['total_cost'] as num).toDouble())),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_stats',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
