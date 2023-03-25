
import 'dart:async';
import 'dart:ffi';

import 'package:amarp/api/get_class.dart';
import 'package:amarp/api/post_class.dart';
import 'package:amarp/constants.dart';
import 'package:amarp/widgets/goback_btn.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationsPage extends StatefulWidget {
  LocationsPage({Key? key, required this.buildingsList}) : super(key: key);
  List buildingsList;
  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  List apiRoutesList = [];
  getRoutesFunc()async{
    setState(() {
      isLoading = true;
    });
    List res = await GETClass.getRoutes();
    setState(() {
      apiRoutesList = res;
      isLoading = false;
    });
  }
  // Controller vars
  bool isLoading = false;
  bool isSubmitBtnLoading = false;
  String onTopHeight = "down";
  
  final TextEditingController positionValuesTextControl = TextEditingController();
  // Building Text Controllers
  final TextEditingController buildingName = TextEditingController();
  final TextEditingController buildingDescription = TextEditingController();
  
  final TextEditingController front_view_lat = TextEditingController();
  final TextEditingController front_view_long = TextEditingController();
  
  final TextEditingController left_view_lat = TextEditingController();
  final TextEditingController left_view_long = TextEditingController();

  final TextEditingController right_view_lat = TextEditingController();
  final TextEditingController right_view_long = TextEditingController();

  final TextEditingController back_view_lat = TextEditingController();
  final TextEditingController back_view_long = TextEditingController();
  
  final _buildingFormKey = GlobalKey<FormState>();

  // Routes Text Controllers
  List routeCategoryList = ["Main route", "Rough route", "Stair case route"];
  final TextEditingController routeName = TextEditingController();
  final TextEditingController routeCategory = TextEditingController();
  final _routeFormKey = GlobalKey<FormState>();

  // Coordinates Text Controllers
  final TextEditingController coordinateName = TextEditingController();
  final TextEditingController coordinateLat = TextEditingController();
  final TextEditingController coordinateLon = TextEditingController();
  final TextEditingController coordinateRouteID = TextEditingController();
  final _coordinateFormKey = GlobalKey<FormState>();

  // Rooms Text Controllers
  final TextEditingController roomName = TextEditingController();
  final TextEditingController roomLat = TextEditingController();
  final TextEditingController roomLon = TextEditingController();
  final TextEditingController roomAltitude = TextEditingController();
  final TextEditingController roomBuildingID = TextEditingController();
  final _roomsFormKey = GlobalKey<FormState>();
  
  // Location vars
  String? _currentAddress;
  Position? _currentPosition;
  double _currentHeading = 0.00;

  // Stream user location and heading in degree clockwise to magnetic north
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    startListening();
    super.initState();
  }
  
  @override
  void dispose() {
    // dispose building controllers
    buildingName.dispose();
    buildingDescription.dispose();
    front_view_lat.dispose();
    front_view_long.dispose();
    left_view_lat.dispose();
    left_view_long.dispose();
    right_view_lat.dispose();
    right_view_long.dispose();
    back_view_lat.dispose();
    back_view_long.dispose();
    // dispose routes controllers
    routeName.dispose();
    routeCategory.dispose();
    // dispose coordinates controllers
    coordinateName.dispose();
    coordinateLat.dispose();
    coordinateLon.dispose();
    coordinateRouteID.dispose();
    // dispose rooms controllers
    roomName.dispose();
    roomLat.dispose();
    roomLon.dispose();
    roomAltitude.dispose();
    roomBuildingID.dispose();

    positionStream?.cancel();
    super.dispose();
  }

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
   distanceFilter: 10 // chanage in distance in meters before update
  );

  // Location functions
