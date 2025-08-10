import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/skeleton.dart';
import '../repositories/price_repository.dart';

class NearbyStationsPage extends StatefulWidget {
  const NearbyStationsPage({super.key});

  @override
  State<NearbyStationsPage> createState() => _NearbyStationsPageState();
}

enum _Brand { pertamina, shell, bp, total, vivo, other }

class _NearbyStationsPageState extends State<NearbyStationsPage> {
  bool loading = true;
  String? error;
  Position? position;
  List<_Poi> pois = const [];

  // Filter
  final List<String> brands = const [
    'Semua',
    'Pertamina',
    'Shell',
    'BP',
    'Total',
    'Vivo'
  ];
  String selectedBrand = 'Semua';
  final List<int> radiusOptions = const [1, 2, 5];
  int radiusKm = 2;

  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.82);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pre-cache logo assets (ignore errors silently)
    for (final path in const [
      'assets/logos/pertamina.png',
      'assets/logos/shell.png',
      'assets/logos/bp.png',
      'assets/logos/total.png',
      'assets/logos/vivo.png',
    ]) {
      // precache after first frame to have context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        precacheImage(AssetImage(path), context).catchError((_) {});
      });
    }
    _init();
  }

  Future<void> _init() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });
      final perm = await Geolocator.checkPermission();
      LocationPermission p = perm;
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.deniedForever ||
          p == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
      final current = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      position = current;
      await _fetchNearby(current.latitude, current.longitude);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _fetchNearby(double lat, double lon) async {
    // Hitung viewbox dari radius (derajat)
    final dLat = radiusKm / 111.0;
    final dLon = radiusKm / (111.0 * math.cos(lat * math.pi / 180.0));
    final left = lon - dLon;
    final right = lon + dLon;
    final top = lat + dLat;
    final bottom = lat - dLat;

    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&amenity=fuel&limit=50&bounded=1&viewbox=$left,$top,$right,$bottom');
    final resp =
        await http.get(uri, headers: {'User-Agent': 'FuelMeter/1.0 (demo)'});
    if (resp.statusCode != 200) throw Exception('Gagal ambil data SPBU');
    final List data = jsonDecode(resp.body) as List;
    final all = data.map((e) {
      final name = (e['display_name'] as String?) ?? 'SPBU';
      final plat = double.tryParse(e['lat']?.toString() ?? '0') ?? 0;
      final plon = double.tryParse(e['lon']?.toString() ?? '0') ?? 0;
      return _Poi(name: name, lat: plat, lon: plon);
    }).toList();

    // Filter brand sederhana berbasis nama
    final b = selectedBrand.toLowerCase();
    if (selectedBrand == 'Semua') {
      pois = all;
    } else if (selectedBrand == 'BP') {
      pois = all.where((p) {
        final n = p.name.toLowerCase();
        return n.contains('bp') || n.contains('bp akr');
      }).toList();
    } else if (selectedBrand == 'Total') {
      pois = all.where((p) => p.name.toLowerCase().contains('total')).toList();
    } else {
      pois = all.where((p) => p.name.toLowerCase().contains(b)).toList();
    }
  }

  Future<void> _refetch() async {
    final pos = position;
    if (pos == null) return;
    setState(() => loading = true);
    try {
      await _fetchNearby(pos.latitude, pos.longitude);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openMaps(_Poi p) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lon}');
    await launchUrl(url, mode: LaunchMode.platformDefault);
  }

  _Brand _brandOf(String name) {
    final n = name.toLowerCase();
    if (n.contains('pertamina')) return _Brand.pertamina;
    if (n.contains('shell')) return _Brand.shell;
    if (n.contains(' bp ') || n.contains('bp akr') || n.startsWith('bp '))
      return _Brand.bp;
    if (n.contains('total')) return _Brand.total;
    if (n.contains('vivo')) return _Brand.vivo;
    return _Brand.other;
  }

  Color _brandColor(_Brand b) {
    switch (b) {
      case _Brand.pertamina:
        return const Color(0xFFE53935); // red
      case _Brand.shell:
        return const Color(0xFFFFC107); // amber
      case _Brand.bp:
        return const Color(0xFF43A047); // green
      case _Brand.total:
        return const Color(0xFF1976D2); // blue
      case _Brand.vivo:
        return const Color(0xFF7E57C2); // purple
      case _Brand.other:
        return Colors.grey;
    }
  }

  Widget _brandAvatar(_Brand b) {
    String? asset;
    switch (b) {
      case _Brand.pertamina:
        asset = 'assets/logos/pertamina.png';
        break;
      case _Brand.shell:
        asset = 'assets/logos/shell.png';
        break;
      case _Brand.bp:
        asset = 'assets/logos/bp.png';
        break;
      case _Brand.total:
        asset = 'assets/logos/total.png';
        break;
      case _Brand.vivo:
        asset = 'assets/logos/vivo.png';
        break;
      case _Brand.other:
        asset = null;
        break;
    }
    if (asset != null) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.local_gas_station, size: 14),
          ),
        ),
      );
    }
    return const CircleAvatar(
        radius: 14, child: Icon(Icons.local_gas_station, size: 14));
  }

  @override
  Widget build(BuildContext context) {
    final pos = position;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPBU Terdekat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Kembali',
        ),
      ),
      body: loading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SkeletonBox(height: 200, borderRadius: 16),
                SizedBox(height: 12),
                SkeletonBox(height: 200, borderRadius: 16),
              ],
            )
          : (error != null)
              ? Center(child: Text('Error: $error'))
              : (pos == null)
                  ? const Center(child: Text('Lokasi tidak tersedia'))
                  : Column(
                      children: [
                        // Filter bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedBrand,
                                  items: brands
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (v) {
                                    selectedBrand = v ?? 'Semua';
                                    _refetch();
                                  },
                                  decoration:
                                      const InputDecoration(labelText: 'Brand'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: radiusKm,
                                  items: radiusOptions
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text('$e km')))
                                      .toList(),
                                  onChanged: (v) {
                                    radiusKm = v ?? 2;
                                    _refetch();
                                  },
                                  decoration: const InputDecoration(
                                      labelText: 'Radius'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter:
                                  LatLng(pos.latitude, pos.longitude),
                              initialZoom: 14,
                            ),
                            mapController: _mapController,
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.fuelmeter',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(pos.latitude, pos.longitude),
                                    width: 36,
                                    height: 36,
                                    child: const Icon(Icons.my_location,
                                        color: Colors.blue),
                                  ),
                                  ...pois.map((p) {
                                    final b = _brandOf(p.name);
                                    return Marker(
                                      point: LatLng(p.lat, p.lon),
                                      width: 36,
                                      height: 36,
                                      child: _brandAvatar(b),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.centerLeft,
                          child: const Text('Daftar terdekat'),
                        ),
                        SizedBox(
                          height: 180,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (i) {
                              _currentIndex = i;
                              final p = pois[i];
                              _mapController.move(LatLng(p.lat, p.lon), 15);
                            },
                            itemCount: pois.length,
                            itemBuilder: (c, i) {
                              final p = pois[i];
                              final d = Geolocator.distanceBetween(pos.latitude,
                                      pos.longitude, p.lat, p.lon) /
                                  1000.0;
                              final b = _brandOf(p.name);
                              final brandName = () {
                                switch (b) {
                                  case _Brand.pertamina:
                                    return 'Pertamina';
                                  case _Brand.shell:
                                    return 'Shell';
                                  case _Brand.bp:
                                    return 'BP';
                                  case _Brand.total:
                                    return 'Total';
                                  case _Brand.vivo:
                                    return 'Vivo';
                                  case _Brand.other:
                                    return 'SPBU';
                                }
                              }();
                              // Ambil contoh harga untuk fuel umum
                              Future<double?> priceFuture =
                                  PriceRepository().fetchPricePerLiter(
                                brand: brandName,
                                fuelType: brandName == 'Shell'
                                    ? 'Shell Super'
                                    : 'Pertalite',
                              );
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: i == 0 ? 16 : 8,
                                    right: i == pois.length - 1 ? 16 : 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withValues(alpha: .95),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: .05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _brandAvatar(b),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              p.name.split(',').first,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                          '${d.toStringAsFixed(2)} km dari lokasi Anda',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: .7))),
                                      const SizedBox(height: 4),
                                      FutureBuilder<double?>(
                                        future: priceFuture,
                                        builder: (context, snap) {
                                          if (snap.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox(
                                                height: 16,
                                                child: SkeletonBox(
                                                    height: 12, width: 120));
                                          }
                                          if (snap.hasData &&
                                              snap.data != null) {
                                            return Text(
                                                'Harga contoh: Rp ${snap.data!.toStringAsFixed(0)}/L');
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              _mapController.move(
                                                  LatLng(p.lat, p.lon), 16);
                                            },
                                            icon: const Icon(Icons.map_outlined,
                                                size: 16),
                                            label: const Text('Lihat di peta'),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed: () => _openMaps(p),
                                            icon: const Icon(
                                                Icons.navigation_outlined,
                                                size: 16),
                                            label: const Text('Navigasi'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
    );
  }
}

class _Poi {
  const _Poi({required this.name, required this.lat, required this.lon});
  final String name;
  final double lat;
  final double lon;
}
