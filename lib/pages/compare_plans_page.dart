import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';

class ComparePlansPage extends StatelessWidget {
  const ComparePlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = const [
      _RowData('Catatan BBM tak terbatas', free: false, premium: true),
      _RowData('Grafik & analitik lanjutan', free: false, premium: true),
      _RowData('Ekspor CSV', free: false, premium: true),
      _RowData('Sinkronisasi multi-device', free: false, premium: true),
      _RowData('Backup cloud', free: true, premium: true),
      _RowData('Notifikasi pengingat isi BBM', free: false, premium: true),
      _RowData('Tanpa iklan', free: false, premium: true),
      _RowData('Dukungan prioritas', free: false, premium: true),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Perbandingan Paket')),
      bottomNavigationBar: const BottomNav(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: const [
              Expanded(child: SizedBox()),
              Expanded(
                  child: Center(
                      child: Text('Free',
                          style: TextStyle(fontWeight: FontWeight.w700)))),
              Expanded(
                  child: Center(
                      child: Text('Premium',
                          style: TextStyle(fontWeight: FontWeight.w700)))),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((r) => Glass(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Text(r.title)),
                    Expanded(
                        child: Center(
                            child: Icon(
                                r.free ? Icons.check_circle : Icons.cancel,
                                color: r.free ? Colors.green : Colors.grey))),
                    Expanded(
                        child: Center(
                            child: Icon(
                                r.premium ? Icons.check_circle : Icons.cancel,
                                color:
                                    r.premium ? Colors.green : Colors.grey))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RowData {
  const _RowData(this.title, {required this.free, required this.premium});
  final String title;
  final bool free;
  final bool premium;
}
