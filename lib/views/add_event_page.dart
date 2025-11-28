import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/add_event_controller.dart';

class AddEventPage extends GetView<AddEventController> {
  const AddEventPage({super.key});

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
            'Tambah Data Tiket',
            style: TextStyle(color: c4, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Obx(() {
             if (controller.isLoading.value) {
               return const Center(child: CircularProgressIndicator());
             }
             return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- CARD DATA EVENT ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c1,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Nama Event"),
                        _buildTextField(controller.nameC, "JKT48 First Snow"),
                        
                        _buildLabel("Tanggal Event"),
                        GestureDetector(
                          onTap: () => controller.pickDate(context),
                          child: AbsorbPointer(
                            child: _buildTextField(
                              controller.dateC, 
                              "18/03/2000", 
                              icon: Icons.calendar_today_outlined
                            ),
                          ),
                        ),

                        _buildLabel("Jam"),
                        GestureDetector(
                          onTap: () => controller.pickTime(context),
                          child: AbsorbPointer(
                            child: _buildTextField(controller.timeC, "08.00 WIB..."),
                          ),
                        ),

                        _buildLabel("Lokasi (Venue)"),
                        _buildTextField(controller.venueC, "Ex: Stadion GBK"),
                        
                        _buildLabel("Kota"),
                        _buildTextField(controller.cityC, "Jakarta"),
                        
                        _buildLabel("Alamat Lengkap"),
                        _buildTextField(controller.addressC, "Jl. Jendral Sudirman...", maxLines: 2),

                        _buildLabel("Deskripsi"),
                        _buildTextField(controller.descC, "", maxLines: 3),

                        _buildLabel("Poster"),
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
                            child: controller.selectedImage.value != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      controller.selectedImage.value!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, size: 40, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text("Tap to upload", style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildTicketSection(),

                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c4,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.createEvent,
                      child: const Text(
                        "Simpan Event",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF5F6F52), 
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, 
      {IconData? icon, int maxLines = 1, TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null,
        ),
      ),
    );
  }

  Widget _buildTicketSection() {
    return Obx(() => Column(
      children: [
        ...controller.ticketForms.asMap().entries.map((entry) {
          int index = entry.key;
          var form = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c2, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tiket #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: c4)),
                    if (controller.ticketForms.length > 1)
                      InkWell(
                        onTap: () => controller.removeTicketForm(index),
                        child: const Icon(Icons.delete_outline, color: Colors.red),
                      )
                  ],
                ),
                _buildLabel("Tipe Tiket"),
                _buildTextField(form['name']!, "VIP / Reguler"),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Harga (Rp)"),
                          _buildTextField(form['price']!, "150000", type: TextInputType.number),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Stok"),
                          _buildTextField(form['stock']!, "100", type: TextInputType.number),
                        ],
                      ),
                    ),
                  ],
                ),
                 _buildLabel("Deskripsi Tiket (Opsional)"),
                _buildTextField(form['desc']!, "Benefit tiket...", maxLines: 2),
              ],
            ),
          );
        }).toList(),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, color: c4),
            label: const Text("Tambah Kategori Tiket", style: TextStyle(color: c4)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: c4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: controller.addTicketForm,
          ),
        ),
      ],
    ));
  }
}