import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/controllers/location_controller.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';
import 'package:get/get.dart';

class BerandaController extends GetxController {
  final EventRepository _eventRepository;

  BerandaController(this._eventRepository);

  late final LocationController _locationController;

  final RxList<EventModel> featuredEvents =
      <EventModel>[].obs; // daftar event buat di carousel paling atas
  final RxList<Map<String, EventModel>> cityEvents =
      <Map<String, EventModel>>[].obs; // daftar event berdasarkan kota
  final RxList<EventModel> recommendedEvents =
      <EventModel>[].obs; // daftar event rekomendasi (lazy loading)
  final RxList<EventModel> _unfilteredRecommendedEvents = <EventModel>[].obs;

  var isLoading = true.obs;
  var isLoadingMore = false
      .obs; // penanda loading ketika memuat data event rekomendasi tambahan
  var hasMoreData =
      true.obs; // penanda apakah masih ada data lebih banyak untuk dimuat
  DocumentSnapshot? _lastDocument;

  var searchQuery = ''.obs;
  var isSearchActive = false.obs;

  var selectedCity = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _locationController = Get.find<LocationController>();

    _initializeHomepage();

    debounce(searchQuery, _performSearch,
        time: const Duration(milliseconds: 500));
  }

  Future<void> refreshHomepage() async {
    try {
      isLoading(true);

      // Reset variables
      _lastDocument = null;
      hasMoreData.value = true;
      searchQuery.value = '';
      isSearchActive.value = false;
      selectedCity.value = null;

      // Clear existing data
      featuredEvents.clear();
      cityEvents.clear();
      recommendedEvents.clear();
      _unfilteredRecommendedEvents.clear();

      // Reload data
      await _initializeHomepage();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat ulang halaman: ${e.toString()}");
    }
  }

  Future<void> _initializeHomepage() async {
    try {
      isLoading(true);
      await _locationController.getMyCity();
      final featuredFuture = _eventRepository.getFeaturedEvents();
      final cityListFuture = _eventRepository.getAllEventsOnce();
      final initialRecsFuture =
          _eventRepository.getPaginatedRecommendedEvents();

      final results = await Future.wait(
          [featuredFuture, cityListFuture, initialRecsFuture]);

      featuredEvents.assignAll(results[0] as List<EventModel>);
      final allEventsForCities = results[1] as List<EventModel>;
      _buildCityList(allEventsForCities);

      final initialRecsResult =
          results[2] as ({List<EventModel> events, DocumentSnapshot? lastDoc});
      recommendedEvents.assignAll(initialRecsResult.events);
      _unfilteredRecommendedEvents.assignAll(initialRecsResult.events);
      _lastDocument = initialRecsResult.lastDoc;
      hasMoreData.value = initialRecsResult.events.isNotEmpty;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat halaman beranda: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  // Method baru untuk filter berdasarkan kota
  void filterByCity(String cityName) {
    // Jika menekan kota yang sudah aktif, batalkan filter
    if (cityName == selectedCity.value && cityName.isNotEmpty) {
      selectedCity.value = null;
      isSearchActive(false);
      recommendedEvents.assignAll(_unfilteredRecommendedEvents);
    } else {
      if (cityName.isNotEmpty) {
        searchQuery.value = '';
      }

      selectedCity.value = cityName.isEmpty ? null : cityName;

      if (cityName.isEmpty) {
        isSearchActive(false);
        recommendedEvents.assignAll(_unfilteredRecommendedEvents);
      } else {
        isSearchActive(true);
        final results = _unfilteredRecommendedEvents
            .where(
                (event) => event.city.toLowerCase() == cityName.toLowerCase())
            .toList();
        recommendedEvents.assignAll(results);
      }
    }
  }

  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      selectedCity.value = null;
    }

    if (query.isEmpty) {
      isSearchActive(false);
      recommendedEvents.assignAll(_unfilteredRecommendedEvents);
    } else {
      isSearchActive(true);
      final lowerCaseQuery = query.toLowerCase();
      final results = _unfilteredRecommendedEvents.where((event) {
        final eventNameMatch =
            event.name.toLowerCase().contains(lowerCaseQuery);
        final cityNameMatch = event.city.toLowerCase().contains(lowerCaseQuery);
        return eventNameMatch || cityNameMatch; // Kondisi ATAU
      }).toList();
      recommendedEvents.assignAll(results);
    }
  }

  Future<void> loadMoreEvents() async {
    if (isLoadingMore.value || !hasMoreData.value || isSearchActive.value)
      return;

    try {
      isLoadingMore(true);
      final result = await _eventRepository.getPaginatedRecommendedEvents(
          startAfterDoc: _lastDocument);

      if (result.events.isNotEmpty) {
        recommendedEvents.addAll(result.events);
        _unfilteredRecommendedEvents.addAll(result.events);
        _lastDocument = result.lastDoc;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat event lainnya: ${e.toString()}");
    } finally {
      isLoadingMore(false);
    }
  }

  void _buildCityList(List<EventModel> allEvents) {
    // daftar event dikelompokkan berdasarkan kota
    if (allEvents.isEmpty) return;
    final Map<String, EventModel> uniqueCityMap = {};
    for (var event in allEvents) {
      if (!uniqueCityMap.containsKey(event.city)) {
        uniqueCityMap[event.city] = event;
      }
    }
    final String currentUserCity = _locationController.currentCity.value;
    final List<Map<String, EventModel>> sortedCityList = [];
    if (uniqueCityMap.containsKey(currentUserCity)) {
      sortedCityList.add({currentUserCity: uniqueCityMap[currentUserCity]!});
      uniqueCityMap.remove(currentUserCity);
    }
    uniqueCityMap.forEach((city, event) {
      sortedCityList.add({city: event});
    });
    cityEvents.assignAll(sortedCityList);
  }
}
