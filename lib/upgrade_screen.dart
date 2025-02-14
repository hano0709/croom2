import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class UpgradeScreen extends StatefulWidget {
  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  var _razorpay = Razorpay();
  String? _pendingPurchaseType;
  int? _pendingPurchaseAmount;

  final Color primary = Color(0xFF6B9080);
  final Color surface = Color(0xFFF8F9FA);

  int callsLeft = 0;
  int messagesLeft = 0;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadUserCredits();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Update Firestore only after successful payment
    if (_pendingPurchaseType != null && _pendingPurchaseAmount != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

          if (_pendingPurchaseType == 'calls') {
            await userRef.update({'calls_left': FieldValue.increment(_pendingPurchaseAmount!)});
            setState(() => callsLeft += _pendingPurchaseAmount!);
          } else {
            await userRef.update({'messages_left': FieldValue.increment(_pendingPurchaseAmount!)});
            setState(() => messagesLeft += _pendingPurchaseAmount!);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase successful! Added $_pendingPurchaseAmount ${_pendingPurchaseType == "calls" ? "calls" : "messages"}'),
              backgroundColor: primary,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating credits. Please contact support.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Clear pending purchase
    _pendingPurchaseType = null;
    _pendingPurchaseAmount = null;
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? "Unknown error"}'),
        backgroundColor: Colors.red,
      ),
    );
    // Clear pending purchase
    _pendingPurchaseType = null;
    _pendingPurchaseAmount = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        backgroundColor: primary,
      ),
    );
  }

  void _initiatePayment(String type, int amount, int price) {
    var options = {
      'key': 'rzp_test_UtgyctmGrUNtf4',  // Replace with your Razorpay key
      'amount': price * 100, // Razorpay expects amount in paise
      'name': 'Your App Name',
      'description': '$amount ${type == "calls" ? "Calls" : "Messages"} Purchase',
      'prefill': {
        'contact': '',
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
      }
    };

    // Store purchase details for after payment success
    _pendingPurchaseType = type;
    _pendingPurchaseAmount = amount;

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initiating payment. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
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
      onTap: () => _initiatePayment(type, amount, price),
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
                  // Update price calculation here
                  child: _buildPurchaseOption(
                      type,
                      amount,
                      type == 'calls' ? amount * 10 : amount // ₹10 per call, ₹1 per message
                  ),
                )
            ).toList(),
          ),
        ),
      ],
    );
  }
}