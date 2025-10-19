import 'package:get/get.dart';
import 'package:tixcycle/repositories/location_repository.dart';

class LocationController extends GetxController {
  final LocationRepository _locationRepository;
  LocationController(this._locationRepository);

  var currentCity = 'Memuat lokasi...'.obs;
  var isLoading = false.obs;

  @override
  void onInit(){
    super.onInit();
  }

  Future<void> getMyCity()async{
    try{
      isLoading(true);
      final city = await _locationRepository.fetchCurrentCity();
      currentCity.value = city;
    } catch(e){
      currentCity.value = "Gagal memuat lokasi";
      Get.snackbar("Error", e.toString());
    } finally{
      isLoading(false);
    }
  }
}