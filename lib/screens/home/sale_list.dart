import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../services/database.dart';
import '../../shared/loading.dart';

class SaleList extends StatefulWidget {
  const SaleList({super.key});

  @override
  State<SaleList> createState() => _SaleListState();
}

class _SaleListState extends State<SaleList> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserObj?>(context);
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user!.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData? userData = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              shrinkWrap: false,
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: MediaQuery.of(context).size.width < 600 ? 0.5 : 1.5,
              ),
              itemCount: userData?.productdetails.length,
              itemBuilder: (context, productIndex) {
                final product = userData?.productdetails[productIndex];

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                              maxHeight: 120,
                              minHeight: 120),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              product['category'] == 'paper'
                                  ? 'assets/paper.jpg'
                                  : product['category'] == 'metal'
                                  ? 'assets/metal.jpg'
                                  : product['category'] == 'plastic'
                                  ? 'assets/plastic.jpeg'
                                  : product['category'] == 'cardboard'
                                  ? 'assets/cardboard.jpeg'
                                  : product['category'] == 'glass'
                                  ? 'assets/glass.jpeg'
                                  : product['category'] == 'shoes'
                                  ? 'assets/shoes.jpeg'
                                  : product['category'] == 'trash'
                                  ? 'assets/trash.jpeg'
                                  : product['category'] == 'clothes'
                                  ? 'assets/clothes.jpeg'
                                  : product['category'] == 'battery'
                                  ? 'assets/battery.jpeg'
                                  : product['category'] == 'biological'
                                  ? 'assets/biological.jpeg'
                                  : 'assets/other.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          product['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Price: ₹${product['price']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Category: ${product['category']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            _showCancelConfirmation(context, user, userData!, product);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                            backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const Loading();
        }
      },
    );
  }

  void _showCancelConfirmation(BuildContext context, UserObj user, UserData userData, dynamic product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Confirm Cancellation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to remove this item from sale?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("No", style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first

                // Remove the product
                userData.productdetails.remove(product);

                // Update the user data in the database
                await DatabaseService(uid: user.uid).updateUserData(
                  userData.name,
                  userData.rewardpoints,
                  userData.userinfo,
                  userData.productdetails,
                );

                if (mounted) {
                  setState(() {});
                }
              },
              child: const Text(
                "Yes, Remove",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
