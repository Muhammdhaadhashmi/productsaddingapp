import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'LoginScreen.dart';


class forget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: forgetBody(),
    );
  }
}

class forgetBody extends StatefulWidget {
  @override
  State<forgetBody> createState() => _forgetBodyState();
}

class _forgetBodyState extends State<forgetBody> {
  final _auth = FirebaseAuth.instance;

  String email = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 1.0,
      width: MediaQuery.of(context).size.width * 1.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Forget Password',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.blueAccent,
                      ),
                    ),
                    hintText: 'Email',
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      _auth.sendPasswordResetEmail(email: email);
                      await showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text('Important'),
                          content: Text('Check you Email in a moment'),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => login(),
                        ),
                      );
                    } catch (e) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('Warning'),
                                content: Text(
                                  e.toString(),
                                ),
                              ));
                    }
                  },
                  child: Text('Reset Password'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
