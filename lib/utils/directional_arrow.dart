import 'package:flutter/material.dart';
import 'dart:math';

enum Direction { North, South, East, West }

class DirectionalArrow extends StatefulWidget {
  DirectionalArrow({Key? key, required this.heading, required this.user_lat, required this.user_lon, this.next_latitude=-33.865143, this.next_longitude=151.209900}) : super(key: key);
  double heading;
  double user_lat;
  double user_lon;
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

  // 
  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180.0;

  Direction getRelativeDirection(double userLat, double userLon, double destLat, double destLon) {
    double bearing = atan2(
      sin(_toRadians(destLon - userLon)) * cos(_toRadians(destLat)),
      cos(_toRadians(userLat)) * sin(_toRadians(destLat)) -
          sin(_toRadians(userLat)) * cos(_toRadians(destLat)) * cos(_toRadians(destLon - userLon)),
    );

    // Convert the bearing angle to degrees
    double degrees = bearing * 180.0 / pi;

    if (degrees >= -135 && degrees < -45) {
      return Direction.South;
    } else if (degrees >= -45 && degrees < 45) {
      return Direction.West;
    } else if (degrees >= 45 && degrees < 135) {
      return Direction.North;
    } else {
      return Direction.East;
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget activeArrow(){
      
      Direction direction = getRelativeDirection(widget.user_lat, widget.user_lon, widget.next_latitude, widget.next_longitude);
      switch (direction) {
        case Direction.North:
          print("Destination is to the North.");
          break;
        case Direction.South:
          print("Destination is to the South.");
          break;
        case Direction.East:
          print("Destination is to the East.");
          break;
        case Direction.West:
          print("Destination is to the West.");
          break;
      }

      // String location = "N";
      // print('Next coord position : $location');
      /* =================================== 
      Handling if next coordinate is NORTH
      =====================================*/
      // if(location == 'N' || location == 'NW' || location == 'NE'){
      //   print('CAME NORTH');
      //   if(widget.heading >= coordInterval[location][0] && widget.heading <= coordInterval[location][1]){
      //     return Image.asset(
      //         arrowsMap["straight"],
      //         width: 200
      //     );
      //   }
      //   // Location on 45deg Left
      //   else if(widget.heading >= coordInterval[location][1] && widget.heading <= coordInterval[location][1]+45){
      //     return Image.asset(
      //       arrowsMap["semi-left"],
      //       width: 200,
      //     );
      //   }
      //   // Location on 45 deg right
      //   else if(widget.heading >= coordInterval[location][0]-45 && widget.heading <= coordInterval[location][0]){
      //     return Image.asset(
      //       arrowsMap["semi-right"],
      //       width: 200,
      //     );
      //   }
      //   // Location on sharp left
      //   else if(widget.heading >= coordInterval[location][1]+45 && widget.heading <= coordInterval[location][1]+135){
      //     return Image.asset(
      //       arrowsMap["sharp-left"],
      //       width: 200,
      //     );
      //   }
      //   // Location on sharp right
      //   else if(widget.heading >= coordInterval[location][0]-135 && widget.heading <= coordInterval[location][0]-45){
      //     return Image.asset(
      //       arrowsMap["sharp-right"],
      //       width: 200,
      //     );
      //   }

      //   else{
      //     return Image.asset(
      //       arrowsMap["back"],
      //       width: 200,
      //     );
      //   }
      // }
      /* =====================================
      Handling if next coordinate is SOUTH
      =======================================*/
      // else{
      //   // Location == Heading
      //   if((widget.heading >= coordInterval[location][0] && widget.heading <= -coordInterval[location][1]) 
      //   || (widget.heading >= coordInterval[location][1] && widget.heading <= coordInterval[location][1]+45)){
      //       return Image.asset(
      //         arrowsMap["straight"],
      //         width: 200
      //     );
      //   }
      //   // Location on 45deg Left
      //   else if(widget.heading >= coordInterval[location][1]+45 && widget.heading <= coordInterval[location][1]+135){
      //     return Image.asset(
      //       arrowsMap["semi-left"],
      //       width: 200,
      //     );
      //   }
      //   // Location on 45 deg right
      //   else if(widget.heading >= coordInterval[location][0]-45 && widget.heading <= coordInterval[location][0]){
      //     return Image.asset(
      //       arrowsMap["semi-right"],
      //       width: 200,
      //     );
      //   }
      //   // Location on sharp left
      //   else if(widget.heading >= coordInterval[location][1]+135 && widget.heading <= coordInterval[location][1]+180){
      //     return Image.asset(
      //       arrowsMap["sharp-left"],
      //       width: 200,
      //     );
      //   }
      //   // Location on sharp right
      //   else if(widget.heading >= coordInterval[location][0]-135 && widget.heading <= coordInterval[location][0]-45){
      //     return Image.asset(
      //       arrowsMap["sharp-right"],
      //       width: 200,
      //     );
      //   }

      //   else{
      //     return Image.asset(
      //       arrowsMap["back"],
      //       width: 200,
      //     );
      //   }
      // }
    return Image.asset(
            arrowsMap["back"],
            width: 200,
          );
    }
        
    // Return widget
    return activeArrow();
  }
}