import 'package:animate_do/animate_do.dart';
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerDescription(brew: brew),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brews = Provider.of<List<Brew>?>(context) ?? [];
    final user = Provider.of<UserObj?>(context);

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
          String sellerUid = product['sellerUid'] ?? '';

          if (user != null && sellerUid == user.uid) {
            return SizedBox.shrink();
          }

          final brew = brews.firstWhere(
                (brew) => brew.productdetails?.contains(product) ?? false,
          );

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
                        constraints: BoxConstraints(maxHeight: 120, minHeight: 120),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _getProductImage(product['category']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),

                    Text(
                      product['name'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),

                    Text(
                      "Price: ₹${product['price']}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 4),

                    Text(
                      "Category: ${product['category']}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 4),

                    ZoomIn(
                      duration: Duration(milliseconds: 300),
                      child: TextButton(
                        onPressed: () {
                          _sellerDescription(brew);
                          print("🎉 Reward points increased by 500!");
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "BUY",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
