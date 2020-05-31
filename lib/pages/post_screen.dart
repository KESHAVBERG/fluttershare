import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/post.dart';
import 'package:fluttershare/widgets/header.dart';

class PostScreen extends StatefulWidget {
  final String userId,postId;

  const PostScreen({Key key, this.userId, this.postId}) : super(key: key);
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postref
          .document(widget.userId)
          .collection('userpost')
          .document(widget.postId)
          .get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar:header(titleText: post.description,remaoveBackbutton: false) ,
            body:ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
        ],
          ),
          )
        );
      },
    );
  }
}
