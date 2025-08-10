import 'dart:async';

class MockPaymentService {
  Future<bool> checkout({required String plan, required int amountIdr}) async {
    // Simulasi proses pembayaran 2 detik
    await Future.delayed(const Duration(seconds: 2));
    // Bisa tambahkan random gagal/berhasil; sekarang selalu berhasil
    return true;
  }
}
