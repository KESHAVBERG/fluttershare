

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/model/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/post.dart';
import 'package:fluttershare/pages/seach.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class TimeLine extends StatefulWidget {
  final User currentUser;

  const TimeLine({Key key, this.currentUser}) : super(key: key);
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {

  List<Post> post;
  List<String> followingLit;


@override
  void initState() {
  super.initState();
  getTineLine();
  getFollowing();
}
  getFollowing()async{
 QuerySnapshot snapshot =  await followingRef.document(currentUser.id)
    .collection('userfollowing')
      .getDocuments();
  setState(() {
    followingLit = snapshot.documents.map((doc){
      doc.documentID;
    }).toList();
  });
  }

getTineLine() async{
 QuerySnapshot snapshot =  await timeLineRef
     .document(widget.currentUser.id)
     .collection('timelinePost')
      .orderBy('timestamp' , descending: true)
     .getDocuments();
  List<Post> posts= snapshot.documents.map((doc) =>Post.fromDocument(doc)).toList();
  setState(() {
    this.post = posts;
  });
}


  buildTimeLine(){
  if(post == null){
    return CircularProgressIndicator();
  }else if(post.isEmpty){
    return buildUsersToFollow();
  }else {
    return ListView(children: post,);

  }
  }
  buildUsersToFollow(){

  return StreamBuilder(
    stream: userref.orderBy('timestamp' , descending: true).
      limit(20).snapshots(),
    builder: (context , snapshot){
    if(!snapshot.hasData){
    return CircularProgressIndicator();
    }
    List<UserResult> userResults = [];
    snapshot.data.documents.forEach((doc){
    User user = User.fromDocument(doc);
    final bool isAuthUser = currentUser.id == user.id;
    final bool isFollowing = followingLit.contains(user.id);
      if(isAuthUser){
      return;
      }else if(isFollowing){
        return;
      }else{
        UserResult userResult = UserResult(user:user);
        userResults.add(userResult);
      }
      });
    return snapshot!=null?  Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.person),
                SizedBox(width: 10,),
                Text('Follow')
              ],
            ),
          ),
          Column(children: userResults,)
        ],
      ),
    ):Text('');
     },
  );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(titleText: 'flutter share'),
      body: RefreshIndicator(onRefresh:() =>getTineLine() ,
        child: buildTimeLine(),
      )

    );
  }
}
