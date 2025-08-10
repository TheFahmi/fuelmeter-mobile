import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/bottom_nav.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../repositories/price_repository.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  final dateDisplayController = TextEditingController();

  // SPBU & Fuel Mapping (selaras website)
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

  // Harga default per-lokal (bisa disesuaikan). Jika tidak ada, user bisa edit manual.
  static const Map<String, double> kDefaultPricePerLiter = {
    // Pertamina
    'Pertalite': 10000,
    'Pertamax': 12500,
    'Pertamax Turbo': 15000,
    'Pertamax Green 95': 14000,
    'Dexlite': 13950,
    'Pertamina Dex': 15500,
    'Bio Solar': 6500,
    'Solar': 6500,
    'Premium': 6500,
    // Shell
    'Shell Super': 14000,
    'Shell V-Power': 15500,
    'Shell V-Power Racing': 16500,
    'Shell V-Power Diesel': 16500,
    'Shell V-Power Nitro+': 16000,
    'Shell FuelSave 95': 14500,
    'Shell FuelSave Diesel': 15500,
    // BP
    'BP Ultimate': 15500,
    'BP 92': 12000,
    'BP 95': 14500,
    'BP Diesel': 15000,
    'BP Ultimate Diesel': 16000,
    // Lain-lain (approx)
    'Total Quartz 7000': 14000,
    'Total Excellium': 15000,
    'Total Excellium Diesel': 16000,
    'Vivo Revvo 90': 11500,
    'Vivo Revvo 92': 12500,
    'Vivo Revvo 95': 14500,
    'Vivo Diesel': 15000,
    'Petronas Primax 95': 14500,
    'Petronas Primax 97': 15500,
    'Petronas Diesel Max': 15000,
    'Esso Super': 14000,
    'Esso Diesel': 15000,
    'Mobil Super': 14000,
    'Mobil Diesel': 15000,
    'Caltex Super': 14000,
    'Caltex Diesel': 15000,
    'Agip Super': 14000,
    'Agip Diesel': 15000,
    'Texaco Super': 14000,
    'Texaco Diesel': 15000,
    'Chevron Super': 14000,
    'Chevron Diesel': 15000,
    'Phillips 66': 14000,
    'Phillips Diesel': 15000,
    'Lukoil 95': 14500,
    'Lukoil Diesel': 15000,
    'Gazprom 95': 14500,
    'Gazprom Diesel': 15000,
    'Rosneft 95': 14500,
    'Rosneft Diesel': 15000,
  };

  String? _selectedStation = kStations.first;
  List<String> _fuelOptions = kStationFuelMapping[kStations.first]!;
  String? _selectedFuelType = kStationFuelMapping[kStations.first]!.first;

  // Angka
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final totalController = TextEditingController();
  bool loading = false;
  bool _updating = false;
  bool _autoPriceFromReceipt = true; // ON: jumlah otomatis. OFF: total otomatis

  @override
  void initState() {
    super.initState();
    dateDisplayController.text =
        DateFormat('dd MMM yyyy', 'id_ID').format(selectedDate);
    _attachListeners();
    _applyAutoPrice();
  }

  @override
  void dispose() {
    dateDisplayController.dispose();
    quantityController.dispose();
    priceController.dispose();
    totalController.dispose();
    super.dispose();
  }

  void _applyAutoPrice() {
    if (!_autoPriceFromReceipt) return;
    final fuel = _selectedFuelType;
    // Cari brand dari station pilihan
    String brand = 'Pertamina';
    if ((_selectedStation ?? '').toLowerCase().contains('shell'))
      brand = 'Shell';
    else if ((_selectedStation ?? '').toLowerCase().contains('bp'))
      brand = 'BP';
    else if ((_selectedStation ?? '').toLowerCase().contains('total'))
      brand = 'Total';
    else if ((_selectedStation ?? '').toLowerCase().contains('vivo'))
      brand = 'Vivo';

    Future(() async {
      final repo = PriceRepository();
      final remote = fuel != null
          ? await repo.fetchPricePerLiter(brand: brand, fuelType: fuel)
          : null;
      final local = (fuel != null) ? kDefaultPricePerLiter[fuel] : null;
      final p = remote ?? local;
      if (p != null && mounted) {
        priceController.text = p.toStringAsFixed(0);
        _recalculate();
      }
    });
  }

  void _attachListeners() {
    quantityController.addListener(() {
      if (_updating) return;
      if (!_autoPriceFromReceipt) {
        // mode: total otomatis => perubahan jumlah mempengaruhi total
        _recalculate();
      }
    });
    priceController.addListener(() {
      if (_updating) return;
      // perubahan harga mempengaruhi field otomatis (jumlah saat ON, total saat OFF)
      _recalculate();
    });
    totalController.addListener(() {
      if (_updating) return;
      if (_autoPriceFromReceipt) {
        // mode: jumlah otomatis => perubahan total mempengaruhi jumlah
        _recalculate();
      }
    });
  }

  double _parseDouble(String? v) =>
      double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0;

  void _recalculate() {
    final q = _parseDouble(quantityController.text);
    final p = _parseDouble(priceController.text);
    final t = _parseDouble(totalController.text);

    _updating = true;
    try {
      if (_autoPriceFromReceipt) {
        // ON: jumlah otomatis = total / harga
        if (p > 0) {
          final newQ = t / p;
          if (newQ.isFinite) {
            quantityController.text = newQ.toStringAsFixed(2);
          }
        }
      } else {
        // OFF: total otomatis = harga * jumlah
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
      final quantity = _parseDouble(quantityController.text);
      final price = _parseDouble(priceController.text);
      final total = (quantity * price);
      final dateIso =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
              .toIso8601String();
      await supa.from('fuel_records').insert({
        'date': dateIso,
        'fuel_type': _selectedFuelType ?? 'Pertalite',
        'quantity': quantity,
        'price_per_liter': price,
        'total_cost': total,
        'distance_km': 0,
        'odometer_km': null,
        'station': _selectedStation,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Record tersimpan')));
      context.go('/');
    } catch (e) {
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('Tambah Record'),
      ),
      bottomNavigationBar: const BottomNav(),
      body: Form(
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
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _selectedStation = v;
                        _fuelOptions = kStationFuelMapping[v] ??
                            kStationFuelMapping[kStations.first]!;
                        _selectedFuelType = _fuelOptions.first;
                      });
                      _applyAutoPrice();
                    },
                    decoration: const InputDecoration(labelText: 'SPBU'),
            ),
            const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedFuelType,
                    items: _fuelOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedFuelType = v);
                      _applyAutoPrice();
                    },
                    decoration: const InputDecoration(labelText: 'Jenis BBM'),
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
                      _applyAutoPrice();
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
                    readOnly: false,
                    decoration:
                        const InputDecoration(labelText: 'Harga/Liter (Rp)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: quantityController,
                    readOnly: _autoPriceFromReceipt,
                    decoration: InputDecoration(
                        labelText: _autoPriceFromReceipt
                            ? 'Jumlah (L) (otomatis)'
                            : 'Jumlah (L)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
                    controller: totalController,
                    readOnly: !_autoPriceFromReceipt,
                    decoration: InputDecoration(
                      labelText:
                          _autoPriceFromReceipt ? 'Total' : 'Total (otomatis)',
                      helperText:
                          currency.format(_parseDouble(totalController.text)),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loading ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
