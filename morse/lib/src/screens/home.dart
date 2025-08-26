import 'package:flutter/material.dart';
//import 'package:torch_light/torch_light.dart';
import 'camera.dart';

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
  final ScrollController _scrollController = ScrollController(); // ScrollControllerを追加

  String result = '';
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

    // スクロール処理を追加
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
                controller: _scrollController,
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
                  }
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context) => CameraPage())
                    );
                  }
                )
              ],
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}