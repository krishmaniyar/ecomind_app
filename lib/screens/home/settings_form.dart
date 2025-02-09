import 'package:ecomind/models/user.dart';
import 'package:ecomind/services/database.dart';
import 'package:ecomind/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  // Form values
  String? _currentName;
  String? _phoneNumber;
  String? _email;
  String? _organization;

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
              backgroundColor: Colors.green[700],
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              elevation: 3,
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 20.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 50,
                ),
                child: Form(
                  key: _formKey,
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
                              userData?.name ?? "User",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "Edit your details",
                              style: TextStyle(color: Colors.green[800], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Username
                      _buildTextField(
                        icon: Icons.person,
                        label: 'Username',
                        initialValue: _currentName ?? userData?.name,
                        keyboardType: TextInputType.text,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Username is required' : null,
                        onChanged: (val) => setState(() => _currentName = val.trim()),
                      ),

                      // Phone Number (Only allows numbers, enforces 10 digits)
                      _buildTextField(
                        icon: Icons.phone,
                        label: 'Phone Number',
                        initialValue: userData?.userinfo['phoneno'] == "Not Provided yet" ? '' : userData?.userinfo['phoneno'],
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Phone number is required';
                          } else if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                            return 'Enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                        onChanged: (val) => setState(() => _phoneNumber = val.trim()),
                      ),

                      // Email ID (Strict validation)
                      _buildTextField(
                        icon: Icons.email,
                        label: 'Email ID',
                        initialValue: userData?.userinfo['emailid'] == "Not Provided yet" ? '' : userData?.userinfo['emailid'],
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Email is required';
                          } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(val.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        onChanged: (val) => setState(() => _email = val.trim()),
                      ),

                      // Organization (Required)
                      _buildTextField(
                        icon: Icons.business,
                        label: 'Organization',
                        initialValue: userData?.userinfo['organization'],
                        keyboardType: TextInputType.text,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Organization is required' : null,
                        onChanged: (val) => setState(() => _organization = val.trim()),
                      ),

                      const SizedBox(height: 30.0),

                      // Update Profile Button
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await DatabaseService(uid: user!.uid).updateUserData(
                                _currentName ?? userData!.name,
                                userData!.rewardpoints,
                                {
                                  'phoneno': _phoneNumber ?? userData!.userinfo['phoneno'],
                                  'emailid': _email ?? userData!.userinfo['emailid'],
                                  'organization': _organization ?? userData!.userinfo['organization'],
                                },
                                userData.productdetails,
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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

  // Stylish Text Field Builder Function
  Widget _buildTextField({
    required IconData icon,
    required String label,
    required String? initialValue,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
