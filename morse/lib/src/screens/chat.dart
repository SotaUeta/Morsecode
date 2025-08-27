import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'camera.dart';
import 'package:morse_code_generator/morse_code_generator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';


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
  final ScrollController _scrollController = ScrollController();
  final RegExp japaneseRegex = RegExp(r'[ぁ-んァ-ン一-龯]');

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String result = '';

  String _morseOutput = '';

/*
  Future<void> _flashMorseSignal(String morse) async {
      try {
        await TorchLight.isTorchAvailable();
      
        for (int i = 0; i < morse.length; i++) {
          final char = morse[i];
          if (char == '.') {
            await TorchLight.enableTorch();
            await Future.delayed(Duration(milliseconds: 200));
            await TorchLight.disableTorch();
            await Future.delayed(Duration(milliseconds: 200));
          } else if (char == '-') {
            await TorchLight.enableTorch();
            await Future.delayed(Duration(milliseconds: 600));
            await TorchLight.disableTorch();
            await Future.delayed(Duration(milliseconds: 200));
          } else if (char == '/') {
            await Future.delayed(Duration(milliseconds: 400));
          }
        }
    } catch(e) {
      print('Torch error: $e');
    }
  }
*/  

  void addMessage(String result) {
    setState(() {
      chatLog.add(Message('自分', result, DateTime.now()));
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
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatLog.length,
                itemBuilder: (context, index) {
                  final message = chatLog[index];
                  final prevMessage = index > 0 ? chatLog[index - 1] : null;

                  bool showDateLabel = false;
                  if (prevMessage == null) {
                    showDateLabel = true;
                  } else {
                    if (!isSameDay(prevMessage.time, message.time)) {
                      showDateLabel = true;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDateLabel)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              DateFormat('yyyy/MM/dd').format(message.time),
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message.name),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(message.text),
                                ),
                                const SizedBox(width: 8),
                                Text(DateFormat('HH:mm').format(message.time)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(japaneseRegex),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'メッセージを入力',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        result = value;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      addMessage(result);
                      _convertTextToMorse();
                      _textController.clear();

                      await Future.delayed(Duration(milliseconds: 100));
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Text(_morseOutput),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}