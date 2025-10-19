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
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if(placemarks.isNotEmpty){
        String? city = placemarks[0].locality;          // kota
        String? district = placemarks[0].subAdministrativeArea; // kabupaten  

        if(city!=null && city.isNotEmpty){
          return city;
        } else if(district!=null && district.isNotEmpty){
          return district.replaceFirst("Kabupaten ", "");
        } 
      }
      return "kota/kabupaten tidak diketahui";
    } catch(e){
      print("Error converting coordinates to city: $e");
      return "Gagal mendapatkan nama kota/kabupaten";
    }
  }
}