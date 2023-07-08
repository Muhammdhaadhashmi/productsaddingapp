import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
    _startingbidController.dispose();
  }

  bool loading = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _startingbidController = TextEditingController();
  final _ref = FirebaseFirestore.instance.collection('products');
  final _auth = FirebaseAuth.instance;
  String? email;
  var userid = FirebaseAuth.instance.currentUser!.uid;
  List<XFile>? _imageFiles = [];

  Future<void> _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _imageFiles = pickedImages;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final User? user = _auth.currentUser;

    if (user != null) {
      email = user.email;
      print('User email: $email');
    } else {
      print('No user currently signed in.');
    }
  }

  Future<void> _submitForm() async {
    var uuid = Uuid();
    var id = uuid.v1();
    List postId = [];
    postId.add(id);
    var userid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      loading = true;
    });
    final isValid = _formKey.currentState?.validate() ?? false;

    if (isValid) {
      final name = _nameController.text.trim();
      final description = _descController.text.trim();
      final startBid = int.parse(_startingbidController.text.trim());
      await FirebaseFirestore.instance.collection("Users").doc(userid).update({
        "Posts": FieldValue.arrayUnion(postId),
      });
      var gettoken = await FirebaseMessaging.instance.getToken();
      await _ref
          .doc(id)
          .set({
            'name': name,
            'post_id': id,
            'seller_id': userid,
            'description': description,
            "token": gettoken,
            'start_bid': startBid,
            'current_bid': startBid,
            'users_bids': [],
            'seller_email': email,
            "date": DateTime.now(),
          })
          .then((value) => print('Value Added'))
          .onError((error, stackTrace) => print(error.toString()));

      if (_imageFiles?.isNotEmpty ?? false) {
        final List<String> imageUrls = [];

        for (final imageFile in _imageFiles!) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}-${imageFile.name}';
          final ref = FirebaseStorage.instance.ref('product_images/$fileName');
          final snapshot = await ref.putFile(File(imageFile.path));
          final url = await snapshot.ref.getDownloadURL();
          imageUrls.add(url);
        }

        await _ref.doc(id).update({'image_urls': imageUrls});
      }
    }
    setState(() {
      loading = false;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sell a Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormField(
                      textController: _nameController,
                      labelText: 'Product Name',
                      keyboardType: TextInputType.text),
                  FormField(
                      textController: _descController,
                      keyboardType: TextInputType.text,
                      labelText: 'Product Description'),
                  FormField(
                      textController: _startingbidController,
                      labelText: 'Starting Bid Price',
                      keyboardType: TextInputType.number),
                  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _pickImages,
                            child: Text('Select Images'),
                          ),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: loading == false
                                ? Text('Submit')
                                : const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                          ),
                        ],
                      )),
                  SizedBox(height: 8),
                  if (_imageFiles?.isNotEmpty ?? false)
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      children: _imageFiles!.map((file) {
                        return Dismissible(
                          key: Key(file.path),
                          child: Stack(
                            children: [
                              Image.file(
                                File(file.path),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: -20,
                                right: 10,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 10,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _imageFiles!.remove(file);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          onDismissed: (direction) {
                            setState(() {
                              _imageFiles!.remove(file);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 16),
                ],
              ),
            )),
      ),
    );
  }
}

class FormField extends StatelessWidget {
  String labelText;
  final keyboardType;
  FormField(
      {super.key,
      required TextEditingController textController,
      required this.keyboardType,
      required this.labelText})
      : _textController = textController;

  final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
          controller: _textController,
          keyboardType: keyboardType,
          decoration: InputDecoration(
              hintText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              )),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Enter Valid Value';
            }
          }),
    );
  }
}
