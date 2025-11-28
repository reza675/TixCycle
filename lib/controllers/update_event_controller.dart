import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tixcycle/controllers/admin_event_list_controller.dart';
import 'package:tixcycle/controllers/beranda_controller.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/models/ticket_model.dart';
import 'package:tixcycle/repositories/event_repository.dart';
import 'package:tixcycle/services/supabase_storage_service.dart';

class UpdateEventController extends GetxController {
  final EventRepository _eventRepository;
  final SupabaseStorageService _storageService;

  UpdateEventController(this._eventRepository, this._storageService);

  late EventModel originalEvent;

  final nameC = TextEditingController();
  final venueC = TextEditingController();
  final cityC = TextEditingController();
  final addressC = TextEditingController();
  final descC = TextEditingController();
  final dateC = TextEditingController();
  final timeC = TextEditingController();
  final priceC = TextEditingController();

  var isLoading = true.obs;
  var selectedImage = Rx<File?>(null);
  var currentImageUrl = ''.obs;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final ticketForms = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is EventModel) {
      originalEvent = Get.arguments;
      _initializeForm();
    } else {
      Get.back();
      Get.snackbar("Error", "Data event tidak ditemukan");
    }
  }

  Future<void> _initializeForm() async {
    try {
      isLoading(true);

      nameC.text = originalEvent.name;
      venueC.text = originalEvent.venueName;
      cityC.text = originalEvent.city;
      addressC.text = originalEvent.address;
      descC.text = originalEvent.description;
      currentImageUrl.value = originalEvent.imageUrl;
      priceC.text = originalEvent.startingPrice.toStringAsFixed(0);

      selectedDate = originalEvent.date;
      selectedTime = TimeOfDay.fromDateTime(originalEvent.date);

      dateC.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
      timeC.text = DateFormat('HH.mm').format(selectedDate!) + " WIB";

      final tickets =
          await _eventRepository.getTicketsForEvent(originalEvent.id);

      for (var ticket in tickets) {
        ticketForms.add({
          'id': ticket.id,
          'name': TextEditingController(text: ticket.categoryName),
          'price': TextEditingController(text: ticket.price.toStringAsFixed(0)),
          'stock': TextEditingController(text: ticket.stock.toString()),
          'desc': TextEditingController(text: ticket.description),
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat detail event: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- Logic Date & Time & Image  ---
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) selectedImage.value = File(pickedFile.path);
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedDate = picked;
      dateC.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
        context: context, initialTime: selectedTime ?? TimeOfDay.now());
    if (picked != null) {
      selectedTime = picked;
      final now = DateTime.now();
      final dt =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      timeC.text = DateFormat('HH.mm').format(dt) + " WIB";
    }
  }

  // --- Logic Tiket ---
  void addTicketForm() {
    ticketForms.add({
      'id': '',
      'name': TextEditingController(),
      'price': TextEditingController(),
      'stock': TextEditingController(),
      'desc': TextEditingController(),
    });
  }

  void removeTicketForm(int index) {
    ticketForms.removeAt(index);
  }

  Future<void> updateEvent() async {
    try {
      isLoading(true);

      String finalImageUrl = currentImageUrl.value;
      if (selectedImage.value != null) {
        finalImageUrl = await _storageService.uploadProfileImage(
            selectedImage.value!, "event_${originalEvent.id}_update");
      }
      final finalDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      List<TicketModel> ticketsToUpdate = [];
      for (var form in ticketForms) {
        ticketsToUpdate.add(TicketModel(
          id: form['id'],
          categoryName: form['name'].text,
          price: double.tryParse(form['price'].text) ?? 0,
          stock: int.tryParse(form['stock'].text) ?? 0,
          description: form['desc'].text,
        ));
      }

      final updatedEvent = EventModel(
        id: originalEvent.id,
        name: nameC.text,
        description: descC.text,
        imageUrl: finalImageUrl,
        date: finalDateTime,
        venueName: venueC.text,
        city: cityC.text,
        address: addressC.text,
        organizerId: originalEvent.organizerId,
        coordinates: originalEvent.coordinates,
        startingPrice:
            double.tryParse(priceC.text) ?? originalEvent.startingPrice,
      );

      await _eventRepository.updateEventWithTickets(
        event: updatedEvent,
        tickets: ticketsToUpdate,
      );

      if (Get.isRegistered<AdminEventListController>()) {
        Get.find<AdminEventListController>().fetchEvents();
      }

      // Refresh beranda controller untuk update dashboard
      try {
        final berandaController = Get.find<BerandaController>();
        await berandaController.refreshHomepage();
      } catch (e) {
        // BerandaController mungkin belum di-load, tidak masalah
        print("BerandaController not found: $e");
      }

      Get.back();
      Get.snackbar("Sukses", "Data event berhasil diperbarui!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui event: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
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
    priceC.dispose();
    for (var form in ticketForms) {
      (form['name'] as TextEditingController).dispose();
      (form['price'] as TextEditingController).dispose();
      (form['stock'] as TextEditingController).dispose();
      (form['desc'] as TextEditingController).dispose();
    }
    super.onClose();
  }
}
