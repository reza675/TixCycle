import 'package:get/get.dart';
import '../models/ticket_model.dart';

class TicketController extends GetxController {
  // Data tiket yang tersedia
  final List<TicketModel> availableTickets = [
    TicketModel(
      id: '1',
      categoryName: 'GOLD',
      price: 280000,
      description: 'Gold',
      stock: 100,
    ),
    TicketModel(
      id: '2',
      categoryName: 'VIP',
      price: 1000000,
      description: 'VIP',
      stock: 50,
    ),
    TicketModel(
      id: '3',
      categoryName: 'BRONZE',
      price: 350000,
      description: 'Bronze',
      stock: 200,
    ),
    TicketModel(
      id: '4',
      categoryName: 'PLATINUM',
      price: 750000,
      description: 'Platinum',
      stock: 75,
    ),
    TicketModel(
      id: '5',
      categoryName: 'VIP (PRESALE)',
      price: 800000,
      description: 'VIP',
      stock: 30,
    ),
  ];

  // Map untuk menyimpan tiket yang dipilih
  final RxMap<String, int> selectedTickets = <String, int>{}.obs;

  // Fungsi untuk menambah tiket
  void addTicket(String category) {
    selectedTickets[category] = (selectedTickets[category] ?? 0) + 1;
  }

  // Fungsi untuk mengurangi tiket
  void removeTicket(String category) {
    if (selectedTickets[category] != null && selectedTickets[category]! > 0) {
      selectedTickets[category] = selectedTickets[category]! - 1;
      if (selectedTickets[category] == 0) {
        selectedTickets.remove(category);
      }
    }
  }

  // Fungsi untuk menghitung total harga
  int getTotalPrice() {
    int total = 0;
    selectedTickets.forEach((category, quantity) {
      final ticket =
          availableTickets.firstWhere((t) => t.categoryName == category);
      total += (ticket.price * quantity).round();
    });
    return total;
  }

  // Fungsi untuk mendapatkan jumlah tiket yang dipilih
  int getSelectedTicketCount() {
    return selectedTickets.values.fold(0, (sum, quantity) => sum + quantity);
  }

  // Fungsi untuk mendapatkan tiket berdasarkan kategori
  TicketModel? getTicketByCategory(String category) {
    try {
      return availableTickets.firstWhere((t) => t.categoryName == category);
    } catch (e) {
      return null;
    }
  }

  // Fungsi untuk memformat harga
  String formatPrice(double price) {
    return 'Rp${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Fungsi untuk reset pilihan tiket
  void resetSelectedTickets() {
    selectedTickets.clear();
  }

  // Fungsi untuk mendapatkan tiket yang dipilih dengan detail
  List<Map<String, dynamic>> getSelectedTicketsWithDetails() {
    List<Map<String, dynamic>> result = [];
    selectedTickets.forEach((category, quantity) {
      final ticket = getTicketByCategory(category);
      if (ticket != null) {
        result.add({
          'ticket': ticket,
          'quantity': quantity,
          'totalPrice': ticket.price * quantity,
        });
      }
    });
    return result;
  }
}
