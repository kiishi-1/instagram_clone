import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/firestore_method.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/utils.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  const PostCard({Key? key, required this.snap}) : super(key: key);
  final snap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot snapShot = await FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.snap["postId"])
          .collection("comments")
          .get();
      //DocumentSnapshot has .docs() after the collection it want to access. .docs is to specify the document you want
      //QuerySnapshot doesn't have it cus it doesn't need it. QuerySnapshot is to get the enter list of document in the collection
      commentLen = snapShot.docs.length;
      //snapShot.docs.length and not snapshot.data.docs.length cus we're not using it in a stream
      //recall .docs gives us the list of documents
      //.docs is different from .docs()
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //header section
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.snap["profImage"],
                    //snap holds snapshot.data!.docs[index] which is the index of a document in the QuerySnaphot. and document is of type map
                    //basically, we are accessing a list of Maps i.e snapshot.data!.docs[index]["profImage"]
                    //Map<String, dynamic> cus inside every document we have data in the Map form i.e with keys and values and we access the value we want using the key
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.snap["username"],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )),
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: ["delete"]
                                        .map((e) => InkWell(
                                              onTap: () async {
                                                FirestoreMethod().deletePost(
                                                    widget.snap["postId"]);
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 16,
                                                ),
                                                child: Text(e),
                                              ),
                                            ))
                                        .toList()),
                              ));
                    },
                    icon: Icon(Icons.more_vert)),
              ],
            ),
          ),
          //image section
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethod().likePost(
                  widget.snap["postId"], user!.uid, widget.snap["likes"]);
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap["postUrl"],
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  //if isLikeAnimating is true let opacity be 1(it will show)
                  // if isLikeAnimating is false let opacity be 0(it will not show)
                  child: LikeAnimation(
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          //like and comment section
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap["likes"].contains(user!.uid),
                smallLike: true,
                //smallLike is true cus this is the like button
                //smallLike is to check if the like button was clicked
                //so if the like button is clicked we can animate
                child: IconButton(
                    onPressed: () async {
                      await FirestoreMethod().likePost(widget.snap["postId"],
                          user.uid, widget.snap["likes"]);
                    },
                    icon: widget.snap["likes"].contains(user.uid)
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          )),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                                  snap: widget.snap,
                                )));
                  },
                  icon: Icon(
                    Icons.comment_outlined,
                    //color: Colors.red,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.send,
                    //color: Colors.red,
                  )),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.bookmark_border,
                      //color: Colors.red,
                    )),
              ))
            ],
          ),
          //description and number of comments
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    "${widget.snap["likes"].length} likes",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: primaryColor,
                          ),
                          children: [
                        TextSpan(
                            text: widget.snap["username"],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text: " ${widget.snap["description"]}",
                          //style: const TextStyle(fontWeight: FontWeight.bold)
                        )
                      ])),
                  //richtext allows us to have multiple text in it and you can arrange them in a row wise order
                  //it's like a row widget for text
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "View all $commentLen comments",
                      style: TextStyle(fontSize: 16, color: secondaryColor),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap["datePublished"].toDate()),
                    style: TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
