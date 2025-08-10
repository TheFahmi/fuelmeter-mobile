import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/records_providers.dart';
import '../theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../widgets/skeleton.dart';

class RecordDetailPage extends ConsumerWidget {
  const RecordDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recordDetailProvider(id));
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Detail Record'),
      ),
      body: async.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SkeletonBox(height: 18, width: 180),
            SizedBox(height: 12),
            SkeletonBox(height: 120, width: double.infinity, borderRadius: 16),
          ],
        ),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (r) {
          if (r == null) {
            return const Center(child: Text('Record tidak ditemukan'));
          }
          final date =
              DateTime.tryParse(r['date'] as String? ?? '') ?? DateTime.now();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Glass(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _kv(context, 'Jenis BBM',
                        (r['fuel_type'] ?? '-') as String),
                    _kv(context, 'Jumlah (L)', (r['quantity'] ?? 0).toString()),
                    _kv(
                        context,
                        'Harga/L',
                        currency.format(
                            (r['price_per_liter'] as num?)?.toDouble() ?? 0)),
                    _kv(
                        context,
                        'Total',
                        currency.format(
                            (r['total_cost'] as num?)?.toDouble() ?? 0)),
                    _kv(
                        context,
                        'Biaya/km',
                        currency.format(
                          _calculateCostPerKm(
                            (r['total_cost'] as num?)?.toDouble() ?? 0,
                            (r['distance_km'] as num?)?.toDouble() ?? 0,
                          ),
                        )),
                    _kv(context, 'Jarak (km)',
                        (r['distance_km'] ?? 0).toString()),
                    _kv(context, 'Odometer',
                        (r['odometer_km'] ?? '-').toString()),
                    _kv(context, 'SPBU/Tempat',
                        (r['station'] ?? '-') as String),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateCostPerKm(double totalCost, double distanceKm) {
    if (distanceKm <= 0) return 0;
    return totalCost / distanceKm;
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              k,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
