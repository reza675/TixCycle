import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/beli_tiket_controller.dart';
import '../models/ticket_model.dart';
import '../models/cart_item_model.dart';

class BeliTiket extends GetView<BeliTiketController> {
  const BeliTiket({super.key});

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
          colors: [c1, c2, c3, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back,
              color: c4,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'TixCycle',
            style: TextStyle(
              color: c4,
              fontSize: 28,
              fontWeight: FontWeight.w400,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black26,
                  offset: Offset(4, 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c2, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pilih Tiket Anda',
                style: TextStyle(
                  color: c4,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...controller.availableTickets.map((ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTicketCard(ticket),
                      )),
                  const SizedBox(height: 20),
                  if (controller.cartItems.isNotEmpty) _buildCartSummary(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTicketCard(TicketModel ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c2, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.categoryName,
                      style: TextStyle(
                        color: c4,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      'Rp ${ticket.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: c4.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Obx(() {
                final cartItem = controller.cartItems
                    .firstWhereOrNull((item) => item.ticket.id == ticket.id);
                final isSelected = cartItem != null;
                final int currentQuantity = cartItem?.quantity.value ?? 0;
                final int remainingStock = ticket.stock - currentQuantity;
                final bool isStockAvailable = currentQuantity < ticket.stock;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isSelected ? 'Sisa: $remainingStock' : 'Stok: ${ticket.stock}',
                      style: TextStyle(
                        color: remainingStock > 0 ? c3 : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        if (isSelected) ...[
                          GestureDetector(
                            onTap: () {
                              if (cartItem != null) {
                                controller.removeTicketFromCart(cartItem);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: c2,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$currentQuantity',
                            style: TextStyle(
                              color: c4,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        GestureDetector(
                          onTap: isStockAvailable
                              ? () => controller.addTicketToCart(ticket)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isStockAvailable ? c2 : Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          if (ticket.description != null && ticket.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              ticket.description!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildCartSummary() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c1,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c2, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiket yang Dipilih:',
                style: TextStyle(
                  color: c4,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...controller.cartItems
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.ticket.categoryName} (${item.quantity.value}x)',
                              style: TextStyle(
                                color: c4,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Rp ${(item.ticket.price * item.quantity.value).toStringAsFixed(0)}',
                              style: TextStyle(
                                color: c4,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              const Divider(color: c2, thickness: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total :',
                    style: TextStyle(
                      color: c4,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rp ${controller.totalPrice.value.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: c4,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.cartItems.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Silakan pilih tiket terlebih dahulu',
                        backgroundColor: c2.withOpacity(0.8),
                        colorText: Colors.white,
                      );
                      return;
                    }
                    // TODO: Implement checkout logic
                    Get.toNamed('/checkout');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c2,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
