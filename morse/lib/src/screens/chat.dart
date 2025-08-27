import 'package:flutter/material.dart';
//import 'package:torch_light/torch_light.dart';
import 'camera.dart';
import 'package:morse_code_generator/morse_code_generator.dart';

class Message {
  String name = "";
  String text = "";
  DateTime time = DateTime(2025);

  Message(this.name, this.text, this.time);
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> chatLog = [];
  final TextEditingController _textController = TextEditingController();

  String result = '';

  String _morseOutput = '';

  //bool _isTorchOn = false;
/*
  Future<void> _toggleTorch() async {
    if (_isTorchOn) {
      await TorchLight.disableTorch();
    }else {
      await TorchLight.enableTorch();
    }
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }
*/  


  void addMessage(String result) {
    setState(() {
      chatLog.add(Message('aaa', result, DateTime.now()));
    });
  }

  void _convertTextToMorse() {
    setState(() {
      String inputText = _textController.text.replaceAll('\n', ' ');
      _morseOutput = textToMorse(inputText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('モールス信号'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: 
              ListView.builder(
                itemCount: chatLog.length,
                itemBuilder: (context, index) {
                  return Column(
                      children: [Row(children: [Text(chatLog[index].name), Text((chatLog[index].time).toString())],), Text(chatLog[index].text)],
                    );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                      controller: _textController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'メッセージを入力',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String value){
                        result = value;
                      },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    setState((){addMessage(result);});
                    //_toggleTorch();
                    _convertTextToMorse();
                    _textController.clear();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context) => CameraPage())
                    );
                  }
                ),
              ],
            ),
            Text(_morseOutput),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}