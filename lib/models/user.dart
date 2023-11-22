import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;

  const User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "photoUrl": photoUrl,
        "email": email,
        "bio": bio,
        "followers": followers,
        "following": following
      };

  //take in a documentSnapshot then we return the user model
  static User fromSnap(DocumentSnapshot snap) {
    // print(snap);
    // print(snap.data());
    var snapshot = snap.data() as Map<String, dynamic>;
    //or something like this var snapshot = snap["username"]

    return User(
        email: snapshot["email"],
        uid: snapshot["uid"],
        photoUrl: snapshot["photoUrl"],
        username: snapshot["username"],
        bio: snapshot["bio"],
        followers: snapshot["followers"],
        following: snapshot["following"]);

    //referencing brew crew
    //UserDataDoc _userDataFromSnapshot(DocumentSnapshot snapshot) {
    // return UserDataDoc(
    //     //uid is gotten when authentication is done
    //     uid: uid,
    //     name: snapshot['name'],
    //     strength: snapshot['strength'],
    //     sugars: snapshot['sugars']);
  }
}
