import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tixcycle/controllers/admin_delete_event_controller.dart';
import 'package:tixcycle/models/event_model.dart';

class AdminDeleteEventPage extends GetView<AdminDeleteEventController> {
  const AdminDeleteEventPage({super.key});

  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: c4),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Hapus Data Tiket',
            style: TextStyle(color: c4, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: c4));
              }
              if (controller.events.isEmpty) {
                return const Center(child: Text("Tidak ada event untuk dihapus."));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.events.length,
                itemBuilder: (context, index) {
                  final event = controller.events[index];
                  return _buildEventCard(event);
                },
              );
            }),
            
            // Overlay Loading saat menghapus
            Obx(() => controller.isDeleting.value 
                ? Container(
                    color: Colors.black45,
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ) 
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: c4, // Hijau tua
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Header
          Container(
            margin: const EdgeInsets.all(12),
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(event.imageUrl),
                fit: BoxFit.cover,
                onError: (e, s) => const AssetImage('images/placeholder.png'),
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    color: Color(0xFFE8F5E9),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMMM yyyy').format(event.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  "${event.venueName} | ${event.city}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.deleteEvent(event),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.red[900]!.withOpacity(0.8), 
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Hapus",
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}