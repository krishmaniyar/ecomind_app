import 'package:flutter/material.dart';
import 'gemini_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatBotPage extends StatefulWidget {
  final String? initialQuery;
  ChatBotPage({this.initialQuery});
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _controller.text =
      "${widget.initialQuery!} \nGive me tips on how to efficiently manage this kind of waste.";
    }
  }

  void sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({"user": _controller.text.trim()});
      isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    String reply = await GeminiService.sendMessage(messages.last["user"]!);

    setState(() {
      messages.add({"bot": reply});
      isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("EcoMind Chatbot", style: TextStyle(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(15),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SpinKitThreeBounce(
                        color: Colors.green.shade700,
                        size: 20.0,
                      ),
                    ),
                  );
                }

                var entry = messages[index];
                bool isUser = entry.keys.first == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUser
                            ? [Colors.blue.shade400, Colors.blue.shade700]
                            : [Colors.green.shade400, Colors.green.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                        bottomLeft: isUser ? Radius.circular(14) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : Radius.circular(14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      entry.values.first!,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[300],
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.green.shade700,
                    radius: 26,
                    child: Icon(Icons.send, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
