import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatDashboardScreen extends StatefulWidget {
  @override
  _ChatDashboardScreenState createState() => _ChatDashboardScreenState();
}

class _ChatDashboardScreenState extends State<ChatDashboardScreen> {
  final Color primary = Color(0xFF6B9080);
  final Color surface = Color(0xFFF8F9FA);
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String _getChatDocId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  List<QueryDocumentSnapshot> _filterChats(List<QueryDocumentSnapshot> chats) {
    if (_searchQuery.isEmpty) return chats;

    return chats.where((chat) {
      final data = chat.data() as Map<String, dynamic>;
      final lastMessage = data['lastMessage']?.toString().toLowerCase() ?? '';
      final otherUserName = data['otherUserName']?.toString().toLowerCase() ?? '';
      return lastMessage.contains(_searchQuery.toLowerCase()) ||
          otherUserName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle_outlined, size: 64, color: primary),
              SizedBox(height: 16),
              Text('Please log in to view messages',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            color: primary,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: surface,
        child: Column(
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search, color: primary),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('participantIds', arrayContains: currentUser.uid)
                // Temporarily comment out orderBy until index is created
                // .orderBy('lastMessageTime', descending: true)
                    .snapshots(),
                builder: (context, chatSnapshot) {
                  // Handle stream errors
                  if (chatSnapshot.hasError) {
                    print('Error: ${chatSnapshot.error}');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red[300]),
                          SizedBox(height: 16),
                          Text('Something went wrong',
                              style: TextStyle(color: Colors.grey[600])),
                          TextButton(
                            onPressed: () {
                              setState(() {}); // Refresh the widget
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Handle loading state
                  if (!chatSnapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: primary),
                    );
                  }

                  final filteredChats = _filterChats(chatSnapshot.data!.docs);

                  // Handle empty state
                  if (filteredChats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64, color: primary.withOpacity(0.5)),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No conversations yet'
                                : 'No matches found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chatDoc = filteredChats[index];
                      final chatData = chatDoc.data() as Map<String, dynamic>;

                      final participantIds =
                      List<String>.from(chatData['participantIds'] ?? []);
                      final otherUserId = participantIds.firstWhere(
                            (id) => id != currentUser.uid,
                        orElse: () => '',
                      );

                      if (otherUserId.isEmpty) {
                        return SizedBox.shrink();
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(otherUserId)
                            .get(),
                        builder: (context, userSnapshot) {
                          // Handle user data loading state
                          if (!userSnapshot.hasData) {
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: primary.withOpacity(0.2),
                                ),
                                title: Container(
                                  width: 100,
                                  height: 14,
                                  color: Colors.grey[300],
                                ),
                              ),
                            );
                          }

                          final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                          final lastMessage =
                              chatData['lastMessage'] ?? 'No messages yet';
                          final lastMessageTime =
                          chatData['lastMessageTime'] as Timestamp?;
                          final isUnread = chatData['unreadCount'] != null &&
                              chatData['unreadCount'] > 0 &&
                              chatData['lastMessageSenderId'] != currentUser.uid;

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: primary.withOpacity(0.2),
                                backgroundImage: NetworkImage(
                                    userData['profileImage'] ??
                                        'https://via.placeholder.com/150'),
                              ),
                              title: Text(
                                userData['name'] ?? 'Unknown User',
                                style: TextStyle(
                                  fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                  isUnread ? Colors.black87 : Colors.grey[600],
                                  fontWeight:
                                  isUnread ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (lastMessageTime != null)
                                    Text(
                                      _formatTimestamp(lastMessageTime),
                                      style: TextStyle(
                                        color: isUnread ? primary : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (isUnread)
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        chatData['unreadCount'].toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      roomateId: otherUserId,
                                      roommateName:
                                      userData['name'] ?? 'Unknown User',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}