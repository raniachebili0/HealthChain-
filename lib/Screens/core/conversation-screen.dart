import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health_chain/Screens/core/chat-screen.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final storage = FlutterSecureStorage();
  List<Conversation> _conversations = [];
  List<User> _users = [];
  bool _isLoadingConversations = true;
  bool _isLoadingUsers = true;
  bool _isCreatingConversation = false;
  String? _currentUserId;
  final String _baseUrl = 'http://192.168.0.107:3000';
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeApp() async {
    // First get the current user ID
    await _getCurrentUserId();
    
    // Only fetch data if we have a user ID
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      // Run these concurrently for better performance
      await Future.wait([
        fetchUsers(),
        fetchConversations(),
      ]);
    } else {
      // If no user ID, at least try to fetch users
      await fetchUsers();
      
      // Show a message that user needs to log in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to see your conversations'),
          duration: Duration(seconds: 3),
        )
      );
    }
  }

  Future<void> _getCurrentUserId() async {
    try {
      // First try to get user_id directly (this is how it's stored by AuthService)
      final userId = await storage.read(key: 'user_id');
      if (userId != null && userId.isNotEmpty) {
        setState(() {
          _currentUserId = userId;
        });
        print("Current user ID retrieved: $_currentUserId");
        return;
      }
      
      // As fallback, try to get from user object if it exists
      final userJson = await storage.read(key: 'user');
      if (userJson != null) {
        final userData = json.decode(userJson);
        setState(() {
          _currentUserId = userData['_id'];
        });
        print("Current user ID retrieved from user object: $_currentUserId");
        return;
      }
      
      // If we reach here, no user ID was found
      print("No user ID found in secure storage");
      
      // Debug: List all stored keys for troubleshooting
      final allKeys = await storage.readAll();
      print("All keys in secure storage: ${allKeys.keys.join(', ')}");
      print("Storage values: ${allKeys.toString()}");
    } catch (e) {
      print("Error getting current user: $e");
    }
  }

  Future<void> fetchConversations() async {
    setState(() {
      _isLoadingConversations = true;
    });
    
    try {
      if (_currentUserId == null) {
        print("No current user ID found");
        setState(() {
          _isLoadingConversations = false;
        });
        return;
      }

      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        print("No auth token found");
        setState(() {
          _isLoadingConversations = false;
        });
        return;
      }
      
      print("Fetching conversations for user: $_currentUserId");
      final response = await http.get(
        Uri.parse('$_baseUrl/messages/conversations?userId=$_currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Fetched ${data.length} conversations");
        setState(() {
          _conversations = data.map((convo) => Conversation.fromJson(convo)).toList();
          _isLoadingConversations = false;
        });
      } else {
        print("Failed to load conversations: ${response.statusCode}");
        print("Response body: ${response.body}");
        setState(() {
          _isLoadingConversations = false;
        });
      }
    } catch (e) {
      print("Error fetching conversations: $e");
      setState(() {
        _isLoadingConversations = false;
      });
    }
  }

  Future<void> fetchUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });
    
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        print("No auth token found");
        setState(() {
          _isLoadingUsers = false;
        });
        return;
      }
      
      print("Fetching all users");
      final response = await http.get(
        Uri.parse('$_baseUrl/users/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Fetched ${data.length} users");
        setState(() {
          _users = data.map((user) => User.fromJson(user)).toList();
          _isLoadingUsers = false;
        });
      } else {
        print("Failed to load users: ${response.statusCode}");
        print("Response body: ${response.body}");
        setState(() {
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Conversation? findExistingConversation(String userId) {
    try {
      if (_conversations.isEmpty || userId.isEmpty) {
        return null;
      }
      
      for (var conversation in _conversations) {
        if (!conversation.isGroup && 
            conversation.participants.contains(userId) && 
            conversation.participants.contains(_currentUserId)) {
          print("Found existing conversation with user $userId: ${conversation.id}");
          return conversation;
        }
      }
      
      print("No existing conversation found with user $userId");
      return null;
    } catch (e) {
      print("Error finding existing conversation: $e");
      return null;
    }
  }

  Future<void> createOrOpenConversation(String userId) async {
    if (_isCreatingConversation) return; // Prevent multiple taps
    
    try {
      // Check authentication
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        print("Current user ID is missing: '$_currentUserId'");
        
        // Try to get it again in case it was missed
        await _getCurrentUserId();
        
        // Check again after retry
        if (_currentUserId == null || _currentUserId!.isEmpty) {
          print("Still unable to get current user ID after retry");
          
          // Check if auth token exists
          final token = await storage.read(key: 'auth_token');
          if (token == null || token.isEmpty) {
            print("No auth token found - user is not logged in");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please log in to start a conversation'))
            );
          } else {
            print("Auth token exists but user ID is missing");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unable to get your user info. Please try logging in again.'))
            );
          }
          return;
        }
      }

      if (userId == _currentUserId) {
        print("Cannot create conversation with yourself");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot chat with yourself'))
        );
        return;
      }
      
      setState(() {
        _isCreatingConversation = true;
      });
      
      print("Starting conversation between current user ($_currentUserId) and selected user ($userId)");
      
      // Check if conversation with this user already exists
      final existingConversation = findExistingConversation(userId);
      
      if (existingConversation != null) {
        print("Opening existing conversation: ${existingConversation.id}");
        // If conversation exists, navigate to it
        setState(() {
          _isCreatingConversation = false;
        });
        _navigateToChat(existingConversation);
        return;
      }
      
      // Otherwise create new conversation
      print("Creating new conversation with user: $userId");
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        print("No auth token found");
        setState(() {
          _isCreatingConversation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authorization error. Please log in again.'))
        );
        return;
      }
      
      print("Sending request to create conversation with participants: [$_currentUserId, $userId]");
      final response = await http.post(
        Uri.parse('$_baseUrl/messages/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'participants': [_currentUserId, userId],
          'isGroup': false
        }),
      );
      
      setState(() {
        _isCreatingConversation = false;
      });
      
      if (response.statusCode == 201) {
        print("Successfully created new conversation");
        final data = json.decode(response.body);
        final conversation = Conversation.fromJson(data);
        
        setState(() {
          _conversations.add(conversation);
        });
        
        // Navigate to the chat screen with the new conversation
        _navigateToChat(conversation);
      } else {
        print("Failed to create conversation: ${response.statusCode}");
        print("Response body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create conversation. Please try again.'))
        );
      }
    } catch (e) {
      print("Error creating/opening conversation: $e");
      setState(() {
        _isCreatingConversation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.'))
      );
    }
  }

  String _getConversationName(Conversation conversation) {
    if (conversation.isGroup && conversation.groupName != null) {
      return conversation.groupName!;
    }
    
    if (conversation.participantUsers != null && conversation.participantUsers!.isNotEmpty) {
      // For direct conversations, show the other person's name
      final otherUser = conversation.participantUsers!.firstWhere(
        (user) => user.id != _currentUserId,
        orElse: () => User(id: '', name: 'Unknown', avatar: 'assets/images/avatar.png', role: 'user'),
      );
      return otherUser.name;
    }
    
    // If we don't have participant user objects, try to find the user from our users list
    if (_users.isNotEmpty) {
      for (final participant in conversation.participants) {
        if (participant != _currentUserId) {
          final otherUser = _users.firstWhere(
            (user) => user.id == participant,
            orElse: () => User(id: '', name: 'Unknown', avatar: 'assets/images/avatar.png', role: 'user'),
          );
          if (otherUser.id.isNotEmpty) {
            return otherUser.name;
          }
        }
      }
    }
    
    return 'Conversation';
  }

  String _getConversationAvatar(Conversation conversation) {
    if (conversation.isGroup) {
      return 'assets/images/group.png';
    }
    
    if (conversation.participantUsers != null && conversation.participantUsers!.isNotEmpty) {
      final otherUser = conversation.participantUsers!.firstWhere(
        (user) => user.id != _currentUserId,
        orElse: () => User(id: '', name: 'Unknown', avatar: 'assets/images/avatar.png', role: 'user'),
      );
      return otherUser.avatar;
    }
    
    // If we don't have participant user objects, try to find the user from our users list
    if (_users.isNotEmpty) {
      for (final participant in conversation.participants) {
        if (participant != _currentUserId) {
          final otherUser = _users.firstWhere(
            (user) => user.id == participant,
            orElse: () => User(id: '', name: 'Unknown', avatar: 'assets/images/avatar.png', role: 'user'),
          );
          if (otherUser.id.isNotEmpty) {
            return otherUser.avatar;
          }
        }
      }
    }
    
    return 'assets/images/avatar.png';
  }

  void _navigateToChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversation.id,
          doctorName: _getConversationName(conversation),
          doctorAvatar: _getConversationAvatar(conversation),
        ),
      ),
    ).then((_) => fetchConversations());
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users.where((user) => user.id != _currentUserId).toList();
    }
    
    return _users.where((user) => 
      user.id != _currentUserId &&
      (user.name.toLowerCase().contains(_searchQuery) || 
      (user.role == 'practitioner' && user.specialization != null && 
       user.specialization!.toLowerCase().contains(_searchQuery)))
    ).toList();
  }

  List<Conversation> get _filteredConversations {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    
    return _conversations.where((conversation) {
      String name = _getConversationName(conversation);
      return name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              autofocus: true,
            )
          : Text(
              'Chats',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
        leading: _isSearching
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            )
          : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              fetchUsers();
              fetchConversations();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchUsers();
          await fetchConversations();
        },
        child: Column(
          children: [
            // Horizontal list of user avatars (like Messenger)
            if (!_isSearching) ...[
              Container(
                height: 110,
                child: _isLoadingUsers
                  ? Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Text('No users found', 
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          scrollDirection: Axis.horizontal,
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => createOrOpenConversation(user.id),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.teal,
                                              width: 2,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage: AssetImage(user.avatar),
                                            radius: 28,
                                          ),
                                        ),
                                        if (user.role == 'practitioner')
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.medical_services,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    user.name.split(' ')[0], // Show just first name
                                    style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
              Divider(height: 1),
            ],
            
            // Loading indicator when creating conversation
            if (_isCreatingConversation)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Opening conversation...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            
            // Conversations list (like Messenger)
            Expanded(
              child: _isLoadingConversations
                ? Center(child: CircularProgressIndicator())
                : _filteredConversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                ? 'No conversations yet'
                                : 'No conversations found',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 18,
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                'Select a person to start chatting',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _filteredConversations[index];
                          final conversationName = _getConversationName(conversation);
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(_getConversationAvatar(conversation)),
                              backgroundColor: Colors.grey[200],
                              radius: 28,
                            ),
                            title: Text(
                              conversationName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              conversation.lastMessage ?? 'Start a conversation',
                              style: TextStyle(color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (conversation.lastMessageAt != null)
                                  Text(
                                    '${conversation.lastMessageAt!.hour}:${conversation.lastMessageAt!.minute < 10 ? '0' : ''}${conversation.lastMessageAt!.minute}',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                SizedBox(height: 4),
                                // You can add an unread count indicator here
                              ],
                            ),
                            onTap: () => _navigateToChat(conversation),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
} 