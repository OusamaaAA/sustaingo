import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/buttons/secondary_button.dart';
import '../findRestaurants/location_service.dart';
import '../../services/location_api.dart';
import '../findRestaurants/find_restaurants_screen.dart';
import '../../constants.dart';

class LocationScreen extends StatefulWidget {
  final String authToken;
  const LocationScreen({Key? key, required this.authToken}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  double? _lat, _lng;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _updateMarker(LatLng point) {
    setState(() {
      _lat = point.latitude;
      _lng = point.longitude;
    });
  }

  Future<void> _saveLocation() async {
    try {
      await LocationApi.saveLocation(
        latitude: _lat!,
        longitude: _lng!,
        authToken: widget.authToken,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('savedLat', _lat!);
      await prefs.setDouble('savedLng', _lng!);
      await prefs.setBool('locationSet', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FindRestaurantsScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Location Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Location')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(_lat!, _lng!),
          zoom: 15.0,
          onTap: (_, point) => _updateMarker(point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_lat!, _lng!),
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
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
          press: _saveLocation,
          child: const Text('Save & Continue'),
        ),
      ),
    );
  }
}
