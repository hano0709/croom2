import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpgradeScreen extends StatefulWidget {
  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final Color primary = Color(0xFF6B9080);
  final Color surface = Color(0xFFF8F9FA);

  int callsLeft = 0;
  int messagesLeft = 0;

  @override
  void initState() {
    super.initState();
    _loadUserCredits();
  }

  Future<void> _loadUserCredits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          callsLeft = doc.data()?['calls_left'] ?? 0;
          messagesLeft = doc.data()?['messages_left'] ?? 0;
        });
      }
    }
  }

  Future<void> _purchaseCredits(String type, int amount, int price) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    if (type == 'calls') {
      await userRef.update({'calls_left': FieldValue.increment(amount)});
      setState(() => callsLeft += amount);
    } else {
      await userRef.update({'messages_left': FieldValue.increment(amount)});
      setState(() => messagesLeft += amount);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Purchase successful! Added $amount ${type == "calls" ? "calls" : "messages"}'),
        backgroundColor: primary,
      ),
    );
  }

  Widget _buildCreditCard(String title, int count, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 32),
          SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.black54, fontSize: 16)),
          SizedBox(height: 4),
          Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary)),
          Text('remaining', style: TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPurchaseOption(String type, int amount, int price) {
    return GestureDetector(
      onTap: () => _purchaseCredits(type, amount, price),
      child: Container(
        width: 120,
        height: 90, // Increased height
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  type == "calls"
                      ? '$amount Call${amount > 1 ? 's' : ''}'
                      : '$amount Messages',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₹$price',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      backgroundColor: surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildCreditCard('Calls', callsLeft, Icons.phone)),
                SizedBox(width: 16),
                Expanded(child: _buildCreditCard('Messages', messagesLeft, Icons.message)),
              ],
            ),
            SizedBox(height: 32),
            _buildPurchaseSection('Purchase Calls', 'calls', [1, 2, 3, 4, 5]),
            SizedBox(height: 32),
            _buildPurchaseSection('Purchase Messages', 'messages', [10, 20, 30, 40, 50]),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseSection(String title, String type, List<int> amounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: amounts.map((amount) =>
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: _buildPurchaseOption(type, amount, amount * 10),
                )
            ).toList(),
          ),
        ),
      ],
    );
  }
}