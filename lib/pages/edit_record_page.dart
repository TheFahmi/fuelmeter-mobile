import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton.dart';

class EditRecordPage extends StatefulWidget {
  const EditRecordPage({super.key, required this.id});
  final String id;

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  bool loading = true;

  DateTime selectedDate = DateTime.now();
  final dateDisplayController = TextEditingController();

  static const List<String> kStations = [
    'SPBU Pertamina',
    'Shell',
    'BP AKR',
    'Total Energies',
    'Vivo Energy',
    'SPBU Duta Energy',
    'SPBU Petronas',
    'SPBU Bright Gas',
    'SPBU Primagas',
    'SPBU Esso',
    'SPBU Mobil',
    'SPBU Caltex',
    'SPBU Agip',
    'SPBU Texaco',
    'SPBU Chevron',
    'SPBU ConocoPhillips',
    'SPBU Lukoil',
    'SPBU Gazprom',
    'SPBU Rosneft',
  ];

  static const Map<String, List<String>> kStationFuelMapping = {
    'SPBU Pertamina': [
      'Pertalite',
      'Pertamax',
      'Pertamax Turbo',
      'Pertamax Green 95',
      'Dexlite',
      'Pertamina Dex',
      'Bio Solar',
      'Solar',
      'Premium'
    ],
    'Shell': [
      'Shell Super',
      'Shell V-Power',
      'Shell V-Power Racing',
      'Shell V-Power Diesel',
      'Shell V-Power Nitro+',
      'Shell FuelSave 95',
      'Shell FuelSave Diesel'
    ],
    'BP AKR': [
      'BP Ultimate',
      'BP 92',
      'BP 95',
      'BP Diesel',
      'BP Ultimate Diesel'
    ],
    'Total Energies': [
      'Total Quartz 7000',
      'Total Excellium',
      'Total Excellium Diesel'
    ],
    'Vivo Energy': [
      'Vivo Revvo 90',
      'Vivo Revvo 92',
      'Vivo Revvo 95',
      'Vivo Diesel'
    ],
    'SPBU Duta Energy': ['Pertalite', 'Pertamax', 'Solar'],
    'SPBU Petronas': [
      'Petronas Primax 95',
      'Petronas Primax 97',
      'Petronas Diesel Max'
    ],
    'SPBU Bright Gas': ['Premium', 'Pertalite', 'Solar'],
    'SPBU Primagas': ['Premium', 'Pertalite', 'Solar'],
    'SPBU Esso': ['Esso Super', 'Esso Diesel'],
    'SPBU Mobil': ['Mobil Super', 'Mobil Diesel'],
    'SPBU Caltex': ['Caltex Super', 'Caltex Diesel'],
    'SPBU Agip': ['Agip Super', 'Agip Diesel'],
    'SPBU Texaco': ['Texaco Super', 'Texaco Diesel'],
    'SPBU Chevron': ['Chevron Super', 'Chevron Diesel'],
    'SPBU ConocoPhillips': ['Phillips 66', 'Phillips Diesel'],
    'SPBU Lukoil': ['Lukoil 95', 'Lukoil Diesel'],
    'SPBU Gazprom': ['Gazprom 95', 'Gazprom Diesel'],
    'SPBU Rosneft': ['Rosneft 95', 'Rosneft Diesel'],
  };

  String? _selectedStation = kStations.first;
  List<String> _fuelOptions = kStationFuelMapping[kStations.first]!;
  String? _selectedFuelType = kStationFuelMapping[kStations.first]!.first;

  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final totalController = TextEditingController();

  bool _autoPriceFromReceipt = true; // ON: jumlah otomatis, OFF: total otomatis
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    dateDisplayController.dispose();
    quantityController.dispose();
    priceController.dispose();
    totalController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final supa = Supabase.instance.client;
      final rec = await supa
          .from('fuel_records')
          .select()
          .eq('id', widget.id)
          .maybeSingle();
      if (rec == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record tidak ditemukan')));
        context.pop();
        return;
      }
      final dateStr = rec['date'] as String?;
      selectedDate = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
      dateDisplayController.text =
          DateFormat('dd MMM yyyy', 'id_ID').format(selectedDate);

