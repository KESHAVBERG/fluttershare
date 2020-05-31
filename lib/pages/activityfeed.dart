
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;
class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {

  getActivityFeed() async{
  QuerySnapshot snapshot =   await activityRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp' , descending: true)
        .limit(20).getDocuments();
  List<ActivityFeedItem> feeditem = [];
  snapshot.documents.forEach(( doc){
    feeditem.add( ActivityFeedItem.fromDocument(doc));
  });
  return feeditem;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(titleText: 'activity feed'),
      body:Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return CircularProgressIndicator();
            }
            return ListView(
              children: snapshot.data,
            );

          },
        ),
      ),
    );
  }
}
Widget mediaProvider;
String activityProvider;
class ActivityFeedItem extends StatelessWidget {
  final String mediaUrl;
  final String postId;
  final String type;
  final String userid;
  final String username;
  final String commentData;
  final String userProfileImage ;
  final Timestamp timestamp;

  const ActivityFeedItem({Key key,this.userProfileImage,this.commentData, this.mediaUrl, this.postId, this.type, this.userid, this.username, this.timestamp}) : super(key: key);
  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc){
     return ActivityFeedItem(
       mediaUrl: doc['mediaUrl'],
       postId: doc['postId'],
       timestamp: doc['timestamp'],
       username: doc['username'],
       userid: doc['userid'],
       type: doc['type'],
       commentData: doc['comment'],
       userProfileImage: doc['userprofileimg'],
     );
   }
   configureMediaPreview(context){
    if(type == 'comment' || type == 'like'){
      mediaProvider = GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context)=>PostScreen(
              postId: postId,
              userId: userid,
            )
          ));
        },
        child: Container(
          height: 50,
            width: 50,
          decoration: BoxDecoration(
            image: DecorationImage(image: CachedNetworkImageProvider(mediaUrl))
          ),
        ),
      );

    }else{
      mediaProvider =  Text('like');
    }
    //******************************
    if(type == 'like'){
      activityProvider = 'liked you';
    }else if(type == 'comment'){
      activityProvider ='Repiled:$commentData';
    }else if(type == 'follow'){
      activityProvider = 'is following you';
    }else{
      return Text('');
    }
   }
  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
        child: ListTile(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => Profile(
                profileId: userid,
              )
            ));
          },
          title:
          RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: username,
                  style: TextStyle(fontWeight: FontWeight.bold)
                ),
                TextSpan(
                  text: '$activityProvider',
                  style: TextStyle(
                    color: Colors.grey[700]
                  )
                ),
              ]
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImage),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
trailing: mediaProvider,
        ),

      ),
    );
  }
}
//showProfile(BuildContext context, {String profileId}){
//  Navigator.push(context, MaterialPageRoute(
//    builder: (context) => Profile(
//      profileId: profileId,
//    )
//  ));
//}