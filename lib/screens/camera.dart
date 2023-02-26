import 'package:amarp/constants.dart';
import 'package:amarp/widgets/rotate_widget.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isLoading = true;

  @override
  void initState() {
    initializeCamera();
    super.initState();
  }

  Future<void> initializeCamera() async {
    // Get available cameras
    cameras = await availableCameras();

    // Initialize controller
    controller = CameraController(cameras[0], ResolutionPreset.medium);

    // Prepare controller
    await controller.initialize();

    // Stop loader
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
       isLoading
       ? const Center(child: CircularProgressIndicator())
       : controller != null && controller.value.isInitialized
          ? Stack(
            children:[
               SizedBox(
              height: deviceSize(context).height *1,
              child: CameraPreview(controller),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: deviceSize(context).height * 0.4,
                  left: deviceSize(context).width *0.1
                ),
                child: RotatedWidget(
                  // ignore: sort_child_properties_last
                  child: Row(
                    children:  [
                     for(int i=0; i<3; i++)
                      const Icon(Icons.arrow_back_ios_new_outlined, size: 100, color: Colors.blue),
                     
                  ],
                ), angle: 160),
              )
              
            ]
          ) 
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    // Dispose controller
    controller.dispose();
    super.dispose();
  }
}
