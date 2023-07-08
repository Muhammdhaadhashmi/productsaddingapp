import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:productsellingapp/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import 'Product.dart';
import 'desc_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _textEditingController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final firestore =
      FirebaseFirestore.instance.collection('products').snapshots();

  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
  }

  _signOut() async {
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            InkWell(
                onTap: () async {
                  var gettoken = await FirebaseMessaging.instance.getToken();
                  _signOut();
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SplashScreen();
                    },
                  ));
                  log(gettoken!);
                },
                child: Icon(Icons.logout))
          ],
          title: const Text('Auction and Swapping System'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: firestore,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.red,
                    ),
                  );
                }

                return Expanded(
                  child: GridView.builder(
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 0.73),
                    itemBuilder: (context, index) {
                      if (index == snapshot.data!.docs.length) {
                        _buildProgressIndicator();
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return DescScreen(
                                          images: snapshot.data!.docs[index]
                                              ['image_urls'],
                                          token: snapshot.data!.docs[index]
                                              ['token'],
                                          name: snapshot
                                              .data!.docs[index]['name']
                                              .toString(),
                                          description: snapshot
                                              .data!.docs[index]['description']
                                              .toString(),
                                          current_bid: snapshot
                                              .data!.docs[index]['current_bid']
                                              .toString(),
                                          email: snapshot.data!.docs[index]
                                              ['seller_email'],
                                          docId: snapshot.data!.docs[index]
                                              ["post_id"]);
                                    },
                                  ));
                                },
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        snapshot
                                            .data!.docs[index]['image_urls'][2]
                                            .toString(),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                snapshot.data!.docs[index]['name'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                snapshot.data!.docs[index]['description']
                                    .toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat.yMMMd().format(
                                        snapshot.data!.docs[index]['date']
                                            .toDate(),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "Rs.${snapshot.data!.docs[index]['current_bid'].toString()}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
