import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: "Search for a user",
          ),
          onFieldSubmitted: ((value) {
            setState(() {
              isShowUsers = true;
            });
          }),
        ),
      ),
      body: isShowUsers
          ? StreamBuilder(
              //streamBuilder listens and responds to change in realtime
              //StreamBuilder works in realtime, we are using FutureBuilder cus we want to get data after an action is performed
              //in this case when we search
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where(
                    "username",
                    isGreaterThanOrEqualTo: searchController.text,
                    //isGreaterThanOrEqualTo as in if the value "username" key holds is greater than or equal to the value searched(used to get/check)
                    //as in equals to nonso(searched value) = nonso(value in the database)
                    //or greater than nonso(searched value) = nonsoc(value in the database)
                    //greater than nonso(searched value) = nonsochi(value in the database)
                  )
                  .snapshots(),
              //where() is used to get the document(s) in collection that has the value of the key use when the value is searched
              //we are not getting data using document name
              //so in the collection we are getting whatever document that has the value we search
              //username in this case is our key, so whatever value (of the key referenced using .where()) is the same as the value we search,
              //the document(s) of the value we will gotten

              //we use uid or Uuid when we want to handle a particular document - DocumentSnapshot
              //we don't use them when we want to use allz(query) the document in the collection - QuerySnapshot

              builder: ((context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: ((context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                      uid: (snapshot.data! as dynamic)
                                          .docs[index]["uid"])));
                                          //the uid in the document of the particlar index
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                                (snapshot.data! as dynamic).docs[index]
                                    ["photoUrl"]),
                            //so we want to get the images of all the users(one or more) that have the value of the key used(in this case searched)
                          ),
                          title: Text((snapshot.data! as dynamic).docs[index]
                              ["username"]),
                          //so we want to get the usernames of all the users(one or more) that have the value of the key used(in this case searched)
                        ),
                      );
                    }));
              }),
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection("posts").get(),
              builder: ((context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.6),
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                          (snapshot.data! as dynamic).docs[index]["postUrl"]);
                    });
              })),
    );
  }
}
