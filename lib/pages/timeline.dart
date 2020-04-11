import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;


  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
 List<Post> posts;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTimeline();
  }

  getTimeline() async {
   QuerySnapshot snapshot =  await timelineRef
    .document(widget.currentUser.id)
    .collection('timelinePosts')
    .orderBy('timestamp',descending: true)
    .getDocuments();
  List<Post> posts = snapshot.documents.map((doc)=> Post.fromDocument(doc)).toList();
  setState(() {
    this.posts = posts;
  });
  }

  buildTimeline(){
    if(posts == null){
      return circularProgress();
    } else if(posts.isEmpty){
      return buildUsersToFollow();
    } else {
      return ListView(
      children: posts,
    );
    }
    
  }

  buildUsersToFollow(){
    return StreamBuilder(
      stream: usersRef.orderBy('timestamp', descending: true)
      .limit(30).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc){
          User user =  User.fromDocument(doc);
        });
      },
    );
  }


  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      )
    );
  }
}