      _selectedStation = (rec['station'] as String?) ?? _selectedStation;
      _fuelOptions = kStationFuelMapping[_selectedStation!] ?? _fuelOptions;
      _selectedFuelType = (rec['fuel_type'] as String?) ?? _fuelOptions.first;

      final q = (rec['quantity'] as num?)?.toDouble() ?? 0;
      final p = (rec['price_per_liter'] as num?)?.toDouble() ?? 0;
      final t = (rec['total_cost'] as num?)?.toDouble() ?? (q * p);
      quantityController.text = q > 0 ? q.toStringAsFixed(2) : '';
      priceController.text = p > 0 ? p.toStringAsFixed(0) : '';
      totalController.text = t > 0 ? t.toStringAsFixed(0) : '';

      // default: jika total tersedia dan q kosong, asumsikan mode struk (jumlah otomatis)
      _autoPriceFromReceipt = (t > 0 && (q == 0));
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  double _parseDouble(String? v) =>
      double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0;

  void _recalculate() {
    if (_updating) return;
    final q = _parseDouble(quantityController.text);
    final p = _parseDouble(priceController.text);
    final t = _parseDouble(totalController.text);

    _updating = true;
    try {
      if (_autoPriceFromReceipt) {
        if (p > 0) {
          final newQ = t / p;
          if (newQ.isFinite) {
            quantityController.text = newQ.toStringAsFixed(2);
          }
        }
      } else {
        final newT = (q * p);
        if (newT.isFinite) {
          totalController.text = newT.toStringAsFixed(0);
        }
      }
    } finally {
      _updating = false;
    }
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal',
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateDisplayController.text =
            DateFormat('dd MMM yyyy', 'id_ID').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final supa = Supabase.instance.client;
      final q = _parseDouble(quantityController.text);
      final p = _parseDouble(priceController.text);
      final t = (q * p);
      final dateIso =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
              .toIso8601String();
      await supa.from('fuel_records').update({
        'date': dateIso,
        'fuel_type': _selectedFuelType,
        'quantity': q,
        'price_per_liter': p,
        'total_cost': t,
        'station': _selectedStation,
      }).eq('id', widget.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Record diperbarui')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Edit Record'),
      ),
      body: loading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 18, width: 180),
                SizedBox(height: 12),
                SkeletonBox(height: 220, borderRadius: 16),
              ],
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Glass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: dateDisplayController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Tanggal',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: _pickDate,
                            ),
                          ),
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedStation,
                          items: kStations
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedStation = v;
                              _fuelOptions = kStationFuelMapping[v] ??
                                  kStationFuelMapping[kStations.first]!;
                              _selectedFuelType = _fuelOptions.first;
                            });
                            _recalculate();
                          },
                          decoration: const InputDecoration(labelText: 'SPBU'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedFuelType,
                          items: _fuelOptions
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedFuelType = v);
                            _recalculate();
                          },
                          decoration:
                              const InputDecoration(labelText: 'Jenis BBM'),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Harga dari struk (otomatis)'),
                          subtitle: const Text(
                              'ON: Jumlah (L) otomatis • OFF: Total otomatis'),
                          value: _autoPriceFromReceipt,
                          onChanged: (val) {
                            setState(() => _autoPriceFromReceipt = val);
                            _recalculate();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Glass(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                              labelText: 'Harga/Liter (Rp)'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: quantityController,
                          readOnly: _autoPriceFromReceipt,
                          decoration: InputDecoration(
                              labelText: _autoPriceFromReceipt
                                  ? 'Jumlah (L) (otomatis)'
                                  : 'Jumlah (L)'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: totalController,
                          readOnly: !_autoPriceFromReceipt,
                          decoration: InputDecoration(
                            labelText: _autoPriceFromReceipt
                                ? 'Total'
                                : 'Total (otomatis)',
                            helperText: currency
                                .format(_parseDouble(totalController.text)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: loading ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ),
    );
  }
}
