import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LayersWidget extends StatefulWidget {
  final Function(MapType) onMapTypeChanged;

  const LayersWidget({super.key, required this.onMapTypeChanged});

  @override
  // ignore: library_private_types_in_public_api
  _LayersWidgetState createState() => _LayersWidgetState();
}

class _LayersWidgetState extends State<LayersWidget> {
  MapType _currentMapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Normal'),
          leading: Radio<MapType>(
            value: MapType.normal,
            groupValue: _currentMapType,
            onChanged: (MapType? value) {
              setState(() {
                _currentMapType = value!;
                widget.onMapTypeChanged(_currentMapType);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Satellite'),
          leading: Radio<MapType>(
            value: MapType.satellite,
            groupValue: _currentMapType,
            onChanged: (MapType? value) {
              setState(() {
                _currentMapType = value!;
                widget.onMapTypeChanged(_currentMapType);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Terrain'),
          leading: Radio<MapType>(
            value: MapType.terrain,
            groupValue: _currentMapType,
            onChanged: (MapType? value) {
              setState(() {
                _currentMapType = value!;
                widget.onMapTypeChanged(_currentMapType);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Hybrid'),
          leading: Radio<MapType>(
            value: MapType.hybrid,
            groupValue: _currentMapType,
            onChanged: (MapType? value) {
              setState(() {
                _currentMapType = value!;
                widget.onMapTypeChanged(_currentMapType);
              });
            },
          ),
        ),
      ],
    );
  }
}
