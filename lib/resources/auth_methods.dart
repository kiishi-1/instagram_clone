import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/storage_methods.dart';
import 'package:instagram_clone/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get User Details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    // print(currentUser);
    // print(currentUser.uid);
    // print(currentUser.displayName);
    DocumentSnapshot snap =
        await _firestore.collection("users").doc(currentUser.uid).get();

    return model.User.fromSnap(snap);

    //or
    // return model.User(
    // email: snap["email"], or snap.data() as Map<String, dynamic>["email"]
    // uid: snap["uid"],
    // photoUrl: snap["photoUrl"],
    // username: snap["username"],
    // bio: snap["bio"],
    // followers: snap["followers"],
    // following: snap["following"],
    // );
    //but every time we return(use) model.User we'll have to fill every property
  }

  //sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "some error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        //so the file is passed into the uploadImageToStorage() fn, which sends it to the firebase storage
        //"profilePics" is the childName
        String photoUrl = await StorageMethods()
            .uploadImageToStorage("profilePics", file, false);
        //when the image is passed in the firebase Storage and the download url is returned(gotten),
        //it is then passed into the photoUrl varable
        //photoUrl is of type String cus the download url is obviously of type String
        //photurl is then passed into the document specified(using the users ID i.e uid)

        //add user to our database
        model.User user = model.User(
            username: username,
            uid: cred.user!.uid,
            email: email,
            bio: bio,
            followers: [],
            following: [],
            photoUrl: photoUrl);
        _firestore.collection("users").doc(cred.user!.uid).set(user.toJson());
        //we're creating a collection with "users" as it's name
        //and we are using the users uid to tell firebase the document we want to access(since documents use the user uid for identification) in the collection
        //essentially we are using the uids to  name  the documents
        //then we are setting(passing) the data into the document

        //or
        // await _firestore.collection("users").add({
        //   "username": username,
        //   "uid": cred.user!.uid,
        //   "email": email,
        //   "bio": bio,
        //   "followers": [],
        //   "following": []
        // });
        res = "success";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //logging in user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
