import 'package:flutter/material.dart';

class AssignRolePage extends StatelessWidget {
  const AssignRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Affecter un rôle"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Sélectionnez un rôle à attribuer :", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildRoleTile(context, "Administrateur"),
                  _buildRoleTile(context, "Médecin"),
                  _buildRoleTile(context, "Patient"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTile(BuildContext context, String role) {
    return Card(
      elevation: 3,
      child: ListTile(
        title: Text(role),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Affecter"),
        ),
      ),
    );
  }
}
