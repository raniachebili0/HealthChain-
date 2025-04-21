import 'package:health_chain/models/user.dart';

class Conversation {
  final String id;
  final List<dynamic> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isGroup;
  final String? groupName;

  final List<User>? participantUsers;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.isGroup = false,
    this.groupName,
    this.participantUsers,
    this.unreadCount = 0,
  });

  // Add helper method to safely extract participant IDs
  List<String> getParticipantIds() {
    List<String> ids = [];
    for (var participant in participants) {
      if (participant is String) {
        ids.add(participant);
      } else if (participant is Map<String, dynamic> && participant.containsKey('_id')) {
        ids.add(participant['_id'] as String);
      }
    }
    return ids;
  }

  // Helper to check if a user ID is in the participants list
  bool hasParticipant(String userId) {
    if (userId.isEmpty) return false;
    
    for (var participant in participants) {
      String participantId = '';
      if (participant is String) {
        participantId = participant;
      } else if (participant is Map<String, dynamic> && participant.containsKey('_id')) {
        participantId = participant['_id'] as String;
      }
      
      if (participantId == userId) {
        return true;
      }
    }
    return false;
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Debug log to see what raw data we're working with
    print("Parsing conversation with id: ${json['_id']} and raw unreadCount: ${json['unreadCount']}");
    
    List<dynamic> participantsList = [];
    if (json['participants'] != null) {
      participantsList = List<dynamic>.from(
        (json['participants'] as List).map((participant) {
          // Safely handle participants that could be strings or objects
          if (participant is Map) {
            return participant;
          } else if (participant is String) {
            return participant;
          } else {
            return '';
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

    // Get unreadCount, ensuring it's an integer
    int unreadCount = 0;
    if (json['unreadCount'] != null) {
      if (json['unreadCount'] is int) {
        unreadCount = json['unreadCount'];
      } else if (json['unreadCount'] is String) {
        unreadCount = int.tryParse(json['unreadCount']) ?? 0;
      }
    }
    
    print("Parsed unreadCount as: $unreadCount for conversation: ${json['_id']}");

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
      unreadCount: unreadCount,
    );
  }
}