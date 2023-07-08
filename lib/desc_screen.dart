import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:productsellingapp/selection/selectionPage.dart';

import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_image_screen.dart';
import 'notification/notification.dart';

class DescScreen extends StatefulWidget {
  final images;
  String name;
  final description;
  final current_bid;
  final email;
  String token;
  dynamic docId;
  DescScreen(
      {super.key,
      required this.images,
      required this.name,
      required this.token,
      required this.description,
      required this.current_bid,
      required this.email,
      required this.docId});

  @override
  State<DescScreen> createState() => _DescScreenState();
}

class _DescScreenState extends State<DescScreen> {
  LocalNotificationService _localNotificationService =
      LocalNotificationService();
  int _currentIndex = 0;
  String? username;
  final _ref = FirebaseFirestore.instance.collection('products');
  final _usersref = FirebaseFirestore.instance.collection('Users');
  TextEditingController controller = TextEditingController();
  var id = FirebaseAuth.instance.currentUser!.uid;
  var currentEmail = FirebaseAuth.instance.currentUser!.email;
  late String newbid;
  bool _loading = false;
  List postId = [];
  final _auth = FirebaseAuth.instance;
  String userEmail = "";
  void getCurrentUserEmail() async {
    final userEmail = await _auth.currentUser!.email.toString();
    print(userEmail);
  }

  @override
  void initState() {
    super.initState();
    newbid = widget.current_bid;
    getCurrentUserEmail();
  }

  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200, // card height
                  child: PageView.builder(
                    itemCount: widget.images.length,
                    controller: PageController(viewportFraction: 0.7),
                    onPageChanged: (int index) =>
                        setState(() => _currentIndex = index),
                    itemBuilder: (_, i) {
                      return Transform.scale(
                        scale: i == _currentIndex ? 1 : 0.9,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailImage(
                                      image: widget.images[_currentIndex]
                                          .toString()),
                                ));
                          },
                          child: Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Image.network(
                              widget.images[_currentIndex].toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs.${widget.current_bid}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isExpanded = true;
                      });
                    },
                    child: Container(
                      height: isExpanded ? 150 : 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isExpanded ? Colors.white : Colors.blue,
                      ),
                      child: isExpanded == false
                          ? const Center(
                              child: Text(
                                'Enter your Bid',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    height: isExpanded ? 70 : 0,
                                    child: TextFormField(
                                      controller: controller,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              signed: true, decimal: true),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your bid',
                                        border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      if (int.parse(controller.text) >
                                          int.parse(widget.current_bid)) {
                                        postId.add(id);
                                        _loading = true;
                                        setState(() {});
                                        await _ref.doc(widget.docId).update({
                                          'seller_email': userEmail.toString(),
                                          'current_bid': int.parse(
                                              controller.text.toString()),
                                          "users_bids":
                                              FieldValue.arrayUnion(postId),
                                        });
                                        setState(() {
                                          newbid = controller.text.toString();
                                          _loading = false;
                                        });
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
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: 100.0,
                                                      ),
                                                      SizedBox(height: 10.0),
                                                      Text(
                                                          "Please enter bid higher"),
                                                    ],
                                                  ),
                                                ));
                                      }
                                    },
                                    child: _loading == true
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : Text('Update Bid'))
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    if (currentEmail != widget.email) {
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
                                    Text("Are you sure to accept bid ?"),
                                    SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await _localNotificationService
                                                .sendPushMessage(
                                                    "$currentEmail accept the bid",
                                                    "Bid Accepted !",
                                                    widget.token);
                                            await FirebaseFirestore.instance
                                                .collection("products")
                                                .doc(widget.docId)
                                                .delete();
                                            await FirebaseFirestore.instance
                                                .collection("Users")
                                                .doc(id)
                                                .collection("Purchased")
                                                .doc(widget.docId)
                                                .set({
                                              "ImageUrl": widget.images,
                                              "Name": widget.name,
                                              "Price": widget.current_bid,
                                              "Description": widget.description,
                                              "Date": DateTime.now(),
                                              "Id": widget.docId,
                                            });

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
                                                          SizedBox(
                                                              height: 10.0),
                                                          Text(
                                                              "Thanks for Accept!"),
                                                        ],
                                                      ),
                                                    ));
                                          },
                                          child: Text("Accept"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 100.0,
                                    ),
                                    SizedBox(height: 10.0),
                                    Text("You cannot buy this product"),
                                  ],
                                ),
                              ));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue,
                      ),
                      child: const Center(
                        child: Text(
                          "Accept",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    if (currentEmail != widget.email) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return SelectionPage(
                          pro1token: widget.token,
                          pro1ID: widget.docId,
                          pro1Name: widget.name,
                          pro1Image: widget.images[2],
                          pro1Price: widget.current_bid,
                        );
                      }));
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 100.0,
                                    ),
                                    SizedBox(height: 10.0),
                                    Text("You cannot swapping this product"),
                                  ],
                                ),
                              ));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue,
                      ),
                      child: const Center(
                        child: Text(
                          "Swapping",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
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
