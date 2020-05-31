
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  const Comments({Key key, this.postId, this.postOwnerId, this.postMediaUrl}) : super(key: key);


  @override
  _CommentsState createState() => _CommentsState(
      postId: this.postId,
      postOwnerId:this.postOwnerId,
      postMediaUrl:this.postMediaUrl

  );
}


class _CommentsState extends State<Comments> {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  _CommentsState({this.postId, this.postOwnerId, this.postMediaUrl, });
  TextEditingController commentController = TextEditingController();
  showPostComment(){
    return StreamBuilder(
      stream: commentRef
          .document(postId)
          .collection('comments').
      orderBy('timestamp' , descending: true)
          .snapshots(),
      builder: (context , snapshots){
        if(!snapshots.hasData){
          return CircularProgressIndicator();
        }
        List<CommentShow> comment = [];
        snapshots.data.documents.forEach((doc){
          comment.add(CommentShow.fromDocument(doc));
        });
        return ListView(
          children:comment,
        );
      },
    );
  }
  addComment(){
    commentRef.document(postId).collection('comments').add({
      'username':currentUser.username,
      'comment':commentController.text,
      'timestamp':timestamp,
      'avatarUrl':currentUser.photoUrl,
      'userId':currentUser.id,
    });
  bool postOwnerComment = currentUser.id != postOwnerId;
  if(postOwnerComment){
    activityRef.document(postOwnerId).collection('feedItems').add({
      'type':'comment',
      'username':currentUser.username,
      'comment':commentController.text,
      'userprofileimg':currentUser.photoUrl,
      'userid':currentUser.id,
      'mediaUrl':postMediaUrl,
      'postId':postId,
      'timestamp':timestamp,
    });
  }
  commentController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(titleText: 'comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: showPostComment(),
          ),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'add a comment ',
              ),
            ),
            trailing: OutlineButton(
              child: Text('post'),
              onPressed:addComment,
            ),
          )
        ],
      ),
    );
  }
}
class CommentShow extends StatelessWidget {
  final String  comments,username , userUrl, avatarUrl;
  final Timestamp timestamp;

  const CommentShow({  this.comments, this.username, this.userUrl, this.avatarUrl, this.timestamp});
factory CommentShow.fromDocument(doc){
  return CommentShow(
    username: doc['username'],
    comments: doc['comment'],
    avatarUrl: doc['avatarUrl'],
    userUrl: doc['userId'],
    timestamp: doc['timestamp'],
  );
}
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
    ListTile(
    leading: CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(avatarUrl),
    ),
    title: Text(comments),
    subtitle: Text(timeago.format(timestamp.toDate())),
    ),
        Divider(height: 2,)
      ],
    );
  }
}