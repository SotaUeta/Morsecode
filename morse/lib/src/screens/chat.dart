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

  Map<String, dynamic> toJson() => {
    'name': name,
    'text': text,
    'time': time.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    json['name'] ?? "",
    json['text'] ?? "",
    DateTime.parse(json['time']),
  );
}

class ChatRoom {
  String roomName;
  List<Message> messages = [];

  ChatRoom(this.roomName);

  void addMessage(String name, String message) {
    messages.add(Message(name, message, DateTime.now()));
  }

  Map<String, dynamic> toJson() => {
    'roomName': roomName,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final room = ChatRoom(json['roomName'] ?? "");
    if (json['messages'] != null) {
      room.messages = (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList();
    }
    return room;
  }

  void showMessage() {}
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.room,
    required this.userName,
    this.onMessageAdded,
  });
  final ChatRoom room;
  final String userName;
  final VoidCallback? onMessageAdded;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollDown = false;
  bool _isFlashing = false;

  final RegExp allowedRegex = RegExp(r'[a-zA-Z0-9 ,\.?!]');

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String result = '';

  String _morseOutput = '';

  Future<void> _flashMorseSignal(String morse) async {
    try {
      await TorchLight.isTorchAvailable();

      for (int i = 0; i < morse.length; i++) {
        const unitDuration = 500;

        debugPrint(morse[i]);

        final char = morse[i];
        if (char == '.') {
          await TorchLight.enableTorch();
          await Future.delayed(Duration(milliseconds: unitDuration));
          await TorchLight.disableTorch();
          await Future.delayed(Duration(milliseconds: unitDuration));
        } else if (char == '-') {
          await TorchLight.enableTorch();
          await Future.delayed(Duration(milliseconds: unitDuration * 3));
          await TorchLight.disableTorch();
          await Future.delayed(Duration(milliseconds: unitDuration));
        } else if (char == ' ' || char == '/') {
          await Future.delayed(Duration(milliseconds: unitDuration * 3));
        }
      }
    } catch (e) {
      print(Text('Torch error: $e'));
    }
  }

  void addMessage(String result) {
    setState(() {
      widget.room.addMessage(widget.userName, result);
      widget.onMessageAdded?.call();
    });
  }

  void _convertTextToMorse() {
    setState(() {
      String inputText = _textController.text.replaceAll('\n', ' ');
      _morseOutput = textToMorse(inputText);
    });

    debugPrint(_morseOutput);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final atBottom =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 10;
    if (_showScrollDown != !atBottom) {
      setState(() {
        _showScrollDown = !atBottom;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatLog = widget.room.messages;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () async {
              final controller = TextEditingController(
                text: widget.room.roomName,
              );
              final newName = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('ルーム名を変更'),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: '新しいルーム名を入力'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: Text('保存'),
                    ),
                  ],
                ),
              );
              if (newName != null && newName.isNotEmpty) {
                setState(() {
                  widget.room.roomName = newName;
                });
              }
            },
            child: Text(widget.room.roomName),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Scrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: chatLog.length,
                        itemBuilder: (context, index) {
                          final message = chatLog[index];
                          final prevMessage = index > 0
                              ? chatLog[index - 1]
                              : null;

                          bool showDateLabel = false;
                          if (prevMessage == null) {
                            showDateLabel = true;
                          } else {
                            if (!isSameDay(prevMessage.time, message.time)) {
                              showDateLabel = true;
                            }
                          }

                          final bool isMe = message.name == widget.userName;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showDateLabel)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Center(
                                    child: Text(
                                      DateFormat(
                                        'yyyy/MM/dd',
                                      ).format(message.time),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.name,
                                      textAlign: isMe
                                          ? TextAlign.right
                                          : TextAlign.left,
                                    ),
                                    Row(
                                      mainAxisAlignment: isMe
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (!isMe) ...[
                                          Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.5,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(
                                                    0,
                                                    0,
                                                    0,
                                                    0.1,
                                                  ),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Text(message.text),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat(
                                              'HH:mm',
                                            ).format(message.time),
                                          ),
                                        ],
                                        if (isMe) ...[
                                          Text(
                                            DateFormat(
                                              'HH:mm',
                                            ).format(message.time),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.5,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(
                                                    0,
                                                    0,
                                                    0,
                                                    0.1,
                                                  ),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.deepPurpleAccent,
                                              ),
                                            ),
                                            child: Text(message.text),
                                          ),
                                        ],
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
                    if (_showScrollDown)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          tooltip: '一番下へ',
                          onPressed: () {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(allowedRegex),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'メッセージ(英数字)を入力',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          result = value;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _isFlashing || result.trim().isEmpty 
                        ? null
                        : () async {
                          if (result.trim().isEmpty) return;
                          setState(() {
                            _isFlashing = true;
                          });
                          addMessage(result);
                          _convertTextToMorse();
                          _textController.clear();
                          FocusScope.of(context).unfocus();
                          result = '';

                          await Future.delayed(Duration(milliseconds: 100));
                          await _scrollController.animateTo(
                                 _scrollController.position.maxScrollExtent,
                                 duration: Duration(milliseconds: 300),
                                 curve: Curves.easeOut,
                           );
                          await _flashMorseSignal(_morseOutput);

                          setState(() {
                            _isFlashing = false;
                          });
                          _morseOutput = '';
                        },
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraScreen(),
                          ),
                        );

                        if (result != null &&
                            result is String &&
                            result.trim().isNotEmpty) {
                          setState(() {
                            widget.room.addMessage(
                              widget.room.roomName,
                              result,
                            );
                            widget.onMessageAdded?.call();
                          });

                          await Future.delayed(Duration(milliseconds: 100));
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('エラー'),
                              content: const Text('メッセージの取得に失敗しました。'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
