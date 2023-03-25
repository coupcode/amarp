import 'package:amarp/api/get_class.dart';
import 'package:get/get.dart';


var isOffline = false.obs;
var isBuildingLoading = false.obs;


class AppController extends GetxController {  
  List buildingsList = [].obs;

  void getBuildingsController() async {
    isBuildingLoading(true);
    buildingsList = await GETClass.getBuildings();
    isBuildingLoading(false);
  }

}