import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  final url = (dotenv.maybeGet('SUPABASE_URL')) ??
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  final key = (dotenv.maybeGet('SUPABASE_ANON_KEY')) ??
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  if (url.isEmpty || key.isEmpty) {
    throw Exception(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY (provide via .env or --dart-define)');
  }
  await Supabase.initialize(
    url: url,
    anonKey: key,
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );
}
