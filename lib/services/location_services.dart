import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationServices {
  Future<bool> _handleLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted){
      return true;
    }
    if (status.isPermanentlyDenied){
      await openAppSettings();
    }
    return false;
  }

  Future<Position?> getCurrentPosition()async{
    final hasPermission = await _handleLocationPermission();
    if(!hasPermission)return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      print("Error getting current position: $e");
      return null;
    }

  }

  Future<String> getCityFromPosition(Position position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String? district = place.subAdministrativeArea; // Nama Kota/Kabupaten
      String? city = place.locality;                // Nama Kecamatan (atau kadang Kota)

      if (district != null && district.isNotEmpty) {
        
        return district
            .replaceFirst("Kabupaten ", "")
            .replaceFirst("Kota ", "");
      }
      
      else if (city != null && city.isNotEmpty) {
        return city;
      }
      
    }
    return "Lokasi tidak diketahui"; // jika tidak ada data
  } catch (e) {
    print("Error converting coordinates to city: $e");
    return "Gagal mendapatkan lokasi";
  }
}

  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return Position(
          latitude: loc.latitude,
          longitude: loc.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0, 
          altitudeAccuracy: 0, 
          headingAccuracy: 0
        );
      }
      return null;
    } catch (e) {
      print("Error geocoding address: $e");
      return null;
    }
  }
}