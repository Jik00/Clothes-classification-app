import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:clothes_image_classification/model/chosen_picture.dart';

class ImagePreprocessing {
  /// Complete pipeline that stores each step in ChosenPicture
  static Future<Float32List> processImageForModel(File imageFile) async {
    print('=== COMPLETE PREPROCESSING PIPELINE ===');

    try {
      // Clear previous data
      ChosenPicture.clear();

      // STEP 1: Load original image
      final bytes = await imageFile.readAsBytes();
      ChosenPicture.originalImage = img.decodeImage(bytes);
      if (ChosenPicture.originalImage == null) {
        throw Exception('Failed to decode image');
      }
      print('1. ✅ Loaded: ${ChosenPicture.originalImage!.width}x${ChosenPicture.originalImage!.height}');

      // STEP 2: Convert to grayscale
      ChosenPicture.grayScaleImage = img.grayscale(img.Image.from(ChosenPicture.originalImage!));
      print('2. ✅ Grayscale: ${ChosenPicture.grayScaleImage!.numChannels} channels');

      // STEP 3: Resize to 28x28 (Fashion MNIST size)
      ChosenPicture.resizedImage = img.copyResize(
        ChosenPicture.grayScaleImage!,
        width: 28,
        height: 28,
        interpolation: img.Interpolation.nearest,
      );
      // STEP 4: Extract pixel data
      final pixelBytes = ChosenPicture.resizedImage!.getBytes();
      final channels = ChosenPicture.resizedImage!.numChannels;

      // STEP 5: Create raw Float32List (0-255 values)
      final rawPixels = Float32List(28 * 28);
      double sum = 0;

      for (int i = 0; i < pixelBytes.length; i += channels) {
        final index = i ~/ channels;
        rawPixels[index] = pixelBytes[i].toDouble(); // 0-255
        sum += rawPixels[index];
      }

      // STEP 6: Calculate mean brightness
      final mean = sum / rawPixels.length;
      // STEP 7: INVERT if white background (Python: if mean > 127)
      final processedPixels = Float32List.fromList(rawPixels);

      if (mean > 127) {
        print('5. 🔄 Inverting (white background → black)');
        for (int i = 0; i < processedPixels.length; i++) {
          processedPixels[i] = 255 - processedPixels[i];
        }
      }

      // STEP 8: Normalize to 0-1 (Python: / 255.0)
      for (int i = 0; i < processedPixels.length; i++) {
        processedPixels[i] = processedPixels[i] / 255.0;
      }

      // STEP 9: Store in ChosenPicture
      ChosenPicture.processedTensor = processedPixels;

      // Also store as 2D array for compatibility
      ChosenPicture.finalResult = List.generate(28, (_) => List<double>.filled(28, 0.0));
      for (int i = 0; i < 28; i++) {
        for (int j = 0; j < 28; j++) {
          ChosenPicture.finalResult![i][j] = processedPixels[i * 28 + j];
        }
      }


      return processedPixels;

    } catch (e) {
      print('❌ Preprocessing error: $e');
      ChosenPicture.clear();

    }
  }

  // static void _printTensorDebug(Float32List tensor) {
  //   print('6. ✅ Final tensor (784 values):');
  //
  //   // Min, max, average
  //   double minVal = 1.0;
  //   double maxVal = 0.0;
  //   double sum = 0;
  //
  //   for (final val in tensor) {
  //     if (val < minVal) minVal = val;
  //     if (val > maxVal) maxVal = val;
  //     sum += val;
  //   }
  //
  //   print('   Range: ${minVal.toStringAsFixed(3)} - ${maxVal.toStringAsFixed(3)}');
  //   print('   Average: ${(sum / tensor.length).toStringAsFixed(3)}');
  //
  //   // First 10 values
  //   print('   First 10 values:');
  //   for (int i = 0; i < min(10, tensor.length); i++) {
  //     print('     [$i] = ${tensor[i].toStringAsFixed(4)}');
  //   }
  //
  //   // ASCII preview
  //   print('   ASCII Preview:');
  //   _printAsciiPreview(tensor);
  // }

  // static void _printAsciiPreview(Float32List pixels) {
  //   const gradient = '  .:░▒▓█';
  //   print('   ┌' + '─' * 28 + '┐');
  //
  //   for (int i = 0; i < 28; i++) {
  //     String row = '   │';
  //     for (int j = 0; j < 28; j++) {
  //       final val = pixels[i * 28 + j];
  //       final charIndex = (val * (gradient.length - 1)).round();
  //       row += gradient[charIndex];
  //     }
  //     row += '│';
  //     print(row);
  //   }
  //   print('   └' + '─' * 28 + '┘');
  // }
}