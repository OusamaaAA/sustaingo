// ✅ FINAL: find_restaurants_screen.dart (Lebanon-only + reordered UI)
// - Reorders "Use Current Location" between saved address and search

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_manager.dart';
import '../findRestaurants/location_service.dart' as restaurant_loc;
import '../findRestaurants/location_service.dart' hide LocationService;
import '../geolocator/location_api.dart' as geo_loc;

class FindRestaurantsScreen extends StatefulWidget {
  const FindRestaurantsScreen({Key? key}) : super(key: key);

  @override
  State<FindRestaurantsScreen> createState() => _FindRestaurantsScreenState();
}

class _FindRestaurantsScreenState extends State<FindRestaurantsScreen> {
  List<dynamic> _savedLocations = [];
  List<dynamic> _suggestions = [];
  String? _selectedLocationId;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse(
        'https://sustaingobackend.onrender.com/api/user-locations/',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _savedLocations = data;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _onSelectLocation(String id) async {
    final selected = _savedLocations.firstWhere(
      (loc) => loc['id'].toString() == id,
    );
    final name = selected['name'] as String;
    final lat = double.tryParse(selected['latitude'].toString());
    final lng = double.tryParse(selected['longitude'].toString());
    await LocationManager.update(name, lat: lat, lng: lng);
    if (!mounted) return;
    Navigator.of(context).pop(name);
  }

  Future<void> _useCurrentLocation() async {
    try {
      final Position position =
          await geo_loc.LocationService.getCurrentLocation();
      if (!mounted) return;
      await _showNameDialog(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&countrycodes=lb&format=json&addressdetails=1&limit=5',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        setState(() => _suggestions = results);
      }
    } catch (_) {
      setState(() => _suggestions = []);
    }
  }

  Future<void> _showNameDialog(double lat, double lng) async {
    _customNameController.clear();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Name This Location'),
            content: TextField(
              controller: _customNameController,
              decoration: const InputDecoration(hintText: 'e.g. Office, Home'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final name =
                      _customNameController.text.trim().isEmpty
                          ? 'Unnamed Location'
                          : _customNameController.text.trim();

                  try {
                    await geo_loc.LocationApi.updateLocation(
                      name: name,
                      latitude: lat,
                      longitude: lng,
                      authToken: token!,
                    );

                    // Refresh the list
                    await _loadSavedLocations();

                    if (!mounted) return;
                    Navigator.pop(context);
                    Navigator.pop(context, name);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to save location: ${e.toString()}',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose or Select Location',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2d6a4f),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a saved location:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedLocationId,
              items:
                  _savedLocations
                      .map<DropdownMenuItem<String>>(
                        (loc) => DropdownMenuItem(
                          value: loc['id'].toString(),
                          child: Text(loc['name'] ?? 'Unnamed Location'),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedLocationId = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Choose your saved address',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  _selectedLocationId == null
                      ? null
                      : () => _onSelectLocation(_selectedLocationId!),
              child: const Text('Use Selected Location'),
            ),
            const Divider(height: 30),
            const Text(
              'Or use your current location:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Use Current Location (GPS)'),
              onPressed: _useCurrentLocation,
            ),
            const Divider(height: 30),
            const Text(
              'Search for a location :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: _fetchSuggestions,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. Beirut, Saida, Tripoli',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _suggestions.isEmpty
                      ? const SizedBox.shrink()
                      : ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final place = _suggestions[index];
                          return ListTile(
                            title: Text(place['display_name'] ?? ''),
                            onTap: () {
                              final lat = double.tryParse(place['lat'] ?? '');
                              final lng = double.tryParse(place['lon'] ?? '');
                              if (lat != null && lng != null) {
                                _showNameDialog(lat, lng);
                              }
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
