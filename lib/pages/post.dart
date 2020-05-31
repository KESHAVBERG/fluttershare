import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/model/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/chached_image_widget.dart';

import 'comments.dart';

class Post extends StatefulWidget {
  final String postId;
  final String username;
  final String owenerId;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  const Post({Key key, this.postId, this.username, this.owenerId, this.location, this.description, this.mediaUrl, this.likes}) : super(key: key);
  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc['postId'],
      username: doc['username'],
      owenerId: doc['ownerId'],
      location: doc['loaction'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['liskes'],

    );
  }

  // function to get and set likes

  int getLikeCounts(likes){
    if(likes == null){
      return 0;
    }
    int count = 0;
    likes.values.forEach((val){
      if(val == true){
        count +=1;
      }
    });
    return count;
  }
  @override
  _PostState createState() => _PostState(
    postId:this.postId,
    owenerId:this.owenerId,
    username :this.username,
    location:this.location,
    description:this.description,
    mediaUrl:this.mediaUrl,
    likes:this.likes,
    likeCount: getLikeCounts(this.likes),

  );

}
class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String username;
  final String owenerId;
  final String location;
  final String description;
  final String mediaUrl;
  bool showHeart = false;
  Map likes;
  int likeCount;
  bool isLiked;

  _PostState({this.postId, this.username, this.owenerId, this.location, this.description, this.mediaUrl , this.likes,this.likeCount});

  buildPostHeader(){
    return FutureBuilder(
      future: userref.document(owenerId).get(),
      builder: (context , snapshot){
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        }
        User user = User.fromDocument(snapshot.data);
        bool isOwnerPost = currentUserId == owenerId;
        return ListTile(
          trailing:isOwnerPost?IconButton(
            icon:Icon(Icons.more_vert) ,
            onPressed: ()=>handleDeletePost(context),
          ):Text(''),

          title: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=> Profile(
                  profileId: user.id//orowenerId,
                )
              ));
            },
              child: Text(user.displayname)),
          subtitle: Text(location),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          ),
        );
      },
    );
  }
  handleDeletePost(BuildContext parentContext){
    return showDialog(context: parentContext,
      builder: (context) {
      return SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
            onPressed: (){
              Navigator.pop(context);
              deletePost();
            },
            child: Text('delete'),
          ),
          SimpleDialogOption(
            child: Text('cancel'),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      );
      }
    );
  }
  // to delete a post the owner Id should be = to currentUserid

  deletePost() async{
     postref.document(owenerId)
         .collection('userpost')
         .document(postId).get()
         .then((doc){
       if(doc.exists){
        doc.reference.delete();
       }
     });
     // now we delete the image
 storageRef.child('post_$postId.jpg').delete();
 // to the the feed
 QuerySnapshot activityFeedSnapshot = await activityRef
     .document(owenerId)
     .collection('feedItems')
     .where('postId',isEqualTo:postId )
     .getDocuments();
 activityFeedSnapshot.documents.forEach((doc){
   if(doc.exists){
     doc.reference.delete();
   }
 });
// to delete the comment
  QuerySnapshot commentSnapshot =await commentRef
    .document(postId)
    .collection('comments')
    .getDocuments();
  commentSnapshot.documents.forEach((doc){
    if(doc.exists){
      doc.reference.delete();
    }
  });
  }
  /// to handle likes
  handleLike(){
    bool _isLiked = likes[currentUserId] == true;
    if(_isLiked){
      postref
          .document(owenerId)
          .collection('userpost')
          .document(postId)
          .updateData({'liskes.$currentUserId':false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -=1;
        isLiked = false;
        likes[currentUserId] = false;
      });

    }else if(!_isLiked){
      postref
          .document(owenerId)
          .collection('userpost')
          .document(postId)
          .updateData({'liskes.$currentUserId':true});
      addLikeToActivityFeed();
      setState(() {
        likeCount +=1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;

      });
      Timer(Duration(milliseconds: 500),(){
        setState(() {
          showHeart = false;
        });
      });
    }
  }
  //++++++++++++++++++++++++++++++
  removeLikeFromActivityFeed(){
    bool notOwner = currentUserId != owenerId;
    if(notOwner){
      activityRef
          .document(owenerId)
          .collection('feedItems')
          .document(postId)
          .get().then((doc){
        if(doc.exists){
          doc.reference.delete();
        }
      });
    }

  }

  addLikeToActivityFeed(){
    bool notOwner = currentUserId != owenerId;
if(notOwner){
  activityRef
      .document(owenerId)
      .collection('feedItems').document(postId).setData({
    'type':'like',
    'username':currentUser.username,
    'userprofileimg':currentUser.photoUrl,
    'userid':currentUser.id,
    'mediaUrl':mediaUrl,
    'postId':postId,
    'timestamp':timestamp,

  });

}

  }
  //******************************
  buildpostImage(){
    return GestureDetector(
      onDoubleTap: handleLike,
      child: Stack(
        children: <Widget>[
          Container(
            child: cachedNetworkImage(mediaUrl),
          ),
          showHeart? Animator(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            tween: Tween(begin: 0.8,end: 1.4),
            builder: (anim) =>Transform.scale(
                scale: anim.value,
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 40,
              ),
            ),
          ):Text('')
        ],
      )
    );
  }

  buildPostFooter(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
      children: <Widget>[
        IconButton(
          onPressed: handleLike,
          icon: Icon(isLiked?Icons.favorite:Icons.favorite_border,color: Colors.pinkAccent,),
        ),

        IconButton(
          onPressed:(){
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => Comments(
                postId: postId,
                postMediaUrl: mediaUrl,
                postOwnerId: owenerId,
              )
            ));
          },
          icon: Icon(Icons.comment, color: Colors.blue,),
        ),

      ],
        ),
      Container(padding: EdgeInsets.only(left: 10),
          child: Text("$likeCount: Likes")),
      Container(padding: EdgeInsets.only(left: 10),
          child: Text(description)),

      ],

    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId]) == true;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
       buildPostHeader(),
       buildpostImage(),
       buildPostFooter(),
      ],
    );
  }
}

