import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/models/ticket_model.dart';
import 'package:tixcycle/repositories/location_repository.dart';
import 'package:tixcycle/services/location_services.dart'; // Asumsikan ini ada

/// Controller untuk mengelola state dan logika form tambah event dummy.
class DummyEventFormController extends GetxController {
  final LocationRepository _locationRepository = LocationRepository(LocationServices());

  // --- CONTROLLER UNTUK SETIAP TEXTFIELD ---
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final venueController = TextEditingController();
  final imageUrlController = TextEditingController();
  final priceController = TextEditingController(); // Harga Mulai Dari
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();


  // --- STATE MANAGEMENT ---
  final RxList<Map<String, TextEditingController>> ticketFormControllers =
      <Map<String, TextEditingController>>[].obs;

  var isLoading = false.obs;
  var isFetchingCity = false.obs; 
  var autoDetectedCity = '---'.obs;
  final Rxn<DateTime> selectedDateTime = Rxn<DateTime>();

  @override
   void onInit() {
    super.onInit();
    latController.addListener(_onCoordinatesChanged);
    longController.addListener(_onCoordinatesChanged);
    addTicketForm();
  }


  final _debouncer = Debouncer(delay: const Duration(milliseconds: 1000));
  void _onCoordinatesChanged() {
    _debouncer.call(() {
      _fetchCityFromCoordinates();
    });
  }

