import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tixcycle/views/widgets/bottom_bar.dart';
import 'package:tixcycle/views/pencarian_tiket.dart';
import 'package:tixcycle/controllers/search_controller.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        extendBody: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'Hello, Greenies',
                      style: TextStyle(
                        color: const Color(0xFF314417),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(4, 4)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox.shrink(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSearchBar(context),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBannerCard(),
                      const SizedBox(height: 16),
                      Text(
                        'Lokasi',
                        style: TextStyle(
                          color: const Color(0xFF314417),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(
                                blurRadius: 10.0,
                                color: Colors.black26,
                                offset: Offset(4, 4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLocationsRow(),
                      const SizedBox(height: 16),
                      Text(
                        'Rekomendasi',
                        style: TextStyle(
                          color: const Color(0xFF314417),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(
                                blurRadius: 10.0,
                                color: Colors.black26,
                                offset: Offset(4, 4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRecommendationCard('images/beranda/tampilan2.png'),
                      const SizedBox(height: 12),
                      _buildRecommendationCard('images/beranda/tampilan1.jpg'),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CurvedBottomBar(
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CenterActionButton(
          onPressed: () => setState(() => currentIndex = 2),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const PencarianTiketPage());
      },
      child: Container(
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
            const Expanded(
              child: Text(
                'Cari berdasarkan event atau tempat',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
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
      ),
    );
  }

  Widget _buildBannerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Image.asset(
            'images/beranda/tampilan2.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsRow() {
    final List<Map<String, String>> locations = [
      {'name': 'Yogyakarta', 'img': 'images/beranda/tampilan1.jpg'},
      {'name': 'Jakarta', 'img': 'images/beranda/tampilan2.png'},
      {'name': 'Bandung', 'img': 'images/beranda/tampilan1.jpg'},
      {'name': 'Kalimantan', 'img': 'images/beranda/tampilan2.png'},
      {'name': 'Bogor', 'img': 'images/beranda/tampilan1.jpg'},
      {'name': 'Semarang', 'img': 'images/beranda/tampilan2.png'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: c1.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: locations
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(e['img']!),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: c3, width: 2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        e['name']!,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(String asset) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
          color: c1,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    ),  
      const SizedBox(height: 16),
   ],
      
    );
  }
}

//
