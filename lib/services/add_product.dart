import 'package:ecomind/models/user.dart';
import 'package:ecomind/services/database.dart';
import 'package:ecomind/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();

  // Form values
  Map _details = {};
  final List<String> categories = [
    'paper', 'metal', 'plastic', 'cardboard', 'glass',
    'shoes', 'trash', 'clothes', 'battery', 'biological', 'other'
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserObj?>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user!.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData? userData = snapshot.data;
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Text(
                'Add Product',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
              ),
              backgroundColor: Colors.green,
              elevation: 4,
              iconTheme: const IconThemeData(color: Colors.white), // White back button
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Name Field
                      _buildTextField(
                        label: "Product Name",
                        hintText: "Enter product name",
                        onChanged: (val) => setState(() => _details['name'] = val),
                        validator: (val) => val!.trim().isEmpty ? 'Product name is required' : null,
                      ),
                      const SizedBox(height: 20.0),

                      // Price Field
                      _buildTextField(
                        label: "Price",
                        hintText: "Enter price",
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (val) => setState(() => _details['price'] = val),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Price is required';
                          if (int.tryParse(val) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Category Dropdown
                      _buildDropdownField(
                        label: "Category",
                        items: categories,
                        onChanged: (val) => setState(() => _details['category'] = val),
                        validator: (val) => val == null || val.isEmpty ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 30.0),

                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Add Product',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              userData?.productdetails.add(_details);
                              await DatabaseService(uid: user.uid).updateUserData(
                                userData!.name, userData.rewardpoints, userData.userinfo, userData.productdetails,
                              );
                              print(_details);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
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

  // Custom Input Field
  Widget _buildTextField({
    required String label,
    required String hintText,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Custom Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
          items: items.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
