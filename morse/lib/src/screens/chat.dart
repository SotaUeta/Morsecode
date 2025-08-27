import 'package:flutter/material.dart';
//import 'package:torch_light/torch_light.dart';
import 'camera.dart';

class Message {
  String name = "";
  String text = "";
  DateTime time = DateTime(2025);

  Message(this.name, this.text, this.time);
}

class ChatRoom {
  String roomName;
  List<Message> messages = [];
  
  ChatRoom(this.roomName);

  void addMessage(String name, String message) {
    messages.add(Message(name, message, DateTime.now()));
  }

  void showMessage() {
    
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.room});
  final ChatRoom room;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> chatLog = [];

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
      widget.room.addMessage('aaa', result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatLog = widget.room.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.roomName),
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