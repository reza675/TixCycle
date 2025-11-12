import 'package:cloud_firestore/cloud_firestore.dart';

class TicketValidationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> checkInTicket(String ticketId) async {

    final docRef = _db.collection('purchased_tickets').doc(ticketId);

    try {

      return await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("TIKET TIDAK VALID (Kode tidak ditemukan).");
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final bool isCheckedIn = data['isCheckedIn'] ?? false;

        if (isCheckedIn) {
   
          throw Exception("TIKET SUDAH DIGUNAKAN.");
        }

        transaction.update(docRef, {
          'isCheckedIn': true,
          'checkInTime': FieldValue.serverTimestamp(),
        });
        
        return "Check-in SUKSES:\n${data['categoryName']} (${data['seatNumber']})";
      });
    } on Exception catch (e) {
      rethrow;
    } catch (e) {
      throw Exception("Error: Gagal terhubung ke database.");
    }
  }
}