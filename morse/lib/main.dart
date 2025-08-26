import 'package:flutter/material.dart';

class Message{
  String name = "";
  String message = "";
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
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  final String _message = "";
  
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
              child: TextField(
                  decoration: InputDecoration(
                    hintText: 'メッセージを入力',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value){
                    // _message = value;
                  },
              ),
            ),
            
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('メッセージを送信', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}