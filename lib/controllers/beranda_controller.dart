import 'package:tixcycle/controllers/location_controller.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';
import 'package:get/get.dart';

class BerandaController extends GetxController{
  final EventRepository _eventRepository;

  BerandaController(this._eventRepository);

  late final LocationController _locationController;


  final RxList<EventModel> _allEvents = <EventModel>[].obs;

  final RxList<EventModel> filteredEvents = <EventModel>[].obs;
  
  final RxList<String> availableCities = <String>[].obs;

  var isLoading = true.obs; 
  var selectedCity = ''.obs;


  @override
  void onInit() {
    super.onInit();
    _locationController = Get.find<LocationController>();
    

    fetchAllEvents();

    ever(_locationController.currentCity, _filterEventsByCity);
  }

  Future<void> fetchAllEvents() async {
    try {
      isLoading(true);
      final events = await _eventRepository.getAllEvents();
      _allEvents.assignAll(events);
   
      filteredEvents.assignAll(events);
      
      _populateAvailableCities();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data event: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  void clearFilter() {
    _locationController.currentCity.value = 'Tekan untuk mencari lokasi';
  }

  void _filterEventsByCity(String city) {
    selectedCity.value = city;
    if (city.isEmpty ||
        city == 'Tekan untuk mencari lokasi' ||
        city == 'Izin lokasi diperlukan') {
      filteredEvents.assignAll(_allEvents);
      return;
    }

    final filtered = _allEvents.where((event) =>
        event.city.toLowerCase().contains(city.toLowerCase())).toList();

    filteredEvents.assignAll(filtered);
  }

  void _populateAvailableCities() {
    if (_allEvents.isEmpty) return;
    final cities = _allEvents.map((event) => event.city).toSet().toList();
    availableCities.assignAll(cities);
  }
}
