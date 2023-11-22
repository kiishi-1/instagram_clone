import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/firestore_method.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);
  final String uid;
  //the uid's that wil be use in the profile screen to get the users documents and posts will be passed in
  //depending on where you're accessing the screen from
  //if you're accessing the screen from the bottom navigation bar, it means you are a user current in(using) the app
  //so the currentUser!.uid will be passed and thats is what will be used in the profile screen
  //but if your accessing the screen from any other place like the search
  //when a user is searched and clicked on(i.e you're navigating to the profile screen), the search users the detail is what is needed
  //then the searched users uid will be passed and used in the profile screen
  //the uid is what we'll use when we search for a user in the search screen
  //so when then user ListTile is selected it'll navigate to the profile screen with the searched uid (which is what is the name of the document holding users data)

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  //userData is of type Map<dynamic, dynamic>
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .get();
      //we're getting the document in the collection("users") that has the uid referenced

      //get post length
      var postSnap = await FirebaseFirestore.instance
          .collection("posts")
          .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          //find every document in the "posts" collection that has the same value of the key referenced("uid")
          //that is equal to or the same as the value given (in our case the currentUser.uid) and then get them(the documents)
          .get();
      postLen = postSnap.docs.length;
      //getting the length of documents in the "post" collection
      userData = userSnap.data()!;
      //we are passing the data inside a document(which is of type Map) into userData
      //userData is of type Map<dynamic, dynamic>
      followers = userSnap.data()!["followers"].length;
      following = userSnap.data()!["following"].length;
      //getting the length of the elements in the value(a List) of both followers and following keys in the "users" collection
      isFollowing = userSnap
          .data()!["followers"]
          .contains(FirebaseAuth.instance.currentUser!.uid);
      //checking if the current user's uid is inside the searched users document (i.e is the followers list as in "followers": [])
      //if our uid is inside, we added it to the searched user's List(follower: []).
      //essentially we are following the searched user
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData["username"]),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData["photoUrl"]),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLen, "post"),
                                    buildStatColumn(followers, "followers"),
                                    buildStatColumn(following, "following"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        //if it the current users profile(uid) in the profile screen
                                        ? FollowButton(
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            text: "Sign Out",
                                            textColor: primaryColor,
                                            function: () async {
                                              await AuthMethods().signOut();
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen(),));
                                            },
                                          )
                                        : isFollowing
                                            //if it is the searched user profile(uid) in the profile screen
                                            //
                                            //if we are following the searched user
                                            ? FollowButton(
                                                backgroundColor: Colors.white,
                                                borderColor: Colors.grey,
                                                text: "Unfollow",
                                                textColor: Colors.black,
                                                function: () async {
                                                  await FirestoreMethod()
                                                      .followUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          userData["uid"]);
                                                  //userData["uid"] represents the searched user uid
                                                  //since we'll be in the searched user profile screen
                                                  setState(() {
                                                    isFollowing = false;
                                                    followers--;
                                                  });
                                                },
                                              )
                                            : FollowButton(
                                                //if we are not following the searched user
                                                backgroundColor: Colors.blue,
                                                borderColor: Colors.blue,
                                                text: "Follow",
                                                textColor: Colors.white,
                                                function: () async {
                                                  await FirestoreMethod()
                                                      .followUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          userData["uid"]);
                                                  //userData["uid"] represents the searched user uid
                                                  //since we'll be in the searched user profile screen
                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
                                              )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userData["username"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData["bio"],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("posts")
                        .where("uid", isEqualTo: widget.uid)
                        .snapshots(),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return GridView.builder(
                          shrinkWrap: true,
                          itemCount: (snapshot.data! as dynamic).docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 1.5,
                                  childAspectRatio: 1),
                          itemBuilder: (context, index) {
                            return Container(
                              child: Image(
                                image: NetworkImage(
                                  (snapshot.data! as dynamic).docs[index]
                                      ["postUrl"],
                                ),
                                fit: BoxFit.cover,
                              ),
                            );
                          });
                    }))
              ],
            ),
          );
  }

  Column buildStatColumn(int number, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
