import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// class PlacesService {
//   final String apiKey = dotenv.env['MAPS_API_KEY']!;

//   Future<List<Map<String, dynamic>>> getNearbyRestaurants({
//     required double lat,
//     required double lng,
//     double radiusInMeters = 1000,
//   }) async {
//     final url = Uri.parse(
//       'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
//       'location=$lat,$lng&radius=$radiusInMeters&type=restaurant&key=$apiKey',
//     );

//     final response = await http.get(url);
//     final data = json.decode(response.body);

//     if (data['status'] == 'OK') {
//       return List<Map<String, dynamic>>.from(data['results']);
//     } else {
//       throw Exception('Places API error: ${data['status']}');
//     }
//   }
// }

class PlacesService {
  Future<Map<String, dynamic>?> getNearbyRestaurant(LatLng location) async {
    final key = dotenv.env['MAPS_API_KEY'];
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=1000&type=restaurant&key=$key';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      return data['results'][0];
    }
    return null;
  }

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    final key = dotenv.env['MAPS_API_KEY'];
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=walking&key=$key';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final steps = data['routes'][0]['legs'][0]['steps'] as List;
    return steps
        .map((s) => LatLng(s['end_location']['lat'], s['end_location']['lng']))
        .toList();
  }
}
