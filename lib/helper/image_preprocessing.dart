import 'dart:io';
import 'package:clothes_image_classification/model/chosen_picture.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImagePreprocessing {

  static Future<void> imagePreprocessing({required File imageFile})async {
    await convertFileToImage(imageFile: imageFile);
    imageResize(image: ChosenPicture.image!);
    grayScale(image: ChosenPicture.image!);
    invertToBlackBg(image: ChosenPicture.grayScaleImage!);
  normalizeByDividingBy255(image: ChosenPicture.invertedImage!);
  }
  // convert file to image
  static Future<void> convertFileToImage({required File imageFile}) async {
    // Read file directly as bytes
    List<int> imageBytes = await imageFile.readAsBytes();
    // Decode
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    ChosenPicture.image = image;
  }
  // image resize
  static void imageResize({required img.Image image}) {
    image = img.copyResize(image, width: 28, height: 28);
    ChosenPicture.image = image;
  }
  // grayscale due to the data requirments
  static void grayScale({required img.Image image}) {
    image = img.grayscale(image);
    ChosenPicture.grayScaleImage = image;
  }
  // Invert if white background cuz the data has white on black data in it
  static void invertToBlackBg({required img.Image image}) {
    final bytes = image.getBytes();
    if (calculateMean(image: image) > 127) {
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = 255 - bytes[i];
      }
    }
    ChosenPicture.invertedImage = bytes;
  }
// calculate mean to decide wheather to invert or not
  static double calculateMean({required img.Image image}) {
    final bytes = image.getBytes();
    double mean = 0;
    for (int i = 0; i < bytes.length; i++) {
      mean += bytes[i];
    }
    return mean / bytes.length;
  }
  //normalize image
  static void normalizeByDividingBy255({required var image}) {
    final height = image.height;
    final width = image.width;
    final bytes = image.getBytes();
    final result = List.generate(height, (_) => List<double>.filled(width, 0));
    int index = 0;
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        result[i][j] = bytes[index] / 255;
        index++;
      }
    }
    ChosenPicture.finalResult = result;
  }
}