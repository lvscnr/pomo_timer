import 'package:flutter/material.dart';
import 'signin_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You can add your splash screen UI here

    // Replace the following line with the actual navigation logic
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}
