import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/update_event_controller.dart';

class UpdateEventPage extends GetView<UpdateEventController> {
  const UpdateEventPage({super.key});

  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c4 = Color(0xFF3F5135);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Perbarui Data Tiket", style: TextStyle(color: c4, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: c4),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: c4));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEventForm(context),
                const SizedBox(height: 20),
                _buildTicketForm(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c4,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: controller.updateEvent,
                    child: const Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Nama Event"),
          _field(controller.nameC),
          _label("Tanggal Event"),
          GestureDetector(
            onTap: () => controller.pickDate(context),
            child: AbsorbPointer(child: _field(controller.dateC, icon: Icons.calendar_today)),
          ),
          _label("Jam"),
          GestureDetector(
            onTap: () => controller.pickTime(context),
            child: AbsorbPointer(child: _field(controller.timeC)),
          ),
          _label("Lokasi (Venue)"),
          _field(controller.venueC),
          _label("Kota"),
          _field(controller.cityC),
          _label("Alamat"),
          _field(controller.addressC, maxLines: 2),
          _label("Harga Mulai Dari"),
          _field(controller.priceC, type: TextInputType.number),
          _label("Deskripsi"),
          _field(controller.descC, maxLines: 3),
          
          _label("Poster Event"),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: controller.pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: controller.selectedImage.value != null
                    ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover)
                    : Image.network(
                        controller.currentImageUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.add_a_photo, color: Colors.grey)),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTicketForm() {
    return Obx(() => Column(
      children: [
        ...controller.ticketForms.asMap().entries.map((entry) {
          int idx = entry.key;
          var form = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tiket #${idx + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: c4)),
                    
                     InkWell(
                        onTap: () => controller.removeTicketForm(idx),
                        child: const Icon(Icons.delete_outline, color: Colors.red),
                      )
                  ],
                ),
                _label("Tipe Tiket"),
                _field(form['name']),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Harga"), _field(form['price'], type: TextInputType.number)])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Stok"), _field(form['stock'], type: TextInputType.number)])),
                  ],
                ),
                _label("Deskripsi Tiket"),
                _field(form['desc']),
              ],
            ),
          );
        }).toList(),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.addTicketForm,
            icon: const Icon(Icons.add, color: c4),
            label: const Text("Tambah Tiket", style: TextStyle(color: c4)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: c4)),
          ),
        )
      ],
    ));
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(text, style: const TextStyle(color: c4, fontWeight: FontWeight.w600)),
  );

  Widget _field(TextEditingController c, {int maxLines = 1, TextInputType type = TextInputType.text, IconData? icon}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: type,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      ),
    );
  }
}