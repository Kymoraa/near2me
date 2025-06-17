import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final LatLng _center = LatLng(-1.2921, 36.8219); // Nairobi default
  LatLng? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select a Location")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 13.0,
          onTap: (tapPos, latlng) {
            setState(() {
              _selected = latlng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          if (_selected != null)
            MarkerLayer(
              markers: [
                Marker(
                  height: 80,
                  width: 80,
                  point: _selected!,
                  child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selected != null) {
            Navigator.pop(
              context,
              "Lat: ${_selected!.latitude.toStringAsFixed(4)}, Lng: ${_selected!.longitude.toStringAsFixed(4)}",
            );
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
