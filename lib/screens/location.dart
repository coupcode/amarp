import 'package:amarp/controller/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  // Global vars
  String? _currentAddress;
  Position? _currentPosition;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: const Text("Location Page")),
       body: SafeArea(
         child: Center(
           child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                Text('ADDRESS: ${_currentAddress ?? ""}'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: ()async {
                    Position? position = LocationFuncs.getCurrentPosition(context);
                    setState(() {
                      _currentPosition = position;
                    });
                  },
                  child: const Text("Get Current Location"),
                )
              ],
            ),
         ),
       ),
    );
  }
}