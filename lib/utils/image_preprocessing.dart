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
      // Execute the complete preprocessing pipeline
      await _executePreprocessingPipeline(imageFile);
      return ChosenPicture.processedTensor!;

    } catch (e) {
      print('❌ Preprocessing error: $e');
      ChosenPicture.clear();
      rethrow;
    }
  }
  /// Main pipeline function that orchestrates all steps
  static Future<void> _executePreprocessingPipeline(File imageFile) async {
    // Step 1: Load original image
    await _loadOriginalImage(imageFile);

    // Step 2: Convert to grayscale
    _convertToGrayscale();

    // Step 3: Resize to 28x28
    _resizeTo28x28();

    // Step 4: Extract pixel data
    final rawPixels = _extractPixelData();

    // Step 5: Calculate mean brightness
    final meanBrightness = _calculateMeanBrightness(rawPixels);

    // Step 6: Invert if needed (white background)
    final processedPixels = _invertIfWhiteBackground(rawPixels, meanBrightness);

    // Step 7: Normalize to 0-1
    _normalizePixels(processedPixels);

    // Step 8: Store results in ChosenPicture
    _storeFinalResults(processedPixels);
  }
  // Step 1: Load original image
  static Future<void> _loadOriginalImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    ChosenPicture.originalImage = img.decodeImage(bytes);
    if (ChosenPicture.originalImage == null) {
      throw Exception('Failed to decode image');
    }
    print('1. ✅ Loaded: ${ChosenPicture.originalImage!.width}x${ChosenPicture.originalImage!.height}');
  }
  // Step 2: Convert to grayscale
  static void _convertToGrayscale() {
    ChosenPicture.grayScaleImage = img.grayscale(img.Image.from(ChosenPicture.originalImage!));
    print('2. ✅ Grayscale: ${ChosenPicture.grayScaleImage!.numChannels} channels');
  }
  // Step 3: Resize to 28x28 (Fashion MNIST size)
  static void _resizeTo28x28() {
    ChosenPicture.resizedImage = img.copyResize(
      ChosenPicture.grayScaleImage!,
      width: 28,
      height: 28,
      interpolation: img.Interpolation.nearest,
    );
    print('3. ✅ Resized: 28x28');
  }
  // Step 4: Extract pixel data as Float32List (0-255 values)
  static Float32List _extractPixelData() {
    final pixelBytes = ChosenPicture.resizedImage!.getBytes();
    final channels = ChosenPicture.resizedImage!.numChannels;
    final rawPixels = Float32List(28 * 28);

    for (int i = 0; i < pixelBytes.length; i += channels) {
      final index = i ~/ channels;
      rawPixels[index] = pixelBytes[i].toDouble(); // 0-255
    }

    return rawPixels;
  }
  // Step 5: Calculate mean brightness of the image
  static double _calculateMeanBrightness(Float32List pixels) {
    double sum = 0;
    for (final val in pixels) {
      sum += val;
    }

    final mean = sum / pixels.length;
    return mean;
  }
  // Step 6: Invert pixels if white background (mean > 127)
  static Float32List _invertIfWhiteBackground(Float32List pixels, double mean) {
    final processedPixels = Float32List.fromList(pixels);

    if (mean > 127) {
      print('5. 🔄 Inverting (white background → black)');
      for (int i = 0; i < processedPixels.length; i++) {
        processedPixels[i] = 255 - processedPixels[i];
      }
    }

    return processedPixels;
  }
  // Step 7: Normalize pixels to 0-1 range (/ 255.0)
  static void _normalizePixels(Float32List pixels) {
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = pixels[i] / 255.0;
    }
  }
  // Step 8: Store final results in ChosenPicture
  static void _storeFinalResults(Float32List pixels) {
    ChosenPicture.processedTensor = pixels;

    // Also store as 2D array for compatibility
    ChosenPicture.finalResult = List.generate(28, (_) => List<double>.filled(28, 0.0));
    for (int i = 0; i < 28; i++) {
      for (int j = 0; j < 28; j++) {
        ChosenPicture.finalResult![i][j] = pixels[i * 28 + j];
      }
    }
  }
}