import 'package:flutter/material.dart';
import 'dart:math';

class CompassWidget extends StatelessWidget {
  final double bearing;

  const CompassWidget({super.key, this.bearing = 0.0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -bearing * pi / 180,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.navigation,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
