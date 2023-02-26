import 'dart:io';
import 'package:amarp/constants.dart';
import 'package:amarp/screens/buildings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

// Creating certificates for API connection
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

Future main() async{
  
  // Adding certificate global
  HttpOverrides.global = MyHttpOverrides();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  

  @override
  Widget build(BuildContext context) {
    // To set orientation always portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amarp',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: const Color(AppColors.blueColor),
        primaryIconTheme: const IconThemeData(color: Colors.white),

      ),
      builder: EasyLoading.init(),
      home: const BuildingsScreen(),
    );
  }
}

