import 'package:flutter/material.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vérification d'identité"),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Text(
          "Vérification d'identité en cours...",
          style: TextStyle(fontSize: 18, color: Colors.blue[700]),
        ),
      ),
    );
  }
}
