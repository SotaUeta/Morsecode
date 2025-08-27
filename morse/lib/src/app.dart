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
  ChatRoom _currentRoom = ChatRoom("sample");

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final _screens = [
      HomePage(
        title: 'ホーム',
        onRoomSelected: (room) {
          setState(() {
            _currentRoom = room; //選んだルームを保存
            _selectedIndex = 1; //チャットタブに切り替え
          });
        },
      ),
      ChatPage(room: _currentRoom), //現在のルームを参照
      CameraPage(),
    ]; 
    //final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: _screens[_selectedIndex],
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