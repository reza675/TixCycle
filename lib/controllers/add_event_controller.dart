import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/models/ticket_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';
import 'package:tixcycle/services/supabase_storage_service.dart';
import 'package:tixcycle/controllers/beranda_controller.dart';

class AddEventController extends GetxController {
  final EventRepository _eventRepository;
  final SupabaseStorageService _storageService;
  final UserAccountController _userController = Get.find();

  AddEventController(this._eventRepository, this._storageService);

  // form controller
  final nameC = TextEditingController();
  final venueC = TextEditingController();
  final cityC = TextEditingController();
  final addressC = TextEditingController();
  final descC = TextEditingController();
  final dateC = TextEditingController();
  final timeC = TextEditingController();

  // state
  var isLoading = false.obs;
  var selectedImage = Rx<File?>(null);
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final ticketForms = <Map<String, TextEditingController>>[].obs;

  @override
  void onInit() {
    super.onInit();
    addTicketForm();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedDate = picked;
      dateC.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime = picked;
      final now = DateTime.now();
      final dt =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      timeC.text = DateFormat('HH.mm').format(dt) + " WIB";
    }
  }

  void addTicketForm() {
    ticketForms.add({
      'name': TextEditingController(),
      'price': TextEditingController(),
      'stock': TextEditingController(),
      'desc': TextEditingController(),
    });
  }

  void removeTicketForm(int index) {
    if (ticketForms.length > 1) {
      ticketForms[index]['name']?.dispose();
      ticketForms[index]['price']?.dispose();
      ticketForms[index]['stock']?.dispose();
      ticketForms[index]['desc']?.dispose();
      ticketForms.removeAt(index);
    }
  }

  Future<void> createEvent() async {
    if (!_validateInputs()) return;

    try {
      isLoading(true);

      String imageUrl = '';
      if (selectedImage.value != null) {
        String fileName = 'events/${DateTime.now().millisecondsSinceEpoch}';
        imageUrl = await _storageService.uploadProfileImage(
            selectedImage.value!,
            "event_${DateTime.now().millisecondsSinceEpoch}");
      }

      final finalDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      List<TicketModel> tickets = [];
      double startingPrice = double.infinity;

      for (var form in ticketForms) {
        final price = double.parse(form['price']!.text);
        final stock = int.parse(form['stock']!.text);

        if (price < startingPrice) startingPrice = price;

        tickets.add(TicketModel(
          id: '',
          categoryName: form['name']!.text,
          price: price,
          stock: stock,
          description: form['desc']!.text,
        ));
      }

      final event = EventModel(
        id: '',
        name: nameC.text,
        description: descC.text,
        imageUrl: imageUrl,
        date: finalDateTime,
        venueName: venueC.text,
        city: cityC.text,
        address: addressC.text,
        organizerId: _userController.userProfile.value?.id ?? 'admin',
        coordinates: const GeoPoint(0, 0),
        startingPrice: startingPrice == double.infinity ? 0 : startingPrice,
        tickets: [],
      );

      await _eventRepository.createEventWithTickets(
          event: event, tickets: tickets);

      // Refresh beranda controller untuk update dashboard
      try {
        final berandaController = Get.find<BerandaController>();
        await berandaController.refreshHomepage();
      } catch (e) {
        // BerandaController mungkin belum di-load, tidak masalah
        print("BerandaController not found: $e");
      }

      Get.back();
      Get.snackbar("Sukses", "Event berhasil dibuat!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Gagal membuat event: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  bool _validateInputs() {
    if (nameC.text.isEmpty ||
        venueC.text.isEmpty ||
        cityC.text.isEmpty ||
        dateC.text.isEmpty ||
        timeC.text.isEmpty) {
      Get.snackbar("Error", "Mohon lengkapi data utama event");
      return false;
    }
    if (selectedImage.value == null) {
      Get.snackbar("Error", "Mohon pilih poster event");
      return false;
    }
    for (var form in ticketForms) {
      if (form['name']!.text.isEmpty ||
          form['price']!.text.isEmpty ||
          form['stock']!.text.isEmpty) {
        Get.snackbar("Error", "Mohon lengkapi data tiket");
        return false;
      }
    }
    return true;
  }

  @override
  void onClose() {
    nameC.dispose();
    venueC.dispose();
    cityC.dispose();
    addressC.dispose();
    descC.dispose();
    dateC.dispose();
    timeC.dispose();
    for (var form in ticketForms) {
      form.values.forEach((c) => c.dispose());
    }
    super.onClose();
  }
}
