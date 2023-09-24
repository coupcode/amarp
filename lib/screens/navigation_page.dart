import 'package:amarp/constants.dart';
import 'package:amarp/controller/controller.dart';
import 'package:amarp/screens/success_page.dart';
import 'package:amarp/utils/directional_arrow.dart';
import 'package:amarp/utils/location.dart';
import 'package:amarp/widgets/route_banner.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math';
import 'dart:async';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'dart:io' show Platform;


class NavigationPage extends StatefulWidget {
  NavigationPage({Key? key, required this.destinationName,required this.imagePath,required this.routes}) : super(key: key);
  List routes;
  String destinationName;
  String imagePath;

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool arrowIsStraight = false;
  bool safetyPrompt = false;
  int safetyPromptCount = 0;

  Timer? _timer;
  double _heading = 0.0;
  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isLoading = true;
  double isLoadingProgressPercentage = 0.0;
  bool routeSelected = false;
  List selectedRoute = [];
  
  
  double? _targetBearing;

  Location location = Location();
  late LocationData currentLocationData;
  // LocationData? _userLocation;

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

  int userDistanceToActiveCoord = 0;

  void locationListener()async{
    var isAllowed = await requestLocationPerm();
    if (isAllowed == true){
      location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 800, // 1000 is 1 sec
        distanceFilter: 0.5
      );
      location.onLocationChanged.listen((LocationData currentLocation) {
        startListening(currentLocation);
        setState(() {
          currentLocationData = currentLocation;
        });
      });
    }
    else{
      Get.snackbar("Failed", "Couldn't get user location. Please check in your settings to allow");
      Get.back();
    }
  }

// HEADING
double normalizeHeading(double heading) {
  // If the platform is iOS, apply the conversion
  if (Platform.isIOS) {
    // If the heading is in the range of 0 to 180, leave it as is
    if (heading >= 0 && heading <= 180) {
      return heading;
    }

    // If the heading is in the range of 181 to 360, convert it to the -179 to 0 range
    if (heading > 180 && heading <= 360) {
      return heading - 360;
    }

    // If the heading is already in the -179 to 0 range, leave it as is
    if (heading >= -179 && heading < 0) {
      return heading;
    }

    // If the heading is in the range of -360 to -180, convert it to the 0 to -179 range
    if (heading >= -360 && heading < -179) {
      return heading + 360;
    }
    return 0;
    }
    return 0;
  }

  void _startListeningToHeading() {
    FlutterCompass.events?.listen((CompassEvent event) {
    setState(() {
      // Check the platform and apply the conversion if it's iOS
      if (Platform.isIOS) {
        _heading = normalizeHeading(event.heading ?? 0);
      } else {
        // For other platforms, or if not on iOS, use the heading as is
        _heading = event.heading ?? 0;
      }
    });
  });
  }

