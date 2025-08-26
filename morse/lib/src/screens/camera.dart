import 'package:flutter/material.dart';
//import 'package:morse/src/screens/home.dart';

class CameraPage extends StatefulWidget{
  const CameraPage({super.key});
   @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
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