import 'package:supabase_flutter/supabase_flutter.dart';

class RecordsRepository {
  RecordsRepository(this._client);
  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchPage(
      {required int page, required int pageSize}) async {
    final start = (page - 1) * pageSize;
    final end = start + pageSize - 1;
    final res = await _client
        .from('fuel_records')
        .select()
        .order('date', ascending: false)
        .range(start, end);
    final list = res as List;
    return list.map((e) => (e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final res =
        await _client.from('fuel_records').select().eq('id', id).maybeSingle();
    if (res == null) return null;
    return Map<String, dynamic>.from(res);
  }
}
