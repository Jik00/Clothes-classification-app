import 'dart:typed_data';
import 'dart:math';
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
      print('🔄 Loading TFLite model...');

      _interpreter = await Interpreter.fromAsset(
        'assets/models/fashion_mnist.tflite',
        options: InterpreterOptions()..threads = 4,
      );

      // Verify model
      final inputTensor = _interpreter.getInputTensor(0);
      final outputTensor = _interpreter.getOutputTensor(0);

    } catch (e) {
      print('❌ Model loading failed: $e');
      rethrow;
    }
  }

  /// Predict using ChosenPicture's processed tensor
  Future<List<Map<String, dynamic>>> predictFromChosenPicture() async {
    if (ChosenPicture.processedTensor == null) {
      throw Exception('No processed image found. Call ImagePreprocessing first.');
    }

    return await predict(ChosenPicture.processedTensor!);
  }

  /// Main prediction function
// In ModelHandler class
  Future<List<Map<String, dynamic>>> predict(Float32List imageData) async {
    try {
      // Verify input size
      if (imageData.length != 784) {
        throw Exception('Expected 784 values, got ${imageData.length}');
      }
      // Prepare output buffer [1, 10]
      final output = List.filled(1 * 10, 0.0).reshape([1, 10]);

      // Run inference - SIMPLE FIX
      final stopwatch = Stopwatch()..start();

      // Method 1: Try direct run (most common)
      try {
        _interpreter.run(imageData, output);
      } catch (e) {
        print('⚠️ interpreter.run() failed: $e');

        // Method 2: Try with reshape to 4D
        final reshaped = imageData.reshape([1, 28, 28, 1]);
        _interpreter.run(reshaped, output);
        print('✅ Used interpreter.run() with reshape');
      }

      stopwatch.stop();
      print('⏱️ Inference time: ${stopwatch.elapsedMilliseconds}ms');

      // Process results
      final results = _processPredictions(output[0]);

      return results;

    } catch (e, stack) {
      print('❌ Prediction error: $e');
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

    // Print top 3
    print('📊 Top 3 predictions:');
    for (int i = 0; i < min(3, results.length); i++) {
      final result = results[i];
      print('   ${i + 1}. ${result['label']}: ${result['percentage']}');
    }

    return results;
  }

  void dispose() {
    _interpreter.close();
  }
}