import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/detail_event_controller.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/routes/app_routes.dart';

class DetailEventPage extends GetView<DetailEventController> {
  const DetailEventPage({super.key});

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
          colors: [c1, c2, c3, c4],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'TixCycle',
            style: TextStyle(
                color: Color(0xFF314417), fontWeight: FontWeight.w700),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final evt = controller.event.value;
            if (evt == null) {
              return const Center(child: Text('Event tidak ditemukan.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ],
                      border: Border.all(color: c3, width: 1),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _banner(evt),
                        const SizedBox(height: 12),
                        const Divider(
                          color: Colors.black54,
                          thickness: 3,
                        ),
                        _sectionTitle('WAKTU YANG DI NANTI'),
                        const SizedBox(height: 10),
                        _infoRow(
                            Icons.event_outlined, _formatFullDate(evt.date)),
                        const SizedBox(height: 8),
                        _infoRow(Icons.access_time, _formatTime(evt.date)),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.place_outlined,
                          '${evt.venueName}, ${evt.address}',
                        ),
                        const SizedBox(height: 14),
                        const Divider(
                          color: Colors.black54,
                          thickness: 3,
                        ),
                        _sectionTitle('Deskripsi'),
                        const SizedBox(height: 10),
                        _bullet(evt.name),
                        const SizedBox(height: 8),
                        Text(
                          evt.description,
                          style: const TextStyle(height: 1.45),
                        ),
                        const SizedBox(height: 18),
                        _beliTiketButton(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _banner(EventModel evt) {
    return Container(
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c3, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: evt.imageUrl.isNotEmpty
              ? Image.network(
                  evt.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'images/lihatTiket/lihatTiket1.png',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset('images/lihatTiket/lihatTiket1.png',
                  fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF314417),
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black26,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: c1,
            shape: BoxShape.circle,
            border: Border.all(color: c3, width: 1),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: c4),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatFullDate(DateTime d) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h.$m WIB';
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration:
              BoxDecoration(color: c4, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _beliTiketButton(BuildContext context) {
    final String? eventId = controller.event.value?.id;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          if (eventId != null) {
            Get.toNamed(AppRoutes.BELI_TIKET.replaceAll(':id', eventId));
          } else {
            Get.snackbar("Error", "Event ID tidak ditemukan.");
          }
        },  
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFB800)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Beli Tiket',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
