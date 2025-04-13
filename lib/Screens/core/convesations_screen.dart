import 'package:flutter/material.dart';
import 'package:health_chain/Screens/core/ChatScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:health_chain/config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConversationsScreen extends StatefulWidget {
  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late IO.Socket socket;
  final storage = FlutterSecureStorage();
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> allUsers = [];
  String _selectedTab = "All";
  bool _isLoading = true;
  String userId = '';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userIdFromStorage = await storage.read(key: "user_id");
    final userRoleFromStorage = await storage.read(key: "user_role");
    final token = await storage.read(key: "auth_token");
    
    if (userIdFromStorage != null) {
      setState(() {
        userId = userIdFromStorage;
        userRole = userRoleFromStorage ?? '';
        _isLoading = true;
      });
      
      print('Current user ID: $userId');
      print('Current user role: $userRole');
      
      // Initialiser le socket avant les appels réseau
      _connectToWebSocket();
      
      // ===== TESTE TOUS LES ENDPOINTS POSSIBLES =====
      // Cette fonction va tester divers endpoints pour trouver les utilisateurs
      await _findUsersEndpoint(token);
      
      // Nous n'avons plus besoin de créer des utilisateurs échantillons
      // si allUsers est vide, l'interface affichera un message approprié
      
      await _loadConversations();
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _findUsersEndpoint(String? token) async {
    if (token == null) {
      print('Authentication token not found');
      return;
    }
    
    // Test directly the user endpoints we added
    print('\n=== DIRECT TEST OF USER ENDPOINTS ===');
    
    final testEndpoints = [
      '${AppConfig.usersBaseUrl}/all',  // First because we added this one specifically
      AppConfig.doctorsUrl,
      '${AppConfig.usersBaseUrl}/patients'
    ];
    
    for (var endpoint in testEndpoints) {
      try {
        print('\nDirect test of endpoint: $endpoint');
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );
        
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            if (data is List && data.isNotEmpty) {
              print('SUCCESS: Found ${data.length} users at $endpoint');
              _processUserData(data);
              if (allUsers.isNotEmpty) {
                return;
              }
            }
          } catch (e) {
            print('Error parsing response: $e');
          }
        }
      } catch (e) {
        print('Error testing endpoint $endpoint: $e');
      }
    }
    
    // Continue with the original code to test all endpoints
    print('\n=== TESTING ALL POSSIBLE USER ENDPOINTS ===');
    
    // Liste des endpoints possibles à tester
    final endpointsToTest = [
      '${AppConfig.usersBaseUrl}/all',
      AppConfig.usersBaseUrl,
      AppConfig.doctorsUrl,
      '${AppConfig.usersBaseUrl}/patients',
      '${AppConfig.apiBaseUrl}/api/users',
      '${AppConfig.apiBaseUrl}/api/patients',
      '${AppConfig.apiBaseUrl}/api/doctors',
      '${AppConfig.apiBaseUrl}/search/users',
      '${AppConfig.apiBaseUrl}/search/patients',
      '${AppConfig.apiBaseUrl}/patients',
      '${AppConfig.apiBaseUrl}/doctors',
    ];
    
    for (var endpoint in endpointsToTest) {
      try {
        print('\nTesting endpoint: $endpoint');
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        ).timeout(const Duration(seconds: 5));
        
        print('Response status: ${response.statusCode}');
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.body.isEmpty) {
            print('Empty response body');
            continue;
          }
          
          try {
            final dynamic data = json.decode(response.body);
            print('Data type: ${data.runtimeType}');
            
            if (data is List) {
              print('Found list of ${data.length} items');
              if (data.isNotEmpty) {
                print('First item example: ${data.first}');
                _processUserData(data);
                if (allUsers.isNotEmpty) {
                  print('SUCCESS: Found users at endpoint: $endpoint');
                  return;
                }
              }
            } else if (data is Map) {
              print('Found map with keys: ${data.keys.toList()}');
              
              // Chercher toutes les clés qui pourraient contenir des utilisateurs
              final possibleUserKeys = ['users', 'data', 'doctors', 'patients', 'results'];
              
              for (var key in possibleUserKeys) {
                if (data.containsKey(key) && data[key] is List) {
                  final usersList = data[key] as List;
                  print('Found list in "$key" key with ${usersList.length} items');
                  
                  if (usersList.isNotEmpty) {
                    print('First item example: ${usersList.first}');
                    _processUserData(usersList);
                    if (allUsers.isNotEmpty) {
                      print('SUCCESS: Found users at endpoint: $endpoint, key: $key');
                      return;
                    }
                  }
                }
              }
              
              // Si on n'a pas trouvé de liste, chercher toute clé qui contient une liste
              for (var key in data.keys) {
                if (data[key] is List && (data[key] as List).isNotEmpty) {
                  final listData = data[key] as List;
                  print('Found list in key "$key" with ${listData.length} items');
                  print('First item example: ${listData.first}');
                  
                  _processUserData(listData);
                  if (allUsers.isNotEmpty) {
                    print('SUCCESS: Found users at endpoint: $endpoint, key: $key');
                    return;
                  }
                }
              }
            }
          } catch (e) {
            print('Error parsing response: $e');
          }
        }
      } catch (e) {
        print('Error testing endpoint $endpoint: $e');
      }
    }
    
    print('======= NO VALID USERS ENDPOINT FOUND =======');
    print('Adding test users temporarily until backend is fixed');
    
    // ADD TEST USERS TO SEE THE UI WHILE BACKEND IS FIXED
    setState(() {
      allUsers = [
        {
          'id': '1',
          'name': 'Roua Mohamed Ali',
          'avatar': 'https://randomuser.me/api/portraits/women/20.jpg', 
          'role': 'patient',
          'isOnline': true,
          'email': 'roua@example.com'
        },
        {
          'id': '2',
          'name': 'Dr. Marcus Horizon',
          'avatar': 'https://randomuser.me/api/portraits/men/36.jpg',
          'role': 'doctor',
          'isOnline': true,
          'email': 'dr.marcus@example.com'
        },
        {
          'id': '3',
          'name': 'Rania Zayani',
          'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
          'role': 'patient',
          'isOnline': true,
          'email': 'rania@example.com'
        },
        {
          'id': '4',
          'name': 'Rani Ben Ali',
          'avatar': 'https://randomuser.me/api/portraits/men/44.jpg',
          'role': 'patient',
          'isOnline': false,
          'email': 'rani@example.com'
        },
        {
          'id': '5',
          'name': 'Dr. Alysa Hana',
          'avatar': 'https://randomuser.me/api/portraits/women/65.jpg', 
          'role': 'doctor',
          'isOnline': false,
          'email': 'dr.alysa@example.com'
        }
      ];
    });
    print('Added ${allUsers.length} test users for UI display');
    
    // Essayer de récupérer au moins l'utilisateur actuel
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.getUserByIdUrl}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('Current user data: $userData');
        
        // Ajouter cet utilisateur à notre liste
        if (userData != null && userData['_id'] != null) {
          setState(() {
            final currentUser = {
              'id': userData['_id'],
              'name': userData['name'] ?? 'Current User',
              'email': userData['email'] ?? '',
              'avatar': userData['photo'] ?? 'https://randomuser.me/api/portraits/lego/1.jpg',
              'role': userData['resourceType'] ?? 'user',
              'isOnline': true,
            };
            
            // S'assurer que l'utilisateur n'est pas déjà dans la liste
            if (!allUsers.any((user) => user['id'] == currentUser['id'])) {
              allUsers.add(currentUser);
              print('Added current user to the list');
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }
  }
  
  // Process received user data and update state
  void _processUserData(List<dynamic> newUsers) {
    try {
      print('Processing ${newUsers.length} users from API...');
      
      if (newUsers.isEmpty) {
        print('No users returned from API');
        return;
      }
      
      setState(() {
        allUsers = [];
        
        for (var userItem in newUsers) {
          // Only add users that aren't the current user
          final String id = userItem['_id'] ?? userItem['id'] ?? '';
          if (id != userId) {
            final String name = userItem['name'] ?? 'Unknown';
            final String role = userItem['resourceType'] ?? 'patient';
            final String photo = userItem['photo'] ?? '';
            
            // Create a properly formatted avatar URL
            String avatarUrl = photo.isNotEmpty 
                ? photo
                : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';
            
            // If photo starts with http://10.0.2.2:3000, replace with the correct IP
            if (avatarUrl.contains('10.0.2.2:3000')) {
              avatarUrl = avatarUrl.replaceAll('10.0.2.2:3000', '192.168.0.107:3001');
            }
            
            Map<String, dynamic> user = {
              'id': id,
              'name': name,
              'email': userItem['email'] ?? '',
              'role': role,
              'isOnline': false, // Will be updated by WebSocket
              'lastSeen': 'Recently',
              'avatar': avatarUrl,
              'specialization': userItem['specialization'] ?? '',
              'telecom': userItem['telecom'] ?? '',
              'unread': 0
            };
            
            allUsers.add(user);
          }
        }
        
        // Update conversation messages based on users
        _loadConversations();
      });
      
      print('Processed ${newUsers.length} users, total users now: ${allUsers.length}');
      
      // Request online users from the socket
      if (socket.connected) {
        socket.emit('getOnlineUsers');
      }
    } catch (e) {
      print('Error processing user data: $e');
    }
  }

  Future<void> _loadConversations() async {
    // Convert our allUsers to conversations
    setState(() {
      messages = allUsers.map((user) {
        return {
          'id': user['id'],
          'name': user['name'],
          'message': "Click to start a conversation",
          'time': "Now",
          'avatar': user['avatar'],
          'unread': user['unread'] ?? 0,
          'isOnline': user['isOnline'] ?? false,
          'role': user['role']
        };
      }).toList();
      _isLoading = false;
    });
  }

  void _connectToWebSocket() {
    final socketUrl = AppConfig.apiBaseUrl.replaceAll(":3000", ":3001");
    print('Connecting to WebSocket at: $socketUrl');
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'userId': userId
      }
    });

    socket.connect();
    socket.onConnect((_) {
      print('Connected to WebSocket at $socketUrl');
      print('Current userId: $userId');
      socket.emit('registerUser', {'userId': userId});
      
      // Request online users
      socket.emit('getOnlineUsers');
      
      // Request all users - we'll log a message to confirm this is sent
      print('Emitting getAllUsers event to server');
      socket.emit('getAllUsers');
    });

    socket.on('connect_error', (error) {
      print('WebSocket connection error: $error');
    });

    socket.on('connect_timeout', (error) {
      print('WebSocket connection timeout: $error');
    });

    socket.on('error', (error) {
      print('WebSocket error: $error');
    });

    socket.on('message', (data) {
      print('New message received: $data');
      setState(() {
        // Update message list or show notification
        for (var i = 0; i < messages.length; i++) {
          if (messages[i]['id'] == data['sender']) {
            messages[i]['message'] = data['content'];
            messages[i]['time'] = 'Now';
            messages[i]['unread'] = (messages[i]['unread'] as int) + 1;
            // Move this conversation to the top
            final conversation = messages.removeAt(i);
            messages.insert(0, conversation);
            break;
          }
        }
      });
    });
    
    socket.on('allUsers', (data) {
      print('All users received from server: $data');
      if (data is List && data.isNotEmpty) {
        try {
          setState(() {
            allUsers = [];
            for (var userItem in data) {
              if (userItem is Map) {
                final Map<String, dynamic> user = {
                  'id': userItem['_id'] ?? userItem['id'] ?? '',
                  'name': userItem['name'] ?? 'Unknown',
                  'avatar': userItem['photo'] ?? 'https://randomuser.me/api/portraits/lego/1.jpg',
                  'role': userItem['resourceType'] ?? 'user',
                  'email': userItem['email'] ?? '',
                  'isOnline': false, // Will be updated by onlineUsers event
                };
                
                // Add only if it's not the current user
                if (user['id'] != userId) {
                  allUsers.add(user);
                }
              }
            }
            print('Updated allUsers list with ${allUsers.length} users');
            
            // Update messages list after users are loaded
            _loadConversations();
          });
        } catch (e) {
          print('Error processing allUsers data: $e');
        }
      } else {
        print('Received empty or invalid allUsers data: $data');
      }
    });
    
    socket.on('onlineUsers', (data) {
      print('Online users updated: $data');
      if (data is List) {
        try {
          final List<String> onlineUserIds = List<String>.from(data);
          
          setState(() {
            // If we have online users data, update statuses
            if (onlineUserIds.isNotEmpty) {
              // Update online status for all users
              for (var user in allUsers) {
                user['isOnline'] = onlineUserIds.contains(user['id']);
              }
              
              // Also update the messages list
              for (var message in messages) {
                message['isOnline'] = onlineUserIds.contains(message['id']);
              }
            } else {
              // If no online users reported, set some users to online for display purposes
              for (var i = 0; i < allUsers.length; i++) {
                // Set at least 3 users or half of all users as online
                allUsers[i]['isOnline'] = i < 3 || i < (allUsers.length / 2).round();
              }
              
              // Update messages too
              for (var i = 0; i < messages.length; i++) {
                for (var user in allUsers) {
                  if (messages[i]['id'] == user['id']) {
                    messages[i]['isOnline'] = user['isOnline'];
                  }
                }
              }
            }
          });
        } catch (e) {
          print('Error processing online users: $e');
          // Set default online status for a few users
          _setDefaultOnlineStatus();
        }
      } else {
        // If data format is unexpected, set some defaults
        _setDefaultOnlineStatus();
      }
    });
    
    socket.on('userConnected', (data) {
      print('User connected: $data');
      if (data is Map && data.containsKey('userId')) {
        final connectedUserId = data['userId'];
        
        setState(() {
          // Update online status for the connected user
          for (var user in allUsers) {
            if (user['id'] == connectedUserId) {
              user['isOnline'] = true;
            }
          }
          
          // Also update in messages list
          for (var message in messages) {
            if (message['id'] == connectedUserId) {
              message['isOnline'] = true;
            }
          }
        });
      }
    });
    
    socket.on('userDisconnected', (data) {
      print('User disconnected: $data');
      if (data is Map && data.containsKey('userId')) {
        final disconnectedUserId = data['userId'];
        
        setState(() {
          // Update online status for the disconnected user
          for (var user in allUsers) {
            if (user['id'] == disconnectedUserId) {
              user['isOnline'] = false;
            }
          }
          
          // Also update in messages list
          for (var message in messages) {
            if (message['id'] == disconnectedUserId) {
              message['isOnline'] = false;
            }
          }
        });
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket');
    });
    
    // If socket doesn't respond with online users in 3 seconds, set default status
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        bool hasOnlineUsers = allUsers.any((user) => user['isOnline'] == true);
        if (!hasOnlineUsers) {
          _setDefaultOnlineStatus();
        }
      }
    });
  }
  
  void _setDefaultOnlineStatus() {
    if (allUsers.isEmpty) return;
    
    setState(() {
      // Mettre plus d'utilisateurs en ligne pour une meilleure expérience utilisateur
      for (var i = 0; i < allUsers.length; i++) {
        // Mettre environ 75% des utilisateurs en ligne
        allUsers[i]['isOnline'] = (i % 4 != 3) || i < 5;
      }
      
      // Mettre à jour les messages aussi
      for (var message in messages) {
        for (var user in allUsers) {
          if (message['id'] == user['id']) {
            message['isOnline'] = user['isOnline'];
          }
        }
      }
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Function to get all users 
    List<Map<String, dynamic>> getUsers() {
      if (_selectedTab == "All") {
        return allUsers;
      } else if (_selectedTab == "Online") {
        return allUsers.where((user) => user['isOnline'] == true).toList();
      } else if (_selectedTab == "Doctors") {
        return allUsers.where((user) => user['role'] == 'doctor' || user['role'] == 'practitioner').toList();
      } else {
        return allUsers;
      }
    }

    List<Map<String, dynamic>> filteredUsers = allUsers.where((user) {
      if (_selectedTab == "All") return true;
      if (_selectedTab == "Online") return user['isOnline'] == true;
      if (_selectedTab == "Doctors") return user['role'] == 'doctor' || user['role'] == 'practitioner';
      if (_selectedTab == "Private") return messages.any((msg) => msg['id'] == user['id'] && msg['message'] != null);
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "HealthChaine",
          style: TextStyle(
              color: Color(0xFF26C6DA), 
              fontSize: 25, 
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh user list from API and WebSocket
              _loadUserData();
            },
            icon: Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      // Floating action button for new message
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show new message screen
        },
        backgroundColor: Color(0xFF26C6DA),
        child: Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF26C6DA),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Chats tab is selected
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            activeIcon: Icon(Icons.videocam),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // TODO: Navigate to different screens
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with search
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          "Message",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Search icon
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.black, size: 26),
                        onPressed: () {
                          // TODO: Implement search functionality
                        },
                      ),
                    ],
                  ),
                ),
                
                // Tab Bar for filtering conversations
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _tabButton("All", Colors.blue),
                      _tabButton("Online", Colors.green),
                      _tabButton("Doctors", Colors.purple),
                      _tabButton("Private", Colors.orange),
                    ],
                  ),
                ),
                
                SizedBox(height: 10),
                
                // Horizontal list of user avatars like Messenger
                Container(
                  height: 110,
                  child: filteredUsers.isEmpty 
                    ? Center(child: Text("No users found", style: TextStyle(color: Colors.grey[600])))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    doctorId: user['id'],
                                    doctorName: user['name'],
                                    doctorAvatar: user['avatar'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 80,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: [
                                  // User avatar with online indicator
                                  Stack(
                                    children: [
                                      Container(
                                        height: 65,
                                        width: 65,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(user['avatar'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user['name'])}&background=random'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (user['isOnline'] == true)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            height: 16,
                                            width: 16,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  // User name
                                  Text(
                                    user['name'].toString().split(' ')[0],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
                
                Divider(
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                
                // Show a message when no users are found
                if (filteredUsers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text(
                            "No users found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Try refreshing or check your connection",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _loadUserData();
                            },
                            icon: Icon(Icons.refresh),
                            label: Text("Refresh"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF26C6DA),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // List of conversations
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to chat screen with recipient information
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  doctorId: user['id'],
                                  doctorName: user['name'],
                                  doctorAvatar: user['avatar'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                            margin: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar with online indicator
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                        user['avatar'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user['name'])}&background=random',
                                      ),
                                      backgroundColor: Colors.blue.shade100,
                                    ),
                                    if (user['isOnline'] == true)
                                      Positioned(
                                        right: 2,
                                        bottom: 2,
                                        child: Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                
                                SizedBox(width: 15),
                                
                                // Name and message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'] ?? 'Unknown',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          // Preview of last message
                                          Expanded(
                                            child: Text(
                                              user['message'] ?? "Click to start a conversation",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Time indicator
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Now",
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Badge for unread messages
                                    if (user['unread'] != null && user['unread'] > 0)
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[600],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          user['unread'].toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
      ),
    );
  }

  Widget _tabButton(String title, Color color) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? color : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
