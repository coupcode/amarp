import 'package:amarp/constants.dart';
import 'package:amarp/controller/controller.dart';
import 'package:amarp/widgets/route_banner.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum Direction { 
  N, 
  NE,
  E, 
  SE,
  S,
  SW,
  W,
  NW
}

class DirectionalArrow extends StatefulWidget {
  DirectionalArrow({Key? key, required this.heading, required this.user_lat, required this.user_lon, required this.next_latitude, required this.next_longitude}) : super(key: key);
  double heading;
  double user_lat;
  double user_lon;
  double next_latitude;
  double next_longitude;
  

  @override
  State<DirectionalArrow> createState() => _DirectionalArrowState();
}

class _DirectionalArrowState extends State<DirectionalArrow> {
  // Inside some event handler or function
void updateIsArrowStraight(bool value) {
  isArrowStraight(value); // Update the value using the .value setter
}

  // ARROWS
  Map arrowsMap = {
    "straight":"assets/icons/sa.png",
    "back":"assets/icons/ba.png",
    "semi-right":"assets/icons/semi-ra.png",
    "semi-left":"assets/icons/semi-la.png",
    "sharp-left":"assets/icons/sharp-left.png",
    "sharp-right":"assets/icons/sharp-right.png"
  };
  bool tts_for_back = false;

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

