import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/utils/colors.dart';

class ConvesationsScreen extends StatefulWidget {
  const ConvesationsScreen({super.key});

  @override
  State<ConvesationsScreen> createState() => _ConvesationsScreenState();
}

class _ConvesationsScreenState extends State<ConvesationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Mock data for conversations
  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Dr. Sarah Johnson',
      'lastMessage': 'Your test results are ready',
      'time': '10:30 AM',
      'unread': 2,
      'isOnline': true,
      'avatar': 'assets/images/doctor1.png',
    },
    {
      'name': 'Dr. Michael Chen',
      'lastMessage': 'Don\'t forget your appointment tomorrow',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': false,
      'avatar': 'assets/images/doctor2.png',
    },
    {
      'name': 'Dr. Emily Brown',
      'lastMessage': 'The prescription has been sent',
      'time': 'Yesterday',
      'unread': 1,
      'isOnline': true,
      'avatar': 'assets/images/doctor3.png',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Conversations',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            color: Colors.grey[700],
            onPressed: () {
              Navigator.pushNamed(context, '/notification_screen');
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                },
              ),
            ),
          ),

          // Conversations List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return _buildConversationItem(conversation);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new conversation
        },
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.message_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25.r,
              backgroundColor: Colors.grey[200],
              child: conversation['avatar'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: Image.asset(
                        conversation['avatar'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, color: Colors.grey[400]),
                      ),
                    )
                  : Icon(Icons.person, color: Colors.grey[400]),
            ),
            if (conversation['isOnline'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          conversation['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          conversation['lastMessage'],
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              conversation['time'],
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            if (conversation['unread'] > 0) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation['unread'].toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          // Navigate to chat screen
        },
      ),
    );
  }
}
