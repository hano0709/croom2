import 'package:croom2/upgrade_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String roomateId;
  final String roommateName;

  const ChatScreen({
    Key? key,
    required this.roomateId,
    required this.roommateName
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _resetUnreadCount();
  }

  String get _chatDocId {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return '';

    List<String> ids = [currentUser.uid, widget.roomateId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _resetUnreadCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('chats').doc(_chatDocId).update({
      'unreadCount': 0,
      'lastMessageReadBy': FieldValue.arrayUnion([currentUser.uid])
    });
  }

  Future<bool> _checkMessageCredits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final messagesLeft = doc.data()?['messages_left'] ?? 0;

    if (messagesLeft <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Messages Left'),
          content: Text('Please purchase more messages to continue chatting.'),
          actions: [
            TextButton(
              child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF6B9080),
                  ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                  'Purchase',
                  style: TextStyle(
                    color: Color(0xFF6B9080),
                  ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpgradeScreen()),
                );
              },
            ),
          ],
        ),
      );
      return false;
    }

    // Deduct one message
    await _firestore.collection('users').doc(user.uid).update({
      'messages_left': FieldValue.increment(-1)
    });

    return true;
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final hasCredits = await _checkMessageCredits();
    if (!hasCredits) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();

    // Add the message
    final messageRef = _firestore
        .collection('chats')
        .doc(_chatDocId)
        .collection('messages')
        .doc();

    batch.set(messageRef, {
      'text': message,
      'senderId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'senderName': currentUser.displayName ?? 'User',
    });

    // Update the chat document with last message info and increment unread count
    final chatRef = _firestore.collection('chats').doc(_chatDocId);
    batch.set(chatRef, {
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': currentUser.uid,
      'participantIds': [currentUser.uid, widget.roomateId],
      'unreadCount': FieldValue.increment(1),
      'lastMessageReadBy': [currentUser.uid]  // Only sender has read the message
    }, SetOptions(merge: true));

    await batch.commit();

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roommateName),
        backgroundColor: Color(0xFF6B9080),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatDocId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator(
                    color: Color(0xFF6B9080),
                  ));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    var message = messages[index].data() as Map<String, dynamic>;
                    final isCurrentUser = message['senderId'] ==
                        FirebaseAuth.instance.currentUser?.uid;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 8,
                          left: isCurrentUser ? 64 : 0,
                          right: isCurrentUser ? 0 : 64,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Color(0xFF6B9080)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Color(0xFF6B9080),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Color(0xFF6B9080),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                  backgroundColor: Color(0xFF6B9080),
                  elevation: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}