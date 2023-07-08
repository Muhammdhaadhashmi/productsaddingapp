import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../desc_screen.dart';
import '../history/history.dart';
import '../mybids/mybids.dart';
import '../swaping/swaping.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var email = FirebaseAuth.instance.currentUser!.email;
  String username = "";
  var userdata = {};
  List bids = [];
  var uid = FirebaseAuth.instance.currentUser!.uid;
  Future snapData() async {
    try {
      var usersD =
          await FirebaseFirestore.instance.collection("Users").doc(uid).get();

      userdata = usersD.data()!;
      setState(() {
        username = userdata["Name"];
        bids = userdata["Bids"];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    snapData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blueAccent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(
                          "https://cdn-icons-png.flaticon.com/512/3378/3378424.png"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "$email",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const MyBids()));
              },
              title: const Text("View Bids"),
              leading:
                  const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
                size: 20,
              ),
              subtitle:
                  const Text("View where your bids are still in progress"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SwapingPage()));
              },
              title: const Text("Swapping Products"),
              leading:
                  const Icon(Icons.change_circle_outlined, color: Colors.blue),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
                size: 20,
              ),
              subtitle: const Text("View your swpping products"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyHistory()));
              },
              title: const Text("History"),
              leading: const Icon(Icons.timer_outlined, color: Colors.blue),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
                size: 20,
              ),
              subtitle: const Text("View purchased history"),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Your Posts",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("products")
                  .where("seller_id", isEqualTo: uid)
                  .snapshots(),
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
                            crossAxisCount: 2, childAspectRatio: 0.70),
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
                                          token: snapshot.data!.docs[index]
                                              ['token'],
                                          images: snapshot.data!.docs[index]
                                              ['image_urls'],
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
                                          docId: snapshot
                                              .data!.docs[index].reference.id);
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
                                    InkWell(
                                      onTap: () async {
                                        await FirebaseFirestore.instance
                                            .collection("products")
                                            .doc(snapshot.data!.docs[index]
                                                ['post_id'])
                                            .delete();
                                        bids.remove(snapshot.data!.docs[index]
                                            ['post_id']);
                                        showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 100.0,
                                                      ),
                                                      SizedBox(height: 10.0),
                                                      Text(" Successful!"),
                                                    ],
                                                  ),
                                                ));
                                      },
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
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
