import 'package:camera/camera.dart';
import 'package:clothes_image_classification/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;
  final List<CameraDescription> cameras;

  const CameraPreviewScreen({
    super.key,
    required this.camera,
    required this.cameras,
  });

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera(widget.camera);
  }

  void _initializeCamera(CameraDescription cameraDescription) {
    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    initializeControllerFuture = cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _switchCamera() {
    final newCamera = widget.cameras.firstWhere(
      (cam) => cam.lensDirection != cameraController.description.lensDirection,
    );

    _initializeCamera(newCamera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: AppColors.white,
        ),
      ),
      body: FutureBuilder(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox.expand(child: CameraPreview(cameraController));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // switch cam button to and from selfie
          FloatingActionButton(
            heroTag: "switchCam",
            backgroundColor: Colors.white,
            onPressed: _switchCamera,
            child: const Icon(Icons.cameraswitch, color: Colors.black),
          ),
          //button to take pic
          FloatingActionButton(
            heroTag: "capturePic",
            backgroundColor: Colors.white,
            onPressed: () async {
              await initializeControllerFuture;
              final picture = await cameraController.takePicture();
              Navigator.pop(context, picture);
            },
            child: const Icon(Icons.camera_alt, color: Colors.black),
          ),
        ],
      ),
    );
  }
}