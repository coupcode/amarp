import 'package:amarp/constants.dart';
import 'package:amarp/screens/success_page.dart';
import 'package:amarp/utils/directional_arrow.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:async';

import 'package:get/get.dart';


class NavigationPage extends StatefulWidget {
  NavigationPage({Key? key, required this.destinationName,required this.imagePath,required this.routes}) : super(key: key);
  List routes;
  String destinationName;
  String imagePath;

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
  int G_closestRouteDistanceInMeters = 0;
  int G_closestSubRouteIndexInRoute = 0;
  String G_closestSubRouteKeyName = '';
  int G_closestCoordInSubRouteIndex = 0;

  // Calculate and choose route for user
  double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
  void selectRouteForUser(List<String> userCoordinate){
    // Looping through possible routes to find the closest one to user
    List closestRoute = widget.routes[0];
    int closestRouteDistanceInMeters = 0;
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
              int distance = userDistanceAndTargetCoordinatesInMeters(
                userCoordinate, 
                subRoute[subRouteKeyName][coordIndex]// lon, lat
              );
              if (index1 ==0 && subRouteIndex == 0 && coordIndex == 0){
                  closestRouteDistanceInMeters = distance;
                  closestRoute = widget.routes[index1];
                  closestSubRouteIndexInRoute = subRouteIndex;
                  closestSubRouteKeyName = subRouteKeyName;
                  closestCoordInSubRouteIndex=coordIndex;
                  isLoadingProgressPercentage += progressInterval/2;
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

  StreamSubscription<CompassEvent>? _compassSubscription;
  int userDistanceToActiveCoord = 0;
  @override
  void initState() {
    initializeCamera();
    // Listening to compass heading
    _compassSubscription = FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading ?? 0.0;
      });
    });
    // update progress
    setState(() {
      isLoadingProgressPercentage += 0.25;
    });
    // listen to user position every 5 secs
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      startListening();
    });
  
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controller
    _compassSubscription?.cancel();
    _timer?.cancel();
    controller.dispose();
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
      // Update the UI with the new bearing angle
      setState(() {
          _userLocation = _userLocation;
      });
      // ON START: Selecting starting route based on user location
      if(!routeSelected){
        selectRouteForUser([_userLocation!.longitude.toString(), _userLocation!.latitude.toString()]);
      }
      // ON MOVE AFTER START: Progressing to the next routes (directing user)
      else{
        // Check distance between user current location in relative to moving towards the next one
        /* ============================================================================
          * Move user systematically
            -- Last coordinate in a route == final destination
        ==============================================================================*/
        int userAndActiveCoordInterval = userDistanceAndTargetCoordinatesInMeters(
          [_userLocation!.longitude.toString(), _userLocation!.latitude.toString()],
          [
            G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][0], // lon
            G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][1] // lat
          ]
        );
        // TODO: Remove, just for analytical evidence
        setState(() {
            userDistanceToActiveCoord = userAndActiveCoordInterval;
        });
        
        // Check if user is 1 metre or less to the active coordinate (THEN: switch to the next coordinate)
        if(userAndActiveCoordInterval <= 5){
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
              Get.snackbar("AT DESTINATION", "redirecting...", colorText: Colors.white);
              Timer(const Duration(seconds: 1), () {
              Get.off(() => SuccessPage(destinationName: widget.destinationName, imagePath: widget.imagePath));
              });
            }
            // CASE 2-2: Move to the next G_closestSubRouteKeyName
            else{
              int newLocalGclosestSubRouteIndexInRoute = G_closestSubRouteIndexInRoute + 1;
              setState(() {
                G_closestSubRouteIndexInRoute = newLocalGclosestSubRouteIndexInRoute;
                G_closestSubRouteKeyName = G_closestRoute[newLocalGclosestSubRouteIndexInRoute].keys.first;
                G_closestCoordInSubRouteIndex = 0;
              });
            }
          }
        }
      }
  }

  int userDistanceAndTargetCoordinatesInMeters(
    List<String> userCoordinate, List<String> targetCoordinate) {
  const double earthEquatorialRadius = 6378137.0; // Earth's equatorial radius in meters
  const double earthPolarRadius = 6356752.3; // Earth's polar radius in meters

  double userLat = degreesToRadians(double.parse(userCoordinate[1]));
  double userLon = degreesToRadians(double.parse(userCoordinate[0]));

  double targetLat = degreesToRadians(double.parse(targetCoordinate[1]));
  double targetLon = degreesToRadians(double.parse(targetCoordinate[0]));

  double a = earthEquatorialRadius;
  double b = earthPolarRadius;
  double f = 1 / 298.257223563; // Earth's flattening

  double L = targetLon - userLon;

  double tanU1 = (1 - f) * tan(userLat);
  double cosU1 = 1 / sqrt(1 + tanU1 * tanU1);
  double sinU1 = tanU1 * cosU1;

  double tanU2 = (1 - f) * tan(targetLat);
  double cosU2 = 1 / sqrt(1 + tanU2 * tanU2);
  double sinU2 = tanU2 * cosU2;

  double sinLambda;
  double cosLambda;
  double sinSigma;
  double cosSigma;
  double sigma;
  double sinAlpha;
  double cosSqAlpha;
  double cos2SigmaM;
  double C;

  double lambda = L;
  double prevLambda;

  int iterLimit = 100;

  do {
    sinLambda = sin(lambda);
    cosLambda = cos(lambda);
    sinSigma = sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) +
        (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) *
            (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
    if (sinSigma == 0) {
      return 0; // coincident points
    }
    cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
    sigma = atan2(sinSigma, cosSigma);
    sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
    cosSqAlpha = 1 - sinAlpha * sinAlpha;
    cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;

    if (cos2SigmaM.isNaN) {
      cos2SigmaM = 0; // equatorial line: cosSqAlpha=0 (§6)
    }

    C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));

    prevLambda = lambda;
    lambda = L +
        (1 - C) *
            f *
            sinAlpha *
            (sigma +
                C *
                    sinSigma *
                    (cos2SigmaM +
                        C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    iterLimit--;
    if (iterLimit == 0) {
      return double.infinity.toInt(); // formula failed to converge
    }
  } while ((lambda - prevLambda).abs() > 1e-12 && iterLimit > 0);

  double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
  double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
  double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
  double deltaSigma =
      B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
          B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) *
              (-3 + 4 * cos2SigmaM * cos2SigmaM)));

  double distance = b * A * (sigma - deltaSigma);

  return distance.toInt();
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
                    margin: EdgeInsets.only(top: deviceSize(context).height*0.15),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Text('============================'),
                        Text("UserDistanceToActiveCoord: $userDistanceToActiveCoord"),
                        Text('============================'),
                        Text("Sub Route: $G_closestSubRouteKeyName", style: const TextStyle(color: Color.fromARGB(255, 180, 0, 141), fontSize: 20)),
                        Text('============================'),
                        Text("Coord Index: $G_closestCoordInSubRouteIndex", style: const TextStyle(color: Color.fromARGB(255, 180, 168, 0), fontSize: 20)),
                        Text('============================'),
                        Text("Closest SubRoute Dist: ${G_closestRouteDistanceInMeters/1000} metres", style: const TextStyle(color: Colors.green, fontSize: 20)),
                        Text("Closest SubRoute Name: $G_closestSubRouteKeyName", style: const TextStyle(color: Colors.blue, fontSize: 20)),
                        Text("Closest SubRoute CoordIndex: $G_closestCoordInSubRouteIndex", style: const TextStyle(color: Colors.red, fontSize: 20)),
                        Text("Heading : ${_heading}", style: const TextStyle(color: Colors.green, fontSize: 20)),
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
