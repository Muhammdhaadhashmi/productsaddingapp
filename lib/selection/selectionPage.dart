import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:productsellingapp/selection/selection_2.dart';
import 'package:shimmer/shimmer.dart';

class SelectionPage extends StatefulWidget {
  dynamic pro1Name;
  dynamic pro1Image;
  dynamic pro1Price;
  dynamic pro1ID;
  dynamic pro1token;
  SelectionPage({
    required this.pro1Name,
    required this.pro1Image,
    required this.pro1token,
    required this.pro1Price,
    required this.pro1ID,
  });
  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  var uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Select One Item"),
      ),
      body: Column(
        children: [
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    return SelectionTwoPage(
                                      pro1token: widget.pro1token,
                                      pro1Name: widget.pro1Name,
                                      pro1Image: widget.pro1Image,
                                      pro1Price: widget.pro1Price,
                                      pro1ID: widget.pro1ID,
                                      proData2: snapshot.data!.docs[index],
                                    );
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
          ),
        ],
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
