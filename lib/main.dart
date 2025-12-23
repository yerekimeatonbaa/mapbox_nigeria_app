import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Nigeria App',
      home: MapScreen(key: MapScreen.mapKey),
    );
  }
}

List<LatLng> _decodePolyline(String polyline) {
  List<LatLng> points = [];
  int index = 0, len = polyline.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static final GlobalKey<MapScreenState> mapKey = GlobalKey();

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  bool _isMapLoading = true;
  String? _errorMessage;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final TextEditingController searchController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  List<String> _suggestions = [];
  String _travelMode = 'driving';
  String? _eta;
  String? _distance;
  List<String> _instructions = [];

  @override
  void initState() {
    super.initState();
    debugPrint('API Key loaded: ${dotenv.env['GOOGLE_MAPS_API_KEY'] != null ? 'Yes' : 'No'}');
    if (dotenv.env['GOOGLE_MAPS_API_KEY'] == null ||
        dotenv.env['GOOGLE_MAPS_API_KEY']!.isEmpty) {
      setState(() {
        _isMapLoading = false;
        _errorMessage =
            'Google Maps API key is missing. Please add it to your .env file.';
      });
      return;
    }
    _getCurrentLocation();
    // Set a timeout for map loading
    Future.delayed(const Duration(seconds: 10), () {
      if (_isMapLoading && mounted) {
        setState(() {
          _isMapLoading = false;
          _errorMessage =
              'Failed to load map. Please check your internet connection and API key.';
        });
      }
    });
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _errorMessage = null;
      _isMapLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      setState(() {
        _errorMessage = 'Location services are disabled.';
        _isMapLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        setState(() {
          _errorMessage = 'Location permissions are denied';
          _isMapLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _errorMessage =
            'Location permissions are permanently denied, we cannot request permissions.';
        _isMapLoading = false;
      });
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLocation,
            infoWindow: const InfoWindow(
              title: 'Your Location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentLocation, 15.0));
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
        _isMapLoading = false;
      });
    }
  }

  void _addMarker() async {
    final LatLng center = await mapController!.getLatLng(
      ScreenCoordinate(
        x: MediaQuery.of(context).size.width.round() ~/ 2,
        y: MediaQuery.of(context).size.height.round() ~/ 2,
      ),
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(center.toString()),
          position: center,
          infoWindow: const InfoWindow(
            title: 'New Marker',
            snippet: 'This is a new marker',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  void onSearch() async {
    final String query = searchController.text;
    if (query.isEmpty) {
      return;
    }

    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$query&components=country:NG&key=$apiKey';

    debugPrint('Search URL: $url');
    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Search Response Status: ${response.statusCode}');
      debugPrint('Search Response Body: ${response.body}');
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final double lat = data['results'][0]['geometry']['location']['lat'];
        final double lng = data['results'][0]['geometry']['location']['lng'];
        final LatLng location = LatLng(lat, lng);

        mapController?.animateCamera(CameraUpdate.newLatLng(location));
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(location.toString()),
              position: location,
              infoWindow: InfoWindow(
                title: query,
              ),
            ),
          );
          _suggestions = []; // Clear suggestions after search
        });
      } else {
        // Handle error
        debugPrint('Search Error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search failed: ${data['status']}')),
          );
        }
      }
    } catch (e) {
      // Handle error
      debugPrint('Search Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search failed: Network error')),
        );
      }
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&components=country:ng&key=$apiKey';

    debugPrint('Autocomplete URL: $url');
    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Autocomplete Response Status: ${response.statusCode}');
      debugPrint('Autocomplete Response Body: ${response.body}');
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final List predictions = data['predictions'];
        setState(() {
          _suggestions = predictions.map<String>((p) => p['description'] as String).toList();
        });
      } else {
        debugPrint('Autocomplete Error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        setState(() {
          _suggestions = [];
        });
        // Optionally show error, but since it's onChanged, maybe not
      }
    } catch (e) {
      debugPrint('Autocomplete Exception: $e');
      setState(() {
        _suggestions = [];
      });
    }
  }



  void getDirections() async {
    final String originAddress = originController.text;
    final String destinationAddress = destinationController.text;

    if (originAddress.isEmpty || destinationAddress.isEmpty) {
      return;
    }

    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originAddress&destination=$destinationAddress&mode=$_travelMode&alternatives=true&traffic_model=best_guess&departure_time=now&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
        final String encodedPolyline =
    data['routes'][0]['overview_polyline']['points']
        as String;
        final List<LatLng> polylineCoordinates =
            _decodePolyline(encodedPolyline);

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
          final leg = data['routes'][0]['legs'][0];
          _distance = leg['distance']['text'];
          _eta = leg['duration']['text'];
          _instructions = (leg['steps'] as List).map<String>((step) => step['html_instructions'] as String).toList();
        });
      } else {
        // Handle error
        debugPrint('Error getting directions: ${data['status']}');
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps - Nigeria"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Map Features',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.layers),
              title: const Text('Map Layers'),
              children: <Widget>[
                ListTile(
                  title: const Text('Normal'),
                  onTap: () {
                    setState(() {
                      _currentMapType = MapType.normal;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Satellite'),
                  onTap: () {
                    setState(() {
                      _currentMapType = MapType.satellite;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Terrain'),
                  onTap: () {
                    setState(() {
                      _currentMapType = MapType.terrain;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Hybrid'),
                  onTap: () {
                    setState(() {
                      _currentMapType = MapType.hybrid;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const ListTile(
              leading: Icon(Icons.legend_toggle),
              title: Text('Legend'),
            ),
            ExpansionTile(
              leading: const Icon(Icons.directions),
              title: const Text('Directions'),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: originController,
                    decoration: const InputDecoration(
                      labelText: 'Origin',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _travelMode,
                    items: const [
                      DropdownMenuItem(value: 'driving', child: Text('Driving')),
                      DropdownMenuItem(value: 'walking', child: Text('Walking')),
                      DropdownMenuItem(value: 'bicycling', child: Text('Bicycling')),
                      DropdownMenuItem(value: 'transit', child: Text('Transit')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _travelMode = value!;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: getDirections,
                  child: const Text('Get Directions'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(9.0820, 8.6753),
              zoom: 5.0,
            ),
            mapType: _currentMapType,
            onMapCreated: onMapCreated,
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search for a location',
                              border: InputBorder.none,
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: onSearch,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Card(
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_suggestions[index]),
                            onTap: () {
                              searchController.text = _suggestions[index];
                              onSearch();
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isMapLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading map...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (_errorMessage != null)
            Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_eta != null && _distance != null)
            Positioned(
              bottom: 80,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Distance: $_distance'),
                          Text('ETA: $_eta'),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Turn-by-Turn Instructions'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  itemCount: _instructions.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(_instructions[index]),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('View Instructions'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarker,
        child: const Icon(Icons.add_location),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Access the state of the MapScreen to call the search function
    final MapScreenState state = MapScreen.mapKey.currentState!;
    state.searchController.text = query;
    state.onSearch();
    return const Center(
      child: Text("Searching..."),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}