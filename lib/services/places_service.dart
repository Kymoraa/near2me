import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
}
