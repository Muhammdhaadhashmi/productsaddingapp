import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'firebase/firestore.dart';

class VerifyEmail extends StatefulWidget {
  String name;
  String email;
  VerifyEmail({super.key, required this.name, required this.email});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isEmailVerified = false;
  final auth = FirebaseAuth.instance;
  late Timer? timer;
  User? user;
  @override
  void initState() {
    user = auth.currentUser;
    user!.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  Future checkEmailVerified() async {
    user = auth.currentUser;
    await user!.reload();
    if (user!.emailVerified) {
      timer?.cancel();
      await getUserData(widget.name, widget.email);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return Dashboard();
        },
      ));
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Column(
        children: [
          Text(
            'A verification Email has been sent to your Email Address',
            style: TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 24,
          ),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
              onPressed: () {},
              icon: Icon(
                Icons.email,
                size: 30,
              ),
              label: Text(
                'Resend Email',
                style: TextStyle(fontSize: 24),
              )),
        ],
      ),
    );
  }
}
