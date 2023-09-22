import 'package:amarp/constants.dart';
import 'package:amarp/screens/buildings.dart';
import 'package:amarp/widgets/custom_floatingbtn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessPage extends StatelessWidget {
  SuccessPage({Key? key, required this.destinationName,required this.imagePath}) : super(key: key);
  String destinationName;
  String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: 
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Image.asset(imagePath)),
            AppPadding.verticalPaddingExtra,
            const Text('Congratulations'),
            const Text("Trip has ended, because you are at the destination")
          ]
        ),
      )),
    floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFloatingActionButton(
            text: "BACK TO HOME", 
            icon: Icons.note_add_sharp, 
            onPressed: (){
             Get.offAll(()=> const BuildingsScreen());
            }, 
            color: Colors.pink.withOpacity(0.8)
          )
        ],
      )
      
    );
  }
}