import 'package:flutter/material.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(role: 'user', content: userMessage));
      _isLoading = true;
    });

    final url = Uri.parse(
        'http://10.0.2.2:3000/openai/chatCompletion'); // change IP if needed
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "messages": _messages
          .map((msg) => {"role": msg.role, "content": msg.content})
          .toList()
    });

    try {
      final res = await http.post(url, headers: headers, body: body);
      final data = jsonDecode(res.body);
      final content = data['choices'][0]['message']['content'];

      setState(() {
        _messages.add(Message(role: 'assistant', content: content.trim()));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(role: 'assistant', content: '❌ Error: $e'));
        _isLoading = false;
      });
    }

    _controller.clear();
  }

  Widget _buildMessage(Message message) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryColor : AppColors.textInputColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isUser ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: _messages.length,
        itemBuilder: (context, index) => _buildMessage(_messages[index]),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: sendMessage,
              decoration: InputDecoration(
                hintText: "Type your message...",
                filled: true,
                fillColor: AppColors.textInputColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => sendMessage(_controller.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat AI Assistant'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMessageList(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }
}
