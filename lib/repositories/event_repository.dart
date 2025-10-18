import 'package:tixcycle/models/ticket_model.dart';
import 'package:tixcycle/services/firestore_service.dart';
import 'package:tixcycle/models/event_model.dart';

class EventRepository {
  final FirestoreService _firestoreService;
  final String _collectionPath = 'events';

  EventRepository(this._firestoreService);
  Future<List<EventModel>> getAllEvents() async {
    try{
      final docs = await _firestoreService.ambilCollection(collectionPath: _collectionPath);
      return docs.map((doc)=> EventModel.fromSnapshot(doc)).toList();

    } catch (e){
      print("Error fetching events: $e");
      rethrow;
    }
  }

  Future<EventModel> getEventById(String eventId)async{
    try{
      final doc = await _firestoreService.ambilSatuDdata(path: '$_collectionPath/$eventId');
      if(doc.exists){
        return EventModel.fromSnapshot(doc);
      } else {
        throw Exception('Event with ID: $eventId not found');
      }
    } catch (e){
      print('Error fetching event by ID: $e');
      rethrow;
    }
  }

  Future<List<TicketModel>> getTicketsForEvent(String eventId) async {
    try{
      final ticketDocs = await _firestoreService.ambilCollection(collectionPath: '$_collectionPath/$eventId/tickets',);
      return ticketDocs.map((doc)=>TicketModel.fromSnapshot(doc)).toList();
    } catch (e){
      print("Error fetching tickets for event $eventId: $e");
      rethrow;
    }
  }
}