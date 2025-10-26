import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import '../controllers/beranda_controller.dart';
import '../models/event_model.dart';
import '../routes/app_routes.dart';

class PencarianTiketPage extends StatefulWidget {
  final String? initialQuery;

  const PencarianTiketPage({super.key, this.initialQuery});

  @override
  State<PencarianTiketPage> createState() => _PencarianTiketPageState();
}

class _PencarianTiketPageState extends State<PencarianTiketPage> {
  late final TextEditingController _searchController;
  // late final SearchController searchController; // Diganti
  late final BerandaController searchController; // Diganti

  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    // searchController = Get.put(SearchController()); // Diganti
    searchController = Get.find<BerandaController>(); // Diganti (mengambil controller yang sudah ada)
    
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      // searchController.setSearchQuery(widget.initialQuery!); // Diganti
      searchController.onSearchQueryChanged(widget.initialQuery!); // Diganti
    } else {
      // Pastikan search query di controller beranda kosong saat masuk halaman ini
      searchController.onSearchQueryChanged('');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Kosongkan query pencarian di BerandaController saat keluar
    searchController.onSearchQueryChanged('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2, c3, c4],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'TixCycle',
            style: TextStyle(
                color: Color(0xFF314417), fontWeight: FontWeight.w700),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchBar(context),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildHasilPencarian(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true, // Otomatis fokus saat halaman dibuka
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan event atau tempat',
                hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                // searchController.setSearchQuery(value); // Diganti
                searchController.onSearchQueryChanged(value); // Diganti
              },
              onSubmitted: (value) {
                // searchController.setSearchQuery(value); // Diganti
                searchController.onSearchQueryChanged(value); // Diganti
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                // searchController.clearSearch(); // Diganti
                searchController.onSearchQueryChanged(""); // Diganti
              },
              child: const Icon(Icons.clear, color: Colors.black54, size: 20),
            ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: c1,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c3, width: 1),
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.tune, color: Colors.black87, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHasilPencarian(BuildContext context) {
    return Obx(() {
      // if (searchController.isLoading.value) { // Dihapus
      //   return const Center(
      //     child: CircularProgressIndicator(),
      //   );
      // }

      if (searchController.searchQuery.value.isEmpty) {
        return _buildEmptyState();
      }

      // if (searchController.searchResults.isEmpty) { // Diganti
      if (searchController.recommendedEvents.isEmpty) { // Diganti
        return _buildNoResultsState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // 'Hasil Pencarian (${searchController.searchResults.length})', // Diganti
            'Hasil Pencarian (${searchController.recommendedEvents.length})', // Diganti
            style: TextStyle(
              color: c4,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // ...searchController.searchResults // Diganti
          ...searchController.recommendedEvents // Diganti
              .map((event) => _buildEventCard(event))
              .toList(),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 200.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Cari event atau konser favorit Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan nama event, lokasi, atau venue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 200.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba kata kunci yang berbeda',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail event
          Get.toNamed('${AppRoutes.BERANDA}${AppRoutes.LIHAT_TIKET}/${event.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // child: Image.asset( // Diganti
                child: Image.network( // Diganti
                  event.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  // Error handling untuk gambar network
                  errorBuilder: (context, error, stackTrace) => 
                    Container(width: 80, height: 80, color: Colors.grey[200], child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        color: c4,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            // '${event.address} • ${event.venueName}', // Diganti agar lebih ringkas
                            '${event.venueName}, ${event.city}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mulai dari Rp${event.startingPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          style: TextStyle(
                            color: c2,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: c1,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c2, width: 1),
                          ),
                          child: Text(
                            'Lihat Detail',
                            style: TextStyle(
                              color: c4,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}