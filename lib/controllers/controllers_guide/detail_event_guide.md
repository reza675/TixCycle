# PANDUAN PENGGUNAAN EVENT DETAIL CONTROLLER (untuk halaman lihat tiket)

## Navigasi ke halaman ini
    - gunakan Get.toNamed(), isi dengan id event
    - contoh:
        Get.toNamed('/lihat_tiket/${event.id}');

## Instalasi & inisiasi
    - extends class view ke GetView<DetailEventController>
    - contoh:
        import 'package:flutter/material.dart';
        import 'package:get/get.dart';
        import 'package:tixcycle/controllers/detail_event_controller.dart';

        // 1. Gunakan 'GetView<DetailEventController>'
        class LihatTiketPage extends GetView<DetailEventController> {
        const LihatTiketPage({Key? key}) : super(key: key);

        @override
        Widget build(BuildContext context) {
            return Scaffold(
            appBar: AppBar(title: const Text("Detail Event")),
            body: _buildBody(context),
            );
        }

        Widget _buildBody(BuildContext context) {
            // 2. Selalu bungkus widget reaktif dengan Obx
            return Obx(() {
            // 3. Gunakan state 'isLoading' untuk loading awal
            if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
            }

            // 4. Cek apakah event berhasil dimuat
            if (controller.event.value == null) {
                return const Center(child: Text("Event tidak ditemukan."));
            }

            // 5. Setelah selesai, tampilkan semua konten utama
            // Gunakan ListView agar halaman bisa di-scroll
            return ListView(
                children: [
                // Bagian 1: Poster Event
                _buildEventHeader(),

                // Bagian 2: Info Detail (Nama, Tanggal, Lokasi)
                _buildEventDetails(),

                // Bagian 3: Daftar Tiket yang Tersedia
                _buildTicketList(),

                // Bagian 4: Tombol Beli Tiket (sticky di bawah)
                // (Ini biasanya diletakkan di luar ListView, di dalam Scaffold)
                ],
            );
            });
        }
        }

## Menggunakan variabel reaktif (dari getx)

### bagian detail event 
        - gunakan state event (tipe Rx<EventModel>)
        - event bisa null, jadi selalu akses datanya menggunakan controller.event.value? (dengan tanda tanya)
        - contoh:
            Widget _buildEventHeader() {
                // Ambil URL gambar dari state 'event'
                final imageUrl = controller.event.value?.imageUrl ?? 'URL_PLACEHOLDER';
                return Image.network(
                    imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                );
                }

                Widget _buildEventDetails() {
                final event = controller.event.value;
                if (event == null) return const SizedBox.shrink();

                return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Tampilkan Nama Event
                        Text(
                        event.name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        // Tampilkan Info Tanggal
                        InfoRow(
                        icon: Icons.calendar_today,
                        text: "${event.date.day}/${event.date.month}/${event.date.year}",
                        ),
                        const SizedBox(height: 8),

                        // Tampilkan Info Lokasi
                        InfoRow(
                        icon: Icons.location_on,
                        text: "${event.venueName}, ${event.city}",
                        ),
                        const SizedBox(height: 16),
                        
                        // Tampilkan Deskripsi
                        Text(
                        "Deskripsi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(event.description),

                        // TODO: Tambahkan tombol "Lihat di Peta" di sini
                        // Anda bisa gunakan event.latitude dan event.longitude
                    ],
                    ),
                );
                }

                // Widget helper untuk baris info
                class InfoRow extends StatelessWidget {
                final IconData icon;
                final String text;
                const InfoRow({Key? key, required this.icon, required this.text}) : super(key: key);

                @override
                Widget build(BuildContext context) {
                    return Row(
                    children: [
                        Icon(icon, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
                    ],
                    );
                }
                }
    
### bagian daftar tiket
        - gunakan state tickets (tipe RxList<TicketModel>)
        - contoh:
             Widget _buildTicketList() {
                if (controller.tickets.isEmpty) {
                    return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("Tiket untuk event ini belum tersedia."),
                    ));
                }

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Text(
                        "Pilih Tiket Anda",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                    ),
                    
                    // Gunakan ListView.builder untuk menampilkan daftar tiket
                    // physics: NeverScrollableScroll() dan shrinkWrap: true
                    // diperlukan karena ini ada di dalam ListView utama.
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: controller.tickets.length,
                        itemBuilder: (context, index) {
                        final ticket = controller.tickets[index];
                        
                        // TODO: Ganti Card ini dengan Card Tiket Anda
                        return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                Expanded(
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(ticket.categoryName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text("Rp ${ticket.price}", style: TextStyle(fontSize: 16, color: Colors.blue)),
                                        Text(ticket.description ?? '', style: TextStyle(color: Colors.grey[600])),
                                    ],
                                    ),
                                ),
                                // Tombol ini akan mengarahkan ke halaman Beli Tiket
                                ElevatedButton(
                                    child: Text("Tambah"),
                                    onPressed: () {
                                    // TODO: Navigasi ke halaman Beli Tiket
                                    // Get.toNamed(AppRoutes.BELI_TIKET);
                                    // Anda mungkin perlu controller baru (misal: TicketPurchaseController)
                                    // untuk mengelola keranjang belanja.
                                    },
                                )
                                ],
                            ),
                            ),
                        );
                        },
                    ),
                    ],
                );
                }
        