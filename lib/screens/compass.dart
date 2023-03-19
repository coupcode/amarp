import 'package:amarp/constants.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class CompassPage extends StatefulWidget {
  const CompassPage({Key? key}) : super(key: key);

  @override
  _CompassPageState createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  double _heading = 0.0;
  late CameraController _cameraController;
  late Future<void> _cameraInitFuture;

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );
      _cameraInitFuture = _cameraController.initialize();
    });
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass App'),
      ),
      body: FutureBuilder<void>(
        future: _cameraInitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_cameraController),
                ),
                Center(
                  child: Container(
                    color: Colors.white,
                    width: deviceSize(context).width*0.7,
                    height: 30,
                    child: Center(child: Text('Heading: $_heading', style: TextStyle(color:Colors.green, fontSize: 17),)),
                  ),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: Transform.rotate(
                      angle: (_heading) * (math.pi / 180),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green,
                        size: 200,
                      ),
                    ),
                  )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
