import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/records_providers.dart';
import '../widgets/bottom_nav.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton.dart';

class RecordsPage extends ConsumerWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordsPaginationProvider);
    final notifier = ref.read(recordsPaginationProvider.notifier);
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final bool initialLoading = state.items.isEmpty && state.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Fuel Records'),
      ),
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_records',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: initialLoading
          ? ListView(
              padding: EdgeInsets.fromLTRB(12, 12, 12,
                  12 + 76 + MediaQuery.of(context).viewPadding.bottom),
              children: const [
                SkeletonBox(height: 18, width: 160),
                SizedBox(height: 8),
                SkeletonBox(height: 72, borderRadius: 16),
                SizedBox(height: 8),
                SkeletonBox(height: 72, borderRadius: 16),
                SizedBox(height: 8),
                SkeletonBox(height: 72, borderRadius: 16),
                SizedBox(height: 8),
                SkeletonBox(height: 72, borderRadius: 16),
                SizedBox(height: 8),
                SkeletonBox(height: 72, borderRadius: 16),
              ],
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  notifier.loadMore();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: notifier.refresh,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(12, 12, 12,
                      12 + 76 + MediaQuery.of(context).viewPadding.bottom),
                  itemBuilder: (c, i) {
                    if (i >= state.items.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: state.hasMore
                              ? const CircularProgressIndicator()
                              : const Text('Sudah mencapai akhir'),
                        ),
                      );
                    }
                    final r = state.items[i];
                    final date =
                        DateTime.tryParse(r['date'] as String? ?? '') ??
                            DateTime.now();
                    return Glass(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            '${r['fuel_type'] ?? '-'} • ${currency.format((r['total_cost'] as num?)?.toDouble() ?? 0)}'),
                        subtitle: Text(
                            DateFormat('dd MMM yyyy', 'id_ID').format(date)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () =>
                                  context.go('/records/${r['id']}/edit'),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => context.go('/records/${r['id']}'),
                      ),
                    );
                  },
                  separatorBuilder: (c, i) => const SizedBox(height: 8),
                  itemCount: state.items.length + 1,
                ),
              ),
            ),
    );
  }
}
