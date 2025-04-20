import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Veuillez remplir tous les champs.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://localhost:3000/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String role = data["role"];

      if (role.toLowerCase() == "admin") {
        Navigator.pushNamed(context, '/home');
      } else {
        showError("Accès refusé : seul un administrateur peut se connecter.");
      }
    } else {
      showError("Échec de la connexion. Vérifiez vos informations.");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fond circulaire fixe
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade200, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Bulles flottantes animées
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 80 + _animation.value,
                    left: 30,
                    child: _buildBubble(70, Colors.blue.shade100.withOpacity(0.6)),
                  ),
                  Positioned(
                    top: 200 - _animation.value,
                    left: 100,
                    child: _buildBubble(40, Colors.blue.shade300.withOpacity(0.5)),
                  ),
                  Positioned(
                    top: 300 + _animation.value / 2,
                    right: 20,
                    child: _buildBubble(60, Colors.blue.shade200.withOpacity(0.7)),
                  ),
                  Positioned(
                    bottom: 150 - _animation.value,
                    right: 50,
                    child: _buildBubble(50, Colors.blue.shade100.withOpacity(0.6)),
                  ),
                  Positioned(
                    bottom: 80 + _animation.value,
                    left: 60,
                    child: _buildBubble(30, Colors.blue.shade400.withOpacity(0.5)),
                  ),
                  Positioned(
                    bottom: 200 + _animation.value,
                    right: 120,
                    child: _buildBubble(35, Colors.blue.shade300.withOpacity(0.4)),
                  ),
                ],
              );
            },
          ),

          // Formulaire centré
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.blue.shade700],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(Icons.local_hospital, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 500),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                    child: Text("Admin Health Chain"),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Focus(
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      onFocusChange: (hasFocus) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Focus(
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Mot de passe",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      onFocusChange: (hasFocus) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 25),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      onPressed: isLoading ? null : login,
                      child: isLoading
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Se connecter",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
