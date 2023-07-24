import 'package:amarp/constants.dart';
import 'package:amarp/utils/directional_arrow.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:async';

import 'package:get/get.dart';


class NavigationPage extends StatefulWidget {
  NavigationPage({Key? key, required this.routes}) : super(key: key);
  List routes;
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  Timer? _timer;
  double _heading = 0.0;
  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isLoading = true;
  double isLoadingProgressPercentage = 0.0;
  bool routeSelected = false;
  List selectedRoute = [];
  
  Position? _userLocation;
  double? _targetBearing;

  // Selected route Values
  List G_closestRoute = [];
  double G_closestRouteDistanceInMeters = 0;
  int G_closestSubRouteIndexInRoute = 0;
  String G_closestSubRouteKeyName = '';
  int G_closestCoordInSubRouteIndex = 0;

  // Calculate and choose route for user
  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
  void selectRouteForUser(List<String> userCoordinate){
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    double userLat = degreesToRadians(double.parse(userCoordinate[1]));
    double userLon = degreesToRadians(double.parse(userCoordinate[0]));
    
    // Looping through possible routes to find the closest one to user
    List closestRoute = widget.routes[0];
    double closestRouteDistanceInMeters = 0;
    int closestSubRouteIndexInRoute = 0;
    String closestSubRouteKeyName = '';
    int closestCoordInSubRouteIndex = 0;

    // Handling progress indicator status
    double progressInterval = 0.5/widget.routes.length;

    for (int index1=0; index1 < widget.routes.length; index1++){
        List route = widget.routes[index1];
        for (int subRouteIndex=0; subRouteIndex < route.length; subRouteIndex++){
          Map subRoute = route[subRouteIndex];
          String subRouteKeyName = subRoute.keys.first;
          for (int coordIndex=0; coordIndex < subRoute[subRouteKeyName].length; coordIndex++){
              double lat2 = degreesToRadians(double.parse(subRoute[subRouteKeyName][coordIndex][1]));
              double lon2 = degreesToRadians(double.parse(subRoute[subRouteKeyName][coordIndex][0]));

              double dLat = lat2 - userLat;
              double dLon = lon2 - userLon;

              double a = pow(sin(dLat / 2), 2) + 
                  cos(userLat) * cos(lat2) * pow(sin(dLon / 2), 2);
              double c = 2 * atan2(sqrt(a), sqrt(1 - a));

              double distance = earthRadius * c * 1000; // Convert to meters

              if (index1 ==0 && subRouteIndex == 0 && coordIndex == 0){
                closestRouteDistanceInMeters = distance;
                closestRoute = widget.routes[index1];
                closestSubRouteIndexInRoute = subRouteIndex;
                closestSubRouteKeyName = subRouteKeyName;
                closestCoordInSubRouteIndex=coordIndex;
                // update start progress indicator

                setState(() {
                  isLoadingProgressPercentage += progressInterval/2; 
                });
              }
              if (distance < closestRouteDistanceInMeters){
                closestRouteDistanceInMeters = distance;
                closestRoute = widget.routes[index1];
                closestSubRouteIndexInRoute = subRouteIndex;
                closestSubRouteKeyName = subRouteKeyName;
                closestCoordInSubRouteIndex=coordIndex;
              }

              // update last progress indicator
              if(subRouteIndex == route.length -1){
                double newVal = isLoadingProgressPercentage + (progressInterval/2);
                setState(() {
                    if(newVal>1){
                      isLoadingProgressPercentage = 1;
                    }
                    else{
                      isLoadingProgressPercentage += (progressInterval/2);
                    }
                    
                });
              }
          }
        }
    }
    setState(() {
      // Set Global values
      G_closestRoute = closestRoute;
      G_closestRouteDistanceInMeters = closestRouteDistanceInMeters;
      G_closestSubRouteIndexInRoute = closestSubRouteIndexInRoute;
      G_closestSubRouteKeyName = closestSubRouteKeyName;
      G_closestCoordInSubRouteIndex = closestCoordInSubRouteIndex;

      isLoading=false;
      routeSelected=true;
    });
  }

  @override
  void initState() {
    initializeCamera();
    // Listening to compass heading
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading ?? 0.0;
      });
    });
    // update progress
    setState(() {
      isLoadingProgressPercentage += 0.25;
    });
    // listen to user position every 10 secs
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
    // update progress
    setState(() {
      isLoadingProgressPercentage += 0.25;
    });
    // Get the user's current location
    _userLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    // ON START: Selecting starting route based on user location
    if(!routeSelected){
      selectRouteForUser([_userLocation!.longitude.toString(), _userLocation!.latitude.toString()]);
    }
    // ON MOVE AFTER START: Progressing to the next routes (directing user)
    else{
      //TODO: Check distance between user current location in relative to moving towards the next one
      /* ============================================================================
        * Move user systematically
          -- Check the distance of the user to ensure movement towards nex coordinate
          -- Last coordinate in a route == final destination
      ==============================================================================*/
      // FULL SAMPLE PATH(FOR REFERENCE SAKE): var currentCoord = G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex];
      
      // CASE 1: If G_closestCoordInSubRouteIndex < G_closestSubRouteKeyName Array length
      if(G_closestCoordInSubRouteIndex < G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName].length - 1){
        setState(() {
          G_closestCoordInSubRouteIndex += 1;    
        });
      }
      // CASE 2: If G_closestCoordInSubRouteIndex == G_closestSubRouteKeyName Array length
      else{
        // CASE 2-1: Check if destination reach (Meaning that is the last coord in the route)
        if(G_closestSubRouteIndexInRoute == G_closestRoute.length-1){
          Get.snackbar("AT DESTINATION", "Trip should end, because you are at the destination");
        }
        // CASE 2-2: Move to the next G_closestSubRouteKeyName
        else{
          setState(() {
            G_closestSubRouteIndexInRoute += 1;
            G_closestSubRouteKeyName = G_closestRoute[G_closestSubRouteIndexInRoute].keys.first;
          });
        }
      }
    
    }

    // Update the UI with the new bearing angle
    setState(() {
        _userLocation = _userLocation;
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
       ? Column(
         mainAxisAlignment: MainAxisAlignment.center,
        //  crossAxisAlignment: CrossAxisAlignment.center,
         children:  [
          const Text("Calculating route..."),
          AppPadding.verticalPadding,
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: AppPadding.screenPaddingXXL),
             child: LinearProgressIndicator(value: isLoadingProgressPercentage),
           ),
         ],
       )
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
                      heading: _heading,
                      next_latitude: double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][0]),
                      next_longitude: double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][1]),
                    )
                  ),
                  // Data about user and device
                  Container(
                    margin: EdgeInsets.only(top: deviceSize(context).height*0.3),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Text("Closest SubRoute Dist: ${G_closestRouteDistanceInMeters/1000} metres", style: TextStyle(color: Colors.green, fontSize: 20)),
                        Text("Closest SubRoute Name: $G_closestSubRouteKeyName", style: TextStyle(color: Colors.blue, fontSize: 20)),
                        Text("Closest SubRoute CoordIndex: $G_closestCoordInSubRouteIndex", style: TextStyle(color: Colors.red, fontSize: 20)),
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
