import 'package:ecomind/screens/home/settings_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import 'database.dart';
import 'buyer_page.dart';
import 'seller_page.dart';
import 'package:ecomind/screens/home/home.dart';
import 'package:ecomind/services/auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  int _selectedIndex = 3;

  bool sellerPage = false;
  bool homePage = false;
  bool buyerPage = false;
  bool _showDeveloperInfo = false;

  void _onHomeTapped() => setState(() => homePage = true);
  void _onBuyerTapped() => setState(() => buyerPage = true);
  void _onSellerTapped() => setState(() => sellerPage = true);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserObj?>(context);
    DatabaseService databaseService = DatabaseService(uid: user!.uid);

    return sellerPage
        ? SellerPage()
        : homePage
        ? Home()
        : buyerPage
        ? BuyerPage()
        : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.eco, size: 30, color: Colors.white),
            SizedBox(width: 10.0),
            Text('EcoMind', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileCard(userData),
                  SizedBox(height: 16),
                  _buildInfoCard("Phone No", userData.userinfo['phoneno'] ?? "Not Provided", Icons.phone, Colors.green),
                  _buildInfoCard("Email ID", userData.userinfo['emailid'] ?? "Not Provided", Icons.email, Colors.blue),
                  _buildInfoCard("Organization", userData.userinfo['organization'] ?? "Not Provided", Icons.business, Colors.orange),
                  _buildInfoCard("Reward Points", "${userData.rewardpoints}", Icons.stars_outlined, Colors.amber),
                  SizedBox(height: 1),

                  // About Developers (Tap to Reveal)
                  _buildDeveloperToggle(),

                  // Developer Info (Fixed overflow issue)
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    child: _showDeveloperInfo ? _buildDeveloperInfo() : SizedBox.shrink(),
                  ),

                  SizedBox(height: 10),

                  // Logout Button (Reduced space)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text("Logout", style: TextStyle(fontSize: 18, color: Colors.white)),
                      onPressed: () async => await _auth.signOut(),
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
        selectedItemColor: Colors.green,
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
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Buyer'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Seller'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserData userData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(radius: 35, backgroundImage: AssetImage('assets/profile_pic.png')),
            SizedBox(width: 20),
            Expanded(child: Text(userData.name ?? 'Guest User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            IconButton(icon: Icon(Icons.edit, color: Colors.green), onPressed: () {
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => SettingsForm())
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 70,
      margin: EdgeInsets.symmetric(vertical: 1), // Reduced spacing
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: color, size: 30),
          title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: Text(value, style: TextStyle(fontSize: 14, color: Colors.black54)),
        ),
      ),
    );
  }

  Widget _buildDeveloperToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDeveloperInfo = !_showDeveloperInfo;
        });
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(Icons.code, color: Colors.blue, size: 30),
          title: Text("About Developers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: Icon(_showDeveloperInfo ? Icons.expand_less : Icons.expand_more, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👨‍💻 Developers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Krish, Mohit, Anshul, Madhan", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("🚀 Team Name: EcoCoders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("🎯 Our Goal: We aim to optimize waste recycling using technology, making the process more efficient, sustainable, and accessible to everyone.", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
