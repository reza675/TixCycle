# PANDUAN PENGGUNAAN BERANDA CONTROLLER

## Instalasi dan inisiasi
    - extends class view ke GetView<BerandaController>
    - contoh:
    import 'package:flutter/material.dart';
    import 'package:get/get.dart';
    import 'package:tixcycle/controllers/beranda_controller.dart';

    // 1. Gunakan 'GetView<BerandaController>'
    class BerandaPage extends GetView<BerandaController> {
    const BerandaPage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(title: const Text("TixCycle")),
        body: _buildBody(context),
        );
    }

    Widget _buildBody(BuildContext context) {
        // 2. Selalu widget reaktif dengan Obx
        return Obx(() {
        // 3. Gunakan state 'isLoading' untuk loading awal
        if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
        }

        // 4. Setelah selesai, tampilkan semua konten utama
        return Column(
            children: [
            // Bagian 1: Search Bar
            _buildSearchbar(),
            
            // Gunakan Expanded agar daftar rekomendasi bisa di-scroll
            Expanded(
                child: ListView( // Gunakan ListView agar semua bisa di-scroll
                children: [
                    // Bagian 2: Carousel Event Unggulan
                    _buildFeaturedCarousel(),

                    // Bagian 3: Daftar Lokasi (Horizontal)
                    _buildCityList(),

                    // Bagian 4: Judul "Rekomendasi"
                    _buildSectionHeader("Rekomendasi"),

                    // Bagian 5: Daftar Rekomendasi (Vertikal & Lazy Loading)
                    _buildRecommendationList(),
                ],
                ),
            ),
            ],
        );
        });
    }
    }

## Menggunakan variabel reaktif (dari getx)
### bagian search bar:
        - gunakan method onSearchQueryChanged(String query)
        - contoh:
        Widget _buildSearchbar() {
        return Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
            // Panggil metode controller setiap kali teks berubah
            onChanged: (value) => controller.onSearchQueryChanged(value),
            decoration: InputDecoration(
            hintText: "Cari event atau kota...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
        ),
        );
    }
### bagian carousel (poster event paling atas)
        - gunakan state featuredEvents
        - contoh:
          Widget _buildFeaturedCarousel() {
        // tidak perlu Obx karena sudah ada di _buildBody
        if (controller.featuredEvents.isEmpty) {
        return const SizedBox(height: 150, child: Center(child: Text("Tidak ada event unggulan.")));
        }

        // Gunakan ListView horizontal sebagai carousel sederhana
        return SizedBox(
        height: 150, // Tentukan tinggi carousel
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: controller.featuredEvents.length,
            itemBuilder: (context, index) {
            final event = controller.featuredEvents[index];
            // TODO: Ganti Container ini dengan Card Carousel Anda
            return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: NetworkImage(event.imageUrl),
                    fit: BoxFit.cover,
                ),
                ),
                child: Center(child: Text(event.name, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
            );
            },
        ),
        );
    }

### bagian daftar kota dibawah carousel
    - gunakan state cityEvents
    - contoh:
      Widget _buildSectionHeader(String title) {
        return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
        child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        );
    }

    Widget _buildCityList() {
        if (controller.cityEvents.isEmpty) {
        return const SizedBox.shrink(); // Kosong jika tidak ada kota
        }

        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            _buildSectionHeader("Lokasi"),
            SizedBox(
            height: 120, // Tentukan tinggi daftar kota
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: controller.cityEvents.length,
                itemBuilder: (context, index) {
                // Ini adalah cara mengambil data dari struktur Map
                final cityMap = controller.cityEvents[index];
                final String cityName = cityMap.keys.first;
                final EventModel event = cityMap.values.first;

                // TODO: Ganti Container ini dengan Card Lokasi Anda
                return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12.0),
                    child: Column(
                    children: [
                        CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(event.imageUrl),
                        ),
                        const SizedBox(height: 8),
                        Text(cityName, overflow: TextOverflow.ellipsis),
                    ],
                    ),
                );
                },
            ),
            ),
        ],
        );
    }

### bagian rekomendasi (daftar event paling bawah)
    - dibuat lazy build (8 data event sekali load) agar ga berat
    - gunakan:
        * recommendedEvents (Daftar event untuk ditampilkan)
        * isLoadingMore -> untuk membuat indikator loading (Cek apakah sedang loading event lagi ketika scroll)
        * hasMoreData -> untuk berhenti mencoba load (Cek apakah masih ada data event yang belum di load)
        * method loadMoreEvents() -> ketika user scroll
    - contoh: 
      Widget _buildRecommendationList() {
        // Kita harus menggunakan NotificationListener di dalam ListView
        // agar bisa mendeteksi scroll.
        // Kita gunakan physics: NeverScrollableScroll() dan shrinkWrap: true
        // karena ListView ini ada di dalam ListView lain.
        
        // Tampilkan pesan jika hasil pencarian kosong
        if (controller.recommendedEvents.isEmpty && controller.isSearchActive.value) {
        return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text("Tidak ada event yang cocok dengan pencarian Anda."),
        ));
        }
        
        // Tampilkan pesan jika tidak ada event sama sekali
        if (controller.recommendedEvents.isEmpty) {
        return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text("Belum ada event rekomendasi."),
        ));
        }

        return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
            // Logika ini akan berjalan jika scroll utama mencapai 80% ke bawah
            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8 &&
                !controller.isLoadingMore.value &&
                controller.hasMoreData.value) {
            
            // Panggil metode untuk memuat data halaman berikutnya
            controller.loadMoreEvents();
            }
            return false;
        },
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // Tambah 1 item untuk loading indicator
            itemCount: controller.recommendedEvents.length + 1,
            itemBuilder: (context, index) {
            
            // --- Logika untuk menampilkan Indikator Loading di Bawah ---
            if (index == controller.recommendedEvents.length) {
                if (controller.isLoadingMore.value) {
                return const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                ));
                } else if (!controller.hasMoreData.value) {
                return const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Semua event sudah dimuat."),
                ));
                } else {
                return const SizedBox.shrink(); // Tidak ada lagi
                }
            }

            // --- Tampilkan Item Event Biasa ---
            final event = controller.recommendedEvents[index];
            // TODO: Ganti Card ini dengan Card Rekomendasi Anda
            return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                leading: Image.network(event.imageUrl, width: 50, fit: BoxFit.cover),
                title: Text(event.name),
                subtitle: Text("${event.city}\n${event.date.toLocal().toString().split(' ')[0]}"),
                isThreeLine: true,
                onTap: () {
                    // Navigasi ke Halaman Detail
                    Get.toNamed('/lihat_tiket/${event.id}');
                },
                ),
            );
            },
        ),
        );
    }
