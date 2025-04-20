import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Assistant Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MedicalAssistantChatScreen(),
    );
  }
}

class MedicalAssistantChatScreen extends StatefulWidget {
  const MedicalAssistantChatScreen({super.key});

  @override
  _MedicalAssistantChatScreenState createState() =>
      _MedicalAssistantChatScreenState();
}

class _MedicalAssistantChatScreenState
    extends State<MedicalAssistantChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  // Simulate AI response (for the design part, no backend yet)
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({
          'sender': 'user',
          'message': _controller.text,
        });

        // Simulate an AI response
        messages.add({
          'sender': 'assistant',
          'message': "Here's a response to your question: ${_controller.text}",
        });

        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Assistant Chat'),
        backgroundColor: const Color.fromARGB(255,  13, 156, 188),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildChatBubble(message['sender']!, message['message']!);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: const Color.fromARGB(255, 13, 156, 188),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String sender, String message) {
    bool isUser = sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
