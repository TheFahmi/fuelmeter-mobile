import 'package:supabase_flutter/supabase_flutter.dart';

class PriceRepository {
  PriceRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  Future<double?> fetchPricePerLiter(
      {required String brand, required String fuelType}) async {
    final res = await _client
        .from('fuel_prices')
        .select('price_per_liter')
        .ilike('brand', brand)
        .ilike('fuel_type', fuelType)
        .order('last_updated', ascending: false)
        .limit(1);
    if (res is List && res.isNotEmpty) {
      final val = (res.first['price_per_liter'] as num?)?.toDouble();
      return val;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> listAll() async {
    final res = await _client
        .from('fuel_prices')
        .select()
        .order('brand')
        .order('fuel_type');
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listByBrand(String brand) async {
    final res = await _client
        .from('fuel_prices')
        .select()
        .ilike('brand', brand)
        .order('fuel_type');
    return (res as List).cast<Map<String, dynamic>>();
  }
}
