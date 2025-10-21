import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/models/ticket_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';
import 'package:get/get.dart';

class DetailEventController extends GetxController{
  final EventRepository _eventRepository;
  DetailEventController(this._eventRepository);

  final event = Rx<EventModel?>(null);
  final tickets = <TicketModel>[].obs;

  var isLoading = false.obs;

  @override
  void onInit(){
    super.onInit();
    final String? eventId = Get.parameters['id'];
    if(eventId !=null){
      fetchEventDetails(eventId);
    } else {
      print("Error: Event ID is null");
      isLoading(false);
    }
  }

  Future<void> fetchEventDetails(String eventId) async{
    try{
      isLoading(true);
      final eventFuture = _eventRepository.getEventById(eventId);
      final ticketsFuture = _eventRepository.getTicketsForEvent(eventId);

      final results = await Future.wait([eventFuture, ticketsFuture]);
      event.value = results[0] as EventModel;
      tickets.assignAll(results[1] as List<TicketModel>);
    } catch(e){
      print("Error fetching event details: $e");
    } finally{
      isLoading(false);
    }
  }
}