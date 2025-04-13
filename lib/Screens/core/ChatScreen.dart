import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:health_chain/config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class ChatScreen extends StatefulWidget {
  final String doctorName;
  final String doctorAvatar;
  final String doctorId;

  const ChatScreen({
    super.key, 
    required this.doctorName, 
    required this.doctorAvatar,
    required this.doctorId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late IO.Socket socket;
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  final storage = FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String userId = '';
  bool isLoading = true;
  bool isInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initNotifications();
    loadUserData();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    isInForeground = state == AppLifecycleState.resumed;
    
    // Quand on revient à l'appli, actualiser les messages
    if (state == AppLifecycleState.resumed) {
      fetchChatHistory();
    }
  }

  void initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // On peut ajouter une action ici si l'utilisateur appuie sur la notification
      },
    );
  }
  
  void showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void loadUserData() async {
    // Get the user ID from secure storage
    final userIdFromStorage = await storage.read(key: "user_id");
    if (userIdFromStorage != null) {
      setState(() {
        userId = userIdFromStorage;
        isLoading = false;
      });
      // Initialize chat history
      await fetchChatHistory();
      // Connect to socket after we have user data
      connectToWebSocket();
    }
  }

  Future<void> fetchChatHistory() async {
    try {
      // Récupérer le token d'authentification
      final token = await storage.read(key: "auth_token");
      
      // Chercher d'abord s'il existe une conversation
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/conversations/between/${userId}/${widget.doctorId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('Conversation found: $data');
        
        if (data != null && data.containsKey('_id')) {
          final conversationId = data['_id'];
          
          // Récupérer les messages pour cette conversation
          final messagesResponse = await http.get(
            Uri.parse('${AppConfig.apiBaseUrl}/conversations/$conversationId/messages'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
          );
          
          if (messagesResponse.statusCode == 200) {
            final List<dynamic> messagesData = json.decode(messagesResponse.body);
            
            setState(() {
              messages = messagesData.map((msg) {
                return {
                  'text': msg['content'],
                  'isSentByMe': msg['senderId'] == userId,
                  'time': DateTime.parse(msg['createdAt']),
                  'status': msg['status'] ?? 'delivered'
                };
              }).toList();
            });
            
            print('Loaded ${messages.length} messages from history');
          } else {
            print('Failed to fetch messages: ${messagesResponse.statusCode}');
            print('Response: ${messagesResponse.body}');
          }
        } else {
          print('No existing conversation yet');
        }
      } else if (response.statusCode != 404) {
        // 404 est normal si la conversation n'existe pas encore
        print('Failed to fetch conversation: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
      // En cas d'erreur, on laisse les messages vides
      setState(() {
        messages = [];
      });
    }
  }

  void connectToWebSocket() {
    final socketUrl = AppConfig.apiBaseUrl.replaceAll(":3000", ":3001");
    print('Connecting to WebSocket at: $socketUrl');
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'userId': userId,
        'recipientId': widget.doctorId
      }
    });

    socket.connect();
    socket.onConnect((_) {
      print('Connected to WebSocket at $socketUrl');
      socket.emit('joinRoom', {
        'userId': userId,
        'recipientId': widget.doctorId
      });
      
      // Informer le serveur qu'on est en ligne
      socket.emit('registerUser', {'userId': userId});
    });

    socket.on('message', (data) {
      print('Message received: $data');
      
      // Ne pas ajouter le message s'il vient de cet utilisateur (éviter les doublons)
      if (data['sender'] != userId) {
        setState(() {
          messages.add({
            'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'text': data['content'],
            'isSentByMe': false,
            'time': data['timestamp'] != null 
                ? DateTime.parse(data['timestamp']) 
                : DateTime.now(),
            'status': 'read'
          });
        });
        
        // Informer l'expéditeur que le message a été lu
        socket.emit('readReceipt', {
          'messageId': data['id'],
          'sender': userId,
          'recipient': data['sender']
        });
        
        // Afficher une notification si l'app est en arrière-plan
        if (!isInForeground) {
          showNotification(
            data['senderName'] ?? widget.doctorName,
            data['content'] ?? 'Nouveau message'
          );
        }
      }
    });
    
    // Écouter les confirmations de livraison
    socket.on('messageDelivered', (data) {
      print('Message delivered: $data');
      
      if (data['messageId'] != null) {
        setState(() {
          for (var msg in messages) {
            if (msg['id'] == data['messageId']) {
              msg['status'] = 'delivered';
              break;
            }
          }
        });
      }
    });
    
    // Écouter les accusés de lecture
    socket.on('messageRead', (data) {
      print('Message read: $data');
      
      if (data['messageId'] != null) {
        setState(() {
          for (var msg in messages) {
            if (msg['id'] == data['messageId']) {
              msg['status'] = 'read';
              break;
            }
          }
        });
      }
    });
    
    // Listen for incoming audio calls
    socket.on('offer', (data) {
      print('Incoming audio call');
      
      // Play ringtone when receiving an audio call
      if (!isInForeground) {
        showNotification(
          'Incoming Call',
          'Audio call from ${widget.doctorName}'
        );
      }
      
      // Play ringtone sound using simpler method
      FlutterRingtonePlayer.playRingtone(
        looping: true,
        volume: 0.5,
        asAlarm: false,
      );
      
      // Navigate to audio call screen
      Navigator.pushNamed(context, '/audio_call', arguments: {
        'doctorId': widget.doctorId,
        'doctorName': widget.doctorName,
        'doctorAvatar': widget.doctorAvatar
      }).then((_) {
        // Stop ringtone when call screen is closed
        FlutterRingtonePlayer.stop();
      });
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket');
    });
  }

  void sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      // Générer un ID unique pour ce message
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final newMsg = {
        'id': messageId,
        'text': message,
        'isSentByMe': true,
        'time': DateTime.now(),
        'status': 'sending'
      };
      
      setState(() {
        messages.add(newMsg);
      });

      // Envoyer au serveur
      socket.emit('message', {
        'id': messageId,
        'sender': userId,
        'recipient': widget.doctorId,
        'content': message,
        'timestamp': DateTime.now().toIso8601String(),
        'senderName': 'Me', // Idéalement, récupérer le nom de l'utilisateur
        'conversationId': null // Le serveur créera une conversation si nécessaire
      });
      
      // Mettre à jour le statut à "sent" après un petit délai
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          newMsg['status'] = 'sent';
        });
      });

      messageController.clear();
      
      // Faire défiler vers le bas pour montrer le nouveau message
      // Note: cela nécessiterait un ScrollController, à ajouter ultérieurement
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    socket.disconnect();
    socket.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.doctorAvatar),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(
              widget.doctorName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/video_call', arguments: {
                'doctorId': widget.doctorId,
                'doctorName': widget.doctorName,
                'doctorAvatar': widget.doctorAvatar
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/audio_call', arguments: {
                'doctorId': widget.doctorId,
                'doctorName': widget.doctorName,
                'doctorAvatar': widget.doctorAvatar
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Consultation Start Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                const Text(
                  'Consultation Start',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You can consult your problem to the doctor',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length,
              reverse: false,  // Keep messages in chronological order
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Message Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.grey,
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isSentByMe = message['isSentByMe'] as bool;
    final timeString = _formatMessageTime(message['time']);
    
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSentByMe) 
              CircleAvatar(
                backgroundImage: NetworkImage(widget.doctorAvatar),
                radius: 15,
              ),
            
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              margin: EdgeInsets.only(
                left: isSentByMe ? 0 : 8,
                right: isSentByMe ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSentByMe 
                    ? Colors.lightBlue 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isSentByMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          color: isSentByMe 
                              ? Colors.white.withOpacity(0.7) 
                              : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      if (isSentByMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _getMessageStatusIcon(message['status']),
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            
            if (isSentByMe)
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 15,
                child: const Text(
                  'Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (now.difference(time).inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }

  IconData _getMessageStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return Icons.access_time;
      case 'sent':
        return Icons.check;
      case 'delivered':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      default:
        return Icons.check;
    }
  }
}

