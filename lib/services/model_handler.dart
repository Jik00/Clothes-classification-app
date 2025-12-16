import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:clothes_image_classification/model/chosen_picture.dart';

class ModelHandler {
  late Interpreter _interpreter;
  final List<String> _labels = [
    'T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
    'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot'
  ];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/fashion_mnist.tflite',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Predict using ChosenPicture's processed tensor
  Future<List<Map<String, dynamic>>> predictFromChosenPicture() async {
    if (ChosenPicture.processedPic == null) {
      throw Exception('No processed image found.');
    }

    return await predict(ChosenPicture.processedPic!);
  }

  /// Main prediction function
  Future<List<Map<String, dynamic>>> predict(Float32List imageData) async {
    try {
      // Verify input size
      if (imageData.length != 784) {
        throw Exception('Expected 784 values, got ${imageData.length}');
      }
      // Prepare output buffer [1, 10]
      final output = List.filled(10, 0).reshape([1, 10]);
      // reshape 4D
      final reshaped = imageData.reshape([1, 28, 28, 1]);
      _interpreter.run(reshaped, output);
      // Process results
      final results = _processPredictions(output[0]);

      return results;

    } catch (e) {
      rethrow;
    }
  }  List<Map<String, dynamic>> _processPredictions(List<double> probabilities) {
    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < probabilities.length; i++) {
      results.add({
        'index': i,
        'label': _labels[i],
        'confidence': probabilities[i],
        'percentage': '${(probabilities[i] * 100).toStringAsFixed(1)}%',
      });
    }

    // Sort by confidence
    results.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    return results;
  }

  void dispose() {
    _interpreter.close();
  }
}