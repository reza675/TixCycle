import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';
import 'package:tixcycle/controllers/beranda_controller.dart';

class AdminDeleteEventController extends GetxController {
  final EventRepository _eventRepository;
  AdminDeleteEventController(this._eventRepository);

  var isLoading = true.obs;
  var isDeleting = false.obs;
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

  Future<void> deleteEvent(EventModel event) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Hapus Event?"),
          content: Text(
              "Anda yakin ingin menghapus event '${event.name}'? Tindakan ini tidak dapat dibatalkan."),
          actions: [
            TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text("Batal")),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isDeleting(true);
        await _eventRepository.deleteEvent(event.id);

        events.remove(event);

        // Refresh beranda controller untuk update dashboard
        try {
          final berandaController = Get.find<BerandaController>();
          await berandaController.refreshHomepage();
        } catch (e) {
          // BerandaController mungkin belum di-load, tidak masalah
          print("BerandaController not found: $e");
        }

        Get.snackbar("Sukses", "Event berhasil dihapus",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus event: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isDeleting(false);
    }
  }
}
