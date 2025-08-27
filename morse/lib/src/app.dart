import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/camera.dart';
import 'screens/chat.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BottomNavigation()
      );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  List<ChatRoom> _rooms = [ChatRoom("sample")];
  late ChatRoom _currentRoom;
  String _userName = 'モールス太郎';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentRoom = _rooms[0]; // 初期ルーム
  }
  
  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    if (_selectedIndex == 0) {
      currentScreen = HomePage(
        title: 'ホーム',
        rooms: _rooms,
        userName: _userName,
        onUserNameChanged: (newName) {
          setState(() {
            _userName = newName;
          });
        },
        onRoomSelected: (room) {
          setState(() {
            _currentRoom = room;
            _selectedIndex = 1;
          });
        },
      );
    } else if (_selectedIndex == 1) {
      currentScreen = ChatPage(room: _currentRoom, userName: _userName);
    } else {
      currentScreen = CameraPage();
    }
    //final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home), 
            label: 'ホーム'
          ),
          NavigationDestination(
            icon: Icon(Icons.chat), 
            label: 'チャット'
          ),
        ]
      )
    );
  }
}