  Future<void> _fetchCityFromCoordinates() async {
    // ... (kode ini tetap sama)
    final latText = latController.text;
    final longText = longController.text;

    if (latText.isEmpty || longText.isEmpty) return;

    final lat = double.tryParse(latText);
    final long = double.tryParse(longText);

    if (lat == null || long == null) {
      autoDetectedCity.value = 'Koordinat tidak valid';
      return;
    }

    try {
      isFetchingCity(true);
      final city = await _locationRepository.fetchCityFromCoordinates(lat, long);
      autoDetectedCity.value = city;
    } catch (e) {
      autoDetectedCity.value = 'Gagal mendeteksi';
    } finally {
      isFetchingCity(false);
    }
  }

 
  Future<void> pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDateTime.value ?? DateTime.now(),
      firstDate: DateTime.now(), // Mulai dari hari ini
      lastDate: DateTime.now().add(const Duration(days: 730)), // Maksimal 2 tahun ke depan
    );

    if (pickedDate != null) {
      // Jaga jam & menit yang sudah ada (jika ada)
      final currentDateTime = selectedDateTime.value ?? DateTime.now();
      selectedDateTime.value = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        currentDateTime.hour,
        currentDateTime.minute,
      );
    }
  }

  /// Menampilkan dialog Time Picker
  Future<void> pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime.value ?? DateTime.now()),
    );

    if (pickedTime != null) {
      // Jaga tanggal yang sudah ada
      final currentDateTime = selectedDateTime.value ?? DateTime.now();
      selectedDateTime.value = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }
  }

  /// Menambahkan satu set controller baru untuk baris form tiket.
  void addTicketForm() {
    ticketFormControllers.add({
      'category': TextEditingController(),
      'price': TextEditingController(),
      'stock': TextEditingController(),
      'description': TextEditingController(),
    });
  }

  /// Menghapus satu set controller (dan baris form) berdasarkan indeks.
  void removeTicketForm(int index) {
    if (ticketFormControllers.length > 1) { // Jaga agar minimal 1 form tersisa
      // Hapus controller dari memori
      ticketFormControllers[index].forEach((key, controller) => controller.dispose());
      ticketFormControllers.removeAt(index);
    } else {
      Get.snackbar("Info", "Minimal harus ada satu jenis tiket.");
    }
  }
  
  /// Menyimpan event baru ke Firestore.
  Future<void> simpanEvent() async {
    if (nameController.text.isEmpty ||
        autoDetectedCity.value.contains('---') ||
        autoDetectedCity.value.contains('Gagal') ||
        selectedDateTime.value == null) {
      Get.snackbar("Input Tidak Lengkap",
          "Harap isi detail event, pastikan kota terdeteksi, dan atur tanggal & jam.");
      return;
    }

    // Validasi input tiket
    final List<TicketModel> ticketsToSave = [];
    for (var form in ticketFormControllers) {
      final category = form['category']!.text;
      final priceText = form['price']!.text;
      final stockText = form['stock']!.text;
      final description = form['description']!.text;

      if (category.isEmpty || priceText.isEmpty || stockText.isEmpty) {
        Get.snackbar("Input Tiket Tidak Lengkap", "Harap isi Nama Kategori, Harga, dan Stok untuk semua tiket.");
        return;
      }
      final price = double.tryParse(priceText);
      final stock = int.tryParse(stockText);
      if (price == null || stock == null) {
         Get.snackbar("Input Tiket Tidak Valid", "Harga dan Stok harus berupa angka.");
         return;
      }
      ticketsToSave.add(TicketModel(
        id: '', // Firestore akan generate ID
        categoryName: category,
        price: price,
        stock: stock,
        description: description,
      ));
    }

    try {
      isLoading(true);
      final double latitude = double.tryParse(latController.text) ?? 0.0;
      final double longitude = double.tryParse(longController.text) ?? 0.0;
      final double startingPrice = double.tryParse(priceController.text) ?? ticketsToSave.map((t) => t.price).reduce((a, b) => a < b ? a : b); // Ambil harga termurah dari tiket jika field kosong

      // 1. Buat EventModel (tanpa tiket di sini)
      final eventBaru = EventModel(
        id: '',
        name: nameController.text,
        description: descController.text,
        venueName: venueController.text,
        imageUrl: imageUrlController.text.isNotEmpty
            ? imageUrlController.text
            : 'https://placehold.co/600x400?text=Event',
        startingPrice: startingPrice, // Harga termurah
        date: selectedDateTime.value!,
        organizerId: "dummy_organizer_123",
        address: addressController.text,
        city: autoDetectedCity.value,
        coordinates: GeoPoint(latitude, longitude),
      );

      // 2. Simpan Event Utama ke Firestore dan dapatkan ID-nya
      DocumentReference eventRef = await FirebaseFirestore.instance
          .collection('events')
          .add(eventBaru.toJson());
      String eventId = eventRef.id;

      // 3. Simpan Setiap Tiket ke Sub-koleksi
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var ticket in ticketsToSave) {
        // Buat referensi dokumen baru di dalam sub-koleksi 'tickets'
        DocumentReference ticketRef = FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('tickets')
            .doc(); // Biarkan Firestore membuat ID tiket
        // Tambahkan operasi set ke batch
        batch.set(ticketRef, ticket.toJson());
      }
      // Jalankan semua operasi tulis tiket sekaligus (lebih efisien)
      await batch.commit();


      Get.snackbar("Sukses", "Event dummy beserta tiketnya berhasil ditambahkan!");
      _clearFields();
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan event: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  /// Mengosongkan semua field.
  void _clearFields() {
    nameController.clear();
    descController.clear();
    venueController.clear();
    imageUrlController.clear();
    priceController.clear();
    addressController.clear();
    latController.clear();
    longController.clear();
    autoDetectedCity.value = '---';
    selectedDateTime.value = null;
    ticketFormControllers.removeRange(1, ticketFormControllers.length);
    // Kosongkan form tiket pertama
    ticketFormControllers[0].forEach((key, controller) => controller.clear());
  }

 @override
  void onClose() {
    // Hapus semua text editing controller
    nameController.dispose();
    descController.dispose();
    venueController.dispose();
    imageUrlController.dispose();
    priceController.dispose();
    addressController.dispose();
    latController.dispose();
    longController.dispose();
    // Hapus semua controller tiket
    for (var form in ticketFormControllers) {
      form.forEach((key, controller) => controller.dispose());
    }
    latController.removeListener(_onCoordinatesChanged);
    longController.removeListener(_onCoordinatesChanged);
    _debouncer.cancel();
    super.onClose();
  }
}

