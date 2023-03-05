import 'package:amarp/constants.dart';
import 'package:amarp/widgets/rotate_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'dart:async';


class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Timer? _timer;

  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isLoading = true;
  bool isLocationLoading = true;
  
  
  Position? _userLocation;
  double? _targetBearing;

  @override
  void initState() {
    initializeCamera();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      startListening();
    });

    super.initState();
  }

  @override
  void dispose() {
    // Dispose controller
    controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

   void startListening() async {
    // Get the user's current location
    _userLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    // Set the target coordinate (this could be obtained from user input or from a database, for example)
    const targetLat = 37.4219983;
    const targetLong = -122.084;

    final targetPosition = Position(
      latitude: targetLat, 
      longitude: targetLong,
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      timestamp: DateTime.now(),
    );

    // Calculate the bearing angle between the user's location and the target coordinate
    _targetBearing = Geolocator.bearingBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        targetPosition.latitude,
        targetPosition.longitude);

    isLocationLoading = false;
    // Update the UI with the new bearing angle
    setState(() {
        _userLocation = _userLocation;
        _targetBearing = _targetBearing;
    });
  }

  Future<void> initializeCamera() async {
    // Get available cameras
    cameras = await availableCameras();

    // Initialize controller
    controller = CameraController(cameras[0], ResolutionPreset.medium);

    // Prepare controller
    await controller.initialize();

    // Stop loader
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
       isLoading
       ? const Center(child: CircularProgressIndicator())
       : controller != null && controller.value.isInitialized && _targetBearing != null && _userLocation != null
          ? Stack(

            children:[
               SizedBox(
                height: deviceSize(context).height * 1,
                child: CameraPreview(controller),
              ),
              // Current directional arrows
              Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Transform.rotate(
                      angle: (_targetBearing! - _userLocation!.heading) * (math.pi / 180),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.green,
                        size: 200,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Text("Target Bearing : ${_targetBearing!}", style: TextStyle(color: Colors.green, fontSize: 20)),
                        Text("User Location : ${_userLocation!}", style: TextStyle(color: Colors.green, fontSize: 20)),
                      ],
                    ),
                  )
                  
                ],
              ),
              // Old arrow pointers below
              // Padding(
              //   padding: EdgeInsets.only(
              //     top: deviceSize(context).height * 0.4,
              //     left: deviceSize(context).width *0.1
              //   ),
              //   child: RotatedWidget(
              //     // ignore: sort_child_properties_last
              //     child: Row(
              //       children:  [
              //        for(int i=0; i<3; i++)
              //         const Icon(Icons.arrow_back_ios_new_outlined, size: 100, color: Colors.blue),
                     
              //     ],
              //   ), angle: 160),
              // )
              //  ends here
              
            ]
          ) 
          : const Center(child: CircularProgressIndicator()),
    );
  }

  
}
