import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final  datePublished;
  final String postUrl;
  final String profImage;
  final likes;

  const Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.username,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "postId": postId,
        "description": description,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "profImage": profImage,
        "likes": likes
      };

  //take in a documentSnapshot then we return the user model
  static Post fromSnap(DocumentSnapshot snap) {
    print(snap);
    print(snap.data());
    var snapshot = snap.data() as Map<String, dynamic>;
    //or something like this var snapshot = snap["username"]

    return Post(
        description: snapshot["description"],
        uid: snapshot["uid"],
        postId: snapshot["postId"],
        username: snapshot["username"],
        datePublished: snapshot["datePublished"],
        postUrl: snapshot["postUrl"],
        profImage: snapshot["profImage"],
        likes: snapshot["likes"]);

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
