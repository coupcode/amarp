import 'dart:convert';
import 'package:amarp/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class POSTClass{
  // Building
  static createBuilding(data) async {
    try{
      final headers = {'Content-Type': 'application/json'};
      String jsonBody = json.encode(data);

      http.Response response = await http.post(
          Uri.parse("$baseUrl/buildings/"),
          headers: headers,
          body: jsonBody);
      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          "Building upload successful",
          snackPosition: SnackPosition.TOP
        );
        return 201;
      } else {
        Get.snackbar(
          'Failed',
          "Not created",
          snackPosition: SnackPosition.TOP
        );
        return 403;
      }
    }catch(e){
      Get.snackbar(
          'Failed',
          e.toString(),
          snackPosition: SnackPosition.TOP
      );
      return 500;
    }
  }
 
  // Coordinates
  static createCoordinate(data) async {
    try{
      final headers = {'Content-Type': 'application/json'};
      String jsonBody = json.encode(data);

      http.Response response = await http.post(
          Uri.parse("$baseUrl/coordinates/"),
          headers: headers,
          body: jsonBody);
      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          "Coordinate upload successful",
          snackPosition: SnackPosition.TOP
        );
        return 201;
      } else {
        Get.snackbar( 
          'Failed',
          "Not created",
          snackPosition: SnackPosition.TOP
        );
        return 403;
      }
    }catch(e){
      Get.snackbar(
          'Failed',
          e.toString(),
          snackPosition: SnackPosition.TOP
      );
      return 500;
    }
  }

  // Rooms
  static createRoom(data) async {
    try{
      final headers = {'Content-Type': 'application/json'};
      String jsonBody = json.encode(data);

      http.Response response = await http.post(
          Uri.parse("$baseUrl/rooms/"),
          headers: headers,
          body: jsonBody);
      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          "Room upload successful",
          snackPosition: SnackPosition.TOP
      );
      return 201;
      } else {
        Get.snackbar(
          'Failed',
          "Not created",
          snackPosition: SnackPosition.TOP
      );
        return 403;
      }
    }catch(e){
      Get.snackbar(
          'Failed',
          e.toString(),
          snackPosition: SnackPosition.TOP
      );
      return 500;
    }
  }

  // Routes
  static createRoute(data) async {
    try{
      final headers = {'Content-Type': 'application/json'};
      String jsonBody = json.encode(data);

      http.Response response = await http.post(
          Uri.parse("$baseUrl/routes/"),
          headers: headers,
          body: jsonBody);
      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          "Route upload successful",
          snackPosition: SnackPosition.TOP
       );
       return 201;
      } else {
        Get.snackbar(
          'Failed',
          "Not created",
          snackPosition: SnackPosition.TOP
      );
        return 403;
      }
    }catch(e){
      Get.snackbar(
          'Failed',
          e.toString(),
          snackPosition: SnackPosition.TOP
      );
      return 500;
    }
  }


}