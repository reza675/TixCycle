import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/payment_method_model.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/services/firestore_service.dart';

class PaymentService {


  final FirestoreService _firestoreService;
  PaymentService(this._firestoreService);

  Future<List<PaymentMethodModel>> getPaymentMethods()async{
    await Future.delayed(Duration(milliseconds: 500));
    return [
      PaymentMethodModel(id: 'bca_va', name: 'BCA Virtual Account', logoUrl: 'images/payment/bca.png', category: 'Transfer Bank', paymentInstructions: '1. Buka aplikasi BCA Mobile.\n2. Pilih menu “m-BCA”.\n3. Masukkan kode akses Anda.\n4. Pilih menu “m-Transfer”.\n5. Pilih “BCA Virtual Account”.\n6. Masukkan nomor Virtual Account tujuan.\n7. Periksa detail pembayaran, lalu pilih “OK”.\n8. Masukkan PIN m-BCA untuk menyelesaikan transaksi.'),
      PaymentMethodModel(id: 'mandiri_va', name: 'Mandiri Virtual Account', logoUrl: 'images/payment/mandiri.png', category: 'Transfer Bank', paymentInstructions: '1. Buka aplikasi Livin’ by Mandiri.\n2. Login dengan akun Anda.\n3. Pilih menu “Bayar”.\n4. Pilih “Buat Pembayaran Baru”.\n5. Pilih “Multipayment” atau “Virtual Account”.\n6. Masukkan nomor Virtual Account tujuan.\n7. Periksa nama dan nominal tagihan.\n8. Konfirmasi dan masukkan PIN transaksi.'),
      PaymentMethodModel(id: 'bri_va', name: 'BRI Virtual Account', logoUrl: 'images/payment/bri.png', category: 'Transfer Bank', paymentInstructions: '1. Buka aplikasi BRImo.\n2. Login ke akun Anda.\n3. Pilih menu “Pembayaran”.\n4. Pilih “BRIVA”.\n5. Masukkan nomor Virtual Account tujuan.\n6. Periksa detail pembayaran.\n7. Tekan “Bayar” dan masukkan PIN BRImo.'),
      PaymentMethodModel(id: 'dana', name: 'Dana', logoUrl: 'images/payment/dana.png', category: 'E-Wallet', paymentInstructions: '1. Buka aplikasi DANA.\n2. Pilih menu “Kirim”.\n3. Pilih “Kirim ke Rekening Bank”.\n4. Pilih bank sesuai dengan penyedia (misal BCA / Mandiri / BRI).\n5. Masukkan nomor Virtual Account tujuan.\n6. Masukkan nominal pembayaran.\n7. Konfirmasi dan tekan “Bayar Sekarang”.'),
      PaymentMethodModel(id: 'shopeepay', name: 'ShopeePay', logoUrl: 'images/payment/spay.png', category: 'E-Wallet', paymentInstructions: '1. Buka aplikasi Shopee.\n2. Pastikan saldo ShopeePay mencukupi.\n3. Pilih menu “Pulsa, Tagihan & Tiket”.\n4. Pilih kategori “Transfer Virtual Account”.\n5. Masukkan nomor Virtual Account tujuan.\n6. Konfirmasi detail transaksi dan tekan “Bayar Sekarang”.'),
      PaymentMethodModel(id: 'gopay', name: 'Gopay', logoUrl: 'images/payment/gopay.png', category: 'E-Wallet', paymentInstructions: '1. Buka aplikasi Gojek.\n2. Pilih menu “GoPay”.\n3. Tekan “Bayar” atau “Eksplor GoPay”.\n4. Pilih “Transfer ke Rekening Bank”.\n5. Pilih bank tujuan sesuai VA (misal BCA / Mandiri / BRI).\n6. Masukkan nomor Virtual Account tujuan.\n7. Masukkan nominal dan tekan “Konfirmasi”.\n8. Tekan “Kirim” untuk menyelesaikan transaksi.'),
      PaymentMethodModel(id: 'linkaja', name: 'LinkAja', logoUrl: 'images/payment/linkaja.png', category: 'E-Wallet', paymentInstructions: '1. Buka aplikasi LinkAja.\n2. Pilih menu “Transfer”.\n3. Pilih “Ke Rekening Bank”.\n4. Masukkan nomor Virtual Account tujuan.\n5. Masukkan nominal dan tekan “Konfirmasi”.\n6. Tekan “Kirim” untuk menyelesaikan transaksi.'),
      PaymentMethodModel(id: 'indomaret', name: 'Indomaret', logoUrl: 'images/payment/indomaret.png', category: 'Gerai Retail', paymentInstructions: 'Kunjungi gerai Indomaret terdekat.\n2. Informasikan kepada kasir bahwa Anda ingin membayar “Virtual Account”.\n3. Tunjukkan atau sebutkan nomor Virtual Account tujuan.\n4. Kasir akan memverifikasi data dan nominal pembayaran.\n5. Lakukan pembayaran tunai sesuai jumlah tagihan.\n6. Simpan struk pembayaran sebagai bukti.'),
      PaymentMethodModel(id: 'alfamart', name: 'Alfamart', logoUrl: 'images/payment/alfamart.png', category: 'Gerai Retail', paymentInstructions: '1. Kunjungi gerai Alfamart terdekat.\n2. Sampaikan kepada kasir bahwa Anda ingin membayar “Virtual Account”.\n3. Tunjukkan atau sebutkan nomor Virtual Account tujuan.\n4. Pastikan data dan nominal pembayaran sudah benar.\n5. Bayar sesuai nominal yang ditagihkan.\n6. Simpan struk pembayaran sebagai bukti transaksi.'),
    ];
  }

  Future<TransactionModel> createTransaction(
      TransactionModel transactionData) async {
    final _db = FirebaseFirestore.instance;
    WriteBatch batch = _db.batch();

    try {
      
      final transactionRef = _db.collection('transactions').doc();
      final transactionJson = transactionData.toJson();

      
      final List<Map<String, dynamic>> purchasedItems =
          transactionJson['purchasedItems'] as List<Map<String, dynamic>>;

      if (purchasedItems.isEmpty) {
        throw Exception("Tidak ada tiket untuk dibeli.");
      }

      
      for (var item in purchasedItems) {
        final String ticketId = item['ticketId'];
        final ticketRef = _db.collection('purchased_tickets').doc(ticketId);

        batch.set(ticketRef, {
          'transactionId': transactionRef.id,
          'eventId': transactionData.eventId,
          'userId': transactionData.userId,
          'categoryName': item['categoryName'],
          'price': item['price'],
          'seatNumber': item['seatNumber'],
          'isCheckedIn': false,
          'checkInTime': null,
          'createdAt': transactionData.createdAt,
        });
      }

      batch.set(transactionRef, transactionJson);

      
      await batch.commit();
      return transactionData.copyWith(id: transactionRef.id);
      

    } catch (e) {
      print('Error creating transaction batch: $e');
      rethrow;
    }
  }


}