FuelMeter Mobile (Flutter)

Aplikasi Flutter minimal untuk FuelMeter: login, dashboard, daftar record, tambah record, dan halaman Premium. Terhubung ke Supabase.

Setup

1. Install Flutter 3.22+ dan Dart 3.4+
2. Buat file `.env` di folder ini (salin dari `.env.example`):

SUPABASE_URL=...
SUPABASE_ANON_KEY=...

3. Jalankan perintah:

flutter pub get
flutter run -d chrome # atau emulator/device lain

Fitur

- Auth (email/password)
- Dashboard ringkas (stat singkat + 7-day spend)
- Daftar record BBM (read-only)
- Tambah record BBM
- Halaman Premium (status & CTA upgrade/kelola)

Struktur

- lib/main.dart: entry, router
- lib/supabase.dart: init supabase
- lib/providers/: state (Riverpod)
- lib/pages/: layar aplikasi
- lib/widgets/: komponen UI kecil

Catatan: Endpoint tabel mengikuti skema yang sudah ada di aplikasi web (fuel_records, profiles, premium_subscriptions).