// CAUTION PROMPT
  cautionPrompt(){
    Timer.periodic(const Duration(seconds: 15), (timer) {
      safetyPromptCount += 1;
      setState(() {
        safetyPrompt = true;
      });
      Timer(
        const Duration(seconds: 5), () {
            setState(() {
              safetyPrompt = false;
            });
        }
      );

      if (safetyPromptCount == 2) {
        timer.cancel();
      }
    });
  }

  @override
  void initState(){
    initializeCamera();
    // Listening to compass heading
   _startListeningToHeading();

    // update progress
    if (routeSelected == false){
      setState(() {
        isLoadingProgressPercentage += 0.25;
      });
    }
    
    
    locationListener();
    cautionPrompt();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controller
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

   void startListening(LocationData _userLocation) async {
    // ON START: Selecting starting route based on user location
      if(!routeSelected){
        setState(() {
          isLoadingProgressPercentage += 0.25;
        });
        selectRouteForUser([_userLocation.latitude.toString(), _userLocation.longitude.toString()]);
      }
      // ON MOVE AFTER START: Progressing to the next routes (directing user)
      else{
        // Check distance between user current location in relative to moving towards the next one
        /* ============================================================================
          * Move user systematically
            -- Last coordinate in a route == final destination
        ==============================================================================*/
        int userAndActiveCoordInterval = userDistanceAndTargetCoordinatesInMeters(
          double.parse(_userLocation.latitude.toString()), // lat
          double.parse(_userLocation.longitude.toString()), // lon
          
          double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][0]), // lat
          double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][1]) // lon
        );
        // TODO: Remove, just for analytical evidence
        setState(() {
            userDistanceToActiveCoord = userAndActiveCoordInterval;
        });
        
        // Check if user is 6 metre or less to the active coordinate (THEN: switch to the next coordinate)
        if(userAndActiveCoordInterval <= 13){
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
              Get.snackbar("AT DESTINATION", "redirecting...", colorText: Color.fromARGB(255, 12, 65, 13));
              saySomethingToUser("You have reached your destination");
              Timer(
                const Duration(seconds: 1), () {
                    Get.off(() => SuccessPage(destinationName: widget.destinationName, imagePath: widget.imagePath));
                }
              );
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
       : Stack(
         children:[ 
          // STACK 1
          Column(
            children: [
              // SCREEN 1
              SizedBox(
                height: deviceSize(context).height,
                width: deviceSize(context).width,
                child: Stack(
                  children:[
                    // STACK 1
                    Stack(
                      children: [
                        SizedBox(
                          height: deviceSize(context).height *0.7,
                          width: deviceSize(context).width,
                          child: CameraPreview(controller)
                        ),
                        
                        Obx(()=> isArrowStraight.value
                        ? Positioned(
                          left: 0.04130000000035494,
                          top: -0.004099999999951365,
                          child: RouteBanner(
                            heading: _heading,
                            distanceToNextCoord: userDistanceToActiveCoord,
                            routeName: G_closestSubRouteKeyName, routeIndex: G_closestCoordInSubRouteIndex)
                        )
                        : const SizedBox()
                        )
                    ]),
                    // STACK 2
                    // Current directional arrows
                    Column(
                      children: [
                        AppPadding.verticalPaddingExtra,
                        Align(
                          alignment: Alignment.topCenter,
                          child: DirectionalArrow(
                            heading: _heading,
                            user_lat: currentLocationData.latitude ?? 0,
                            user_lon: currentLocationData.longitude ?? 0,
                            next_latitude: double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][0]),
                            next_longitude: double.parse(G_closestRoute[G_closestSubRouteIndexInRoute][G_closestSubRouteKeyName][G_closestCoordInSubRouteIndex][1]),
                          )
                        ),
                      ],
                    )
                  ]
                        ),
              ),
              
            ],
          ),
          // STACK 2
          DraggableScrollableSheet(
            initialChildSize: 0.33, // Adjust as needed
            maxChildSize: 0.6, // Adjust as needed
            minChildSize: 0.33, // Adjust as needed
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 27, 26, 26),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 2, bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal:10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: deviceSize(context).width *0.65,
                                child: Text(widget.destinationName, style: AppWhiteTextStyle.texth1)),
                              SizedBox(
                                width: deviceSize(context).width *0.29,
                                child: Text("${currentLocationData.speed!.toStringAsFixed(2)}m/s", style: const TextStyle(color: Colors.blue, fontSize: 20))),
                            ],
                          ),
                          const Divider(color: Colors.grey),
                          SizedBox(
                            height: 250,
                            width: deviceSize(context).width,
                            child: Image.asset(widget.imagePath)),
                          const Divider(color: Colors.grey),
                          AppPadding.verticalPadding,
                          Text("Current route: $G_closestSubRouteKeyName", style: AppWhiteTextStyle.texth3),
                          Text("User latitude : ${currentLocationData.latitude}", style: AppWhiteTextStyle.texth4),
                          Text("User longitude : ${currentLocationData.longitude}", style: AppWhiteTextStyle.texth4),
                          AppPadding.verticalPadding,
                          const Divider(color: Colors.grey),
                          AppPadding.verticalPadding,
                          Text("Coord Index: $G_closestCoordInSubRouteIndex", style: const TextStyle(color: Color.fromARGB(255, 180, 168, 0), fontSize: 16)),
                          Text("Checkpoint Distance: $userDistanceToActiveCoord metres", style: AppWhiteTextStyle.texth4),
                          Text("Heading : $_heading", style: const TextStyle(color: Colors.green, fontSize: 16)),
                          AppPadding.verticalPadding,
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // STACK 3
          safetyPrompt
          ? Container(
            color: Colors.black.withOpacity(0.85),
            width: deviceSize(context).width,
            height: deviceSize(context).height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.warning_rounded, color: Colors.white, size: 70),
                Text("Be safe", style: AppWhiteTextStyle.texth1),
                Text("Pay attention to your environment", style: AppWhiteTextStyle.texth3),
                Text("while walking", style: AppWhiteTextStyle.texth3)
              ],
            ),
          )
          : const SizedBox()

         ]
          
       ),  

      
      
    );
  }

  
}
