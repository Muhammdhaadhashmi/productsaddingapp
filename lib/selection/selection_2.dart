import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard.dart';
import '../notification/notification.dart';

class SelectionTwoPage extends StatefulWidget {
  dynamic pro1Name;
  dynamic pro1Image;
  dynamic pro1Price;
  dynamic proData2;
  dynamic pro1ID;
  dynamic pro1token;
  SelectionTwoPage({
    required this.pro1Name,
    required this.pro1Image,
    required this.pro1Price,
    required this.proData2,
    required this.pro1token,
    required this.pro1ID,
  });

  @override
  State<SelectionTwoPage> createState() => _SelectionTwoPageState();
}

class _SelectionTwoPageState extends State<SelectionTwoPage> {
  @override
  Widget build(BuildContext context) {
    LocalNotificationService _localNotificationService =
        LocalNotificationService();
    var num1 = int.tryParse(widget.pro1Price.replaceAll(RegExp(r'[^0-9]'), ''));
    var num2;
    var id = FirebaseAuth.instance.currentUser!.uid;
    var total;
    setState(() {
      num2 = widget.proData2["current_bid"];
      total = (num1! - num2).abs();
    });
    print("$num1 is num1 and $num2");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Details of Swapping"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.pro1Image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        image: NetworkImage(widget.proData2["image_urls"][0]),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Name :",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.pro1Name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Price :",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.pro1Price,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Name :",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.proData2["name"],
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Price :",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.proData2["current_bid"].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          ListTile(
            title: const Text(
              "You will Pay :",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              "$total",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 100.0,
                        ),
                        SizedBox(height: 10.0),
                        Text("Are you sure to swapping with this product ?"),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _localNotificationService.sendPushMessage(
                                    "${widget.pro1Name} is swapping with ${widget.proData2["name"]}",
                                    "Swapping !",
                                    widget.pro1token);
                                await FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(id)
                                    .collection("Swap Products")
                                    .doc(widget.pro1ID)
                                    .set({
                                  "Product 1 Name": widget.pro1Name,
                                  "Product 1 Price": widget.pro1Price,
                                  "Product 1 Image": widget.pro1Image,
                                  "id": widget.pro1ID,
                                  "DateTime": DateTime.now(),
                                });
                                await FirebaseFirestore.instance
                                    .collection("products")
                                    .doc(widget.proData2["post_id"])
                                    .delete();
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
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
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return Dashboard();
                                }));
                              },
                              child: Text("Accept"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
        },
        child: const Center(
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
