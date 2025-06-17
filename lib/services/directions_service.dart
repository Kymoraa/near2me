import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  final String apiKey = dotenv.env['MAPS_API_KEY']!;

  Future<List<LatLng>> getWalkingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=walking&key=$apiKey',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] != 'OK') {
      throw Exception('Directions API error: ${data['status']}');
    }

    final points = data['routes'][0]['overview_polyline']['points'];
    final decoded = PolylinePoints().decodePolyline(points);

    return decoded.map((e) => LatLng(e.latitude, e.longitude)).toList();
  }
}
