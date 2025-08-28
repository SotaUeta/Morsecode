import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Pulse {
  final bool isOn;
  final int micros;
  Pulse(this.isOn, this.micros);
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  //カメラコントローラー
  late final CameraController? _cameraController;

  // モデル
  late final Interpreter? _interpreter;

  //初期化済みかのフラグ
  bool _isCameraInitialized = false;

  // 画像処理中かのフラグ
  bool _isProcessing = false;

  // 推論準備
  List<String> classLabels = [
    'on', 'off', 'unknown'
  ];

  List<Pulse> _pulse = [];
  bool _signalState = false;

  // 推論結果
  String? _predictionLabel;
  double? _predictionScore;
  
  //利用可能なカメラのリスト
  List<CameraDescription> _cameras = [];
  //現在選択中のカメラの向き
  CameraLensDirection _currentLensDirection = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  // モデルのロード
  Future<void> _loadModel() async {
    final options = InterpreterOptions();
    options.threads = 2;

    try {
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      debugPrint('モデルのロードが完了');
    } catch (e) {
      debugPrint('モデルのロードでエラーが発生: $e');
    }
  }

  //カメラの初期化
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras found');
      }
      await _initializeCameraController();
    } catch (e) {
      _showInitializationErrorDialog();
    }

    if (_cameraController != null) {


        final inT = _interpreter!.getInputTensor(0);
        debugPrint('input shape=${inT.shape}, type=${inT.type}'); // 例: [1,224,224,3], float32
        final outT = _interpreter!.getOutputTensor(0);
        debugPrint('output shape=${outT.shape}, type=${outT.type}');

      // リアルタイム画像を取得開始
      await _cameraController.startImageStream(_processImage);
    }

    setState(() {});
  }

  // 画像の処理
  void _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      Uint8List? bytes;

      // フォーマット判別
      if (image.format.group == ImageFormatGroup.yuv420) {
        bytes = convertYUV420ToImage(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        bytes = convertBGRA8888toImage(image);
      } else {
        debugPrint('Unsupported image format: ${image.format.group}');
        return;
      }

      if (bytes == null) return;

      await _runInference(bytes);
    } finally {
      _isProcessing = false;
    }
  }

  Uint8List convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final img.Image imgImage = img.Image(width: image.width, height: image.height);

    final Plane planeY = image.planes[0];
    final Plane planeU = image.planes[1];
    final Plane planeV = image.planes[2];

    final int strideY = planeY.bytesPerRow;
    final int strideUV = planeU.bytesPerRow;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = (y ~/ 2) * strideUV + (x ~/ 2);

        final int yIndex = y * strideY + x;

        final int Y = planeY.bytes[yIndex];
        final int U = planeU.bytes[uvIndex];
        final int V = planeV.bytes[uvIndex];

        final int r = (Y + (1.370705 * (V - 128))).clamp(0, 255).toInt();
        final int g = (Y - (0.337633 * (U - 128)) - (0.698001 * (V - 128))).clamp(0, 255).toInt();
        final int b = (Y + (1.732446 * (U - 128))).clamp(0, 255).toInt();

        imgImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(img.encodePng(imgImage));
  }


  // 取得した画像をpng形式に変換
  Uint8List convertBGRA8888toImage(CameraImage image) {
    final img.Image rgbImage = img.Image(width: image.width, height: image.height);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final index = (y * image.width + x) * 4;
        final b = image.planes[0].bytes[index];
        final g = image.planes[0].bytes[index + 1];
        final r = image.planes[0].bytes[index + 2];
        rgbImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(img.encodePng(rgbImage));
  }
  // 推論
  Future<void> _runInference(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    final resized = img.copyResize(image!, width: 224, height: 224);

    final input = List.generate(
      1,
      (_) => List.generate(224, (y) => List.generate(224, (x) {
        final pixel = resized.getPixel(x, y);
        return [
          pixel.r.toDouble() / 255.0,
          pixel.g.toDouble() / 255.0,
          pixel.b.toDouble() / 255.0
        ];
      })),
    );

    final output = List<List<double>>.generate(1, (_) => List<double>.filled(3, 0.0));

    if (_interpreter != null) {
      _interpreter.run(input, output);
    }

    final scores = output[0];

    if (classLabels.length == scores.length) {
    // 例: "on: 0.812  off: 0.143  unknown: 0.045"
    final buf = StringBuffer();
    for (int i = 0; i < scores.length; i++) {
      buf.write('${classLabels[i]}: ${scores[i].toStringAsFixed(3)}  ');
    } 
    debugPrint(buf.toString());
    } else {
      // ラベル数が合ってない場合のフォールバック
      debugPrint('scores: ${scores.map((v) => v.toStringAsFixed(3)).toList()}');
    }

    final maxScore = output[0].reduce((a, b) => a > b ? a : b);
    final maxIndex = output[0].indexOf(maxScore);

    setState(() {
      _predictionLabel = classLabels[maxIndex];
      _predictionScore = maxScore;
    });

    if (_signalState != !_signalState) {
      _signalState = !_signalState;
    } 

     debugPrint("$_predictionLabel: $_predictionScore");
  }

  Future<void> _initializeCameraController() async {
      final initialCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == _currentLensDirection,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        initialCamera,
        ResolutionPreset.low,
        enableAudio: false,
      );

      debugPrint("3");

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  //初期化失敗時のダイアログ
  void _showInitializationErrorDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: const Text('カメラの初期化に失敗しました。アプリを終了します。'),
        actions: [
          TextButton(
            onPressed: () => exit(0),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized && _cameraController != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                Text('$_predictionLabel:$_predictionScore'),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

//import 'package:morse/src/screens/home.dart';
//import 'package:morse_code_generator/morse_code_generator.dart';


/*
  final TextEditingController _morseController = TextEditingController();

  String _textOutput = '';

  void _convertMorseToText() {
    setState(() {
      String inputMorse = _morseController.text.trim();
      _textOutput = morseToText(inputMorse);
    });
  }
  */