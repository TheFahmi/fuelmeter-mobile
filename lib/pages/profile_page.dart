import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/skeleton.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  bool saving = false;

  final displayNameController = TextEditingController();
  final vehicleTypeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final licensePlateController = TextEditingController();
  final monthlyBudgetController = TextEditingController();
  String currency = 'IDR';
  DateTime? lastServiceDate;
  final serviceIntervalDaysController = TextEditingController(text: '90');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    vehicleTypeController.dispose();
    vehicleModelController.dispose();
    licensePlateController.dispose();
    monthlyBudgetController.dispose();
    serviceIntervalDaysController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      setState(() => loading = true);
      final supa = Supabase.instance.client;
      final res = await supa.from('user_settings').select().maybeSingle();
      final map = res as Map<String, dynamic>?;
      if (map != null) {
        displayNameController.text = (map['display_name'] ?? '') as String;
        vehicleTypeController.text = (map['vehicle_type'] ?? '') as String;
        vehicleModelController.text = (map['vehicle_model'] ?? '') as String;
        licensePlateController.text = (map['license_plate'] ?? '') as String;
        monthlyBudgetController.text =
            (map['monthly_budget']?.toString() ?? '');
        currency = (map['currency'] ?? 'IDR') as String;
        final lastService = map['last_service_date'] as String?;
        lastServiceDate =
            lastService != null ? DateTime.tryParse(lastService) : null;
        serviceIntervalDaysController.text =
            (map['service_interval_days']?.toString() ?? '90');
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: lastServiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal Servis Terakhir',
    );
    if (picked != null) {
      setState(() => lastServiceDate = picked);
    }
  }

  Future<void> _save() async {
    try {
      setState(() => saving = true);
      final supa = Supabase.instance.client;
      final data = {
        'display_name': displayNameController.text.trim(),
        'vehicle_type': vehicleTypeController.text.trim(),
        'vehicle_model': vehicleModelController.text.trim(),
        'license_plate': licensePlateController.text.trim(),
        'monthly_budget': double.tryParse(monthlyBudgetController.text) ?? 0,
        'currency': currency,
        'last_service_date': lastServiceDate?.toIso8601String(),
        'service_interval_days':
            int.tryParse(serviceIntervalDaysController.text) ?? 90,
      };
      // upsert berdasarkan RLS owner
      await supa.from('user_settings').upsert(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profil tersimpan')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = lastServiceDate != null
        ? DateFormat('dd MMM yyyy', 'id_ID').format(lastServiceDate!)
        : '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      bottomNavigationBar: const BottomNav(),
      body: loading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 120, borderRadius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 260, borderRadius: 16),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Glass(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personal Information',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: displayNameController,
                        decoration:
                            const InputDecoration(labelText: 'Display Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: vehicleTypeController,
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Type'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: vehicleModelController,
                        decoration:
                            const InputDecoration(labelText: 'Vehicle Model'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: licensePlateController,
                        decoration:
                            const InputDecoration(labelText: 'License Plate'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Glass(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preferences',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: monthlyBudgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Monthly Budget'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: currency,
                        items: const [
                          DropdownMenuItem(
                              value: 'IDR', child: Text('IDR (Rupiah)')),
                          DropdownMenuItem(
                              value: 'USD', child: Text('USD (US Dollar)')),
                          DropdownMenuItem(
                              value: 'EUR', child: Text('EUR (Euro)')),
                        ],
                        onChanged: (v) => setState(() => currency = v ?? 'IDR'),
                        decoration:
                            const InputDecoration(labelText: 'Currency'),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Last Service Date'),
                        subtitle: Text(dateText),
                        trailing: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Pilih'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: serviceIntervalDaysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Service Interval (days)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            ),
    );
  }
}
