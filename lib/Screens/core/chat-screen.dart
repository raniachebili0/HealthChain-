import 'package:flutter/material.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

class User {
  final String id;
  final String name;
  final String avatar;
  final String role;
  final String? specialization;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
    this.specialization,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'] ?? 'assets/images/doctor.png',
      role: json['role'] ?? 'user',
      specialization: json['specialization'],
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool read;
  final DateTime? readAt;
  final User? sender;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.read = false,
    this.readAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Handle case where sender might be null or missing _id
    String senderId = '';
    User? senderUser;
    
    if (json['sender'] != null) {
      // Handle case where sender might be a string ID instead of an object
      if (json['sender'] is String) {
        senderId = json['sender'];
      } else if (json['sender'] is Map) {
        senderId = json['sender']['_id'] ?? '';
        senderUser = User.fromJson(json['sender']);
      }
    }
    
    // Handle case where _id might be in different formats
    String messageId = '';
    if (json['_id'] != null) {
      messageId = json['_id'] is String ? json['_id'] : json['_id'].toString();
    }
    
    return Message(
      id: messageId,
      senderId: senderId,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      read: json['read'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sender: senderUser,
    );
  }

  String get timeString {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

class Conversation {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isGroup;
  final String? groupName;
  final List<User>? participantUsers;

  Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.isGroup = false,
    this.groupName,
    this.participantUsers,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<String> participantsList = [];
    if (json['participants'] != null) {
      participantsList = List<String>.from(
        json['participants'].map((participant) {
          if (participant is Map) {
            return participant['_id'] ?? '';
          } else {
            return participant ?? '';
          }
        })
      );
    }

    List<User>? participantUsersList;
    if (json['participants'] != null && json['participants'] is List) {
      participantUsersList = (json['participants'] as List)
          .where((participant) => participant is Map)
          .map<User>((participant) => User.fromJson(participant))
          .toList();
    }

    return Conversation(
      id: json['_id'] ?? '',
      participants: participantsList,
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      isGroup: json['isGroup'] ?? false,
      groupName: json['groupName'],
      participantUsers: participantUsersList,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  final String doctorName;
  final String doctorAvatar;
  
  const ChatScreen({
    super.key, 
    this.conversationId,
    this.doctorName = "Dr. Marcus Horizon", 
    this.doctorAvatar = "assets/images/doctor.png"
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final storage = FlutterSecureStorage();
  List<User> _users = [];
  Conversation? _conversation;
  List<Message> _messages = [];
  bool _isLoadingUsers = false;
  bool _isLoadingChat = true;
  String? _currentUserId;
  io.Socket? socket;
  Map<String, bool> _typingUsers = {};
  
  // Base URL for API calls
  final String _baseUrl = 'http://192.168.0.107:3000';
  
  Timer? _refreshTimer;
  Set<String> _messageIds = {};

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    socket?.disconnect();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // First, make sure we have the current user ID
    await _getCurrentUserId();
    
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      print("Failed to get current user ID during initialization");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to use the chat feature'))
      );
      return;
    }
    
    print("Initializing chat with user ID: $_currentUserId");
    
    // Connect to socket for real-time updates
    _connectToSocket();
    
    // If conversation ID is provided, load the conversation and messages
    if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
      await _loadConversation(widget.conversationId!);
    } else {
      setState(() {
        _isLoadingChat = false;
      });
      print("No conversation ID provided");
    }
    
    // Set up a timer to refresh messages periodically
    _startMessageRefreshTimer();
  }

  Future<void> _getCurrentUserId() async {
    try {
      // Try to get user_id directly (from user_id storage key)
      final userId = await storage.read(key: 'user_id');
      if (userId != null && userId.isNotEmpty) {
        setState(() {
          _currentUserId = userId;
        });
        print("Current user ID retrieved from user_id: $_currentUserId");
        return;
      }
      
      // As fallback, try to get from user object if it exists
      final userJson = await storage.read(key: 'user');
      if (userJson != null) {
        final userData = json.decode(userJson);
        if (userData['_id'] != null && userData['_id'].toString().isNotEmpty) {
          setState(() {
            _currentUserId = userData['_id'];
          });
          print("Current user ID retrieved from user object: $_currentUserId");
          
          // Save it to user_id for future reference
          await storage.write(key: 'user_id', value: _currentUserId);
          return;
        }
      }
      
      print("No user ID found in secure storage, trying to get it from token");
      
      // Last resort: try to get from token
      final token = await storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        try {
          // Call the backend to get user information
          final response = await http.get(
            Uri.parse('$_baseUrl/users/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (response.statusCode == 200) {
            final userData = json.decode(response.body);
            if (userData['_id'] != null) {
              setState(() {
                _currentUserId = userData['_id'];
              });
              // Save it for future reference
              await storage.write(key: 'user_id', value: _currentUserId);
              print("Current user ID retrieved from API: $_currentUserId");
              return;
            }
          } else {
            print("Failed to get user information from API: ${response.statusCode}");
          }
        } catch (e) {
          print("Error fetching user information from API: $e");
        }
      }
      
      print("All methods to get user ID failed");
    } catch (e) {
      print("Error getting current user: $e");
    }
  }

  void _connectToSocket() async {
    try {
      // Make sure we have a current user ID first
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        print("No current user ID found when connecting to socket, trying to retrieve it");
        await _getCurrentUserId();
      }
      
      final token = await storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        print("No auth token found for socket connection");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to connect to chat: Not authenticated'))
        );
        return;
      }

