import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future getUserData(String name, String currentUserEmail) async {
  try {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var gettoken = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance.collection("Users").doc(uid).set({
      "Name": name,
      "Email": currentUserEmail,
      "id": uid,
      "Bids": [],
      "Token": gettoken,
      "Posts": [],
      "Date": DateTime.now(),
    });
  } catch (e) {
    print(e.toString());
  }
}

Future createNewUser(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  } catch (e) {
    print(e.toString());
  }
}
