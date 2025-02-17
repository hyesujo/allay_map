
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getgeoLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}