import 'package:flutter/material.dart';
import 'chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title, required this.onRoomSelected});

  final String title;
  final void Function(ChatRoom room) onRoomSelected;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatRoom> rooms = [
    ChatRoom("Sample"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(rooms[index].roomName),
            onTap: () {
              widget.onRoomSelected(rooms[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newRoomName = await showDialog<String>(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: Text('新しいチャットルーム'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'ルーム名を入力'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("キャンセル"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: Text("追加"),
                  ),
                ],
              );
            },
          );
          if (newRoomName != null && newRoomName.isNotEmpty) {
            setState((){
              rooms.add(ChatRoom(newRoomName));
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}