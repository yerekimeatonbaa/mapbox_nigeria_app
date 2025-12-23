import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class ScaleWidget extends StatelessWidget {
  final GoogleMapController? mapController;
  final LatLng? center;

  const ScaleWidget({super.key, this.mapController, this.center});

  @override
  Widget build(BuildContext context) {
    if (mapController == null || center == null) {
      return Container();
    }

    return FutureBuilder<double>(
      future: _getScale(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '1 km = ${snapshot.data!.toStringAsFixed(2)} pixels',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Future<double> _getScale() async {
    final LatLngBounds visibleRegion = await mapController!.getVisibleRegion();
    final LatLng center = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );
    final LatLng oneKmNorth = _calculateOffset(center, 1000, 0);
    final ScreenCoordinate screenCoordinateCenter =
        await mapController!.getScreenCoordinate(center);
    final ScreenCoordinate screenCoordinateOneKmNorth =
        await mapController!.getScreenCoordinate(oneKmNorth);
    final double distanceInPixels =
        _calculateDistance(screenCoordinateCenter, screenCoordinateOneKmNorth);
    return distanceInPixels;
  }

  LatLng _calculateOffset(LatLng center, double distance, double bearing) {
    const double radius = 6371; // Earth's radius in kilometers
    final double lat1 = _degreesToRadians(center.latitude);
    final double lon1 = _degreesToRadians(center.longitude);
    final double dByR = distance / radius;
    final double bearingRad = _degreesToRadians(bearing);

    final double lat2 = asin(
        sin(lat1) * cos(dByR) + cos(lat1) * sin(dByR) * cos(bearingRad));
    final double lon2 = lon1 +
        atan2(sin(bearingRad) * sin(dByR) * cos(lat1),
            cos(dByR) - sin(lat1) * sin(lat2));

    return LatLng(_radiansToDegrees(lat2), _radiansToDegrees(lon2));
  }

  double _calculateDistance(ScreenCoordinate p1, ScreenCoordinate p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double _radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }
}
