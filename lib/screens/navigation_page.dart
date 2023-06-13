import 'package:amarp/constants.dart';
import 'package:amarp/utils/directional_arrow.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'dart:async';


class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  Timer? _timer;
  double _heading = 0.0;
  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isLoading = true;
  
  Position? _userLocation;
  double? _targetBearing;

  @override
  void initState() {
    initializeCamera();
    // Listening to compass heading
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading ?? 0.0;
      });
    });
    // listen to user position every 3 secs
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
    // Update the UI with the new bearing angle
    setState(() {
        _userLocation = _userLocation;
        isLoading = false;
    });
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
       isLoading
       ? const Center(child: CircularProgressIndicator())
       : Stack(
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
                    child: DirectionalArrow(
                      heading: _heading
                    )
                  ),
                  // Data about user and device
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Text("${_userLocation!}", style: TextStyle(color: Colors.green, fontSize: 20)),
                        Text("Heading : ${_heading}", style: TextStyle(color: Colors.green, fontSize: 20)),
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
          
    );
  }

  
}
