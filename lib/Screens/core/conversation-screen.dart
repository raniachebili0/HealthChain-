import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health_chain/Screens/core/chat-screen.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/services.dart';
import '../../config/api_config.dart';
import '../../Widgets/notification_badge.dart';
import 'package:flutter/foundation.dart';
import 'audio_call_implementation.dart';
import '../../services/socket_service.dart';
import 'package:health_chain/models/user.dart';
import 'package:health_chain/models/conversation.dart';
import 'call_handling_service.dart';
import '../../services/socket_manager.dart';



class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> with TickerProviderStateMixin {
  final storage = FlutterSecureStorage();
  List<Conversation> _conversations = [];
  List<User> _users = [];
  bool _isLoadingConversations = true;
  bool _isLoadingUsers = true;
  bool _isCreatingConversation = false;
  String? _currentUserId;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  io.Socket? socket;
  Timer? _refreshTimer;
  Map<String, bool> _newMessageAnimations = {};
  
  @override
  void initState() {
    super.initState();
    
    // First initialize socket connections to receive real-time updates
    _connectToSocket();
    _initializeSocketService();
    
    // Then initialize app data
    _initializeApp();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    
    // Add this line to initialize call handling
    initCallHandling();
    
    // Listen for app lifecycle changes to reconnect socket when app comes back to foreground
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async {
          print("[CONVERSATION] App resumed, reconnecting socket");
          _connectToSocket();
          fetchConversations();
          return;
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    socket?.disconnect();
    _refreshTimer?.cancel();
    _periodicRefreshTimer?.cancel(); // Cancel periodic refresh timer
    
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(
      LifecycleEventHandler(resumeCallBack: () async => null),
    );
    
    super.dispose();
  }
  
  Future<void> _initializeApp() async {
    // First get the current user ID
    await _getCurrentUserId();
    
    // Only fetch data if we have a user ID
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      // Connect to socket for real-time updates
      _connectToSocket();
      
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
        Uri.parse('${ApiConfig.baseUrl}/messages/conversations?userId=$_currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Fetched ${data.length} conversations");
        
        // More detailed debug logging for the API response
        print("Full API response: ${json.encode(data)}");
        
        // Debug print all conversation unread counts
        for (var convo in data) {
          print("API Conversation: ${convo['_id']} has unreadCount: ${convo['unreadCount']}");
          print("Conversation participants: ${convo['participants']}");
          
          // Check if the current user is in the recipients list (for debugging)
          if (convo['unreadCounts'] != null) {
            print("Individual unread counts: ${convo['unreadCounts']}");
          }
        }
        
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
        Uri.parse('${ApiConfig.baseUrl}/users/all'),
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
            conversation.hasParticipant(userId) && 
            conversation.hasParticipant(_currentUserId ?? '')) {
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
        Uri.parse('${ApiConfig.baseUrl}/messages/conversations'),
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
      try {
      // For direct conversations, show the other person's name
      final otherUser = conversation.participantUsers!.firstWhere(
          (user) {
            // Make sure user is not null and has the proper type before accessing id
            if (user == null) return false;
            return user is User && user.id != _currentUserId;
          },
        orElse: () => User(id: '', name: 'Unknown', avatar: 'assets/images/avatar.png', role: 'user'),
      );
      return otherUser.name;
      } catch (e) {
        print("Error finding participant: $e");
        return 'Unknown User';
      }
    }
    
    // If we don't have participant user objects, try to find the user from our users list
    if (_users.isNotEmpty && conversation.participants.isNotEmpty) {
      for (final participant in conversation.participants) {
        // Handle case where participant could be a String or an Object
        String participantId = '';
        if (participant is String) {
          participantId = participant;
        } else if (participant is Map<String, dynamic> && participant.containsKey('_id')) {
          participantId = participant['_id'] as String;
        }
        
        if (participantId.isNotEmpty && participantId != _currentUserId) {
          final otherUser = _users.firstWhere(
            (user) => user.id == participantId,
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
      try {
      final otherUser = conversation.participantUsers!.firstWhere(
          (user) {
            // Make sure user is not null and has the proper type before accessing id
            if (user == null) return false;
            return user is User && user.id != _currentUserId;
          },
        orElse: () => User(id: '', name: 'Unknown', avatar: 'assets/images/avatar.png', role: 'user'),
      );
      return otherUser.avatar;
      } catch (e) {
        print("Error finding participant avatar: $e");
        return 'assets/images/avatar.png';
      }
    }
    
    // If we don't have participant user objects, try to find the user from our users list
    if (_users.isNotEmpty && conversation.participants.isNotEmpty) {
      for (final participant in conversation.participants) {
        // Handle case where participant could be a String or an Object
        String participantId = '';
        if (participant is String) {
          participantId = participant;
        } else if (participant is Map<String, dynamic> && participant.containsKey('_id')) {
          participantId = participant['_id'] as String;
        }
        
        if (participantId.isNotEmpty && participantId != _currentUserId) {
          final otherUser = _users.firstWhere(
            (user) => user.id == participantId,
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
    // Reset the animation for this conversation
    setState(() {
      _newMessageAnimations[conversation.id] = false;
    });
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversation.id,
          doctorName: _getConversationName(conversation),
          doctorAvatar: _getConversationAvatar(conversation),
        ),
      ),
    ).then((_) {
      // Immédiate rafraîchissement après le retour du chat
      fetchConversations();
      
      // Aussi vérifier immédiatement si des mises à jour sont disponibles via socket
      if (socket?.connected == true) {
        socket?.emit('request_conversations_update', {'userId': _currentUserId});
      }
    });
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
          // Admin option to see all messages from database
          IconButton(
            icon: Icon(Icons.storage, color: Colors.black),
            tooltip: 'View all messages from database',
            onPressed: () {
              Navigator.pushNamed(context, '/all-messages-screen');
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
                            
                            return _buildUserItem(user);
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
                          
                          // Debug print to check unread count
                          print("Conversation with ${conversationName} has unreadCount: ${conversation.unreadCount}");
                          
                          return InkWell(
                            onTap: () => _navigateToChat(conversation),
                            child: Container(
                              decoration: BoxDecoration(
                                color: (conversation.unreadCount > 0)
                                    ? Colors.green.withOpacity(0.08)
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // Avatar avec indicateur de notification
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage(_getConversationAvatar(conversation)),
                                        backgroundColor: Colors.grey[200],
                                        radius: 28,
                                      ),
                                      // Green notification badge with count
                                      if (conversation.unreadCount > 0)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${conversation.unreadCount > 99 ? "99+" : conversation.unreadCount}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(width: 16),
                                  // Infos de la conversation
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Nom et heure
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Nom avec éventuel badge de notification
                                            Row(
                                              children: [
                                                Text(
                              conversationName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Heure
                                            conversation.lastMessageAt != null
                                              ? Text(
                                                  '${conversation.lastMessageAt!.hour}:${conversation.lastMessageAt!.minute < 10 ? '0' : ''}${conversation.lastMessageAt!.minute}',
                                                  style: TextStyle(
                                                    color: Colors.grey, 
                                                    fontSize: 12,
                                                  ),
                                                )
                                              : SizedBox(),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        // Dernier message et badge de notification
                                        Row(
                                          children: [
                                            // Dernier message
                                            Expanded(
                                              child: Text(
                              conversation.lastMessage ?? 'Start a conversation',
                                                style: TextStyle(
                                                  color: conversation.unreadCount > 0 ? Colors.black : Colors.grey,
                                                  fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                                ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                                            ),
                                            
                                            // Show the green "1" notification badge only for unread messages
                                            if (conversation.unreadCount > 0)
                                              Container(
                                                width: 24,
                                                height: 24,
                                                margin: EdgeInsets.only(left: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 1.5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 2,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    conversation.unreadCount > 99 ? "99+" : "${conversation.unreadCount}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
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
      ),
    );
  }

  Widget _buildUserItem(User user) {
    // Check if this is the "roua" user to match with the image
    bool isRouaUser = user.name.toLowerCase() == 'roua';
    
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
                // Online status indicator (green dot) for 'roua' user
                if (isRouaUser)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
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
  }

  Future<void> _connectToSocket() async {
    try {
      final SocketService socketService = SocketService();
      
      // If socket is already connected, just add the event listener
      if (socketService.socket?.connected == true) {
        print("Socket already connected, setting up listeners");
        _setupSocketListeners(socketService.socket!);
        return;
      }

      // Otherwise initialize the socket with better connection handling
      await socketService.initializeSocket();
      
      if (socketService.socket != null) {
        print("Setting up socket listeners after initialization");
        _setupSocketListeners(socketService.socket!);
        
        // Emit an immediate request for conversations
        if (_currentUserId != null) {
          socketService.emit('fetch_conversations', {'userId': _currentUserId});
        }
      }
    } catch (e) {
      print("Error connecting to socket: $e");
    }
  }

  // Setup all socket event listeners in one place
  void _setupSocketListeners(io.Socket socket) {
    // Remove any existing listeners to avoid duplicates
    socket.off('new_conversation');
    socket.off('conversation_updated');
    socket.off('new_message');
    
    // Listen for new conversations
    socket.on('new_conversation', (data) {
      print("New conversation received: $data");
      if (mounted) {
        fetchConversations(); // Refresh the list
      }
    });
    
    // Listen for conversation updates
    socket.on('conversation_updated', (data) {
      print("Conversation updated: $data");
      if (mounted) {
        fetchConversations(); // Refresh the list
      }
    });
    
    // Listen for new messages to update the conversation list
    socket.on('new_message', (data) {
      print("New message received: $data");
      if (mounted) {
        // Add more detailed logging
        if (data is Map) {
          if (data.containsKey('message')) {
            final message = data['message'];
            if (message is Map) {
              final conversationId = message['conversationId'];
              final senderId = message['senderId'];
              
              print("New message in conversation: $conversationId from sender: $senderId");
              print("Current user ID: $_currentUserId");
              
              // Only increment unread count if the sender is NOT the current user
              bool shouldIncrementUnread = senderId != _currentUserId;
              print("Should increment unread count: $shouldIncrementUnread");
              
              // Update conversation in the list
              setState(() {
                for (int i = 0; i < _conversations.length; i++) {
                  if (_conversations[i].id == conversationId) {
                    print("Found conversation to update at index $i");
                    // Instead of trying to modify the existing object directly,
                    // create a new Conversation object with updated data
                    final oldConversation = _conversations[i];
                    
                    // Only increment unread count if message is from someone else
                    final newUnreadCount = shouldIncrementUnread 
                        ? oldConversation.unreadCount + 1 
                        : oldConversation.unreadCount;
                    
                    print("Updating unread count from ${oldConversation.unreadCount} to $newUnreadCount");
                    
                    // Create a copy of the old conversation with updated fields
                    final updatedConversation = Conversation.fromJson({
                      '_id': oldConversation.id,
                      'participants': oldConversation.participants,
                      'lastMessage': message['content'],
                      'lastMessageAt': message['createdAt'],
                      'isGroup': oldConversation.isGroup,
                      'groupName': oldConversation.groupName,
                      'unreadCount': newUnreadCount,
                      // Copy any other fields as needed
                    });
                    
                    // Replace the old conversation with the updated one
                    _conversations[i] = updatedConversation;
                    
                    // Start animation for new message indicator
                    _newMessageAnimations[conversationId] = true;
                    
                    // Move this conversation to the top
                    if (i > 0) {
                      final conversation = _conversations.removeAt(i);
                      _conversations.insert(0, conversation);
                    }
                    break;
                  }
                }
              });
              
              // Play a subtle vibration for new message notification
              HapticFeedback.lightImpact();
            }
          }
        }
        
        // Ensure we refresh the conversation list to get server-side unread counts
        fetchConversations();
      }
    });
    
    // Add a listener for direct conversation updates from the server
    socket.on('conversations_list', (data) {
      print("Received complete conversations list update");
      if (mounted) {
        _updateConversationsFromSocket(data);
      }
    });
  }

  // Make the socket service initialization more robust
  void _initializeSocketService() {
    try {
      final socketService = SocketService();
      
      // Track last HTTP refresh time to prevent spam
      DateTime lastHttpRefresh = DateTime.now();
      bool wasConnected = false;
      
      socketService.initializeSocket().then((_) {
        if (_currentUserId != null) {
          // Listen for connection status changes
          socketService.connectionStatus.listen((isConnected) {
            if (mounted) {
              if (isConnected) {
                print("[CONVERSATION] Socket connected, joining user room");
                // If we were previously disconnected and now connected again, refresh data
                if (!wasConnected) {
                  // We reconnected after being disconnected
                  print("[CONVERSATION] Reconnected after disconnect, refreshing data");
                  fetchConversations();
                }
                
                wasConnected = true;
                
                // Emit an event to join user's room
                socketService.emit('join_user_room', {'userId': _currentUserId});
                
                // Request initial conversations via socket
                socketService.emit('fetch_conversations', {'userId': _currentUserId});
                
                // Setup periodic refresh to ensure we always have latest data
                _setupPeriodicRefresh();
              } else {
                print("[CONVERSATION] Socket disconnected");
                wasConnected = false;
                
                // Only fetch via HTTP if enough time has passed since last fetch
                if (DateTime.now().difference(lastHttpRefresh).inSeconds >= 10) {
                  print("[CONVERSATION] Using HTTP fallback to fetch conversations");
                  lastHttpRefresh = DateTime.now();
            fetchConversations();
                }
          }
        }
      });

          // Set up listener for conversation updates
          socketService.listenForEvent('conversations_updated', (data) {
            if (mounted) {
              print("[CONVERSATION] Received conversation update via socket");
              _updateConversationsFromSocket(data);
              
              // Update the lastHttpRefresh time to prevent immediate HTTP refresh
              lastHttpRefresh = DateTime.now();
            }
          });
        }
      });
          } catch (e) {
      print("Error initializing socket service: $e");
    }
  }
  
  // Timer for periodic refresh
  Timer? _periodicRefreshTimer;
  
  // Setup periodic refresh to ensure conversations are always updated
  void _setupPeriodicRefresh() {
    // Cancel any existing timer
    _periodicRefreshTimer?.cancel();
    
    // Create a new timer that runs every 2 seconds instead of 60 seconds
    _periodicRefreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      print("[CONVERSATION] Performing periodic refresh every 2 seconds");
            fetchConversations();
      
      // Also request conversation updates via socket
      if (_currentUserId != null) {
        final socketService = SocketService();
        socketService.emit('fetch_conversations', {'userId': _currentUserId});
      }
    });
  }

  // Add this new method to handle socket updates
  void _updateConversationsFromSocket(dynamic data) {
    try {
      List<Conversation> newConversations = [];
      
      if (data is List) {
        // Handle array of conversation objects
        for (var convo in data) {
          try {
            if (convo is Map<String, dynamic>) {
              newConversations.add(Conversation.fromJson(convo));
            }
    } catch (e) {
            print("Error parsing individual conversation: $e");
          }
        }
      } else if (data is Map<String, dynamic> && data.containsKey('conversations')) {
        // Handle object with conversations array
        final List<dynamic> conversations = data['conversations'];
        for (var convo in conversations) {
          try {
            if (convo is Map<String, dynamic>) {
              newConversations.add(Conversation.fromJson(convo));
            }
    } catch (e) {
            print("Error parsing individual conversation: $e");
          }
        }
      }
      
      // Only update state if we parsed conversations successfully
      if (newConversations.isNotEmpty && mounted) {
    setState(() {
          _conversations = newConversations;
    });
      }
    } catch (e) {
      print("Error parsing conversation data from socket: $e");
    }
  }

  Widget _buildPulsingNotification() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(int count) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${count > 99 ? "99+" : count}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void initCallHandling() async {
    try {
      final callHandler = CallHandlingService();
      await callHandler.initialize();
      
      // Force reconnect if needed
      if (callHandler.getConnectionStatus() != ConnectionStatus.connected) {
        await callHandler.reconnectSocket();
      }
      
      // Add this: Listen for incoming calls
      callHandler.incomingCallStream.listen((callData) {
        if (callData != null && mounted) {
          callHandler.showIncomingCallUI(context, callData);
        }
      });
      
      debugPrint('[CALL] Call handling initialized with status: ${callHandler.getConnectionStatus()}');
    } catch (e) {
      // Handle any errors gracefully
      print("Error initializing call handling: $e");
    }
  }
}

// Add this class to handle app lifecycle events
class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await resumeCallBack();
    }
  }
} 