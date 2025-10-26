# PANDUAN PENGGUNAAN BELI TIKET CONTROLLER (untuk beli tiket)

## Instalasi & Navigasi
    - kirim eventId sebagai parameter ketika navigasi ke halaman ini.
    - contoh:
        ElevatedButton(
        child: Text("Buy Ticket"),
        onPressed: () {
            // Gunakan ID event saat bernavigasi
            Get.toNamed(AppRoutes.BELI_TIKET.replaceAll(':id', eventId));
        },
        )
    - extends page beli tiket ke GetView<TicketPurchaseController>
    - contoh inisiasi:
        // 1. Gunakan 'GetView<TicketPurchaseController>'
        class BeliTiket extends GetView<TicketPurchaseController> {
            const BeliTiket({Key? key}) : super(key: key);

            @override
            Widget build(BuildContext context) {
                return Scaffold(
                appBar: AppBar(title: const Text("Pilih Tiket Anda")),
                // 2. Bungkus body dengan Obx untuk loading awal
                body: Obx(() {
                    if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                    }

                    // 3. Tampilkan konten utama setelah loading selesai
                    return Column(
                    children: [
                        // Bagian 1: Daftar tiket yang tersedia
                        Expanded(
                        child: _buildAvailableTicketList(),
                        ),
                        
                        // Bagian 2: Ringkasan keranjang di bagian bawah
                        _buildCartSummary(),
                    ],
                    );
                }),
                );
            }
        }

## Penggunaan variabel reaktif
### Bagian daftar tiket
    - gunakan variabel reaktif availableTicket sebagai daftar tiket yang tersedia untuk event yang bersangkutan
    - contoh:
        Widget _buildAvailableTicketList() {
            // 'availableTickets' adalah RxList, otomatis ter-update
            return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.availableTickets.length,
                itemBuilder: (context, index) {
                final ticket = controller.availableTickets[index];

                // TODO: Ganti Card ini dengan desain Anda (dari Beli Tiket-1.png)
                return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Text(ticket.categoryName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ElevatedButton(
                                child: const Text("Tambah"),
                                // Panggil metode controller saat tombol ditekan
                                onPressed: () => controller.addTicketToCart(ticket),
                            ),
                            ],
                        ),
                        Text("Rp ${ticket.price.toStringAsFixed(0)}"),
                        const SizedBox(height: 8),
                        Text(ticket.description ?? ''),
                        ],
                    ),
                    ),
                );
                },
            );
            }

### Bagian keranjang paling bwawah
    - gunakan cartItems untuk daftar tiket yang dipilih dan totalPrice untuk total harga semua tiket di keranjang
    - jangan lupa bungkus dengan obx agar bisa rebuild
    - contoh:
        Widget _buildCartSummary() {
            // Bungkus dengan Obx agar update saat cartItems atau totalPrice berubah
            return Obx(() {
                // Jangan tampilkan apapun jika keranjang kosong
                if (controller.cartItems.isEmpty) {
                return const SizedBox.shrink();
                }

                // Tampilan ini sesuai dengan Beli Tiket-2.png
                return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                    ),
                    ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // Gunakan ListView.builder untuk item di keranjang
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.cartItems.length,
                        itemBuilder: (context, index) {
                        final item = controller.cartItems[index];
                        // PENTING: Bungkus item list dengan Obx agar quantity (1x, 2x)
                        // bisa update secara individual.
                        return Obx(() => ListTile(
                            title: Text(item.ticket.categoryName),
                            trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                // Tombol Kurang (-)
                                IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => controller.removeTicketFromCart(item),
                                ),
                                Text(
                                "${item.quantity.value}x", // Ambil dari .quantity.value
                                style: const TextStyle(fontSize: 16),
                                ),
                                // Tombol Tambah (+)
                                IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                // Asumsi CartItemModel punya metode incrementQuantity()
                                onPressed: () => controller.addTicketToCart(item.ticket),
                                ),
                            ],
                            ),
                        ));
                        },
                    ),

                    const Divider(height: 24),

                    // Tampilan Total Harga
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        // Ambil .value dari totalPrice
                        Text(
                            "Rp ${controller.totalPrice.value.toStringAsFixed(0)}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        ],
                    ),
                    const SizedBox(height: 16),

                    // Tombol Lanjutkan
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Lanjutkan"),
                        onPressed: () {
                        // TODO: Navigasi ke halaman checkout/pembayaran
                        // Get.toNamed('/checkout', arguments: controller.cartItems);
                        },
                    ),
                    ],
                ),
                );
            });
            }