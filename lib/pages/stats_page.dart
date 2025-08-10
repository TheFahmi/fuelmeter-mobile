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
  List<Map<String, dynamic>> last7 = const [];
  List<Map<String, dynamic>> allRecords = const [];

  // 30 days stats
  double total30 = 0;
  double totalDistance30 = 0;
  double totalLiters30 = 0;
  double costPerKm30 = 0;
  double efficiencyKmPerLiter30 = 0;

  // 7 days stats
  double total7 = 0;
  double totalDistance7 = 0;
  double totalLiters7 = 0;
  double costPerKm7 = 0;
  double efficiencyKmPerLiter7 = 0;

  // All time stats
  double totalAllTime = 0;
  double totalDistanceAllTime = 0;
  double totalLitersAllTime = 0;
  double costPerKmAllTime = 0;
  double efficiencyKmPerLiterAllTime = 0;
  int totalTrips = 0;

  // Monthly breakdown
  Map<String, double> monthlyTotals = {};
  Map<String, double> monthlyLiters = {};
  Map<String, double> monthlyDistance = {};

  // Fuel type breakdown
  Map<String, double> fuelTypeCosts = {};
  Map<String, double> fuelTypeLiters = {};

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

    // Load all records
    final allRes = await supa
        .from('fuel_records')
        .select(
            'date,total_cost,distance_km,quantity,fuel_type,station,price_per_liter')
        .order('date', ascending: false);
    allRecords = (allRes as List).cast<Map<String, dynamic>>();

    final now = DateTime.now();
    final fromDate30 = now.subtract(const Duration(days: 30));
    final fromDate7 = now.subtract(const Duration(days: 7));

    // Filter records for different periods
    last30 = allRecords.where((r) {
      final date =
          DateTime.tryParse(r['date']?.toString() ?? '') ?? DateTime.now();
      return date.isAfter(fromDate30);
    }).toList();

    last7 = allRecords.where((r) {
      final date =
          DateTime.tryParse(r['date']?.toString() ?? '') ?? DateTime.now();
      return date.isAfter(fromDate7);
    }).toList();

    // Calculate 30 days stats
    _calculate30DaysStats();

    // Calculate 7 days stats
    _calculate7DaysStats();

    // Calculate all time stats
    _calculateAllTimeStats();

    // Calculate monthly breakdown
    _calculateMonthlyBreakdown();

    // Calculate fuel type breakdown
    _calculateFuelTypeBreakdown();

    setState(() {
      loading = false;
    });
  }

  void _calculate30DaysStats() {
    total30 = last30.fold<double>(
        0, (sum, r) => sum + ((r['total_cost'] as num?)?.toDouble() ?? 0));
    totalDistance30 = last30.fold<double>(
        0, (sum, r) => sum + ((r['distance_km'] as num?)?.toDouble() ?? 0));
    totalLiters30 = last30.fold<double>(
        0, (sum, r) => sum + ((r['quantity'] as num?)?.toDouble() ?? 0));
    costPerKm30 = totalDistance30 > 0 ? total30 / totalDistance30 : 0;
    efficiencyKmPerLiter30 =
        totalLiters30 > 0 ? totalDistance30 / totalLiters30 : 0;
  }

  void _calculate7DaysStats() {
    total7 = last7.fold<double>(
        0, (sum, r) => sum + ((r['total_cost'] as num?)?.toDouble() ?? 0));
    totalDistance7 = last7.fold<double>(
        0, (sum, r) => sum + ((r['distance_km'] as num?)?.toDouble() ?? 0));
    totalLiters7 = last7.fold<double>(
        0, (sum, r) => sum + ((r['quantity'] as num?)?.toDouble() ?? 0));
    costPerKm7 = totalDistance7 > 0 ? total7 / totalDistance7 : 0;
    efficiencyKmPerLiter7 =
        totalLiters7 > 0 ? totalDistance7 / totalLiters7 : 0;
  }

  void _calculateAllTimeStats() {
    totalAllTime = allRecords.fold<double>(
        0, (sum, r) => sum + ((r['total_cost'] as num?)?.toDouble() ?? 0));
    totalDistanceAllTime = allRecords.fold<double>(
        0, (sum, r) => sum + ((r['distance_km'] as num?)?.toDouble() ?? 0));
    totalLitersAllTime = allRecords.fold<double>(
        0, (sum, r) => sum + ((r['quantity'] as num?)?.toDouble() ?? 0));
    costPerKmAllTime =
        totalDistanceAllTime > 0 ? totalAllTime / totalDistanceAllTime : 0;
    efficiencyKmPerLiterAllTime =
        totalLitersAllTime > 0 ? totalDistanceAllTime / totalLitersAllTime : 0;
    totalTrips = allRecords.length;
  }

  void _calculateMonthlyBreakdown() {
    monthlyTotals = {};
    monthlyLiters = {};
    monthlyDistance = {};

    for (final record in allRecords) {
      final date =
          DateTime.tryParse(record['date']?.toString() ?? '') ?? DateTime.now();
      final monthKey = DateFormat('MMM yyyy', 'id_ID').format(date);

      final cost = (record['total_cost'] as num?)?.toDouble() ?? 0;
      final liters = (record['quantity'] as num?)?.toDouble() ?? 0;
      final distance = (record['distance_km'] as num?)?.toDouble() ?? 0;

      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + cost;
      monthlyLiters[monthKey] = (monthlyLiters[monthKey] ?? 0) + liters;
      monthlyDistance[monthKey] = (monthlyDistance[monthKey] ?? 0) + distance;
    }
  }

  void _calculateFuelTypeBreakdown() {
    fuelTypeCosts = {};
    fuelTypeLiters = {};

    for (final record in allRecords) {
      final fuelType = record['fuel_type']?.toString() ?? 'Unknown';
      final cost = (record['total_cost'] as num?)?.toDouble() ?? 0;
      final liters = (record['quantity'] as num?)?.toDouble() ?? 0;

      fuelTypeCosts[fuelType] = (fuelTypeCosts[fuelType] ?? 0) + cost;
      fuelTypeLiters[fuelType] = (fuelTypeLiters[fuelType] ?? 0) + liters;
    }
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
                  // All Time Overview
                  const Text('Statistik Keseluruhan',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildOverviewCards(),

                  const SizedBox(height: 20),

                  // Period Comparison
                  const Text('Perbandingan Periode',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildPeriodComparison(),

                  const SizedBox(height: 20),

                  // 30 Days Chart
                  const Text('Tren 30 Hari Terakhir',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 12),
                  Glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total: ${currency.format(total30)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text('${last30.length} transaksi',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
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

                  const SizedBox(height: 20),

                  // Fuel Type Breakdown
                  if (fuelTypeCosts.isNotEmpty) ...[
                    const Text('Analisis Jenis BBM',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildFuelTypeBreakdown(),
                    const SizedBox(height: 20),
                  ],

                  // Monthly Breakdown
                  if (monthlyTotals.isNotEmpty) ...[
                    const Text('Breakdown Bulanan',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildMonthlyBreakdown(),
                    const SizedBox(height: 20),
                  ],

                  // Recent Records
                  const Text('Transaksi Terbaru',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 12),
                  _buildRecentRecords(),
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

  Widget _buildOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Glass(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Total Pengeluaran',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(currency.format(totalAllTime),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Glass(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_gas_station,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text('Total Liter',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${totalLitersAllTime.toStringAsFixed(1)} L',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Glass(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.route,
                            size: 20,
                            color: Theme.of(context).colorScheme.tertiary),
                        const SizedBox(width: 8),
                        Text('Total Jarak',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${totalDistanceAllTime.toStringAsFixed(0)} km',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Glass(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt,
                            size: 20,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Total Transaksi',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$totalTrips',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodComparison() {
    return Glass(
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                  child: Text('Periode',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(
                  child: Text('Biaya',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(
                  child: Text('Efisiensi',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(
                  child: Text('Biaya/km',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
          const Divider(height: 20),

          // 7 Days
          Row(
            children: [
              Expanded(
                  child: Text('7 Hari',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant))),
              Expanded(
                  child: Text(currency.format(total7),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                  child: Text(
                      '${efficiencyKmPerLiter7.toStringAsFixed(1)} km/L',
                      textAlign: TextAlign.right)),
              Expanded(
                  child: Text('${currency.format(costPerKm7)}/km',
                      textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 12),

          // 30 Days
          Row(
            children: [
              Expanded(
                  child: Text('30 Hari',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant))),
              Expanded(
                  child: Text(currency.format(total30),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                  child: Text(
                      '${efficiencyKmPerLiter30.toStringAsFixed(1)} km/L',
                      textAlign: TextAlign.right)),
              Expanded(
                  child: Text('${currency.format(costPerKm30)}/km',
                      textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 12),

          // All Time
          Row(
            children: [
              Expanded(
                  child: Text('Semua Waktu',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant))),
              Expanded(
                  child: Text(currency.format(totalAllTime),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                  child: Text(
                      '${efficiencyKmPerLiterAllTime.toStringAsFixed(1)} km/L',
                      textAlign: TextAlign.right)),
              Expanded(
                  child: Text('${currency.format(costPerKmAllTime)}/km',
                      textAlign: TextAlign.right)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuelTypeBreakdown() {
    final sortedFuelTypes = fuelTypeCosts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sortedFuelTypes.map((entry) {
            final fuelType = entry.key;
            final cost = entry.value;
            final liters = fuelTypeLiters[fuelType] ?? 0;
            final percentage =
                totalAllTime > 0 ? (cost / totalAllTime * 100) : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fuelType,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currency.format(cost)),
                      Text('${liters.toStringAsFixed(1)} L'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown() {
    final sortedMonths = monthlyTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...sortedMonths.take(6).map((entry) {
            final month = entry.key;
            final cost = entry.value;
            final liters = monthlyLiters[month] ?? 0;
            final distance = monthlyDistance[month] ?? 0;
            final efficiency = liters > 0 ? distance / liters : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(month,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(currency.format(cost),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Liter',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            Text('${liters.toStringAsFixed(1)} L'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jarak',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            Text('${distance.toStringAsFixed(0)} km'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Efisiensi',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                            Text('${efficiency.toStringAsFixed(1)} km/L'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentRecords() {
    final recentRecords = allRecords.take(10).toList();

    return Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...recentRecords.map((record) {
            final date = DateTime.tryParse(record['date']?.toString() ?? '') ??
                DateTime.now();
            final cost = (record['total_cost'] as num?)?.toDouble() ?? 0;
            final liters = (record['quantity'] as num?)?.toDouble() ?? 0;
            final fuelType = record['fuel_type']?.toString() ?? '-';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('dd MMM yyyy', 'id_ID').format(date),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(fuelType,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(currency.format(cost),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${liters.toStringAsFixed(1)} L',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (allRecords.length > 10) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.go('/records'),
                child: Text('Lihat Semua (${allRecords.length} transaksi)'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
