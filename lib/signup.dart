import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:productsellingapp/verify_email.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'firebase/firestore.dart';
import 'main.dart';

class signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: signupBody(),
    );
  }
}

class signupBody extends StatefulWidget {
  @override
  State<signupBody> createState() => _signupBodyState();
}

class _signupBodyState extends State<signupBody> {
  bool showPassword = true;
  final _Auth = FirebaseAuth.instance;

  String name = '';

  String DOB = '';

  String email = '';

  String password = '';

  String re_password = '';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 1.0,
      width: MediaQuery.of(context).size.width * 1.0,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'SignUp Form',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value!.length < 2) {
                            return "Please enter Correct Username";
                          }
                        },
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.blueAccent,
                            ),
                          ),
                          hintText: 'Name',
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          name = value;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter email";
                          }
                          if (!EmailValidator.validate(email)) {
                            return "Please Enter correct Email";
                          }
                        },
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
                        child: TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 6) {
                              return "Password Length must be greater than 6";
                            }
                          },
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
                      SizedBox(
                        height: 55,
                        child: TextFormField(
                          controller: repasswordController,
                          validator: (value) {
                            if (passwordController.text.toString() !=
                                repasswordController.text.toString()) {
                              return "Password and Confirm Password Does not Match";
                            }
                          },
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
                            hintText: 'ReEnter-Password',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            re_password = value;
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => login()));
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await createNewUser(
                                          emailController.text, re_password)
                                      .then((value) {
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                      builder: (context) {
                                        return VerifyEmail(
                                          email: email,
                                          name: name,
                                        );
                                      },
                                    ));
                                  });

                                  print("Complete");
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
                              }
                            },
                            child: Text('SignUp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
