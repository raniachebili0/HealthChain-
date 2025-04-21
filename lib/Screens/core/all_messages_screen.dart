import 'package:flutter/material.dart';
import 'package:health_chain/models/message.dart';
import 'package:health_chain/services/message_service.dart';
import 'package:intl/intl.dart';

class AllMessagesScreen extends StatefulWidget {
  const AllMessagesScreen({Key? key}) : super(key: key);

  @override
  State<AllMessagesScreen> createState() => _AllMessagesScreenState();
}

class _AllMessagesScreenState extends State<AllMessagesScreen> {
  final MessageService _messageService = MessageService();
  List<Message> _messages = [];
  bool _isLoading = true;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllMessages();

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

  Future<void> _fetchAllMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _messageService.getAllMessages();
      
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching all messages: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e'))
      );
    }
  }

  List<Message> get _filteredMessages {
    if (_searchQuery.isEmpty) {
      return _messages;
    }
    
    return _messages.where((message) {
      return message.content.toLowerCase().contains(_searchQuery) ||
             (message.senderName?.toLowerCase().contains(_searchQuery) ?? false) ||
             (message.conversationId.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Messages'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchAllMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          
          // Messages list
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _filteredMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                            ? 'No messages found in the database'
                            : 'No messages match your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchAllMessages,
                    child: ListView.builder(
                      itemCount: _filteredMessages.length,
                      itemBuilder: (context, index) {
                        final message = _filteredMessages[index];
                        return _buildMessageItem(message);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    // Format the date
    final DateFormat formatter = DateFormat('MMM d, yyyy HH:mm');
    final String formattedDate = formatter.format(message.createdAt);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          message.senderName ?? 'Unknown Sender',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(message.content),
            SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        isThreeLine: true,
        leading: CircleAvatar(
          child: Text(
            (message.senderName ?? 'U')[0],
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
        ),
        trailing: Text(
          'Conv: ${message.conversationId.substring(0, 6)}...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        onTap: () {
          // Show message details
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Message Details'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('ID', message.id),
                    _buildDetailRow('Sender', message.senderId),
                    _buildDetailRow('Sender Name', message.senderName ?? 'Unknown'),
                    _buildDetailRow('Conversation', message.conversationId),
                    _buildDetailRow('Time', formattedDate),
                    Divider(),
                    Text(
                      'Content:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(message.content),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 