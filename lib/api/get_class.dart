import 'dart:convert';
import 'dart:io';
import 'package:amarp/constants.dart';
import 'package:amarp/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class GETClass{
  
  static getBuildings() async {
    try{
    http.Response response =
        await http.get(Uri.parse("$baseUrl/buildings/"));
 
    if (response.statusCode == 200) {
      return json.decode(response.body)["results"];
    } else {
      return [];
    }
  }on SocketException catch (_) {
      Get.snackbar(
          'Error',
          "No internet",
          colorText: Color.fromARGB(0, 255, 255, 255),
          backgroundColor: Color.fromARGB(0, 240, 0, 0),
          snackPosition: SnackPosition.TOP
      ) ;
    }
  }


  static getRoutes() async {
    try{
    http.Response response =
        await http.get(Uri.parse("$baseUrl/routes/"));
    if (response.statusCode == 200) {
      return json.decode(response.body)["results"];
    } else {
      return [];
    }
  }on SocketException catch (_) {
      Get.snackbar(
          'Error',
          "No internet",
          colorText: Color.fromARGB(0, 255, 255, 255),
          backgroundColor: Color.fromARGB(0, 240, 0, 0),
          snackPosition: SnackPosition.TOP
      ) ;
    }
    return [];
  }
}