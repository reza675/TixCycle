import 'package:get/get.dart';
import '../models/event_model.dart';

class SearchController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxList<EventModel> searchResults = <EventModel>[].obs;
  final RxBool isLoading = false.obs;

  // Data dummy untuk pencarian
  final List<EventModel> allEvents = [
    EventModel(
      id: '1',
      name: 'Konser Ungu',
      description: 'Konser nostalgia bersama band legendaris Ungu',
      address: 'Jakarta',
      venueName: 'Stadion Utama Gelora Bung Karno',
      date: DateTime(2024, 3, 15),
      imageUrl: 'images/beranda/tampilan1.jpg',
      startingPrice: 280000,
      organizerId: 'org1',
    ),
    EventModel(
      id: '2',
      name: 'Festival Musik Jazz',
      description: 'Festival musik jazz terbesar di Indonesia',
      address: 'Yogyakarta',
      venueName: 'Taman Budaya Yogyakarta',
      date: DateTime(2024, 4, 20),
      imageUrl: 'images/beranda/tampilan2.png',
      startingPrice: 350000,
      organizerId: 'org2',
    ),
    EventModel(
      id: '3',
      name: 'Konser Rock Indonesia',
      description: 'Konser rock dengan lineup band terbaik Indonesia',
      address: 'Bandung',
      venueName: 'Gedung Sate Convention Center',
      date: DateTime(2024, 5, 10),
      imageUrl: 'images/beranda/tampilan1.jpg',
      startingPrice: 450000,
      organizerId: 'org3',
    ),
    EventModel(
      id: '4',
      name: 'Festival Pop Indonesia',
      description: 'Festival musik pop dengan artis-artis ternama',
      address: 'Surabaya',
      venueName: 'Tunjungan Plaza',
      date: DateTime(2024, 6, 5),
      imageUrl: 'images/beranda/tampilan2.png',
      startingPrice: 500000,
      organizerId: 'org4',
    ),
    EventModel(
      id: '5',
      name: 'Konser Akustik',
      description: 'Konser akustik intim dengan penyanyi indie',
      address: 'Semarang',
      venueName: 'Lawang Sewu',
      date: DateTime(2024, 7, 12),
      imageUrl: 'images/beranda/tampilan1.jpg',
      startingPrice: 200000,
      organizerId: 'org5',
    ),
    EventModel(
      id: '6',
      name: 'Festival EDM',
      description: 'Festival electronic dance music terbesar',
      address: 'Bali',
      venueName: 'Garuda Wisnu Kencana',
      date: DateTime(2024, 8, 18),
      imageUrl: 'images/beranda/tampilan2.png',
      startingPrice: 750000,
      organizerId: 'org6',
    ),
  ];

  // Fungsi untuk melakukan pencarian
  void searchEvents(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;

    // Simulasi delay untuk loading
    Future.delayed(const Duration(milliseconds: 500), () {
      final results = allEvents.where((event) {
        final searchLower = query.toLowerCase();
        return event.name.toLowerCase().contains(searchLower) ||
            event.address.toLowerCase().contains(searchLower) ||
            event.venueName.toLowerCase().contains(searchLower) ||
            event.description.toLowerCase().contains(searchLower);
      }).toList();

      searchResults.value = results;
      isLoading.value = false;
    });
  }

  // Fungsi untuk mengatur query pencarian
  void setSearchQuery(String query) {
    searchQuery.value = query;
    searchEvents(query);
  }

  // Fungsi untuk clear pencarian
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  // Fungsi untuk mendapatkan event berdasarkan ID
  EventModel? getEventById(String id) {
    try {
      return allEvents.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fungsi untuk mendapatkan event berdasarkan lokasi
  List<EventModel> getEventsByLocation(String location) {
    return allEvents
        .where((event) =>
            event.venueName.toLowerCase().contains(location.toLowerCase()))
        .toList();
  }

  // Fungsi untuk mendapatkan event berdasarkan kategori/genre
  List<EventModel> getEventsByCategory(String category) {
    return allEvents
        .where((event) =>
            event.name.toLowerCase().contains(category.toLowerCase()) ||
            event.description.toLowerCase().contains(category.toLowerCase()))
        .toList();
  }
}
