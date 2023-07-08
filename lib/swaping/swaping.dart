import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../profile/profile.dart';

class SwapingPage extends StatefulWidget {
  const SwapingPage({super.key});

  @override
  State<SwapingPage> createState() => _SwapingPageState();
}

class _SwapingPageState extends State<SwapingPage> {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Swapping Products"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(uid)
              .collection("Swap Products")
              .snapshots(),
          builder: ((context, snapshot) {
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
            } else if (snapshot.data!.docs.length == 0) {
              return const Center(
                child: Text("No Swapping Products!"),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  return ListTile(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 100.0,
                                    ),
                                    const SizedBox(height: 10.0),
                                    const Text("Do you want to delete ?"),
                                    const SizedBox(height: 10.0),
                                    ElevatedButton(
                                      onPressed: () async {
                                        var docID =
                                            snapshot.data!.docs[index]["id"];
                                        await FirebaseFirestore.instance
                                            .collection("Users")
                                            .doc(uid)
                                            .collection("Swap Products")
                                            .doc(docID)
                                            .delete()
                                            .then((value) => {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) {
                                                      return const ProfilePage();
                                                    }),
                                                  ),
                                                });
                                      },
                                      child: const Center(
                                        child: Text("Delete"),
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          snapshot.data!.docs[index]["Product 1 Image"]),
                    ),
                    title: Text(
                      snapshot.data!.docs[index]["Product 1 Name"],
                    ),
                    subtitle: Text(
                        "Rs.${snapshot.data!.docs[index]["Product 1 Price"]}"),
                    trailing: Text(
                      DateFormat.yMMMd().format(
                        snapshot.data!.docs[index]['DateTime'].toDate(),
                      ),
                    ),
                  );
                }));
          })),
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
