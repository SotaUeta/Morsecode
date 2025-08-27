import 'package:flutter/material.dart';
import 'package:morse/src/screens/home.dart';
import 'package:morse_code_generator/morse_code_generator.dart';

class CameraPage extends StatefulWidget{
  const CameraPage({super.key});
   @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カメラ'),
      ),
      body: Center(
        child: Text('カメラ画面'),
      ),
    );
  }
}