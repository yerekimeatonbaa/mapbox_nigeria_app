import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapbox Nigeria App',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  bool _isMapLoading = true;
  String? _errorMessage;

  // Corrected: Use Point instead of LngLat with Position for coordinates
  final Point nigeriaCenter = Point(
    coordinates: Position(8.6753, 9.0820), // Correct order: (lng, lat)
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapbox - Nigeria")),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            onMapCreated: onMapCreated,
          ),
          if (_isMapLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Loading map...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Error: $_errorMessage",
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Map creation callback with error handling
  Future<void> onMapCreated(MapboxMap map) async {
    try {
      // Store the map instance in your state
      setState(() {
        mapboxMap = map;
        _errorMessage = null;
      });

      // Set the map style
      await map.style.setStyleURI('mapbox://styles/mapbox/streets-v12');

      // Set the initial camera position
      map.camera.easeTo(
        CameraOptions(
          center: nigeriaCenter,
          zoom: 5.0,
        ),
        MapAnimationOptions(duration: 0, startDelay: 0),
      );

      // Update loading state
      setState(() {
        _isMapLoading = false;
      });
    } catch (e) {
      print("Error initializing map: $e");
      setState(() {
        _isMapLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    mapboxMap?.dispose();
    super.dispose();
  }
}