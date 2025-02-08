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
            backgroundColor: Colors.white, // White background
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Seller Contact Details',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInfo('Name', brew.name, context),
                      _buildInfo('Points', '${brew.rewardpoints}', context),
                      _buildInfo('Phone Number', brew.userinfo['phoneno'], context),
                      _buildInfo('Email Address', brew.userinfo['emailid'], context),
                      _buildInfo('Organization', brew.userinfo['organization'], context),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Loading();
        }
      },
    );
  }

  Widget _buildInfo(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity, // Ensures full width
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light grey background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true, // Ensures text wraps instead of overflowing
              overflow: TextOverflow.visible, // Allows multiline text
            ),
          ),
        ],
      ),
    );
  }
}