      print("Connecting to socket with token");
      socket = io.io('$_baseUrl/chat', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
        'extraHeaders': {'Authorization': 'Bearer $token'}
      });

      socket?.onConnect((_) {
        print('Socket connected successfully');
        
        // Join conversation room if we have a conversation ID
        if (_conversation != null) {
          print('Joining conversation room: ${_conversation!.id}');
          socket?.emit('join_conversation', {
            'conversationId': _conversation!.id,
            'userId': _currentUserId
          });
        } else {
          print('No conversation to join');
        }
      });

      socket?.onDisconnect((_) {
        print('Socket disconnected');
      });

      socket?.on('error', (data) {
        print('Socket error: $data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: ${data.toString().substring(0, 50)}'))
        );
      });

      socket?.on('new_message', (data) {
        print('Received new message event from socket');
        if (data != null && data['message'] != null) {
          print('Message data: ${data['message']}');
          try {
            final message = Message.fromJson(data['message']);
            
            // Check if this message already exists in our list
            if (message.id.isEmpty) {
              print('Ignored message with empty ID');
              return;
            }
            
            // Skip temporary messages from the socket response
            if (message.id.contains('_temp')) {
              print('Ignored temporary message from socket');
              return;
            }
            
            // Check if this is our own message that we already displayed
            bool isOwnRecentMessage = false;
            if (message.senderId == _currentUserId) {
              // This is our own message - check if we already have a temp version of it
              isOwnRecentMessage = _messages.any((msg) => 
                msg.id.contains('_temp') && 
                msg.content == message.content &&
                msg.senderId == _currentUserId &&
                DateTime.now().difference(msg.createdAt).inMinutes < 1
              );
              
              if (isOwnRecentMessage) {
                print('Received confirmation of our own recent message: ${message.content}');
                
                // If we have a temporary version, update it instead of adding a duplicate
                setState(() {
                  // Find our temporary message
                  final tempIndex = _messages.indexWhere((msg) => 
                    msg.id.contains('_temp') && 
                    msg.content == message.content &&
                    msg.senderId == _currentUserId
                  );
                  
                  if (tempIndex >= 0) {
                    // Found the temp message, replace it with the real one
                    print('Replacing temporary message with confirmed message');
                    _messageIds.remove(_messages[tempIndex].id);
                    _messages[tempIndex] = message;
                    _messageIds.add(message.id);
                    return; // Skip adding a new message
                  }
                });
              }
            }
            
            // Use our tracked message IDs for normal deduplication
            final isDuplicate = _messageIds.contains(message.id);
            if (!isDuplicate && !isOwnRecentMessage) {
              setState(() {
                _messages.add(message);
                // Add to our tracking set
                _messageIds.add(message.id);
                // Re-sort messages
                _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              });
              print('Added new message from ${message.sender?.name ?? "Unknown"}: ${message.content}');
            } else {
              print('Ignored duplicate message with ID: ${message.id}');
            }
          } catch (e) {
            print('Error parsing message data: $e');
          }
        } else {
          print('Invalid message data received');
        }
      });

      socket?.on('user_typing', (data) {
        if (data != null && data['userId'] != null) {
          setState(() {
            _typingUsers[data['userId']] = data['isTyping'];
          });
        }
      });

      print("Attempting to connect to socket");
      socket?.connect();
    } catch (e) {
      print("Error connecting to socket: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to chat server'))
      );
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    setState(() {
      _isLoadingChat = true;
    });
    
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        print("No auth token found");
        setState(() {
          _isLoadingChat = false;
        });
        return;
      }
      
      // Get conversation details
      final conversationResponse = await http.get(
        Uri.parse('$_baseUrl/messages/conversations/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (conversationResponse.statusCode == 200) {
        final conversationData = json.decode(conversationResponse.body);
        setState(() {
          _conversation = Conversation.fromJson(conversationData);
        });
        
        // Now fetch messages for this conversation
        await fetchMessages(conversationId);
      } else {
        print("Failed to load conversation: ${conversationResponse.statusCode}");
        setState(() {
          _isLoadingChat = false;
        });
      }
    } catch (e) {
      print("Error loading conversation: $e");
      setState(() {
        _isLoadingChat = false;
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
      
      final response = await http.get(
        Uri.parse('$_baseUrl/users/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _users = data.map((user) => User.fromJson(user)).toList();
          _isLoadingUsers = false;
        });
      } else {
        print("Failed to load users: ${response.statusCode}");
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

  Future<void> fetchMessages(String conversationId) async {
    setState(() {
      _isLoadingChat = true;
    });
    
    try {
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        print("No current user ID found when fetching messages, trying to retrieve it");
        await _getCurrentUserId();
        
        if (_currentUserId == null || _currentUserId!.isEmpty) {
          print("Still unable to get current user ID");
          setState(() {
            _isLoadingChat = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to load messages: User ID not found'))
          );
          return;
        }
      }

      final token = await storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        print("No auth token found when fetching messages");
        setState(() {
          _isLoadingChat = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load messages: Not authenticated'))
        );
        return;
      }
      
      print("Fetching messages for conversation: $conversationId with user: $_currentUserId");
      
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/messages/conversations/$conversationId/messages?userId=$_currentUserId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          print("Successfully fetched ${data.length} messages");
          
          // Create a proper List<Message> by carefully handling each message
          final List<Message> messages = [];
          for (var msgData in data) {
            try {
              final msg = Message.fromJson(msgData);
              // Only add valid messages
              if (msg.id.isNotEmpty && msg.content.isNotEmpty) {
                messages.add(msg);
              }
            } catch (parseError) {
              print("Error parsing message: $parseError");
              print("Problematic message data: $msgData");
            }
          }
          
          // Sort messages by creation time (most recent last)
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          // Store existing message IDs to check for duplicates when receiving socket messages
          _messageIds = messages.map((msg) => msg.id).toSet();
          
          setState(() {
            _messages = messages;
            _isLoadingChat = false;
          });
        } else {
          print("Failed to load messages: ${response.statusCode}");
          print("Response body: ${response.body}");
          setState(() {
            _isLoadingChat = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load messages: Server error'))
          );
        }
      } catch (e) {
        print("Error fetching messages: $e");
        setState(() {
          _isLoadingChat = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: ${e.toString().substring(0, math.min(e.toString().length, 50))}...'))
        );
      }
    } catch (e) {
      print("Error fetching messages: $e");
      setState(() {
        _isLoadingChat = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: ${e.toString().substring(0, math.min(e.toString().length, 50))}...'))
      );
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _conversation == null) return;

    _controller.clear();
    
    // Clear typing status
    _setTyping(false);

    try {
      // Check if we have current user ID, if not try to get it
      if (_currentUserId == null || _currentUserId!.isEmpty) {
        print("No current user ID found when sending message, trying to retrieve it");
        await _getCurrentUserId();
        
        if (_currentUserId == null || _currentUserId!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to send message: User ID not found'))
          );
          return;
        }
      }

      // Get auth token
      final token = await storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        print("No auth token found when sending message");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to send message: Not authenticated'))
        );
        return;
      }
      
      // Get proper user name (if available)
      String userName = "You";
      String userAvatar = 'assets/images/avatar.png';
      
      final userJson = await storage.read(key: 'user');
      if (userJson != null) {
        try {
          final userData = json.decode(userJson);
          if (userData['name'] != null) {
            userName = userData['name'];
          }
          if (userData['avatar'] != null) {
            userAvatar = userData['avatar'];
          }
        } catch (e) {
          print("Error parsing user data: $e");
        }
      }

      // Generate a temporary ID for optimistic UI update
      final tempId = "${DateTime.now().millisecondsSinceEpoch}_temp";
      
      // Optimistically add message to UI
      final tempMessage = Message(
        id: tempId,
        senderId: _currentUserId!,
        content: content,
        createdAt: DateTime.now(),
        sender: User(
          id: _currentUserId!, 
          name: userName, 
          avatar: userAvatar, 
          role: 'user'
        ),
      );
      
      // Add message to UI
      setState(() {
        _messages.add(tempMessage);
        // Add to tracking set to prevent duplicates
        _messageIds.add(tempId);
        // Re-sort messages (not really needed for newly added message, but for consistency)
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });

      // Create a flag to track if message is confirmed
      bool messageConfirmed = false;

      // Also send via HTTP to ensure it's stored
      try {
        print("Sending message via HTTP first to store it");
        final response = await http.post(
          Uri.parse('$_baseUrl/messages?userId=$_currentUserId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'content': content,
            'conversationId': _conversation!.id,
          }),
        );
        
        if (response.statusCode == 201) {
          print("Message successfully sent and stored via HTTP");
          messageConfirmed = true;
          
          // Message successfully stored - update the temporary message with real data
          final messageData = json.decode(response.body);
          
          try {
            final realMessage = Message.fromJson(messageData);
            
            // Find and update the temporary message with the real one from the server
            setState(() {
              // Remove temp ID from tracking
              _messageIds.remove(tempId);
              
              // Find the temp message
              final index = _messages.indexWhere((msg) => msg.id == tempId);
              if (index >= 0) {
                // Replace with real message
                _messages[index] = realMessage;
                
                // Add real ID to tracking
                if (realMessage.id.isNotEmpty) {
                  _messageIds.add(realMessage.id);
                }
              }
            });
          } catch (parseError) {
            print("Error parsing real message data: $parseError");
          }
        } else {
          print("Failed to store message via HTTP: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      } catch (e) {
        print("Error sending message via HTTP: $e");
      }
      
      // If we already got confirmation, don't use socket
      if (!messageConfirmed) {
        print("Using socket as backup to send message");
        // Send message via socket for real-time updates
        socket?.emit('send_message', {
          'message': {
            'content': content,
            'conversationId': _conversation!.id,
            'sender': _currentUserId,
          }
        });
      }
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString().substring(0, math.min(e.toString().length, 50))}...'))
      );
    }
  }

  void _setTyping(bool isTyping) {
    if (_currentUserId != null && _conversation != null) {
      socket?.emit('typing', {
        'conversationId': _conversation!.id,
        'isTyping': isTyping,
        'userId': _currentUserId
      });
    }
  }

  String _getParticipantName() {
    if (_conversation == null) return widget.doctorName;
    
    if (_conversation!.isGroup && _conversation!.groupName != null) {
      return _conversation!.groupName!;
    }
    
    if (_conversation!.participantUsers != null && _conversation!.participantUsers!.isNotEmpty) {
      // For direct conversations, show the other person's name
      final otherUser = _conversation!.participantUsers!.firstWhere(
        (user) => user.id != _currentUserId,
        orElse: () => User(id: '', name: 'Unknown', avatar: 'assets/images/avatar.png', role: 'user'),
      );
      return otherUser.name;
    }
    
    return widget.doctorName;
  }

  String _getParticipantAvatar() {
    if (_conversation == null) return widget.doctorAvatar;
    
    if (_conversation!.isGroup) {
      return 'assets/images/group.png';
    }
    
    if (_conversation!.participantUsers != null && _conversation!.participantUsers!.isNotEmpty) {
      final otherUser = _conversation!.participantUsers!.firstWhere(
        (user) => user.id != _currentUserId,
        orElse: () => User(id: '', name: 'Unknown', avatar: 'assets/images/avatar.png', role: 'user'),
      );
      return otherUser.avatar;
    }
    
    return widget.doctorAvatar;
  }

  void _startMessageRefreshTimer() {
    // Cancel any existing timer
    _refreshTimer?.cancel();
    
    // Set up a new timer that refreshes messages every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_conversation != null && mounted) {
        print("Auto-refreshing messages");
        fetchMessages(_conversation!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(_getParticipantAvatar()),
              radius: 16,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getParticipantName(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: Colors.teal),
            onPressed: () {
              // Video call
            },
          ),
          IconButton(
            icon: Icon(Icons.call, color: Colors.teal),
            onPressed: () {
              // Audio call
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list
          _isLoadingChat
            ? Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Expanded(
                child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                          SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message.senderId == _currentUserId;
                        final senderName = isUser ? "You" : (message.sender?.name ?? "Other user");
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              // Sender label with timestamp
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                child: Text(
                                  "$senderName · ${message.timeString}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              // Message bubble with sender avatar
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  // Other user's avatar on the left
                                  if (!isUser) ...[
                                    CircleAvatar(
                                      backgroundImage: AssetImage(
                                        message.sender?.avatar ?? 'assets/images/avatar.png'
                                      ),
                                      radius: 14,
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                  
                                  // Message content
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isUser ? Colors.teal : Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isUser ? Colors.white : Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  
                                  // Current user's avatar on the right
                                  if (isUser) ...[
                                    SizedBox(width: 8),
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: AssetImage('assets/images/avatar.png'),
                                          radius: 14,
                                        ),
                                        if (message.read)
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.done_all,
                                                color: Colors.teal,
                                                size: 10,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
          
          // Typing indicator
          if (_typingUsers.values.any((isTyping) => isTyping))
            Padding(
              padding: EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                    radius: 16,
                  ),
                  SizedBox(width: 8),
                  Text("Typing...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          
          // Message input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (text) {
                        // Notify typing status
                        _setTyping(text.isNotEmpty);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () => sendMessage(_controller.text),
                    child: Text(
                      'Send',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Audio call screen for future implementation
class AudioCallScreen extends StatelessWidget {
  final String doctorName;
  final String doctorAvatar;
  
  const AudioCallScreen({
    Key? key, 
    required this.doctorName, 
    required this.doctorAvatar
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade200, Colors.teal.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Spacer(),
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(doctorAvatar),
              ),
              SizedBox(height: 20),
              Text(
                doctorName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '00:05:24',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CallButton(
                    icon: Icons.videocam,
                    color: Colors.white,
                    onPressed: () {},
                  ),
                  SizedBox(width: 30),
                  CallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 30),
                  CallButton(
                    icon: Icons.mic,
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 40),
              Text(
                'Swipe back to menu',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Video call screen for future implementation
class VideoCallScreen extends StatelessWidget {
  final String doctorName;
  final String doctorAvatar;
  
  const VideoCallScreen({
    Key? key, 
    required this.doctorName, 
    required this.doctorAvatar
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (doctor video)
          Image.asset(
            doctorAvatar,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          
          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                Spacer(),
                Text(
                  doctorName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '00:05:24',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CallButton(
                      icon: Icons.switch_camera,
                      color: Colors.white,
                      onPressed: () {},
                    ),
                    SizedBox(width: 30),
                    CallButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 30),
                    CallButton(
                      icon: Icons.mic,
                      color: Colors.white,
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Text(
                  'Swipe back to menu',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          
          // User camera preview
          Positioned(
            right: 20,
            top: 100,
            child: Container(
              height: 150,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable call button widget
class CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  
  const CallButton({
    Key? key, 
    required this.icon, 
    required this.color, 
    required this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: IconButton(
        icon: Icon(icon, color: color == Colors.white ? Colors.black : Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
