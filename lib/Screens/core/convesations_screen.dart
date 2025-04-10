import 'package:flutter/material.dart';
import 'package:health_chain/Screens/core/ChatScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [
    {
      'name': 'Dr. Marcus Horizon',
      'message': "I don’t have any fever, but headache...",
      'time': "10:24",
      'avatar': 'https://via.placeholder.com/150',
      'unread': 1
    },
    {
      'name': 'Dr. Alysa Hana',
      'message': "Hello, How can I help you?",
      'time': "09:04",
      'avatar': 'https://via.placeholder.com/150',
      'unread': 0
    },
    {
      'name': 'Dr. Maria Elena',
      'message': "Do you have fever?",
      'time': "08:57",
      'avatar': 'https://via.placeholder.com/150',
      'unread': 0
    },
  ];

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
  }

  void connectToWebSocket() {
    socket = IO.io('http://192.168.1.18:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      print('Connected to WebSocket');
    });

    socket.on('onMessage', (data) {
      print('New message received: $data');
      setState(() {
        messages.insert(0, {
          'name': 'New Message',
          'message': data['content'],
          'time': "Now",
          'avatar': 'https://via.placeholder.com/150',
          'unread': 1
        });
      });
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket');
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Message",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton("All", true),
                _buildTabButton("Group", false),
                _buildTabButton("Private", false),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(message['avatar']),
                  ),
                  title: Text(
                    message['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(message['message']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(message['time']),
                      if (message['unread'] > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            message['unread'].toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                doctorName: "New Chat",
                doctorAvatar: "https://via.placeholder.com/150",
              ),
            ),
          );
        },
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
