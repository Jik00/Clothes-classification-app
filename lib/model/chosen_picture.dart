// lib/model/chosen_picture.dart
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ChosenPicture {
  static img.Image? originalImage;
  static img.Image? grayScaleImage;
  static img.Image? resizedImage;
  static Float32List? processedPic;
  static List<List<double>>? finalResult;
  static void clear() {
    originalImage = null;
    grayScaleImage = null;
    resizedImage = null;
    processedPic = null;
    finalResult = null;
  }
}