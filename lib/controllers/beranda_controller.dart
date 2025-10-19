import 'package:tixcycle/controllers/location_controller.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';
import 'package:get/get.dart';

class BerandaController extends GetxController{
  final EventRepository _eventRepository;

  BerandaController(this._eventRepository);

  LocationController _locationController = Get.find<LocationController>();

  final eventList = <EventModel>[].obs;
  final filteredEvents = <EventModel>[].obs;

  var selectedCity = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit(){
    super.onInit();
    fetchEvents();

    ever(_locationController.currentCity, _filterEventsByCity);
  }

  void fetchEvents() async{
    try{
      isLoading(true);
      final events = await _eventRepository.getAllEvents();
      eventList.assignAll(events);
  filteredEvents.assignAll(events);
    }catch(e){
      Get.snackbar("Error", "Failed to fetch event data: ${e.toString()}");
    }finally{
      isLoading(false);
    }
  }

void _filterEventsByCity(String city) {
    selectedCity.value = city;
    if (city.isEmpty || city == 'Izin lokasi diperlukan') {
      filteredEvents.assignAll(eventList);
      return;
    }

    
    final filtered = eventList.where((event) =>
      event.city.toLowerCase().contains(city.toLowerCase())
    ).toList();

    filteredEvents.assignAll(filtered);
  }

  
  void clearFilter() {
    _locationController.currentCity.value = 'Tekan untuk mencari lokasi';
    filteredEvents.assignAll(eventList);
  }
}