/// Widget View untuk menampilkan form.
class DummyEventFormPage extends StatelessWidget {
  const DummyEventFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DummyEventFormController controller = Get.put(DummyEventFormController());

    return Scaffold(
      appBar: AppBar(title: const Text("Form Event Dummy")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Detail Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: controller.nameController, decoration: const InputDecoration(labelText: "Nama Event")),
            TextField(controller: controller.descController, decoration: const InputDecoration(labelText: "Deskripsi")),
            TextField(controller: controller.venueController, decoration: const InputDecoration(labelText: "Nama Tempat (Venue)")),
            TextField(controller: controller.imageUrlController, decoration: const InputDecoration(labelText: "URL Gambar Poster")),
            TextField(controller: controller.priceController, decoration: const InputDecoration(labelText: "Harga Mulai Dari"), keyboardType: TextInputType.number),
            
            // --- UI BARU UNTUK TANGGAL & JAM ---
            const SizedBox(height: 16),
            Obx(() {
              // Format tanggal dan jam secara manual agar rapi
              final dt = controller.selectedDateTime.value;
              final dateText = dt == null ? 'Belum diatur' : '${dt.day}/${dt.month}/${dt.year}';
              final timeText = dt == null ? 'Belum diatur' : '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              
              return InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Tanggal & Jam Event",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tanggal: $dateText', style: const TextStyle(fontSize: 16)),
                    Text('Jam: $timeText', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text("Pilih Tanggal"),
                    onPressed: controller.pickDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: const Text("Pilih Jam"),
                    onPressed: controller.pickTime,
                  ),
                ),
              ],
            ),
            // --- AKHIR DARI UI BARU ---

            const SizedBox(height: 24),
            const Text("Lokasi Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: controller.addressController, decoration: const InputDecoration(labelText: "Alamat Lengkap (cth: Jl. Sudirman No. 1)")),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: controller.latController, decoration: const InputDecoration(labelText: "Latitude"), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: controller.longController, decoration: const InputDecoration(labelText: "Longitude"), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Kota (Otomatis)",
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(controller.autoDetectedCity.value, style: const TextStyle(fontSize: 16))),
                      if (controller.isFetchingCity.value)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
            const Text("Tiket Tersedia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => ListView.builder(
              shrinkWrap: true, // Penting karena di dalam SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll internal
              itemCount: controller.ticketFormControllers.length,
              itemBuilder: (context, index) {
                final form = controller.ticketFormControllers[index];
                return _buildTicketFormRow(controller, form, index);
              },
            )),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Tambah Jenis Tiket"),
              onPressed: controller.addTicketForm,
            ),
            const SizedBox(height: 32),
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.simpanEvent,
                  child: controller.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("SIMPAN EVENT"),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketFormRow(
      DummyEventFormController controller,
      Map<String, TextEditingController> form,
      int index,
    ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("Tiket #${index + 1}", style: TextStyle(fontWeight: FontWeight.bold))),
                // Tombol Hapus hanya muncul jika ada lebih dari 1 tiket
                if (controller.ticketFormControllers.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => controller.removeTicketForm(index),
                    tooltip: "Hapus Jenis Tiket Ini",
                  ),
              ],
            ),
            TextField(
              controller: form['category'],
              decoration: const InputDecoration(labelText: "Nama Kategori (cth: VIP)"),
            ),
            TextField(
              controller: form['price'],
              decoration: const InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: form['stock'],
              decoration: const InputDecoration(labelText: "Stok Tersedia"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: form['description'],
              decoration: const InputDecoration(labelText: "Deskripsi Singkat (Opsional)"),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class untuk Debouncer
class Debouncer {
  final Duration delay;
  VoidCallback? _callback;
  Timer? _timer;
  Debouncer({required this.delay});

  void call(VoidCallback callback) {
    _callback = callback;
    _timer?.cancel();
    _timer = Timer(delay, _callback!);
  }

  void cancel() {
    _timer?.cancel();
  }
}

