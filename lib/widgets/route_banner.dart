import 'package:amarp/constants.dart';
import 'package:flutter/material.dart';

class RouteBanner extends StatefulWidget {
  RouteBanner({Key? key, required this.heading, required this.distanceToNextCoord,required this.routeName, required this.routeIndex,this.top=200, this.left=150, this.right=0.0}) : super(key: key);
  final String routeName;
  final int routeIndex;
  final double top;
  final double left;
  final double right;
  final distanceToNextCoord;
  final heading;

  @override
  State<RouteBanner> createState() => _RouteBannerState();
}

class _RouteBannerState extends State<RouteBanner> {
  @override
  Widget build(BuildContext context) {
    Widget boardWidget(double fontSize, double marginTop, double marginLeft, double cardHeight, double cardWidth, double poleWidth, double poleHeight){
      return Container(
      margin: EdgeInsets.only(
        top: marginTop, 
        left: marginLeft,

      ),
      child: Column(
        children: [
          Card(
            elevation: 5,
            color: const Color.fromARGB(255, 28, 27, 27),
            child: Container(
              padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            height: cardHeight,
            width: cardWidth,
            child: Text(widget.routeName, style: TextStyle(color: Colors.white, fontSize: fontSize)),
          ),
          ),
          // Container(
          //   height: poleHeight,
          //   width: poleWidth,
          //   color: const Color.fromARGB(255, 28, 27, 27),
          // )
        ],
      ),
    );
    }
    double distanceToCoord = double.parse(widget.distanceToNextCoord.toString());
    double marginLeftVal = widget.heading > 0 
      ? (700 - (distanceToCoord*2)) - (widget.heading*5) // positive headings
      : (600 - (distanceToCoord*2)) + (widget.heading*5); // negative headings ;
    return 
     distanceToCoord <= 60 && distanceToCoord >=20 && marginLeftVal > 0
      ? boardWidget(
          distanceToCoord < 25  ? 18 : 550 / (distanceToCoord), // fontSize
          300 - distanceToCoord, // marginTop
          marginLeftVal, // marginLeft
          90 - distanceToCoord, // cardHeight
          180 - distanceToCoord, // cardWidth
          distanceToCoord >= 40 && distanceToCoord <= 50 ? 2 : 3, // poleWidth
          distanceToCoord > 40 && distanceToCoord <= 50 
          ? 0 
          : distanceToCoord > 20 && distanceToCoord <= 40
           ? 300 // poleHeight
           : 200
        )
      : const SizedBox();
  }
}