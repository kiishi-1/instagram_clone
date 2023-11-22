import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    String res = "some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage("Post", file, true);

      //uuid is used to generate a unique identifier
      //it provides you with two functions when we initialize it v1 and v4
      //v1 creates a unique identifer based on the time, sp it'll give us a unique id everytime. so we don't worry about having the same id

      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        postId: postId,
        username: username,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );
      _firestore.collection("posts").doc(postId).set(post.toJson());
      //we're creating a collection with "posts" as it's name
      //and we are using the postId(since it's a collection of posts) to tell firebase the post we want to access(since post use the postId for identification) in the collection
      //essentially,the uuid().v1(); generates random ids(names) for different posts
      //then we are setting(passing) the data into the document

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    //we are taking List likes only cus we don't want to make another call to our database
    //to return no of likes cus we already get the data using a StreamBuilder in our feed screen

    try {
      if (likes.contains(uid)) {
        //likes is a list, whenever users likes they add their uid to the list, thereby increasing the list i.e is  the no of likes
        //essentially, the no of likes == the no of uids in the list
        //so if the post has already been liked it means that the user uid is as already in the list(i.e they added their uid to the list)
        //and to unlike they have to remove their uid
        await _firestore.collection("posts").doc(postId).update({
          //we are using update and not set cus for set we have to put in all the values
          //we use update to update a value in the documents in this case the likes array
          "likes": FieldValue.arrayRemove([uid]),
          //FieldValue.arrayRemove([uid]) to remove uid
        });
      } else {
        await _firestore.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayUnion([uid]),
          //FieldValue.arrayUnion([uid]) to add uid
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic) async {
    //String postId so that we know the document(post) we want to access
    //String text contains wha ever we'll type as comment
    //String uid of the to store the comment
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        //we're using a subcollection i.e creating a collection inside the another collection in this case the post collection
        //why? i think cus collections are arrays(Lists) and it as documents where we can store each comments inside a document.
        //hence we use collection(subcollection) cus we can manipulate it easily(that why we are not using a "traditional list").
        _firestore
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .set({
          "profilePic": profilePic,
          "name": name,
          "uid": uid,
          "text": text,
          "commentId": commentId,
          "datePublished": DateTime.now()
          //we are not creating a model for it cus we are only using it in one place
        });
      } else {
        print("Text is empty");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //deleting the post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection("posts").doc(postId).delete();
      //to delete a document from a collection
      //to delete a collection(or delete all the document in the collection) => _firestore.collection("posts").delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection("users").doc(uid).get();
      List following = (snap.data()! as dynamic)["following"];
      //the List of elements inside the "following"(key) list as in "following":[]
      //inside the current user's document which is inside the "users" collection

      if (following.contains(followId)) {
        //so if the List contains the searched users uid, you want to
        await _firestore.collection("users").doc(followId).update({
          "followers": FieldValue.arrayRemove([uid])
          //remove the current user's uid from the searched user followers list as in "followers": []
        });
        //and
        await _firestore.collection("users").doc(uid).update({
          "following": FieldValue.arrayRemove([followId])
          //remove the searched user's uid from the current user's following list as in "following": []
        });
      }else{
        //so if the List doesn't contains the searched users uid, you want to
        await _firestore.collection("users").doc(followId).update({
          "followers": FieldValue.arrayUnion([uid])
          //add the current user's uid to the searched user followers list as in "followers": []
        });
        //and
        await _firestore.collection("users").doc(uid).update({
          "following": FieldValue.arrayUnion([followId])
          //add the searched user's uid to the current user's following list as in "following": []
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
