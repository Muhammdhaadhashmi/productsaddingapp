import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return Dashboard();
        } else {
          return const SplashScreen();
        }
      }),
    );
    if (user != null) {
      Timer(Duration(seconds: 3), () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return Dashboard();
          },
        ));
      });
    } else {
      Timer(Duration(seconds: 3), () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return login();
          },
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset("assets/icons/icon.png"),
          ),
        ],
      ),
    );
  }
}
