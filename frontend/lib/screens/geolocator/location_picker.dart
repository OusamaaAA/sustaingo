import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants.dart';
import '../../components/buttons/secondary_button.dart';

/// A full-screen map widget that shows a tappable marker to select location.
/// initialLat / initialLng come from GPS; user can tap on map to pick.
class LocationPicker extends StatefulWidget {
  final double initialLat, initialLng;
  final void Function(double lat, double lng) onLocationPicked;

  const LocationPicker({
    Key? key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationPicked,
  }) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late LatLng _pickedPoint;

  @override
  void initState() {
    super.initState();
    _pickedPoint = LatLng(widget.initialLat, widget.initialLng);
  }

  void _updatePoint(LatLng p) {
    setState(() => _pickedPoint = p);
    widget.onLocationPicked(p.latitude, p.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Your Location')),
      body: FlutterMap(
        options: MapOptions(
          center: _pickedPoint,
          zoom: 15.0,
          onTap: (_, latlng) => _updatePoint(latlng),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _pickedPoint,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: SecondaryButton(
          press: () => Navigator.of(context).pop(),
          child: const Text('Confirm'),
        ),
      ),
    );
  }
}
