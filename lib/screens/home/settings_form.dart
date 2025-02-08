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
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 20.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 50,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Update Your Profile',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Username
                      _buildTextField(
                        label: 'Username',
                        initialValue: _currentName ?? userData?.name,
                        keyboardType: TextInputType.text,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Username is required' : null,
                        onChanged: (val) => setState(() => _currentName = val.trim()),
                      ),

                      // Phone Number (Only allows numbers, enforces 10 digits)
                      _buildTextField(
                        label: 'Phone Number',
                        initialValue: userData?.userinfo['phoneno'],
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
                        label: 'Email ID',
                        initialValue: userData?.userinfo['emailid'],
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
                        label: 'Organization',
                        initialValue: userData?.userinfo['organization'],
                        keyboardType: TextInputType.text,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Organization is required' : null,
                        onChanged: (val) => setState(() => _organization = val.trim()),
                      ),

                      const SizedBox(height: 30.0),

                      // Update Profile Button
                      Center(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
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

  // Text Field Builder Function
  Widget _buildTextField({
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
          border: OutlineInputBorder(),
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
