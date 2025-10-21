import 'package:geolocator/geolocator.dart';
import 'package:tixcycle/services/location_services.dart';

class LocationRepository {
  final LocationServices _locationService;

  LocationRepository(this._locationService);

  Future<String> fetchCurrentCity() async {
    try{
      Position? position = await _locationService.getCurrentPosition();

      if(position!=null){
        return await _locationService.getCityFromPosition(position);
      } else {
        return "Tidak dapat memperoleh posisi saat ini";

      }
    } catch (e){
      print("Error in LocationRepository: $e");
      return "Gagal memuat lokasi";
    }
  }
}