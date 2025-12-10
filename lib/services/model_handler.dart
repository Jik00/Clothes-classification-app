import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelHandler {
  late Interpreter _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // Fashion MNIST constants
  static const int INPUT_SIZE = 28;
  static const int NUM_CLASSES = 10;
  static const List<int> INPUT_SHAPE = [1, 28, 28, 1];
  static const List<int> OUTPUT_SHAPE = [1, 10];

  Future<void> loadModel() async {
    if (_isLoaded) return;

    try {
      print('🔄 Loading TFLite model...');

      // Load interpreter
      _interpreter = await Interpreter.fromAsset(
        'assets/models/fashion_mnist.tflite',
        options: InterpreterOptions()..threads = 4,
      );

      // Verify model signature
      final inputTensor = _interpreter.getInputTensor(0);
      final outputTensor = _interpreter.getOutputTensor(0);

      print('✅ Model loaded!');
      print('   Input: ${inputTensor.shape} (${inputTensor.type})');
      print('   Output: ${outputTensor.shape} (${outputTensor.type})');

      // Load labels
      await _loadLabels();
      _isLoaded = true;

    } catch (e) {
      print('❌ Model loading failed: $e');
      _isLoaded = false;
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();
      print('📝 Loaded ${_labels.length} labels');
    } catch (e) {
      print('⚠️ Could not load labels, using defaults: $e');
      _labels = [
        'T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
        'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot'
      ];
    }
  }

  // Main prediction function for your processed image
  Future<List<Map<String, dynamic>>> predictFromProcessedImage(List<List<double>> imageData) async {
    if (!_isLoaded) {
      await loadModel();
    }

    try {
      // Convert 2D array to proper tensor format
      final inputTensor = _prepareInputTensor(imageData);

      // Run inference
      final outputTensor = await _runInference(inputTensor);

      // Process results
      return _processPredictions(outputTensor);

    } catch (e) {
      print('❌ Prediction error: $e');
      rethrow;
    }
  }

  // Prepare input tensor from 2D normalized array [0.0-1.0]
  List<List<List<List<double>>>> _prepareInputTensor(List<List<double>> imageData) {
    // Create 4D tensor: [1, 28, 28, 1]
    final tensor = List.generate(
      1,
          (_) => List.generate(
        INPUT_SIZE,
            (i) => List.generate(
          INPUT_SIZE,
              (j) => List.generate(1, (_) => imageData[i][j]),
        ),
      ),
    );

    return tensor;
  }

  // Alternative: Faster tensor preparation
  Float32List _prepareInputTensorFast(List<List<double>> imageData) {
    // Flatten to 1D array: 28 * 28 * 1 = 784 elements
    final flatList = Float32List(INPUT_SIZE * INPUT_SIZE);

    for (int i = 0; i < INPUT_SIZE; i++) {
      for (int j = 0; j < INPUT_SIZE; j++) {
        flatList[i * INPUT_SIZE + j] = imageData[i][j].toDouble();
      }
    }

    return flatList;
  }

  Future<List<List<double>>> _runInference(dynamic input) async {
    // Prepare output buffer
    final List<List<double>> output = [
      List<double>.filled(NUM_CLASSES, 0.0)
    ];

    // Time the inference
    final stopwatch = Stopwatch()..start();

    if (input is Float32List) {
      // For Float32List input
      _interpreter.run(input, output);
    } else {
      // For 4D tensor input
      _interpreter.run(input, output);
    }

    stopwatch.stop();
    print('⏱️ Inference time: ${stopwatch.elapsedMilliseconds}ms');

    return output;
  }

  List<Map<String, dynamic>> _processPredictions(List<List<double>> output) {
    final results = <Map<String, dynamic>>[];
    final probabilities = output[0]; // Get first batch

    // Apply softmax if needed (convert logits to probabilities)
    final processedProbs = _softmax(probabilities);

    for (int i = 0; i < processedProbs.length; i++) {
      final confidence = processedProbs[i];

      results.add({
        'index': i,
        'label': i < _labels.length ? _labels[i] : 'Class $i',
        'confidence': confidence,
        'percentage': '${(confidence * 100).toStringAsFixed(1)}%',
      });
    }

    // Sort by confidence (highest first)
    results.sort((a, b) => b['confidence'].compareTo(a['confidence']));

    // Print top 3 predictions
    if (results.isNotEmpty) {
      print('🎯 Top 3 predictions:');
      for (int i = 0; i < min(3, results.length); i++) {
        print('   ${i + 1}. ${results[i]['label']}: ${results[i]['percentage']}');
      }
    }

    return results;
  }

  // Softmax function to convert logits to probabilities
  List<double> _softmax(List<double> logits) {
    // Find max for numerical stability
    final maxLogit = logits.reduce(max);

    // Compute exponentials
    final exps = logits.map((x) => exp(x - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);

    // Normalize to probabilities
    return exps.map((x) => x / sumExps).toList();
  }

  // Utility: Test with random data
  Future<void> testModel() async {
    try {
      await loadModel();

      // Create dummy image (all zeros or random)
      final dummyImage = List.generate(
        INPUT_SIZE,
            (_) => List.filled(INPUT_SIZE, 0.0),
      );

      final predictions = await predictFromProcessedImage(dummyImage);
      print('🧪 Model test successful!');
      print('   First prediction: ${predictions.first}');

    } catch (e) {
      print('❌ Model test failed: $e');
    }
  }

  void dispose() {
    if (_isLoaded) {
      _interpreter.close();
      _isLoaded = false;
      print('🗑️ Model interpreter closed');
    }
  }

}