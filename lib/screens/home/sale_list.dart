import 'package:animate_do/animate_do.dart';
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
              physics: AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: MediaQuery.of(context).size.width < 600 ? 0.5 : 1.5,
              ),
              itemCount: userData?.productdetails.length,
              itemBuilder: (context, productIndex) {
                final product = userData?.productdetails[productIndex];

                return FadeInUp(
                  duration: Duration(milliseconds: 500 + (productIndex * 100)),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeIn(
                            duration: Duration(milliseconds: 400),
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.5,
                                maxHeight: 120,
                                minHeight: 120,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  _getProductImage(product['category']),
                                  fit: BoxFit.cover,
                                ),
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

                          ZoomIn(
                            duration: Duration(milliseconds: 300),
                            child: TextButton(
                              onPressed: () {
                                _showCancelConfirmation(context, user, userData!, product);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                backgroundColor: Colors.green[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                Navigator.of(context).pop();
              },
              child: const Text("No", style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                userData.productdetails.remove(product);

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

  String _getProductImage(String category) {
    switch (category) {
      case 'paper': return 'assets/paper.jpg';
      case 'metal': return 'assets/metal.jpg';
      case 'plastic': return 'assets/plastic.jpeg';
      case 'cardboard': return 'assets/cardboard.jpeg';
      case 'glass': return 'assets/glass.jpeg';
      case 'shoes': return 'assets/shoes.jpeg';
      case 'trash': return 'assets/trash.jpeg';
      case 'clothes': return 'assets/clothes.jpeg';
      case 'battery': return 'assets/battery.jpeg';
      case 'biological': return 'assets/biological.jpeg';
      default: return 'assets/other.png';
    }
  }
}
