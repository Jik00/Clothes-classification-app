import 'dart:io';
import 'package:camera/camera.dart';
// import 'package:clothes_image_classification/helper/image_preprocessing.dart';
import 'package:clothes_image_classification/utils/app_colors.dart';
import 'package:clothes_image_classification/utils/app_images.dart';
import 'package:clothes_image_classification/utils/app_styles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../utils/widgets/custom_elevated_button.dart';
import 'camera_preview_screen.dart';

class UploadPic extends StatefulWidget {
  final CameraDescription camera;

  const UploadPic({super.key, required this.camera});

  @override
  State<UploadPic> createState() => _UploadPicState();
}

class _UploadPicState extends State<UploadPic> {
  late CameraController _cameraController;
  PlatformFile? file;
  XFile? _imagePath;
  File? imageFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cameraController = CameraController(widget.camera, ResolutionPreset.high);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: AppColors.white, toolbarHeight: 95),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.07),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_imagePath != null || imageFile != null)
                  Icon(Icons.check_circle, color: Colors.green),
                if (_imagePath != null || imageFile != null)
                  const SizedBox(width: 8),
                Text(
                  _imagePath == null && imageFile == null
                      ? 'Upload Your Clothing Item'
                      : 'Picture Uploaded\nSuccessfully',
                  textAlign: TextAlign.center,
                  style: AppStyles.black24bold_poppins,
                  softWrap: true,
                ),
              ],
            ),
            SizedBox(height: 40),
            _imagePath == null && imageFile == null
                ? Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.08),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gray, width: 2),
                    ),
                    child: Column(
                      spacing: 20,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ImageIcon(
                          AssetImage(AppImages.uploadIcon),
                          color: AppColors.primary,
                          size: 98,
                        ),
                        Text(
                          'Upload Picture',
                          style: AppStyles.primary24bold_tiroTamil,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: size.height * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.file(
                      File(
                        imageFile == null ? _imagePath!.path : imageFile!.path,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
            SizedBox(height: 38),
            // upload from gallery
            Visibility(
              visible: _imagePath == null && imageFile == null,
              child: CustomElevatedButton(
                text: 'Upload from gallery',
                textStyle: AppStyles.white20bold_poppins,
                iconColor: AppColors.white,
                backgroundColor: AppColors.primary,
                onPressed: _pickFile,
                icon: AppImages.fileIcon,
              ),
            ),
            SizedBox(height: 16),
            // open camera to take a photo
            Visibility(
              visible: _imagePath == null && imageFile == null,
              child: CustomElevatedButton(
                text: 'Take a photo',
                textStyle: AppStyles.primary20bold_poppins,
                iconColor: AppColors.primary,
                backgroundColor: Colors.transparent,
                onPressed: openCam,
                icon: AppImages.cameraIcon,
                borderColor: AppColors.primary,
              ),
            ),
            Visibility(
              visible: _imagePath != null || imageFile != null,
              child: CustomElevatedButton(
                text: 'Submit',
                textStyle: AppStyles.white20bold_poppins,
                iconColor: AppColors.white,
                backgroundColor: AppColors.primary,
                onPressed: submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      file = result.files.first;
      imageFile = File(file!.path!);
      _imagePath = null;
      setState(() {});
    }
    print(imageFile);
  }

  Future<void> openCam() async {
    final cameras = await availableCameras();

    final XFile? img = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CameraPreviewScreen(camera: widget.camera, cameras: cameras),
      ),
    );

    if (img != null) {
      setState(() {
        _imagePath = img;
        imageFile = null;
      });
    }
  }

  Future<void> submit() async{
    // ChosenPicture.image = await convertFileToImage(imageFile: imageFile ?? File(_imagePath!.path));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Processing...',style: AppStyles.white20bold_poppins,),shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10)),backgroundColor: AppColors.primary,persist: true,)
    // );
    // await ImagePreprocessing.imagePreprocessing(imageFile: imageFile ?? File(_imagePath!.path));
    // ScaffoldMessenger.of(context).clearSnackBars();
  }


}