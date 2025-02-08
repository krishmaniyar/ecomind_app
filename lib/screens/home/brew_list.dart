import 'package:ecomind/screens/home/seller_description.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/brew.dart';
import '../../models/user.dart';
import '../../services/database.dart';

class BrewList extends StatefulWidget {
  const BrewList({super.key});

  @override
  State<BrewList> createState() => _BrewListState();
}

class _BrewListState extends State<BrewList> {
  void _sellerDescription(Brew brew) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
            child: SellerDescription(brew: brew),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final brews = Provider.of<List<Brew>?>(context) ?? [];
    final user = Provider.of<UserObj?>(context);

    // Flatten product details from all brews
    final allProducts = brews.expand((brew) => brew.productdetails ?? []).toList();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        shrinkWrap: false,
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: MediaQuery.of(context).size.width < 600 ? 0.5 : 1.5,
        ),
        itemCount: allProducts.length,
        itemBuilder: (context, productIndex) {
          final product = allProducts[productIndex];

          // Get the seller UID from the product details
          String sellerUid = product['sellerUid'] ?? '';

          // Hide product if the logged-in user is the seller
          if (user != null && sellerUid == user.uid) {
            return SizedBox.shrink();
          }

          final brew = brews.firstWhere(
                (brew) => brew.productdetails?.contains(product) ?? false,
          );

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
                  // Product Image
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
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
                  SizedBox(height: 8.0),

                  // Product Name
                  Text(
                    product['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),

                  // Product Price
                  Text(
                    "Price: ₹${product['price']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),

                  // Product Category
                  Text(
                    "Category: ${product['category']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),

                  // BUY Button
                  TextButton(
                    onPressed: () async {
                      try {
                        if (user == null) return;

                        // Use Brew's UID instead of User's UID
                        DatabaseService databaseService = DatabaseService(uid: user.uid);
                        UserData? userData = await databaseService.userData.first;

                        if (userData == null) return;

                        // Increase reward points by 500
                        _sellerDescription(brew);
                        await databaseService.updateUserData(
                          userData.name,
                          userData.rewardpoints + 500,
                          userData.userinfo,
                          userData.productdetails,
                        );

                        print("🎉 Reward points increased by 500!");

                      } catch (e) {
                        print("❌ Error updating reward points: $e");
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "BUY",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper function to get product images
  String _getProductImage(String category) {
    switch (category) {
      case 'paper':
        return 'assets/paper.jpg';
      case 'metal':
        return 'assets/metal.jpg';
      case 'plastic':
        return 'assets/plastic.jpeg';
      case 'cardboard':
        return 'assets/cardboard.jpeg';
      case 'glass':
        return 'assets/glass.jpeg';
      case 'shoes':
        return 'assets/shoes.jpeg';
      case 'trash':
        return 'assets/trash.jpeg';
      case 'clothes':
        return 'assets/clothes.jpeg';
      case 'battery':
        return 'assets/battery.jpeg';
      case 'biological':
        return 'assets/biological.jpeg';
      default:
        return 'assets/other.png';
    }
  }
}
