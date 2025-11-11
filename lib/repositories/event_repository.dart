import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/ticket_model.dart';
import 'package:tixcycle/services/firestore_service.dart';
import 'package:tixcycle/models/event_model.dart';

class EventRepository {
  final FirestoreService _firestoreService;
  final String _collectionPath = 'events';

  EventRepository(this._firestoreService);

  Future<List<EventModel>> getFeaturedEvents() async {
    // ambil data event yang ditaroh di carousel (banner gede paling atas)
    try {
      final querySnapshot = await _firestoreService.getQuery(
          collectionPath: _collectionPath,
          whereField: 'isFeatured',
          isEqualTo: true);
      return querySnapshot.docs
          .map((doc) => EventModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print("Error fetching featured events: $e");
      rethrow;
    }
  }

  Future<List<EventModel>> getAllEventsOnce() async {
    // ambil semua data event di awal
    try {
      final docs = await _firestoreService.getCollection(
          collectionPath: _collectionPath);
      return docs.map((doc) => EventModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching all events: $e");
      rethrow;
    }
  }

  Future<({List<EventModel> events, DocumentSnapshot? lastDoc})>
      getPaginatedRecommendedEvents({
    DocumentSnapshot? startAfterDoc,
    int limit = 10,
  }) async {
    try {
      QuerySnapshot snapshot;
      if (startAfterDoc == null) {
        snapshot = await _firestoreService.getPaginatedQuery(
            collectionPath: (_collectionPath), limit: limit, orderBy: 'date');
      } else {
        snapshot = await _firestoreService.getPaginatedQuery(
            collectionPath: _collectionPath,
            limit: limit,
            orderBy: 'date',
            startAfter: startAfterDoc);
      }
      final events =
          snapshot.docs.map((doc) => EventModel.fromSnapshot(doc)).toList();
      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      return (events: events, lastDoc: lastDoc);
    } catch (e) {
      print('Error fetching paginated recommended events: $e');
      rethrow;
    }
  }

  Future<EventModel> getEventById(String eventId) async {
    try {
      final doc = await _firestoreService.getDocument(
          path: '$_collectionPath/$eventId');
      if (doc.exists) {
        return EventModel.fromSnapshot(doc);
      } else {
        throw Exception('Event with ID: $eventId not found');
      }
    } catch (e) {
      print('Error fetching event by ID: $e');
      rethrow;
    }
  }

  Future<List<TicketModel>> getTicketsForEvent(String eventId) async {
    try {
      final ticketDocs = await _firestoreService.getCollection(
        collectionPath: '$_collectionPath/$eventId/tickets',
      );
      return ticketDocs.map((doc) => TicketModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching tickets for event $eventId: $e");
      rethrow;
    }
  }

  Future<void> updateTicketStock({
    required String eventId,
    required String ticketId,
    required int quantity,
  }) async {
    try {
      final ticketPath = '$_collectionPath/$eventId/tickets/$ticketId';
      await _firestoreService.decrementField(
        path: ticketPath,
        field: 'stock',
        decrementBy: quantity,
      );
    } catch (e) {
      print("Error updating ticket stock: $e");
      rethrow;
    }
  }

  Future<void> updateMultipleTicketStocks({
    required String eventId,
    required Map<String, int> ticketQuantities, // Map of ticketId: quantity
  }) async {
    try {
      for (var entry in ticketQuantities.entries) {
        await updateTicketStock(
          eventId: eventId,
          ticketId: entry.key,
          quantity: entry.value,
        );
      }
    } catch (e) {
      print("Error updating multiple ticket stocks: $e");
      rethrow;
    }
  }
}
