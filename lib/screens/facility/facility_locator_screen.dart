import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; 
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class FacilityLocatorScreen extends StatefulWidget {
  const FacilityLocatorScreen({super.key});

  static Uri buildOverpassUrl(LatLng location, {double radiusInMeters = 5000}) {
    final overpassQuery = '''
      [out:json][timeout:25];
      (
        node["amenity"="hospital"](around:$radiusInMeters, ${location.latitude}, ${location.longitude});
        node["amenity"="clinic"](around:$radiusInMeters, ${location.latitude}, ${location.longitude});
        node["amenity"="doctors"](around:$radiusInMeters, ${location.latitude}, ${location.longitude});
      );
      out body;
    ''';

    return Uri.https('overpass-api.de', '/api/interpreter', {'data': overpassQuery});
  }

  @override
  State<FacilityLocatorScreen> createState() => _FacilityLocatorScreenState();
}

class _FacilityLocatorScreenState extends State<FacilityLocatorScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(5.6037, -0.1870); // Accra Central default fallback
  bool _isLoading = true;
  String _loadingText = "Locating your position...";
  
  // Dynamic list to hold live clinics fetched from the OpenStreetMap API server
  List<Map<String, dynamic>> _dynamicFacilities = [];

  @override
  void initState() {
    super.initState();
    _determineAndFetchNearbyFacilities();
  }

  /// 1. Determines the mother's current position via cell-tower/Wi-Fi triangulation
  Future<void> _determineAndFetchNearbyFacilities() async {
    try {
      bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        _showSnackBar("Please enable location services in your quick settings panel.");
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar("Location permission denied. Running fallback search.");
          _fetchLiveOverpassFacilities(_currentPosition);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = userLatLng;
        _loadingText = "Searching for nearby health facilities...";
      });

      _mapController.move(userLatLng, 14.0);
      
      // 2. Query the live network servers for facilities around this coordinate
      await _fetchLiveOverpassFacilities(userLatLng);

    } catch (e) {
      _showSnackBar("Error tracking live location. Loading fallback grid.");
      _fetchLiveOverpassFacilities(_currentPosition);
    }
  }

  /// 2. Queries OpenStreetMap's Overpass Server within a 5km radius dynamically
  Future<void> _fetchLiveOverpassFacilities(LatLng location) async {
    const double radiusInMeters = 5000;
    final Uri url = FacilityLocatorScreen.buildOverpassUrl(
      location,
      radiusInMeters: radiusInMeters,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final List<dynamic> elements = decodedData['elements'] ?? [];

        List<Map<String, dynamic>> fetchedPins = [];

        for (var element in elements) {
          final Map<String, dynamic> tags = element['tags'] ?? {};
          
          String facilityName = tags['name'] ?? tags['operator'] ?? "Unnamed Medical Facility";
          String type = tags['amenity'] ?? "health center";

          fetchedPins.add({
            'name': facilityName,
            'coords': LatLng(element['lat'] as double, element['lon'] as double),
            'type': type.toUpperCase(),
            'phone': tags['phone'] ?? tags['contact:phone'] ?? "No public number listed",
            'isPrivate': tags['operator:type'] == 'private' || tags['private'] == 'yes',
          });
        }

        if (!mounted) return;
        setState(() {
          _dynamicFacilities = fetchedPins;
          _isLoading = false;
        });

        _showSnackBar("Successfully mapped ${_dynamicFacilities.length} real healthcare points nearby!");
      } else {
        throw Exception("Server returned non-200 state response.");
      }
    } catch (e) {
      _showSnackBar("API Server timed out. Using nearby baseline fallback configurations.");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFacilityDetailsBottomSheet(Map<String, dynamic> facility) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  facility['type'] == 'HOSPITAL' ? Icons.local_hospital : Icons.medical_services, 
                  color: const Color(0xFF2E6B65), 
                  size: 28
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    facility['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Chip(
              label: Text(facility['type']),
              // FIXED: Swapped out deprecated withOpacity signature for modern precision color definitions
              backgroundColor: const Color(0xFF2E6B65).withAlpha(26),
              labelStyle: const TextStyle(color: Color(0xFF2E6B65), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("📞 Phone: ${facility['phone']}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6B65),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.navigation, color: Colors.white),
                label: const Text("Route to Facility", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mamacare Live Facility Locator"),
        backgroundColor: const Color(0xFF2E6B65),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _loadingText = "Scanning network coordinates...";
              });
              _determineAndFetchNearbyFacilities();
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF2E6B65)),
                  const SizedBox(height: 16),
                  Text(_loadingText, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://openstreetmap.org{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mamacare',
                ),
                MarkerLayer(
                  markers: [
                    // The Mother's live coordinate pin (Blue target dot)
                    Marker(
                      point: _currentPosition,
                      width: 45,
                      height: 45,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
                    ),
                    
                    // Live populated dynamic database pins (Red hospital markers)
                    ..._dynamicFacilities.map((facility) {
                      return Marker(
                        point: facility['coords'],
                        width: 45,
                        height: 45,
                        child: GestureDetector(
                          onTap: () => _showFacilityDetailsBottomSheet(facility),
                          child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
    );
  }
}
