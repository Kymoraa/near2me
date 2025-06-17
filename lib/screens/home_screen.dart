import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:near2me/agent/suggestion_agent.dart';
import 'package:near2me/services/places_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  LatLng? _selected;
  bool _loading = false;

  LatLng? userLocation;
  LatLng? restaurantLatLng;
  Map<String, dynamic>? selectedRestaurant;

  final SuggestionAgent _agent = SuggestionAgent(dotenv.env['GEMINI_API_KEY']!);
  final PlacesService placesService = PlacesService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      _selected = userLocation;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _selected = latLng;
    });
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    final southwestLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    final southwestLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    final northeastLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    final northeastLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );
  }

  Future<void> _getSuggestion() async {
    if (_selected == null) return;
    setState(() => _loading = true);

    final timeString = TimeOfDay.now().format(context);
    final restaurant = await placesService.getNearbyRestaurant(_selected!);
    if (restaurant == null) {
      setState(() => _loading = false);
      _showError("No restaurant found nearby.");
      return;
    }

    selectedRestaurant = restaurant;
    restaurantLatLng = LatLng(
      restaurant['geometry']['location']['lat'],
      restaurant['geometry']['location']['lng'],
    );

    final suggestion = await _agent.getSuggestion(
      timeOfDay: timeString,
      userLocation: _selected!,
      restaurant: restaurant,
    );

    setState(() => _loading = false);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Top Pick For You!"),
            content: SingleChildScrollView(child: Text(suggestion)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final path = await placesService.getDirections(
                    userLocation!,
                    restaurantLatLng!,
                  );
                  setState(() {
                    _polylines = {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: path,
                        color: Colors.blue,
                        width: 5,
                      ),
                    };
                  });
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngBounds(_getBounds(path), 50),
                  );
                },
                child: const Text("Directions"),
              ),
            ],
          ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Near2Me"), centerTitle: true),
      body:
          _selected == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _selected!,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: _selected!,
                    draggable: true,
                    onDragEnd: _onMapTapped,
                  ),
                  if (restaurantLatLng != null)
                    Marker(
                      markerId: const MarkerId('restaurant'),
                      position: restaurantLatLng!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      ),
                    ),
                },
                polylines: _polylines,
                onTap: _onMapTapped,
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getSuggestion,
        label:
            _loading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text("Get Suggestion"),
        icon: const Icon(Icons.lightbulb),
      ),
    );
  }
}