void startListening(){
  positionStream = Geolocator.getPositionStream(
    locationSettings: locationSettings
    ).listen((Position position) {
    if (position == null) {
      return;
    }
    if (position.heading != null) {
      setState(() {
        _currentHeading = position.heading;
      });
    }
  });
}


  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    setState(() {
      isLoading = true;
      positionValuesTextControl.text = "";
    });

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() => _currentPosition = position);
      setState(() {
         // Write to textfield
        positionValuesTextControl.text = """
  LAT: ${_currentPosition?.latitude}
  LON: ${_currentPosition?.longitude ?? ""}
  ALT: ${_currentPosition?.altitude ?? ""} metres
  """;
    isLoading = false;
      });
      // _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      setState(() {
        positionValuesTextControl.text = "Error Occured";
        isLoading = false;
      });
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
       
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  // =============================
    // Form Widgets
    // =============================
    Widget buildingForm() {
      return Form(
          key: _buildingFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Text("Building Form", style: AppBlackTextStyle.texth1,),
              const Divider(),
              const Text("Name", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: buildingName,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (buildingName.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Text("Description", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: buildingDescription,
                style: const TextStyle(fontSize: 12),
                maxLines: 3,
                validator: (e) {
                  if (buildingDescription.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Divider(),
              AppPadding.verticalPadding,
              const Text("front_view_lat", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: front_view_lat,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (front_view_lat.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Text("front_view_long", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: front_view_long,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (front_view_long.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Text("left_view_lat", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: left_view_lat,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (left_view_lat.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Text("left_view_long", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: left_view_long,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (left_view_long.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Text("right_view_lat", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: right_view_lat,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (right_view_lat.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Text("right_view_long", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: right_view_long,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (right_view_long.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Text("back_view_lat", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: back_view_lat,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (back_view_lat.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              const Text("back_view_long", style: AppBlackTextStyle.texth5),
              TextFormField(
                controller: back_view_long,
                style: const TextStyle(fontSize: 12),
                validator: (e) {
                  if (back_view_long.text.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                decoration: AppInputFieldDecorations.decor1,
              ),
              AppPadding.verticalPadding,
              ElevatedButton(
                onPressed: ()async{
                  setState(() {
                    isSubmitBtnLoading = true;
                  });
                  if (_buildingFormKey.currentState!.validate()) {
                      Map<String, dynamic> data = {
                      "description": buildingDescription.text,
                      "name": buildingName.text,
                      "front_view_lat": front_view_lat.text,
                      "front_view_long": front_view_long.text,
                      "left_view_lat": left_view_lat.text,
                      "left_view_long": left_view_long.text,
                      "right_view_lat": right_view_lat.text,
                      "right_view_long": right_view_long.text,
                      "back_view_lat": back_view_lat.text,
                      "back_view_long": back_view_long.text
                    };
                    int res = await POSTClass.createBuilding(data);
                    if (res == 201){
                      _buildingFormKey.currentState?.reset();
                    }
                    setState(() {
                    isSubmitBtnLoading = false;
                  });
                  }
                  
                }, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isSubmitBtnLoading ? "Uploading.." :"Submit"),
                    AppPadding.horizontalPadding,
                    isSubmitBtnLoading 
                    ? const SizedBox(
                      width: 15,
                      height: 15,
                      child:  CircularProgressIndicator(strokeWidth: 2,color: Colors.white, ))
                    : const SizedBox()
                  ],
                ))
            ],
          ));
    }

    Widget routeForm() {
      return Form(
          key: _routeFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text("Route Form", style: AppBlackTextStyle.texth1,),
              const Divider(),
               const Text("routeName", style: AppBlackTextStyle.texth5),
                TextFormField(
                  controller: routeName,
                  style: const TextStyle(fontSize: 12),
                  validator: (e) {
                    if (routeName.text.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: AppInputFieldDecorations.decor1,
                ),
                AppPadding.verticalPadding,
                const Text("routeCategory", style: AppBlackTextStyle.texth5),
                Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 240, 237, 237),
            borderRadius: BorderRadius.circular(10)),
        height: 40,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: DropdownButton(
            hint: Text(
                routeCategory.text == "" ? "Select" : routeCategory.text,
                style: AppBlackTextStyle.textpGrey),
            icon: const Icon(Icons.arrow_drop_down_outlined,
                size: 15, color: Colors.grey),
            underline: const SizedBox(),
            items: [
              if (routeCategoryList.isEmpty)
                const DropdownMenuItem(
                    value: "",
                    child:
                        Text("No route category", style: AppBlackTextStyle.textpBlack)),
              if (routeCategoryList.isNotEmpty)
                for (int index = 0;
                    index < routeCategoryList.length;
                    index++)
                  DropdownMenuItem(
                      value: routeCategoryList[index],
                      child: Text(
                          routeCategoryList[index],
                          style: AppBlackTextStyle.textpBlack)),
            ],
            isExpanded: true,
            onChanged: (value) async {
              setState(() {
                // Updated selected slug
                routeCategory.text = value.toString();
                
              });
              
            },
          ),
        ),
      ),
        AppPadding.verticalPadding,
        ElevatedButton(
                onPressed: ()async{
                  setState(() {
                    isSubmitBtnLoading = true;
                  });
                  if (_roomsFormKey.currentState!.validate()) {
                      Map<String, String> data = {
                      "description": buildingDescription.text,
                      "name": buildingName.text,
                      "front_view_lat": front_view_lat.text,
                      "front_view_long": front_view_long.text,
                      "left_view_lat": left_view_lat.text,
                      "left_view_long": left_view_long.text,
                      "right_view_lat": right_view_lat.text,
                      "right_view_long": right_view_long.text,
                      "back_view_lat": back_view_lat.text,
                      "back_view_long": back_view_long.text
                    };
                    int res = await POSTClass.createBuilding(data);
                    if (res == 201){
                      _roomsFormKey.currentState?.reset();
                    }
                    setState(() {
                    isSubmitBtnLoading = false;
                  });
                  }
                  
                }, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isSubmitBtnLoading ? "Uploading.." :"Submit"),
                    AppPadding.horizontalPadding,
                    isSubmitBtnLoading 
                    ? const SizedBox(
                      width: 15,
                      height: 15,
                      child:  CircularProgressIndicator(strokeWidth: 2,color: Colors.white, ))
                    : const SizedBox()
                  ],
                ))
              
              ],
            ),
          ));
    }

    Widget coordinateForm() {
      return Form(
          key: _coordinateFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text("Coordinate Form", style: AppBlackTextStyle.texth1,),
              const Divider(),
               const Text("coordinateName", style: AppBlackTextStyle.texth5),
                TextFormField(
                  controller: coordinateName,
                  style: const TextStyle(fontSize: 12),
                  validator: (e) {
                    if (coordinateName.text.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: AppInputFieldDecorations.decor1,
                ),
                AppPadding.verticalPadding,
                const Text("coordinateLat", style: AppBlackTextStyle.texth5),
                TextFormField(
                  controller: coordinateLat,
                  style: const TextStyle(fontSize: 12),
                  validator: (e) {
                    if (coordinateLat.text.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: AppInputFieldDecorations.decor1,
                ),
                AppPadding.verticalPadding,
                 const Text("coordinateLon", style: AppBlackTextStyle.texth5),
                TextFormField(
                  controller: coordinateLon,
                  style: const TextStyle(fontSize: 12),
                  validator: (e) {
                    if (coordinateLon.text.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: AppInputFieldDecorations.decor1,
                ),
                AppPadding.verticalPadding,
                const Text("coordinateRouteID", style: AppBlackTextStyle.texth5),
                Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 240, 237, 237),
            borderRadius: BorderRadius.circular(10)),
        height: 40,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: DropdownButton(
            hint: Text(
                coordinateRouteID.text == "" ? "Select" : coordinateRouteID.text,
                style: AppBlackTextStyle.textpGrey),
            icon: const Icon(Icons.arrow_drop_down_outlined,
                size: 15, color: Colors.grey),
            underline: const SizedBox(),
            items: [
              if (apiRoutesList.isEmpty)
                const DropdownMenuItem(
                    value: "",
                    child:
                        Text("No route category", style: AppBlackTextStyle.textpBlack)),
              if (apiRoutesList.isNotEmpty)
                for (int index = 0;
                    index < apiRoutesList.length;
                    index++)
                  DropdownMenuItem(
                      value: apiRoutesList[index]["id"],
                      child: Text(
                          apiRoutesList[index]["name"],
                          style: AppBlackTextStyle.textpBlack)),
            ],
            isExpanded: true,
            onChanged: (value) async {
              setState(() {
                // Updated selected slug
                coordinateRouteID.text = value.toString();
                
              });
              
            },
          ),
        ),
      ),
        AppPadding.verticalPadding,
        ElevatedButton(onPressed: ()async{
          if (_coordinateFormKey.currentState!.validate()) {
              setState(() {
                isSubmitBtnLoading = true;
              });
              Map<String, String> data = {
                  "name": coordinateName.text,
                  "lat": coordinateLat.text,
                  "lon": coordinateLon.text,
                  "route": coordinateRouteID.text
              };
              int res = await POSTClass.createCoordinate(data);
              if (res == 201){
                _coordinateFormKey.currentState?.reset();
              }
              setState(() {
                isSubmitBtnLoading = false;
              });
          }
        }, 
        child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isSubmitBtnLoading ? "Uploading.." :"Submit"),
                    AppPadding.horizontalPadding,
                    isSubmitBtnLoading 
                    ? const SizedBox(
                      width: 15,
                      height: 15,
                      child:  CircularProgressIndicator(strokeWidth: 2,color: Colors.white, ))
                    : const SizedBox()
                  ],
                ))
              
              ],
            ),
          ));
    }

    Widget roomForm() {
      return Form(
          key: _roomsFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text("Room Form", style: AppBlackTextStyle.texth1,),
              const Divider(),
               const Text("roomName", style: AppBlackTextStyle.texth5),
                TextFormField(
                  controller: roomName,
                  style: const TextStyle(fontSize: 12),
                  validator: (e) {
                    if (roomName.text.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: AppInputFieldDecorations.decor1,
                ),
                AppPadding.verticalPadding,
                const Text("roomLat", style: AppBlackTextStyle.texth5),
                TextFormField(
                  controller: roomLat,
                  style: const TextStyle(fontSize: 12),
                  validator: (e) {
                    if (roomLat.text.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: AppInputFieldDecorations.decor1,
                ),
                AppPadding.verticalPadding,
                 const Text("roomLon", style: AppBlackTextStyle.texth5),
                TextFormField(
                  controller: roomLon,
                  style: const TextStyle(fontSize: 12),
                  validator: (e) {
                    if (roomLon.text.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: AppInputFieldDecorations.decor1,
                ),
                AppPadding.verticalPadding,
                const Text("roomAltitude", style: AppBlackTextStyle.texth5),
                TextFormField(
                  controller: roomAltitude,
                  style: const TextStyle(fontSize: 12),
                  validator: (e) {
                    if (roomAltitude.text.isEmpty) {
                      return "This field is required";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: AppInputFieldDecorations.decor1,
                ),
                AppPadding.verticalPadding,
                const Text("roomBuildingID", style: AppBlackTextStyle.texth5),
                Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 240, 237, 237),
            borderRadius: BorderRadius.circular(10)),
        height: 40,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: DropdownButton(
            hint: Text(
                roomBuildingID.text == "" ? "Select" : roomBuildingID.text,
                style: AppBlackTextStyle.textpGrey),
            icon: const Icon(Icons.arrow_drop_down_outlined,
                size: 15, color: Colors.grey),
            underline: const SizedBox(),
            items: [
              if (widget.buildingsList.isEmpty)
                const DropdownMenuItem(
                    value: "",
                    child:
                        Text("No building", style: AppBlackTextStyle.textpBlack)),
              if (widget.buildingsList.isNotEmpty)
                for (int index = 0;
                    index < widget.buildingsList.length;
                    index++)
                  DropdownMenuItem(
                      value: widget.buildingsList[index]["id"],
                      child: Text(
                          widget.buildingsList[index]["name"],
                          style: AppBlackTextStyle.textpBlack)),
            ],
            isExpanded: true,
            onChanged: (value) async {
              setState(() {
                // Updated selected slug
                roomBuildingID.text = value.toString();
                
              });
              
            },
          ),
        ),
      ),
        AppPadding.verticalPadding,
        ElevatedButton(onPressed: (){
          
          if (_roomsFormKey.currentState!.validate()) {
              setState(() {
                isSubmitBtnLoading = true;
              });
              Map<String, dynamic> data ={
                "name": roomName.text,
                "lat": roomLat.text,
                "lon": roomLon.text,
                "altitude": roomAltitude.text,
                "building": roomBuildingID.toString()
              };
              int res = POSTClass.createRoom(data);
              if (res == 201){
                _roomsFormKey.currentState?.reset();
              }
              setState(() {
                isSubmitBtnLoading = false;
              });
          }
        }, 
        child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isSubmitBtnLoading ? "Uploading.." :"Submit"),
                    AppPadding.horizontalPadding,
                    isSubmitBtnLoading 
                    ? const SizedBox(
                      width: 15,
                      height: 15,
                      child:  CircularProgressIndicator(strokeWidth: 2,color: Colors.white, ))
                    : const SizedBox()
                  ],
                ))
              
              ],
            ),
          ));
    }
    //================================
    // Main Scaffold
    // ===============================
    String activeForm = "building";

  @override
  Widget build(BuildContext context) {
   
    
    return Scaffold(
      appBar: AppBar(
        leading: const GoBackButton(color: AppColors.whitecode),
        title: const Text("Admin Data Collection Page", style: AppWhiteTextStyle.texth3,)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children:[ 
              // Main Page, forms section
              SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    activeForm == "building"
                    ? buildingForm()
                    : activeForm == "route"
                    ? routeForm()
                    : activeForm == "coordinate"
                    ? coordinateForm()
                    : activeForm == "room"
                    ? roomForm() 
                    : const Text(""), 
          
                    AppPadding.verticalPaddingXXL,
                    const Divider(),
                    AppPadding.verticalPaddingXXL,

                    Container(
                      width: deviceSize(context).width,
                      height: 80,
                      child: Text('LOCATION ADDRESS: ${_currentAddress ?? "null"}')),
                    
                    AppPadding.verticalPadding,
                    const Divider(),
                    AppPadding.verticalPaddingXXL,
                    
                  ],
                ),
              ),
            ),
            // On top values
            Align(
              alignment: onTopHeight == "down"
              ? Alignment.bottomRight
              : Alignment.topRight,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 22, 152, 238),
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                width: 250,
                height: 185,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                         onTopHeight= "top";
                        });
                      },
                      child: const Icon(Icons.arrow_upward)),
                    TextFormField(
                      controller: positionValuesTextControl,
                      style: const TextStyle(fontSize: 20),
                      maxLines: 4,
                      decoration: AppInputFieldDecorations.decor1,
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                         onTopHeight= "down";
                        });
                      },
                      child: const Icon(Icons.arrow_downward)),
                  ],
                ),
              ),
            )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppPadding.screenPadding),
        child: Row(
          children: [
            SizedBox(
              width: deviceSize(context).width*0.18,
              child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                         activeForm = "building";
                        });
                      

                    },
                    child: const Text("Building", style: AppWhiteTextStyle.textp,),
                  ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: deviceSize(context).width*0.18,
              child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                          activeForm = "route";
                        });
                      
                    },
                    child: const Text("Route", style: AppWhiteTextStyle.textp,),
                  ),
            ),

            AppPadding.horizontalPadding,
            SizedBox(
              width: deviceSize(context).width*0.14,
              child: ElevatedButton(
                    onPressed: _getCurrentPosition,
                    child: isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.location_on, size: 20,),
                  ),
            ),
            AppPadding.horizontalPadding,

            SizedBox(
              width: deviceSize(context).width*0.18,
              child: ElevatedButton(
                    onPressed: (){
                      getRoutesFunc();
                      setState(() {
                          activeForm = "coordinate";
                        });
                    },
                    child: const Text("Coord", style: AppWhiteTextStyle.textp,),
                  ),
            ),
            const SizedBox(width: 5,),
            SizedBox(
              width: deviceSize(context).width*0.18,
              child: ElevatedButton(
                    onPressed: (){
                      setState(() {
                          activeForm = "room";
                        });
                    },
                     
                    child: const Text("Room", style: AppWhiteTextStyle.textp,),
                  ),
            ),
          ],
        ),
    ));
  }
}