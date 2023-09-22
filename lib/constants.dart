import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';


const baseUrl = "http://amarp.pythonanywhere.com/api/v1";
// Text to speech
TextToSpeech tts = TextToSpeech();
void saySomethingToUser(String text){
  tts.setVolume(1.0);
  tts.speak(text);
}

// Global methods
deviceSize(context) {
  return MediaQuery.of(context).size;
}
String truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
    ? myString
    : '${myString.substring(0, cutoff)}...';
}

class AppColors {
  static const backgroundColor = 0xFFFFFF;
  static const blueColor = 0xFF0044FF;
  static const blackCode = 0xFF000000;
  static const whitecode = 0xFFFFFFFF;
  static const greycode = 0xFFdfdfe6;
  static const greencode = 0xFF008631;
  static const redcode = 0xFF880808;
}

class AppPadding {
  static const double screenPadding = 10.0;
  static const double screenPaddingExtra = 15.0;
  static const double screenPaddingXXL = 20.0;
  static const horizontalPadding = SizedBox(width: 10);
  static const verticalPadding = SizedBox(height: 10);
  static const verticalPaddingExtra = SizedBox(height: 15);
  static const verticalPaddingXXL = SizedBox(height: 20);
}

class AppInputFieldDecorations {
  static const decor1 = InputDecoration(
      filled: true,
      fillColor: Color.fromARGB(255, 243, 243, 243),
      isDense: true,
      errorStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      contentPadding: EdgeInsets.all(12),
      border: OutlineInputBorder(
          // borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(5))));
  
  static const decor2 = InputDecoration(
    filled: false,
    errorStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
    contentPadding: EdgeInsets.all(13),
  );
}

class AppWhiteTextStyle {
  static const texth1 =
      TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: Colors.white);
  static const texth2 =
      TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: Colors.white);
  static const texth3 =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white);
  static const texth4 = TextStyle(fontSize: 14, color: Colors.white);
  static const texth5 =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white);
  static const textp =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white);
 
}

class AppBlackTextStyle {
  
  static const texth1 =
      TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: Colors.black);
  static const texth2 =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black);
  static const texth2B =
      TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Colors.black);
  static const texth3 =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black);
  static const texth4 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black);
  static const texth4B =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black);
  static const texth5 =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black);
  static const textpBlack =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black);
  static const textpGrey =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey);
}

