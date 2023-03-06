import 'package:amarp/constants.dart';
import 'package:amarp/screens/camera.dart';
import 'package:amarp/screens/compass.dart';
import 'package:amarp/screens/locations.dart';
import 'package:amarp/widgets/shimmer_results_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildingsScreen extends StatefulWidget {
  const BuildingsScreen({super.key});

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen> {
  List buildingList = [
    {
    "name": "LT 1",
    "image": "assets/images/lt1.jpeg",
    "description": "It is a lecture hall"
    },
    {
    "name": "SH 1",
    "image": "assets/images/lt1.jpeg",
    "description": "It is a lecture hall"
    },
    {
    "name": "Auditorium 1",
    "image": "assets/images/lt1.jpeg",
    "description": "It is a lecture hall"
    },
  ];
  List searchedBuildingList =[];
  bool isLoading = false;
  bool searchOpened = false;

  final TextEditingController _searchField = TextEditingController();

  @override
  void dispose() {
    _searchField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget searchWidget() {
      return Container(
        width: double.infinity,
        height: 35,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: TextField(
          controller: _searchField,
          style: const TextStyle(fontSize: 12),
          onChanged: (val){
            List data = buildingList
            .where((event) => 
            event["name"].toLowerCase().contains(val.toLowerCase())).toList();
            setState(() {
              searchedBuildingList = data;
            });
          },
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear,
                  size: 15, color: Color(AppColors.greycode)),
              onPressed: () {
                setState(() {
                  _searchField.text = "";
                  searchedBuildingList = buildingList;
                });
              },
            ),
            contentPadding: const EdgeInsets.all(5),
            hintStyle: AppBlackTextStyle.textpGrey,
            hintText: 'Search...',
            focusedBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: Color(AppColors.blueColor), width: 1.0),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: Color(AppColors.greycode), width: 1.0),
            ),
          ),
        ),
      );
    }

    Widget listBuildings() {
      return ListView.builder(
          itemCount: searchOpened ? searchedBuildingList.length : buildingList.length,
          itemBuilder: (((context, index) => Card(
              elevation: 1,
              child: SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: deviceSize(context).width * 0.2,
                        child: 
                        searchOpened
                        ? searchedBuildingList[index]["image"] != null
                            ? Image.asset(searchedBuildingList[index]["image"])
                            : Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    color: Color.fromARGB(255, 235, 234, 234)),
                                child: const Center(
                                    child: Icon(Icons.camera_alt_outlined,
                                        color: Colors.white)),
                              )
                        : buildingList[index]["image"] != null
                            ? Image.asset(buildingList[index]["image"])
                            : Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    color: Color.fromARGB(255, 235, 234, 234)),
                                child: const Center(
                                    child: Icon(Icons.camera_alt_outlined,
                                        color: Colors.white)),
                              ),
                      ),
                      SizedBox(
                        width: deviceSize(context).width * 0.4,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(searchOpened 
                              ? searchedBuildingList[index]["name"] 
                              : buildingList[index]["name"],
                                  style: AppBlackTextStyle.texth5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(searchOpened
                                      ? "${searchedBuildingList[index]["description"]}"
                                      : "${buildingList[index]["description"]}",
                                      style: AppBlackTextStyle.textpBlack),
                                  
                                ],
                              )
                            ]),
                      ),
                      SizedBox(
                          width: deviceSize(context).width * 0.2,
                          child: Column(
                            children: [
                              const Text("View",
                                  style: AppBlackTextStyle.textpBlack),
                              TextButton(
                                  onPressed: () {
                                    Get.bottomSheet(Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15))),
                                      height: 160,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          TextButton(onPressed: (){
                                            Get.to(()=> CameraScreen());
                                          }, child: Text("Open Camera")),
                                          TextButton(onPressed: (){
                                            Get.to(()=> LocationsPage());
                                          }, child: Text("Locations Page")),
                                          TextButton(onPressed: (){
                                            Get.to(()=> CompassPage());
                                          }, child: Text("Compass Page")),
                                        ]),
                                      ),
                                    ));
                                  },
                                  child: const Icon(
                                    Icons.more_vert,
                                    color: Colors.black,
                                    size: 20,
                                  )),
                            ],
                          ))
                    ],
                  ),
                ),
              )))));
    }

    return Scaffold(
       appBar:  AppBar(
          title: searchOpened
              ? searchWidget()
              : const Text("Amarp", style: AppBlackTextStyle.texth4),

          elevation: 0,
          // centerTitle: true,
          backgroundColor: Colors.white,
          // leading: const GoBackButton(color: AppColors.blackCode),
          actions: [
            searchOpened
              // Cancel
                ? TextButton(
                  onPressed: (){
                     setState(() {
                       searchOpened = false;
                  _searchField.text = "";
                  searchedBuildingList = [];
                     });
                  }, 
                  child: const Text("cancel", style: AppBlackTextStyle.texth5)
                )
                // Search Icon
                : IconButton(
                    onPressed: () {
                      setState(() {
                        searchOpened = true;
                        searchedBuildingList = buildingList;
                      });
                    },
                    icon: const Icon(Icons.search,
                        color: Color(AppColors.blackCode), size: 15))
          ],
        ),
      body: SafeArea(
            child: isLoading
                ? const ShimmerResultList(count: 5)
                : buildingList.isEmpty || (searchOpened && searchedBuildingList.isEmpty)
                    ? Center(
                        child: Text(
                          searchOpened 
                          ? "No result found" 
                          : "No created event",
                            style: AppBlackTextStyle.textpGrey))
                    : listBuildings()),
    );
  }
}