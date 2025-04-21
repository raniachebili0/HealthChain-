import 'package:health_chain/models/user.dart';


class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool read;
  final DateTime? readAt;
  final User? sender;
  final String? senderName;
  final String conversationId;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.conversationId,
    this.read = false,
    this.readAt,
    this.sender,
    this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      // Handle case where sender might be null or missing _id
      String senderId = '';
      User? senderUser;
      String? senderName;
      
      if (json['sender'] != null) {
        // Handle case where sender might be a string ID instead of an object
        if (json['sender'] is String) {
          senderId = json['sender'];
        } else if (json['sender'] is Map) {
          senderId = json['sender']['_id'] ?? '';
          senderUser = User.fromJson(json['sender']);
          senderName = senderUser.name;
        }
      } else if (json['senderId'] != null) {
        // Some responses might use senderId directly
        senderId = json['senderId'];
      }
      
      // Extract sender name if it's directly in the message
      if (json['senderName'] != null) {
        senderName = json['senderName'];
      }
      
      // Handle case where _id might be in different formats
      String messageId = '';
      if (json['_id'] != null) {
        messageId = json['_id'] is String ? json['_id'] : json['_id'].toString();
      } else if (json['id'] != null) {
        messageId = json['id'] is String ? json['id'] : json['id'].toString();
      }
      
      // Better handling for content
      String messageContent = '';
      if (json['content'] != null) {
        messageContent = json['content'].toString();
      }
      
      // Extract conversation ID
      String conversationId = '';
      if (json['conversationId'] != null) {
        conversationId = json['conversationId'] is String ? 
            json['conversationId'] : json['conversationId'].toString();
      } else if (json['conversation'] != null) {
        // Handle case where conversation might be an object
        if (json['conversation'] is String) {
          conversationId = json['conversation'];
        } else if (json['conversation'] is Map && json['conversation']['_id'] != null) {
          conversationId = json['conversation']['_id'].toString();
        }
      }
      
      // Log message data for debugging
      print("Parsing message: id=$messageId, content=$messageContent, senderId=$senderId, senderName=$senderName");
      
      // Parse createdAt with better error handling
      DateTime createdAt;
      try {
        createdAt = json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now();
      } catch (e) {
        print("Error parsing createdAt: $e");
        createdAt = DateTime.now();
      }
      
      return Message(
        id: messageId,
        senderId: senderId,
        content: messageContent,
        conversationId: conversationId,
        createdAt: createdAt,
        read: json['read'] ?? false,
        readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
        sender: senderUser,
        senderName: senderName,
      );
    } catch (e) {
      print("Error creating Message from JSON: $e");
      print("Problematic JSON: $json");
      
      // Create a fallback message to prevent crashes
      return Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: '',
        content: 'Error parsing message',
        createdAt: DateTime.now(),
        conversationId: '',
      );
    }
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