import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = prefs.getString('chat_rooms');
    final userName = prefs.getString('user_name');
    if (roomsJson != null) {
      final List decoded = jsonDecode(roomsJson);
      _rooms = decoded.map((e) => ChatRoom.fromJson(e)).toList().cast<ChatRoom>();
      _currentRoom = _rooms.isNotEmpty ? _rooms[0] : ChatRoom("sample");
    } else {
      _currentRoom = _rooms[0];
    }
    if (userName != null) {
      _userName = userName;
    }
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = jsonEncode(_rooms.map((r) => r.toJson()).toList());
    await prefs.setString('chat_rooms', roomsJson);
    await prefs.setString('user_name', _userName);
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
            _saveData();
          });
        },
        onRoomSelected: (room) {
          setState(() {
            _currentRoom = room;
            _selectedIndex = 1;
            _saveData();
          });
        },
      );
    } else if (_selectedIndex == 1) {
      currentScreen = ChatPage(
        room: _currentRoom,
        userName: _userName,
        onMessageAdded: () {
          _saveData();
        },
      );
    } else {
      currentScreen = CameraScreen(
        room: _currentRoom,
        roomName: _currentRoom.roomName, 
        onMessageAdded: () {
          _saveData();
        },
      );
    }
    
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