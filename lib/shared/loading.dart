import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Use Scaffold for better UI management
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Add padding around the image
          child: Column(
            mainAxisSize: MainAxisSize.min, // Center the column content vertically
            mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
            children: [
              // Optional: Add a nice header or text above the GIF
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800], // Change to a darker shade for contrast
                ),
              ),
              SizedBox(height: 20), // Add some space between the text and the image
              // The loading GIF
              Image(
                image: AssetImage('assets/load.gif'),
                color: Colors.green,
                fit: BoxFit.contain, // Fit image inside the box without distortion
              ),
            ],
          ),
        ),
      ),
    );
  }


// Widget build(BuildContext context) {
  //   return Container(
  //     color: Colors.green[100],
  //     child: Center(
  //       child: SpinKitChasingDots(
  //         color: Colors.green[400],
  //         size: 70.0,
  //       ),
  //     ),
  //   );
  // }
}
