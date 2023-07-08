import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../profile/profile.dart';

class MyHistory extends StatefulWidget {
  const MyHistory({super.key});

  @override
  State<MyHistory> createState() => _MyHistoryState();
}

class _MyHistoryState extends State<MyHistory> {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Purchased History"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(uid)
              .collection("Purchased")
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
                child: Text("No History !"),
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
                                            snapshot.data!.docs[index]["Id"];
                                        await FirebaseFirestore.instance
                                            .collection("Users")
                                            .doc(uid)
                                            .collection("Purchased")
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
                          snapshot.data!.docs[index]["ImageUrl"][0]),
                    ),
                    title: Text(
                      snapshot.data!.docs[index]["Name"],
                    ),
                    subtitle: Text("Rs.${snapshot.data!.docs[index]["Price"]}"),
                    trailing: Text(
                      DateFormat.yMMMd().format(
                        snapshot.data!.docs[index]['Date'].toDate(),
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
