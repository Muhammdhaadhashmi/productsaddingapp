import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:productsellingapp/signup.dart';

import 'dashboard.dart';
import 'forgetpassword.dart';


class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loginbody(),
    );
  }
}

class loginbody extends StatefulWidget {
  @override
  State<loginbody> createState() => _loginbodyState();
}

class _loginbodyState extends State<loginbody> {
  bool showPassword = true;
  String email = '';

  String password = '';
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 1.0,
      width: MediaQuery.of(context).size.width * 1.0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.20,
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Login Form',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
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
                  SizedBox(
                    height: 55,
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: showPassword,
                      decoration: InputDecoration(
                        suffix: IconButton(
                          iconSize: 20,
                          onPressed: () {
                            if (showPassword == true) {
                              showPassword = false;
                            } else {
                              showPassword = true;
                            }
                            setState(() {});
                          },
                          icon: Icon(CupertinoIcons.eye_fill),
                        ),
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final user = await auth.signInWithEmailAndPassword(
                                email: email, password: password);

                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Dashboard(),
                                ),
                              );
                            }
                          } catch (e) {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('Warning'),
                                      content: Text(
                                        e.toString(),
                                      ),
                                    ));
                          }
                        },
                        child: Text('Login'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => signup(),
                            ),
                          );
                        },
                        child: Text('Signup?'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => forget(),
                            ),
                          );
                        },
                        child: Text('Forget Password?'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