    if(degrees >= 67.5 && degrees < 112.5){
      return Direction.E;
    } else if(degrees >= 112.5 && degrees < 157.5){
      return Direction.SE;
    } else if(degrees >= -157.5 && degrees < -112.5){
      return Direction.SW;
    } else if(degrees >= -112.5 && degrees < -67.5){
      return Direction.W;
    } else if(degrees >= -67.5 && degrees < -22.5){
      return Direction.NW;
    } else if(degrees >= -22.5 && degrees < 22.5){
      return Direction.N;
    } else if(degrees >= 22.2 && degrees < 67.5){
      return Direction.NE;
    } else{
      return Direction.S;
    }
  
  }

  String userInfo = "";

  @override
  Widget build(BuildContext context) {

    Widget activeArrow(){
      
      // Direction direction = getRelativeDirection(
      //   widget.user_lat, widget.user_lon, 
      //   widget.next_latitude, widget.next_longitude
      // );
      Direction direction = Direction.E;
      switch (direction) {
        /* ====================================================
          EAST
        ================================================== */
        case Direction.E:
          if(widget.heading >= 67.5 && widget.heading < 112.5){
            tts_for_back = false;
            updateIsArrowStraight(true);
            return Image.asset(
              arrowsMap["straight"],
              width: 200
            );
          }
          else if(widget.heading >= 22.5 && widget.heading < 67.5){
            tts_for_back = false;
            updateIsArrowStraight(true);
            return Image.asset(
              arrowsMap["semi-right"],
              width: 200
            );
          }
          else if(widget.heading >= -67.5 && widget.heading < 22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-right"],
              width: 200
            );
          }
          else if(widget.heading >= 112.5 && widget.heading < 157.5){
            tts_for_back = false;
            updateIsArrowStraight(true);
            return Image.asset(
              arrowsMap["semi-left"],
              width: 200
            );
          }
          else if(widget.heading >= -112.5 && widget.heading < -67.5){
            if (tts_for_back == false){
              saySomethingToUser("Please, Turn back");
              tts_for_back = true;
            }
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["back"],
              width: 200
            );
          }
          else{
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-left"],
              width: 200
            );
          }
        
        /* ====================================================
          SOUTH EAST
        ================================================== */
        case Direction.SE:
          if(widget.heading >= 112.5 && widget.heading < 157.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["straight"],
              width: 200
            );
          }
          else if(widget.heading >= 67.5 && widget.heading < 112.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-right"],
              width: 200
            );
          }
          else if(widget.heading >= -22.5 && widget.heading < 67.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-right"],
              width: 200
            );
          }
          else if (widget.heading >= -67.5 && widget.heading < -22.5){
            if (tts_for_back == false){
              saySomethingToUser("Please, Turn back");
              tts_for_back = true;
            }
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["back"],
              width: 200
            );
          }
          else if(widget.heading >= -157.5 && widget.heading < -67.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-left"],
              width: 200
            );
          }
          else{
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-left"],
              width: 200
            );
          }

        /* ====================================================
          SOUTH WEST
        ================================================== */
        case Direction.SW:
          if(widget.heading >= -157.5 && widget.heading < -112.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["straight"],
              width: 200
            );
          }
          else if(widget.heading >= -112.5 && widget.heading < -67.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-left"],
              width: 200
            );
          }
          else if(widget.heading >= -67.5 && widget.heading < 22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-left"],
              width: 200
            );
          }
          else if(widget.heading >= 22.5 && widget.heading < 67.5){
            if (tts_for_back == false){
              saySomethingToUser("Please, Turn back");
              tts_for_back = true;
            }
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["back"],
              width: 200
            );
          }
          else if(widget.heading >= 67.5 && widget.heading < 157.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-right"],
              width: 200
            );
          }
          else{
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-right"],
              width: 200
            );
          }

         /* ====================================================
          WEST
        ================================================== */
        case Direction.W:
          if(widget.heading >= -112.5 && widget.heading < -67.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["straight"],
              width: 200
            );
          }
          else if(widget.heading >= -67.5 && widget.heading < -22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-left"],
              width: 200
            );
          }
          else if(widget.heading >= -22.5 && widget.heading < 67.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-left"],
              width: 200
            );
          }
          else if(widget.heading >= 67.5 && widget.heading < 112.5){
            if (tts_for_back == false){
              saySomethingToUser("Please, Turn back");
              tts_for_back = true;
            }
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["back"],
              width: 200
            );
          }
          else if(widget.heading >= -157.5 && widget.heading < -112.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-right"],
              width: 200
            );
          }
          else{
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-right"],
              width: 200
            );
          }

        /* ====================================================
          NORTH WEST
        ================================================== */
        case Direction.NW:
          if(widget.heading >= -67.5 && widget.heading < -22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["straight"],
              width: 200
            );
          }
          else if(widget.heading >= -22.5 && widget.heading < 22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-left"],
              width: 200
            );
          }
          else if(widget.heading >= 22.5 && widget.heading < 112.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-left"],
              width: 200
            );
          }
          else if(widget.heading >= 112.5 && widget.heading < 157.5){
            if (tts_for_back == false){
              saySomethingToUser("Please, Turn back");
              tts_for_back = true;
            }
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["back"],
              width: 200
            );
          }
          else if(widget.heading >= -112.5 && widget.heading < -67.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-right"],
              width: 200
            );
          }
          else{
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-right"],
              width: 200
            );
          }

        /* ====================================================
         NORTH
        ================================================== */
        case Direction.N:
          if(widget.heading >= -22.5 && widget.heading < 22.5){
            tts_for_back =false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["straight"],
              width: 200
            );
          }
          else if(widget.heading >= 22.5 && widget.heading < 67.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-left"],
              width: 200
            );
          }
          else if (widget.heading >= 67.5 && widget.heading < 157.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-left"],
              width: 200
            );
          }
          else if (widget.heading >= -67.5 && widget.heading < -22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-right"],
              width: 200
            );
          }
          else if (widget.heading >= -157.5 && widget.heading < -67.5){
            tts_for_back = false; 
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-right"],
              width: 200
            );
          }
          else{
            if (tts_for_back == false){
              saySomethingToUser("Please, Turn back");
              tts_for_back = true;
            }
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["back"],
              width: 200
            );
          }

        /* ====================================================
         NORTH EAST
        ================================================== */
        case Direction.NE:
          if(widget.heading >= 22.2 && widget.heading < 67.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["straight"],
              width: 200
            );
          }
          else if (widget.heading >= 67.5 && widget.heading < 112.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-left"],
              width: 200
            );
          }
          else if (widget.heading >= -22.5 && widget.heading < 22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-right"],
              width: 200
            );
          }
          else if (widget.heading >= -112.5 && widget.heading < -22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-right"],
              width: 200
            );
          }
          else if(widget.heading >= -157.5 && widget.heading < -112.5){
            if (tts_for_back == false){
              saySomethingToUser("Please, Turn back");
              tts_for_back = true;
            }
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["back"],
              width: 200
            );
          }
          else{
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-left"],
              width: 200
            );
          }

        /* ====================================================
         SOUTH
        ================================================== */
        case Direction.S:
          if(widget.heading >= -157.5 && widget.heading < -112.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-left"],
              width: 200
            );
          }
          else if(widget.heading >= -112.5 && widget.heading < -22.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-left"],
              width: 200
            );
          }
          else if(widget.heading >= 112.5 && widget.heading < 157.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["semi-right"],
              width: 200
            );
          }
          else if(widget.heading >= 22.5 && widget.heading < 112.5){
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["sharp-right"],
              width: 200
            );
          }
          else if(widget.heading >= -22.5 && widget.heading < 22.5){
            if (tts_for_back == false){
              saySomethingToUser("Please, Turn back");
              tts_for_back = true;
            }
            updateIsArrowStraight(false);
            return Image.asset(
              arrowsMap["back"],
              width: 200
            );
          }
          else{
            tts_for_back = false;
            updateIsArrowStraight(false);
            return Image.asset(
                arrowsMap["straight"],
                width: 200
              );
          }
      }
    }
        
    // Return widget
    return Column(
      children: [
        activeArrow(),
        // Position logger
        // Text(userInfo, style: const TextStyle(color: Color.fromARGB(255, 18, 150, 8), fontWeight: FontWeight.w800, fontSize: 30))
      ],
    );
  }
}

