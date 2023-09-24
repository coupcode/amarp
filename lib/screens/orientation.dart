import 'package:amarp/constants.dart';
import 'package:amarp/screens/navigation_page.dart';
import 'package:amarp/widgets/custom_floatingbtn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class OrientationScreen extends StatelessWidget {
  OrientationScreen({Key? key, required this.destinationName,required this.imagePath,required this.routes}) : super(key: key);
  List routes;
  String destinationName;
  String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.phone_iphone_outlined, size: 180, color: Colors.white),
            const Text("Tip: Position your phone vertically", style: AppWhiteTextStyle.texth3),
            const Text("pointing to your view", style: AppWhiteTextStyle.texth3),
            AppPadding.verticalPaddingXXL,
            CustomFloatingActionButton(text: "Got it", icon: Icons.thumb_up, onPressed: (){
              Get.off(()=> NavigationPage(
                destinationName: destinationName,
                imagePath: imagePath,
                routes: routes
              ));
            }, color: Colors.red)
          ],
        ),
      ),
    );
  }
}