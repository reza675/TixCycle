import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/repositories/location_repository.dart';
import 'package:tixcycle/services/location_services.dart'; // Asumsikan ini ada

/// Controller untuk mengelola state dan logika form tambah event dummy.
class DummyEventFormController extends GetxController {
  // Untuk testing, kita bisa inject repository-nya langsung.
  // Pastikan Anda sudah mendaftarkan ini di AppBindings Anda.
  final LocationRepository _locationRepository = LocationRepository(LocationServices());

  // --- CONTROLLER UNTUK SETIAP TEXTFIELD ---
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final venueController = TextEditingController();
  final imageUrlController = TextEditingController();
  final priceController = TextEditingController();
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  // --- STATE MANAGEMENT ---
  var isLoading = false.obs;
  var isFetchingCity = false.obs; // State khusus untuk loading nama kota
  var autoDetectedCity = '---'.obs; // State untuk menampilkan kota yang terdeteksi

  @override
  void onInit() {
    super.onInit();
    // Tambahkan listener dengan debounce pada field latitude dan longitude.
    // Ini akan memanggil API geocoding hanya setelah pengguna berhenti mengetik.
    latController.addListener(_onCoordinatesChanged);
    longController.addListener(_onCoordinatesChanged);
  }

  // Gunakan debounce untuk mencegah pemanggilan API berlebihan
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 1000));
  void _onCoordinatesChanged() {
    _debouncer.call(() {
      _fetchCityFromCoordinates();
    });
  }

  /// Mengambil nama kota berdasarkan input latitude dan longitude.
  Future<void> _fetchCityFromCoordinates() async {
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
      // Panggil repository untuk melakukan reverse geocoding
      final city = await _locationRepository.fetchCityFromCoordinates(lat, long);
      autoDetectedCity.value = city;
    } catch (e) {
      autoDetectedCity.value = 'Gagal mendeteksi';
    } finally {
      isFetchingCity(false);
    }
  }

  /// Menyimpan event baru ke Firestore.
  Future<void> simpanEvent() async {
    // Validasi sederhana
    if (nameController.text.isEmpty || autoDetectedCity.value.contains('---') || autoDetectedCity.value.contains('Gagal')) {
      Get.snackbar("Input Tidak Lengkap", "Harap isi nama event dan pastikan kota terdeteksi.");
      return;
    }
    
    try {
      isLoading(true);
      final double latitude = double.tryParse(latController.text) ?? 0.0;
      final double longitude = double.tryParse(longController.text) ?? 0.0;
      final double startingPrice = double.tryParse(priceController.text) ?? 0.0;
      
      final eventBaru = EventModel(
        id: '', // Firestore akan membuat ID secara otomatis
        name: nameController.text,
        description: descController.text,
        venueName: venueController.text,
        imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : 'https://placehold.co/600x400?text=Event',
        startingPrice: startingPrice,
        date: DateTime.now().add(const Duration(days: 30)), // Tanggal dummy
        organizerId: "dummy_organizer_123", // ID panitia dummy
        
        // Data lokasi dari input
        address: addressController.text,
        city: autoDetectedCity.value, // Gunakan kota yang terdeteksi otomatis
        coordinates: GeoPoint(latitude, longitude),
      );

      // Simpan ke Firestore
      await FirebaseFirestore.instance.collection('events').add(eventBaru.toJson());

      Get.snackbar("Sukses", "Event dummy berhasil ditambahkan!");
      _clearFields();

    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan event: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

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
  }

  @override
  void onClose() {
    // Hapus listener untuk mencegah memory leak
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
    // Inisialisasi controller saat view dibuat
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

            // Tampilan untuk kota yang terdeteksi otomatis
            Obx(() => InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Kota (Otomatis)",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(controller.autoDetectedCity.value, style: TextStyle(fontSize: 16))),
                      if (controller.isFetchingCity.value)
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                )),
            
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
}


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
