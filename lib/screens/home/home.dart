import 'package:ecomind/chatbot/chatbot_main.dart';
import 'package:ecomind/chatbot/classifier.dart';
import 'package:ecomind/services/auth.dart';
import 'package:ecomind/services/buyer_page.dart';
import 'package:ecomind/services/seller_page.dart';
import 'package:flutter/material.dart';
import 'package:ecomind/services/database.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../models/brew.dart';
import '../../models/user.dart';
import '../../services/profile_page.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  int _selectedIndex = 0;

  bool profilePage = false;
  bool buyerPage = false;
  bool sellerPage = false;

  void _onHomeTapped() {}
  void _onBuyerTapped() => setState(() => buyerPage = true);
  void _onSellerTapped() => setState(() => sellerPage = true);
  void _onProfileTapped() => setState(() => profilePage = true);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning! ☀️";
    if (hour < 18) return "Good afternoon! 🌿";
    return "Good evening! 🌙";
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserObj?>(context);

    return profilePage
        ? ProfilePage()
        : buyerPage
        ? BuyerPage()
        : sellerPage
        ? SellerPage()
        : StreamProvider<List<Brew>?>.value(
      initialData: null,
      value: DatabaseService(uid: user!.uid).brews,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.eco, size: 30, color: Colors.white),
              SizedBox(width: 10.0),
              Text(
                'EcoMind',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 4,
          actions: [
            TextButton.icon(
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text('Logout', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Message
              FadeIn(
                duration: Duration(milliseconds: 800),
                child: Text(
                  _getGreeting(),
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Let's make the world greener, one step at a time! 🌱",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),

              // Recycling Statistics
              FadeInUp(duration: Duration(milliseconds: 800), child: _buildStatisticsCard()),

              SizedBox(height: 20),

              // Feature Buttons
              _buildFeatureButton(
                title: "Chat with EcoBot",
                description: "Get quick answers to your recycling questions.",
                icon: Icons.chat_bubble_outline,
                color1: Colors.blue.shade400,
                color2: Colors.blue.shade700,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotMain()));
                },
              ),
              SizedBox(height: 20),
              _buildFeatureButton(
                title: "Know Your Waste",
                description: "Classify waste items for proper disposal.",
                icon: Icons.search_rounded,
                color1: Colors.orange.shade400,
                color2: Colors.orange.shade700,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ClassifierScreen()));
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 0) _onHomeTapped();
            else if (index == 1) _onBuyerTapped();
            else if (index == 2) _onSellerTapped();
            else if (index == 3) _onProfileTapped();
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Buyer'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Seller'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "♻️ Recycling Facts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
            ),
            SizedBox(height: 10),
            _buildStatisticRow("🌍 Every year, 8 million tons of plastic enter our oceans."),
            _buildStatisticRow("🗑️ Recycling one aluminum can saves enough energy to run a TV for 3 hours."),
            _buildStatisticRow("🌱 Glass can be recycled endlessly without losing quality."),
            _buildStatisticRow("📄 Recycling a ton of paper saves 17 trees and 7,000 gallons of water."),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String fact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text(fact, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 5),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
