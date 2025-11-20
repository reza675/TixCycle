import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/models/purchased_ticket_model.dart';
import 'package:tixcycle/models/transaction_model.dart';
import 'package:tixcycle/models/validation_result_model.dart';

class TicketValidationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<ValidationResultModel> checkInTicket(String ticketId) async {

    final ticketRef = _db.collection('purchased_tickets').doc(ticketId);
    

    try {
      return await _db.runTransaction((transaction) async {
        final ticketSnapshot = await transaction.get(ticketRef);

        if (!ticketSnapshot.exists) {
          throw Exception("TIKET TIDAK VALID (Kode tidak ditemukan).");
        }

        final ticketData = ticketSnapshot.data() as Map<String, dynamic>;
        final bool isCheckedIn = ticketData['isCheckedIn'] ?? false;

        if (isCheckedIn) {
          throw Exception("TIKET SUDAH DIGUNAKAN.");
        }

        final String transactionId = ticketData['transactionId'];
        final String eventId = ticketData['eventId'];

        final transactionRef = _db.collection('transactions').doc(transactionId);
        final eventRef = _db.collection('events').doc(eventId);

        final transactionSnapshot = await transaction.get(transactionRef);
        final eventSnapshot = await transaction.get(eventRef);

        if (!transactionSnapshot.exists) {
          throw Exception("Data transaksi induk tidak ditemukan.");
        }
        if (!eventSnapshot.exists) {
          throw Exception("Data event tidak ditemukan.");
        }

        transaction.update(ticketRef, {
          'isCheckedIn': true,
          'checkInTime': FieldValue.serverTimestamp(),
        });

        final ticketModel = PurchasedTicketModel(id: ticketSnapshot.id, transactionId: ticketData['transactionId'], eventId: ticketData['eventId'], userId: ticketData['userId'], categoryName: ticketData['categoryName'], price: (ticketData['price'] as num).toDouble(), seatNumber: ticketData['seatNumber'], isCheckedIn: true, checkInTime: Timestamp.now());
        final eventModel = EventModel.fromSnapshot(eventSnapshot);
        final transactionModel = TransactionModel.fromSnapshot(transactionSnapshot);
        return ValidationResultModel(ticket: ticketModel, transaction: transactionModel, event: eventModel);
      });
    } on Exception catch (e) {
      rethrow;
    } catch (e) {
      print("Error in checkInTicket: $e");
      throw Exception("Error: Gagal terhubung ke database.");
    }
  }
}