import 'package:flutter/material.dart';

class DirectionalArrow extends StatefulWidget {
  DirectionalArrow({Key? key, required this.heading, this.next_latitude=-33.865143, this.next_longitude=151.209900}) : super(key: key);
  double heading;
  double next_latitude;
  double next_longitude;

  @override
  State<DirectionalArrow> createState() => _DirectionalArrowState();
}

class _DirectionalArrowState extends State<DirectionalArrow> {
  Map arrowsMap = {
    "straight":"assets/icons/sa.png",
    "back":"assets/icons/ba.png",
    "semi-right":"assets/icons/semi-ra.png",
    "semi-left":"assets/icons/semi-la.png",
    "sharp-left":"assets/icons/sharp-left.png",
    "sharp-right":"assets/icons/sharp-right.png"
  };

  Map coordInterval = {
    // North
    "N": [-44, 44],
    "NW": [-90, -45],
    "NE": [45, 90],
    // South
    "S": [-135, -179],
    "SS": [135, 179],
    "SW": [-91, -134],
    "SE": [91, 134],
    
    "Equator": [0, 0]
  };

  @override
  Widget build(BuildContext context) {
    Widget activeArrow(){
      // Check the heading/location of the next coord
      String getNextCoordLocation(double latitude, double longitude) {
        if (latitude > 0) {
          if (longitude > 0) {
            return "NE";
          } else if (longitude < 0) {
            return "NW";
          } else {
            return "N";
          }
        } else if (latitude < 0) {
          if (longitude > 0) {
            return "SE";
          } else if (longitude < 0) {
            return "SW";
          } else {
            return "S";
          }
        } else {
          if (longitude > 0) {
            return "E";
          } else if (longitude < 0) {
            return "W";
          } else {
            return "Equator";
          }
        }
      }
      // String location = getNextCoordLocation(widget.next_latitude, widget.next_longitude);
      String location = "NE";
      print('Next coord position : $location');
      /* =================================== 
      Handling if next coordinate is NORTH
      =====================================*/
      if(location == 'N' || location == 'NW' || location == 'NE'){
        print('CAME NORTH');
        if(widget.heading >= coordInterval[location][0] && widget.heading <= coordInterval[location][1]){
          return Image.asset(
              arrowsMap["straight"],
              width: 200
          );
        }
        // Location on 45deg Left
        else if(widget.heading >= coordInterval[location][1] && widget.heading <= coordInterval[location][1]+45){
          return Image.asset(
            arrowsMap["semi-left"],
            width: 200,
          );
        }
        // Location on 45 deg right
        else if(widget.heading >= coordInterval[location][0]-45 && widget.heading <= coordInterval[location][0]){
          return Image.asset(
            arrowsMap["semi-right"],
            width: 200,
          );
        }
        // Location on sharp left
        else if(widget.heading >= coordInterval[location][1]+45 && widget.heading <= coordInterval[location][1]+135){
          return Image.asset(
            arrowsMap["sharp-left"],
            width: 200,
          );
        }
        // Location on sharp right
        else if(widget.heading >= coordInterval[location][0]-135 && widget.heading <= coordInterval[location][0]-45){
          return Image.asset(
            arrowsMap["sharp-right"],
            width: 200,
          );
        }

        else{
          return Image.asset(
            arrowsMap["back"],
            width: 200,
          );
        }
      }
      /* =====================================
      Handling if next coordinate is SOUTH
      =======================================*/
      // SOUTH: SS
      else if(location == 'SS'){
        print('CAME SS');
        // Straight
        if(widget.heading >= coordInterval[location][0] && widget.heading <= coordInterval[location][1]){
          return Image.asset(
              arrowsMap["straight"],
              width: 200
          );
        }
        // Location on 45deg Left
        else if(widget.heading >= -coordInterval[location][1] && widget.heading <= (-coordInterval[location][1]+45)){
          return Image.asset(
            arrowsMap["semi-left"],
            width: 200,
          );
        }
        // Location on 45 deg right
        else if(widget.heading >= coordInterval[location][0]-45 && widget.heading <= coordInterval[location][0]){
          return Image.asset(
            arrowsMap["semi-right"],
            width: 200,
          );
        }
        // Location on sharp left
        else if(widget.heading >= (-coordInterval[location][1]+45) && widget.heading <= (-coordInterval[location][1]+135)){
          return Image.asset(
            arrowsMap["sharp-left"],
            width: 200,
          );
        }
        // Location on sharp right
        else if(widget.heading >= coordInterval[location][0]-135 && widget.heading <= coordInterval[location][0]-45){
          return Image.asset(
            arrowsMap["sharp-right"],
            width: 200,
          );
        }

        else{
          return Image.asset(
            arrowsMap["back"],
            width: 200,
          );
        }
      }
      // SOUTH: S
      else if(location == 'S'){
         print('CAME S');
        // Straight
        if(widget.heading >= coordInterval[location][1] && widget.heading <= coordInterval[location][0]){
          return Image.asset(
              arrowsMap["straight"],
              width: 200
          );
        }
        // Location on 45deg Left
        else if(widget.heading >= coordInterval[location][0] && widget.heading <= (coordInterval[location][0]+45)){
          return Image.asset(
            arrowsMap["semi-left"],
            width: 200,
          );
        }
        // Location on 45 deg right
        else if(widget.heading >= -coordInterval[location][0] && widget.heading <= -coordInterval[location][1]){
          return Image.asset(
            arrowsMap["semi-right"],
            width: 200,
          );
        }
        // Location on sharp left
        else if(widget.heading >= (coordInterval[location][0]+45) && widget.heading <= (coordInterval[location][0]+135)){
          return Image.asset(
            arrowsMap["sharp-left"],
            width: 200,
          );
        }
        // Location on sharp right
        else if(widget.heading >= -coordInterval[location][0]-45 && widget.heading <= -coordInterval[location][0]){
          return Image.asset(
            arrowsMap["sharp-right"],
            width: 200,
          );
        }

        else{
          return Image.asset(
            arrowsMap["back"],
            width: 200,
          );
        }
      }
      // SOUTH: SW
      else if(location == 'SW'){
        print('CAME SW');
        // Straight
        if(widget.heading >= coordInterval[location][1] && widget.heading <= coordInterval[location][0]){
          return Image.asset(
              arrowsMap["straight"],
              width: 200
          );
        }
        // Location on 45deg Left
        else if(widget.heading >= coordInterval[location][0] && widget.heading <= (coordInterval[location][0]+45)){
          return Image.asset(
            arrowsMap["semi-left"],
            width: 200,
          );
        }
        // Location on 45 deg right
        else if(widget.heading >= coordInterval[location][1]-45 && widget.heading <= coordInterval[location][1]){
          return Image.asset(
            arrowsMap["semi-right"],
            width: 200,
          );
        }
        // Location on sharp left
        else if(widget.heading >= (coordInterval[location][0]+45) && widget.heading <= (coordInterval[location][0]+135)){
          return Image.asset(
            arrowsMap["sharp-left"],
            width: 200,
          );
        }
        // Location on sharp right
        else if(widget.heading >= 135 && widget.heading <= 179){
          return Image.asset(
            arrowsMap["sharp-right"],
            width: 200,
          );
        }

        else{
          return Image.asset(
            arrowsMap["back"],
            width: 200,
          );
        }
      }
      else if(location == 'SE'){
        print('CAME SE');
        // Straight
        if(widget.heading >= coordInterval[location][0] && widget.heading <= coordInterval[location][1]){
          return Image.asset(
              arrowsMap["straight"],
              width: 200
          );
        }
        // Location on 45deg Left
        else if(widget.heading >= coordInterval[location][1] && widget.heading <= (coordInterval[location][1]+45)){
          return Image.asset(
            arrowsMap["semi-left"],
            width: 200,
          );
        }
        // Location on 45 deg right
        else if(widget.heading >= coordInterval[location][0]-45 && widget.heading <= coordInterval[location][0]){
          return Image.asset(
            arrowsMap["semi-right"],
            width: 200,
          );
        }
        // Location on sharp left
        else if(widget.heading >= -179 && widget.heading <= -135){
          return Image.asset(
            arrowsMap["sharp-left"],
            width: 200,
          );
        }
        // Location on sharp right
        else if(widget.heading >= coordInterval[location][0]-135 && widget.heading <= coordInterval[location][0]-45){
          return Image.asset(
            arrowsMap["sharp-right"],
            width: 200,
          );
        }

        else{
          return Image.asset(
            arrowsMap["back"],
            width: 200,
          );
        }
      }
      else{
        return const SizedBox();
      }
      
    }
    return activeArrow();
  }
}