import 'package:ecomind/services/seller_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecomind/screens/home/home.dart';
import 'package:ecomind/services/auth.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../screens/home/settings_form.dart';
import 'buyer_page.dart';
import 'database.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  double fsize = 25.0;
  int _selectedIndex = 3;

  bool seller_page = false;
  bool home_page = false;
  bool buyer_page = false;

  void _onHomeTapped() {
    setState(() {
      home_page = true;
    });
  }

  void _onBuyerTapped() {
    setState(() {
      buyer_page = true;
    });
  }

  void _onSellerTapped() {
    setState(() {
      seller_page = true;
    });
  }

  void _onProfileTapped() {}

  void _showRewardPopup(int rewardPoints) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "🎉 Reward Points",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("⭐ Total Points: $rewardPoints", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                "💡 Tip: Earn more points by selling more products!",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Got it!", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSupportPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("💡 About Us"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("👨‍💻 Developers:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("• Krish\n• Mohit\n• Anshul\n• Madhan"),
              SizedBox(height: 10),
              Text("🚀 Team Name:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("EcoCoders"),
              SizedBox(height: 10),
              Text("🎯 Goal:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("To optimize the recycling flow and make it more efficient."),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Close", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void _showSettingsPanel() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: SettingsForm(),
            );
          });
    }

    final user = Provider.of<UserObj?>(context);
    DatabaseService databaseService = DatabaseService(uid: user!.uid);

    return seller_page
        ? SellerPage()
        : home_page
        ? Home()
        : buyer_page
        ? BuyerPage()
        : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(width: 10.0),
            Icon(Icons.recycling_outlined, size: fsize + 10),
            SizedBox(width: 10.0),
            Text(
              'EcoMind',
              style: TextStyle(fontSize: fsize + 5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: StreamBuilder<UserData>(
        stream: databaseService.userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No user data available'));
          }

          UserData userData = snapshot.data!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Row(
                            children: [
                              SizedBox(width: 10.0),
                              CircleAvatar(radius: fsize + 4, backgroundImage: AssetImage('assets/profile_pic.png')),
                              SizedBox(width: 20.0),
                              Text(userData.name ?? 'Guest User', style: TextStyle(fontSize: fsize - 5)),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: TextButton(
                            child: Text('Edit >', style: TextStyle(color: Colors.blue)),
                            onPressed: _showSettingsPanel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () => _showRewardPopup(userData.rewardpoints),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            SizedBox(width: 10.0),
                            Icon(Icons.stars_outlined, size: fsize),
                            SizedBox(width: 20.0),
                            Text(
                              'Reward Points: ${userData.rewardpoints}',
                              style: TextStyle(fontSize: fsize - 3, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () => _showSupportPopup(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            SizedBox(width: 10.0),
                            Icon(CupertinoIcons.info, size: fsize),
                            SizedBox(width: 20.0),
                            Text(
                              'About us',
                              style: TextStyle(fontSize: fsize - 3, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        await _auth.signOut();
                      },
                      label: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Row(
                          children: [
                            SizedBox(width: 10.0),
                            Icon(Icons.logout_outlined, size: fsize, color: Colors.black),
                            SizedBox(width: 20.0),
                            Text(
                              'Logout',
                              style: TextStyle(fontSize: fsize - 3, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) _onHomeTapped();
            else if (index == 1) _onBuyerTapped();
            else if (index == 2) _onSellerTapped();
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.money_outlined), label: 'Buyer'),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Seller'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}
