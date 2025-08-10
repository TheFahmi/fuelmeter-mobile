import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/toast.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
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
      final map = res;
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
      showAppToast(context, 'Profil tersimpan', type: ToastType.success);
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Gagal simpan: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final dateText = lastServiceDate != null
        ? DateFormat('dd MMM yyyy', 'id_ID').format(lastServiceDate!)
        : 'Belum diatur';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Pribadi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Information Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi Akun',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Email', user?.email ?? '-'),
                        const SizedBox(height: 12),
                        _buildInfoRow('User ID', user?.id ?? '-'),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Bergabung',
                          user?.createdAt != null
                              ? DateFormat('dd MMM yyyy', 'id_ID')
                                  .format(DateTime.parse(user!.createdAt))
                              : '-',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Personal Information Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Data Pribadi',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (loading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          TextField(
                            controller: displayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Tampilan',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Vehicle Information Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi Kendaraan',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (loading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          TextField(
                            controller: vehicleTypeController,
                            decoration: const InputDecoration(
                              labelText: 'Jenis Kendaraan',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: vehicleModelController,
                            decoration: const InputDecoration(
                              labelText: 'Model Kendaraan',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.model_training_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: licensePlateController,
                            decoration: const InputDecoration(
                              labelText: 'Nomor Plat',
                              border: OutlineInputBorder(),
                              prefixIcon:
                                  Icon(Icons.confirmation_number_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Preferences Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Preferensi',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (loading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          TextField(
                            controller: monthlyBudgetController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Budget Bulanan',
                              border: OutlineInputBorder(),
                              prefixIcon:
                                  Icon(Icons.account_balance_wallet_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: currency,
                            decoration: const InputDecoration(
                              labelText: 'Mata Uang',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'IDR', child: Text('IDR (Rupiah)')),
                              DropdownMenuItem(
                                  value: 'USD', child: Text('USD (US Dollar)')),
                              DropdownMenuItem(
                                  value: 'EUR', child: Text('EUR (Euro)')),
                            ],
                            onChanged: (v) =>
                                setState(() => currency = v ?? 'IDR'),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal Servis Terakhir',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: serviceIntervalDaysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Interval Servis (hari)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.schedule_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: saving || loading ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ),

                // Bottom padding for BottomAppBar
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_personal_info',
        onPressed: () => context.go('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
