import 'package:ecomind/models/user.dart';
import 'package:ecomind/services/database.dart';
import 'package:ecomind/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/brew.dart';

class SellerDescription extends StatelessWidget {
  final Brew brew;
  const SellerDescription({super.key, required this.brew});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserObj?>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user!.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.grey[100], // Light grey background
            appBar: AppBar(
              backgroundColor: Colors.green[700],
              title: const Text(
                'Seller Details',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              elevation: 3,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.green[700],
                          child: const Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          brew.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Eco Seller",
                          style: TextStyle(color: Colors.green[800], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact Information
                  _buildInfoCard(
                    icon: Icons.emoji_events,
                    label: "Reward Points",
                    value: '${brew.rewardpoints}',
                    color: Colors.orange,
                  ),
                  _buildInfoCard(
                    icon: Icons.phone,
                    label: "Phone Number",
                    value: brew.userinfo['phoneno'],
                    color: Colors.blue,
                  ),
                  _buildInfoCard(
                    icon: Icons.email,
                    label: "Email Address",
                    value: brew.userinfo['emailid'],
                    color: Colors.redAccent,
                  ),
                  _buildInfoCard(
                    icon: Icons.business,
                    label: "Organization",
                    value: brew.userinfo['organization'],
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Loading();
        }
      },
    );
  }

  // Stylish Card Design for Displaying Information
  Widget _buildInfoCard({required IconData icon, required String label, required String value, required Color color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
