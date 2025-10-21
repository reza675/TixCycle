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

  Future<String> fetchCityFromCoordinates(double latitude, double longitude) async {
    try {
      final position = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0,
        heading: 0.0,
        headingAccuracy: 0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      return await _locationService.getCityFromPosition(position);
    } catch (e) {
      print("Error in LocationRepository (fetchCityFromCoordinates): $e");
      rethrow;
    }
  }
}