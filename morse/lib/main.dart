import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class Message{
  String name;
  String text;
  //DateTime timestamp;

  Message(this.name, this.text);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ChatPage(title:'morse'),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  var chat1 = Message("","");
  String result = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('モールス信号'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              child: Text(chat1.text)
            ),
            SizedBox(
              width: 350,
              child: TextField(
                  decoration: InputDecoration(
                    hintText: 'メッセージを入力',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value){
                    result = value;
                  },
              ),
            ),
            
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  setState((){chat1.text=result;
                  });
                },
                child: const Text('メッセージを送信', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}