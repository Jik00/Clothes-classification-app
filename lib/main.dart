import 'package:camera/camera.dart';
import 'package:clothes_image_classification/ui/upload_pic.dart';
import 'package:clothes_image_classification/utils/app_theme.dart';
import 'package:flutter/material.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(
      MyApp(cameraDescription:firstCamera ,)
  );
}
class MyApp extends StatelessWidget {
  final CameraDescription cameraDescription;
  const MyApp({super.key, required this.cameraDescription});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: UploadPic(camera: cameraDescription,),
    );

  }
}