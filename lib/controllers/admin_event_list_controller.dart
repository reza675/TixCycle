import 'package:get/get.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';

class AdminEventListController extends GetxController {
  final EventRepository _eventRepository;
  AdminEventListController(this._eventRepository);

  var isLoading = true.obs;
  final RxList<EventModel> events = <EventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading(true);
     
      final result = await _eventRepository.getAllEventsOnce();
      events.assignAll(result);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat daftar event: $e");
    } finally {
      isLoading(false);
    }
  }
}