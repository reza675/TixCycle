import 'package:flutter/material.dart';
import 'package:tixcycle/models/user_model.dart';
import 'package:tixcycle/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:tixcycle/controllers/beranda_controller.dart';
import 'package:tixcycle/models/event_model.dart';
import 'package:tixcycle/views/widgets/bottom_bar.dart';
import 'package:tixcycle/controllers/user_account_controller.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int currentIndex = 0;

  int _currentCarouselIndex = 0;
  final List<String> _carouselImages = [
    'images/beranda/tampilan1.jpg',
    'images/beranda/tampilan2.png',
    'images/beranda/tampilan3.png',
  ];
  late final PageController _pageController;
  static const Color c1 = Color(0xFFFFF8E2);
  static const Color c2 = Color(0xFFB3CC86);
  static const Color c3 = Color(0xFF798E5E);
  static const Color c4 = Color(0xFF3F5135);

  void _handleNavigation(int index) {
    final userAccountController = Get.find<UserAccountController>();
    final bool isLoggedIn = userAccountController.firebaseUser.value != null;

    final halamanIndeks = [1, 2, 3, 4];
    if (halamanIndeks.contains(index) && !isLoggedIn) {
      Get.toNamed(AppRoutes.LOGIN);
      return;
    }
    if (index == 0) {
      setState(() {
        currentIndex = index;
      });
    } else if (index == 1) {
      Get.toNamed(AppRoutes.MY_TICKETS);
    } else if (index == 2) {
      if (userAccountController.isAdmin) {
        Get.toNamed(AppRoutes.ADMIN_SCANNER);
      } else {
        Get.toNamed(AppRoutes.SCAN);
      }
    } else if (index == 3) {
      Get.toNamed(AppRoutes.KOIN);
    } else if (index == 4) {
      Get.toNamed(AppRoutes.PROFILE);
    } else {
      Get.snackbar("Info", "Halaman ini belum diimplementasikan.");
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BerandaController>();

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
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: _buildBody(context, controller),
        ),
        bottomNavigationBar: CurvedBottomBar(
          currentIndex: currentIndex,
          onTap: (i) => _handleNavigation(i),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CenterActionButton(
          onPressed: () => _handleNavigation(2),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBody(BuildContext context, BerandaController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final UserAccountController userAccountController =
          Get.find<UserAccountController>();
      final UserModel? userProfile = userAccountController.userProfile.value;
      String displayName;
      if (userProfile != null && userProfile.username.isNotEmpty) {
        displayName = userProfile.username;
      } else {
        displayName = "Greenies"; // Fallback jika (belum login)
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Hello, $displayName!',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchbar(controller),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              margin: const EdgeInsets.only(bottom: 0),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBannerCard(),
                  const SizedBox(height: 16),
                  // Lokasi menggunakan data dari controller, fallback ke aset jika tidak ada
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text(
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
                  ),
                  const SizedBox(height: 8),
                  _buildLocationsRow(controller),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text(
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
                  ),
                  const SizedBox(height: 8),
                  if (controller.recommendedEvents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child:
                          Center(child: Text('Belum ada event rekomendasi.')),
                    )
                  else
                    Column(
                      children: controller.recommendedEvents
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: _buildRecommendationCard(e),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBannerCard() {
    final BerandaController controller = Get.find<BerandaController>();
    return Obx(() {
      final featured = controller.featuredEvents;

      // Tetap siapkan fallback jika featuredEvents kosong
      final List<String> fallbackImages = _carouselImages;
      final bool hasFeaturedEvents = featured.isNotEmpty;
      // Tentukan jumlah item berdasarkan apakah event unggulan ada atau tidak
      final int itemCount =
          hasFeaturedEvents ? featured.length : fallbackImages.length;

      if (itemCount == 0) {
        return Container(
          height: MediaQuery.of(context).size.width * (7 / 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 12, offset: Offset(0, 2)),
            ],
          ),
          child: const Center(child: Icon(Icons.image_not_supported)),
        );
      }

      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * (7 / 16),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: itemCount,
                  onPageChanged: (index) =>
                      setState(() => _currentCarouselIndex = index),
                  itemBuilder: (context, idx) {
                    String imageUrl;
                    EventModel?
                        event; // Event bisa null jika kita pakai fallback

                    if (hasFeaturedEvents) {
                      event = featured[idx];
                      imageUrl = event.imageUrl;
                    } else {
                      imageUrl = fallbackImages[idx];
                      event = null;
                    }

                    final bool isNetwork = imageUrl.startsWith('http');

                    final imageWidget = isNetwork
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: Icon(Icons.image_not_supported)),
                            ),
                          )
                        : Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: Icon(Icons.image_not_supported)),
                            ),
                          );
                    return GestureDetector(
                      onTap: () {
                        if (event != null) {
                          Get.toNamed(AppRoutes.LIHAT_TIKET
                              .replaceAll(':id', event.id));
                        }
                      },
                      child: AspectRatio(
                        aspectRatio: 16 / 7,
                        child: imageWidget,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (entry) {
              return Container(
                width: _currentCarouselIndex == entry ? 10 : 8,
                height: _currentCarouselIndex == entry ? 10 : 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == entry ? c2 : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildLocationsRow(BerandaController controller) {
    if (controller.cityEvents.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: c1.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Belum ada lokasi tersedia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: c4,
            ),
          ),
        ),
      );
    }

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: c1.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCityButton(
                  controller: controller,
                  cityName: "",
                  imageUrl: 'images/beranda/tampilan1.jpg',
                  isAsset: true,
                ),
                ...controller.cityEvents.map((cityMap) {
                  String cityName = cityMap.keys.first;
                  EventModel event = cityMap.values.first;

                  return _buildCityButton(
                    controller: controller,
                    cityName: cityName,
                    imageUrl: event.imageUrl,
                    isAsset: false, // Ini dari network
                  );
                }).toList(),
              ],
            ),
          ),
        ));
  }

  Widget _buildCityButton({
    required BerandaController controller,
    required String cityName,
    required String imageUrl,
    bool isAsset = false,
  }) {
    final bool isActive =
        (cityName.isEmpty && controller.selectedCity.value == null) ||
            (controller.selectedCity.value == cityName);

    final String label = cityName.isEmpty ? "Semua" : cityName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              controller.filterByCity(cityName);
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? c4.withOpacity(0.8) : c3,
                  width: isActive ? 3 : 2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: c4.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1)
                      ]
                    : [],
              ),
              child: ClipOval(
                child: isAsset
                    ? Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.public, color: c3),
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.location_city, color: c3),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: c4,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.brown[50],
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
        onTap: () =>
            Get.toNamed(AppRoutes.LIHAT_TIKET.replaceAll(':id', event.id)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  event.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey[400]),
                  ),
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
                            '${event.venueName}, ${event.city}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
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
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai dari Rp${event.startingPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                      style: TextStyle(
                        color: c2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildSearchbar(BerandaController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.PENCARIAN_TIKET);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c3, width: 1),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: c4),
              const SizedBox(width: 8),
              Text(
                "Cari event atau kota...",
                style: TextStyle(color: c4.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
