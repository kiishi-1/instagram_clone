import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //we want to store the image in Firebase storage
  //and we want to create folders that will hold the image in the storage
  //we do this so that firebase doesn't override it and in case we want to store multiple images
  //we use FirebaseStorage to store images, videos, and other files

  //adding image to firebase storage
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    //the ref method(.ref()) is a pointer to the file in our storage
    //it could be a reference to a file that already exist or doesn't exist
    //.child() can be a folder that exist or doesn't
    //it's supposed to hold the file we want to end in or the file we're referencing
    //if it exist the file will go into that folder
    //if it does't firebase will create the folder and pass the file in
    //the uid is passed so we can know the user and the document we are accessing (i think)
    //or maybe uid will be used to create a folder (inside the .child()) that will hold the file
    Reference reference =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    //when we uploading the profile pic we used this Reference reference = _storage.ref().child(childName).child(_auth.currentUser!.uid);
    //cus we want to upload one image. so, this is what is happening - we have the first folder that we'll name ourselves(childName)
    //then inside that folder is where we want to put our file(image) and the name of the file(image) will be the user uid


    
    //if we are uploading post to the storage
    //cus we might have multiple post on like for profile pic. a user has one profile pic that's why the user uid is used
    //but for posts, we have to create a unique id for each posts
    if (isPost) {
      //we want to create a unique id
      String id = const Uuid().v1();
       reference = reference.child(id);
      //so what is happening here is this
      //_storage.ref().child(childName).child(_auth.currentUser!.uid).child(id); ,if there is a post or posts.
      //we have a folder that we'll name. inside that folder, we another folder that take the users uid(as it's name).then, inside that folderis where the posts we be
      // and it takes in multiple posts because of that we use
      //Uuid().v1() to generate random unique IDs(basically, names) for each post
    }

    //UploadTask helps us control how the file is being uploaded to the firebase storage
    UploadTask uploadTask = reference.putData(file);
    //with this we have successfully uploaded our file

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    //getDownloadURL() will fetch us the download url of the file thats being uploaded
    //url is always a type String
    //with snap.ref.getDownloadURL() we'll ba able to get the download url that we will save in the firestore database
    //then we'll access it with the network image and display it in the app to the users
    return downloadUrl;
  }
}
