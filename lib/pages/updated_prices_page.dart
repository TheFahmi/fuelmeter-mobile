import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/price_repository.dart';
import '../widgets/skeleton.dart';

class UpdatedPricesPage extends StatefulWidget {
  const UpdatedPricesPage({super.key});

  @override
  State<UpdatedPricesPage> createState() => _UpdatedPricesPageState();
}

class _UpdatedPricesPageState extends State<UpdatedPricesPage> {
  bool loading = true;
  String brand = 'Semua';
  List<Map<String, dynamic>> rows = const [];
  final brands = const ['Semua', 'Pertamina', 'Shell', 'BP', 'Total', 'Vivo'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final repo = PriceRepository();
    rows =
        brand == 'Semua' ? await repo.listAll() : await repo.listByBrand(brand);
    if (mounted) setState(() => loading = false);
  }

  Future<void> _refreshFromEdge() async {
    try {
      setState(() => loading = true);
      final res =
          await Supabase.instance.client.functions.invoke('update_fuel_prices');
      final ok = res.status == 200;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(ok ? 'Updated: ${res.data}' : 'Gagal: ${res.status}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dt = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updated Prices'),
        actions: [
          IconButton(
              onPressed: _refreshFromEdge, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 40, borderRadius: 8),
                SizedBox(height: 12),
                SkeletonBox(height: 280, borderRadius: 12),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: brand,
                          items: brands
                              .map((b) =>
                                  DropdownMenuItem(value: b, child: Text(b)))
                              .toList(),
                          onChanged: (v) {
                            brand = v ?? 'Semua';
                            _load();
                          },
                          decoration: const InputDecoration(labelText: 'Brand'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: rows.isEmpty
                      ? const Center(child: Text('Belum ada data'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemBuilder: (c, i) {
                            final r = rows[i];
                            final lu = r['last_updated'] as String?;
                            final ts =
                                lu != null ? DateTime.tryParse(lu) : null;
                            return ListTile(
                              title: Text('${r['brand']} • ${r['fuel_type']}'),
                              subtitle: Text(
                                  'Last updated • ${ts != null ? dt.format(ts.toLocal()) : '-'}'),
                              trailing: Text(fmt.format(
                                  (r['price_per_liter'] as num).toDouble())),
                            );
                          },
                          separatorBuilder: (c, i) => const Divider(height: 1),
                          itemCount: rows.length,
                        ),
                ),
              ],
            ),
    );
  }
}
