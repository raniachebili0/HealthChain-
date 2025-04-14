import 'package:flutter/material.dart';
import 'package:health_chain/Screens/core/chat-screen.dart';

class ConvesationsScreen extends StatefulWidget {
  const ConvesationsScreen({super.key});

  @override
  State<ConvesationsScreen> createState() => _ConvesationsScreenState();
}

class _ConvesationsScreenState extends State<ConvesationsScreen> {
  @override
  Widget build(BuildContext context) {
    // Wrap the ChatScreen in a try-catch block to prevent crashes
    try {
      return ChatScreen();
    } catch (e) {
      // If there's an error, show a simple error screen
      print("Error loading ChatScreen: $e");
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                "Something went wrong",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "We're working on fixing the issue",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {});  // Refresh the screen
                },
                child: Text("Try Again"),
              )
            ],
          ),
        ),
      );
    }
  }
}
