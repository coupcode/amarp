import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoBackButton extends StatelessWidget {
  final int color;
  const GoBackButton({
    Key? key,
    required this.color
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() => Get.back()),
      child: Icon(
        Icons.arrow_back_ios_new_outlined,
        size: 16,
        color: Color(color)
      ),
    ) ;
    
   
  }
}
