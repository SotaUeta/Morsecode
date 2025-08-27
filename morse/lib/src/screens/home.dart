import 'package:flutter/material.dart';
import 'chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.rooms, required this.title, required this.onRoomSelected, required this.userName, required this.onUserNameChanged,});

  final String title;
  final List<ChatRoom> rooms;
  final String userName;
  final void Function(ChatRoom room) onRoomSelected;
  final void Function(String newName) onUserNameChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _editName() async {
    final controller = TextEditingController(text: widget.userName);
    final newName = await showDialog<String>(
      context: context,
      builder:(context) => AlertDialog(
        title: Text('名前を編集'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "名前を入力"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context,controller.text),
            child: Text('保存'),
          )
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty){
      widget.onUserNameChanged(newName);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: Column(
        children:[
          Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text("プロフィール"),
              subtitle: GestureDetector(
                onTap: _editName,
                child: Text(widget.userName, style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.rooms.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.rooms[index].roomName),
                  onTap: () {
                    widget.onRoomSelected(widget.rooms[index]);
                  },
                );
              },
            ),
          ),
        ],
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
              widget.rooms.add(ChatRoom(newRoomName));
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}