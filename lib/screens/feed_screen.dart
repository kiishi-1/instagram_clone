import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          "assets/ic_instagram.svg",
          color: primaryColor,
          height: 32,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.messenger_outline))
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("posts").snapshots(),
          //we are not using .doc() (i.e specifying the document we want to access) cus we want to get all the documents in that collection, not just one
          //
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            //we spcify the type of snapshot we want AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot
            //AsyncSnapshot cus AsyncSnapshot<T> class Null safety. Immutable representation of the most recent interaction with an asynchronous computation.
            //QuerySnapshot cus we want to get all the document in the collection. a collection is basically a list
            //Map<String, dynamic> cus inside every document we have data in the Map form i.e with keys and values and we access the value we want using the key
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                //the snapshot is an object that contains the current document or the enter collection of document(depending on the type of snapshot) and their properties and values in the collection at moment in time
                //in snapshot.data!.docs.length(QuerySnapshot), the data(documents) can be null cus there might not be data stored in the database or rather collection
                //we are call .docs cus it will give us the list of documents
                //so essentially, snapshot.data!.docs.length means the no of documents in the collection
                itemBuilder: (context, index) {
                  return PostCard(
                    snap: snapshot.data!.docs[index],
                  );
                });
          }),
    );
  }
}
