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
                double.parse(userCoordinate[0]), double.parse(userCoordinate[1]), // USER: lat, lon 
                double.parse(subRoute[subRouteKeyName][coordIndex][0]), double.parse(subRoute[subRouteKeyName][coordIndex][1]) //TARGET: lat, lon
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
    // listen to user position every 1 secs
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    if(!routeSelected){
        // update progress
        setState(() {
          isLoadingProgressPercentage += 0.25;
        });
      }

      for(int i = 0; i <= 6; i++){
        _userLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
      }
      setState(() {
        _userLocation = _userLocation;
      });

      // ON START: Selecting starting route based on user location
      if(!routeSelected){
        selectRouteForUser([_userLocation!.latitude.toString(), _userLocation!.longitude.toString()]);
      }
      // ON MOVE AFTER START: Progressing to the next routes (directing user)
      else{
        // Check distance between user current location in relative to moving towards the next one
        /* ============================================================================
          * Move user systematically
            -- Last coordinate in a route == final destination
        ==============================================================================*/
        int userAndActiveCoordInterval = userDistanceAndTargetCoordinatesInMeters(
          double.parse(_userLocation!.latitude.toString()), // lat
          double.parse(_userLocation!.longitude.toString()), // lon
          
          double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][0]), // lat
          double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][1]) // lon
        );
        // TODO: Remove, just for analytical evidence
        setState(() {
            userDistanceToActiveCoord = userAndActiveCoordInterval;
        });
        
        // Check if user is 6 metre or less to the active coordinate (THEN: switch to the next coordinate)
        if(userAndActiveCoordInterval <= 6){
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
// ===========
  double coordToRadians(double lat1) {
  double pi = 3.14159;
  double radians = lat1 * pi / 180;
  return radians;
  }
  int userDistanceAndTargetCoordinatesInMeters(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371000; // Earth's radius in meters
    double lat1Rad = coordToRadians(lat1);
    double lat2Rad = coordToRadians(lat2);
    double lon1Rad = coordToRadians(lon1);
    double lon2Rad = coordToRadians(lon2);

    double dlat = lat2Rad - lat1Rad;
    double dlon = lon2Rad - lon1Rad;

    double a = pow(sin(dlat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dlon / 2), 2);
    double c = 2 * asin(sqrt(a));
    double result = c * r; 
    return result.toInt();
}
  // ================
  
  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: 
       isLoading
       ? Column(
         mainAxisAlignment: MainAxisAlignment.center,
        //  crossAxisAlignment: CrossAxisAlignment.center,
         children:  [
          const Text("Calculating route...", style: AppWhiteTextStyle.texth3,),
          AppPadding.verticalPadding,
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: AppPadding.screenPaddingXXL),
             child: LinearProgressIndicator(value: isLoadingProgressPercentage),
           ),
         ],
       )
       : Column(
          children: [
            // SCREEN 0
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: deviceSize(context).width,
              height: deviceSize(context).height * 0.07,
              child: Text('Destination: ${widget.destinationName}', style: AppWhiteTextStyle.texth3),
            ),
            // SCREEN 1
            SizedBox(
              height: deviceSize(context).height * 0.7,
              width: deviceSize(context).width,
              child: Stack(
                children:[
                  SizedBox(
                    height: deviceSize(context).height,
                    width: deviceSize(context).width,
                    child: CameraPreview(controller),
                  ),
                  // Current directional arrows
                  Column(
                    children: [
                      AppPadding.verticalPaddingExtra,
                      Align(
                        alignment: Alignment.topCenter,
                        child: DirectionalArrow(
                          heading: _heading,
                          user_lat: _userLocation!.latitude,
                          user_lon: _userLocation!.longitude,
                          next_latitude: double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][0]),
                          next_longitude: double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][1]),
                        )
                      ),
                    ],
                  )
                ]
                      ),
            ) ,
            // SCREEN 2
            SizedBox(
              height: deviceSize(context).height * 0.2,
              width: deviceSize(context).width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('============================', style: AppWhiteTextStyle.textp),
                    Text("UserDistanceToActiveCoord: $userDistanceToActiveCoord", style: AppWhiteTextStyle.texth5),
                    Text('============================', style: AppWhiteTextStyle.textp),
                    Text("Sub Route: $G_closestSubRouteKeyName", style: const TextStyle(color: Color.fromARGB(255, 125, 7, 99), fontSize: 16)),
                    Text('============================', style: AppWhiteTextStyle.textp),
                    Text("Coord Index: $G_closestCoordInSubRouteIndex", style: const TextStyle(color: Color.fromARGB(255, 180, 168, 0), fontSize: 16)),
                    Text('============================', style: AppWhiteTextStyle.textp),
                    Text("USER LAT : ${_userLocation!.latitude}", style: AppWhiteTextStyle.textp),
                    Text("USER LON : ${_userLocation!.longitude}", style: AppWhiteTextStyle.textp),
                    Text('============================', style: AppWhiteTextStyle.textp),
                    Text("Closest SubRoute Dist: ${G_closestRouteDistanceInMeters} metres", style: const TextStyle(color: Colors.green, fontSize: 16)),
                    Text("Heading : ${_heading}", style: const TextStyle(color: Colors.green, fontSize: 16)),
                  ],
                ),
              ),
            )
          ],
       ) 
       
       
          
    );
  }

  
}
