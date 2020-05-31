import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/model/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/post.dart';
import 'package:fluttershare/pages/psot_title.dart';
import 'package:fluttershare/pages/uplaod.dart';
import 'package:fluttershare/widgets/header.dart';
import 'EditProfile.dart';
/// currentUserId is me

class Profile extends StatefulWidget {
final String profileId;

  const Profile({Key key, this.profileId}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  /// first function buildProfileHeader
  /// second function buildCountColumn
  /// third function buildprofilebutton
  /// fourth function to buildButton
  /// fifth function is editProfile
  /// getProfilePosts is sixth function
  /// build profilePost is seventh function

  final String currentUserId = currentUser?.id;// user id
 bool isLoading = false;
 bool isFollowing = false;
 int postCount = 0;
 int followerCount = 0;
 int followingCount = 0;
 List<Post> posts = [];
 String postOrientation = 'grid';
  
  @override
  void initState(){
    super.initState();
    getProfilePosts();
    getFollower();
    getFollowing();
    checkIfFollowing();
  }
  getFollower() async{
 QuerySnapshot snapshot =    await followerRef.document(widget.profileId)
        .collection('userfollower')
        .getDocuments();
 setState(() {
   followerCount = snapshot.documents.length;
 });
  }
  getFollowing() async{
    QuerySnapshot snapshot = await followingRef
        .document(currentUserId)
        .collection('userfollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }
  checkIfFollowing() async{
   DocumentSnapshot doc =  await followerRef.document(widget.profileId)
        .collection('userfollower')
        .document(currentUserId)
        .get();
   setState(() {
     isFollowing = doc.exists;
   });
  }

  getProfilePosts() async{
    setState(() {
      isLoading = true;
    });
      QuerySnapshot snapshot= await postref.document(widget.profileId)
        .collection('userpost')
        .orderBy('timestamp' , descending: true)
        .getDocuments();
      setState(() {
        isLoading = false;
        postCount = snapshot.documents.length;
        posts = snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();
      });
  }

  Column buildCountColumn(String label , int count){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(color: Colors.grey),
          ),
        )
      ],
    );
  }
  /// function for edit profile
  editProfile(){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => EditProfile(currentUserId:currentUserId)
    ));
  }
  /// function to build button
  Container buildButton({String title , Function function}){
    return Container(
      width: 200,
      height: 30,
      padding: EdgeInsetsDirectional.only(top: 2.0),
      child: FlatButton(
        child: Container(
            alignment: Alignment.center,
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              color: isFollowing?Colors.white:Colors.blue,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color:isFollowing? Colors.blue:Colors.white,
              ),

            ),
            child: Text(title,style: TextStyle(
              color: Colors.amber
            ),)
        ),
        onPressed: function,
      ),
    );
  }
  /// button function
  buildProfileButton(){
    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner){
      return buildButton(
        title: 'Edit Profile',
        function: editProfile,
      );
    }else if (isFollowing){
      return buildButton(
        title: 'unfollow',
        function: handleUnfollow,
      );
    }else if(!isFollowing){
      return buildButton(
        title: 'follow',
        function: handleFollow,
      );
    }
  }
//  handleUnfollow(){
//    setState(() {
//      isFollowing = true;
//    });
//    followerRef.document(widget.profileId)
//        .collection('followers').document(currentUserId)
//        .setData({});
//    /// /// /// ///
//    followingRef.document(currentUserId)
//        .collection('userfollowing')
//        .document(widget.profileId).setData({});
//    /// /// /// ///
//    activityRef.document(widget.profileId)
//        .collection('feedItems')
//        .document(currentUserId)
//        .setData({
//      'type':'follow',
//      'ownerId':widget.profileId,
//      'userId':currentUser.id,
//      'username':currentUser.username,
//      'userprofilephoto':currentUser.photoUrl,
//      'timstamp':timestamp
//    });
//  }
//  handleFollow(){
//    setState(() {
//      isFollowing = false;
//    });
//    followerRef.document(widget.profileId)
//    .collection('followers').document(currentUserId)
//        .delete();
//    /// /// /// ///
//    followingRef.document(currentUserId)
//    .collection('userfollowing')
//    .document(widget.profileId).delete();
//    /// /// /// ///
//    activityRef.document(widget.profileId)
//    .collection('feedItems')
//    .document(currentUserId).delete();
////    .setData({
////      'type':'follow',
////      'ownerId':widget.profileId,
////      'userId':currentUser.id,
////      'username':currentUser.username,
////      'userprofilephoto':currentUser.photoUrl,
////      'timstamp':timestamp
////    });
//  }
  handleUnfollow(){
    setState(() {
      isFollowing = false;
    });
    /// to add follower to the user whom your following
    followerRef
        .document(widget.profileId)
        .collection('userfollower')
        .document(currentUserId)
        .delete();
    /// to add following to me
    followingRef
        .document(currentUserId)
        .collection('userfollowing')
        .document(widget.profileId)
        .delete();
    /// to activity feed to the user
    activityRef
        .document(widget.profileId)
        .collection('feeditems')
        .document(currentUserId).delete();
//        .setData({
//      'type':'follow',
//      'ownerid':widget.profileId,
//      'username':currentUser.username,
//      'userProfilePic':currentUser.photoUrl,
//      'userId':currentUser.id,
//
//
//    });
  }
  handleFollow(){
    setState(() {
      isFollowing = true;
    });
    /// to add follower to the user whom your following
    followerRef
    .document(widget.profileId)
    .collection('userfollower')
    .document(currentUserId)
    .setData({});
    /// to add following to me
    followingRef
    .document(currentUserId)
    .collection('userfollowing')
    .document(widget.profileId)
    .setData({});
    /// to activity feed to the user
    activityRef
    .document(widget.profileId)
    .collection('feeditems')
    .document(currentUserId)
    .setData({
      'type':'follow',
      'ownerid':widget.profileId,
      'username':currentUser.username,
      'userProfilePic':currentUser.photoUrl,
      'userId':currentUser.id,


    });

  }

  buildProfileHeader(){
    return FutureBuilder(
      future: userref.document(widget.profileId).get(),
      builder: (context , snapshot){
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding:EdgeInsets.all(10.0) ,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundImage: CachedNetworkImageProvider(
                        user.photoUrl
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            buildCountColumn('posts' , postCount),
                            buildCountColumn('followers' , followerCount),
                            buildCountColumn('following' , followingCount),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton()
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsetsDirectional.only(top: 10),
                child: Text(user.username,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsetsDirectional.only(top: 10),
                child: Text(user.displayname,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsetsDirectional.only(top: 10),
                child: Text(user.bio,
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 10
                  ),),
              ),

            ],
          ),
        );
      },
    );
  }
 showUserPost(){
    if(postOrientation == 'grid'){
       List<GridTile> gridTitle =[];
      posts.forEach((post){
        gridTitle.add(GridTile(child: PostTitle(post: post,),));
      });
      return
        GridView.count(crossAxisCount: 3,
        shrinkWrap: true,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        children: gridTitle,);

    }else if(posts.isEmpty){
      return Column(
        children: <Widget>[
          Text('No content to show' , style: TextStyle(
            color: Colors.black,fontSize: 15,
            fontWeight: FontWeight.bold
          ),),

        ],
      );
    }
    else if(postOrientation == 'list'){
      return Column(
     children: posts,
    );

    }


  }
  setPostOrientation(String postOrientation){
    setState(() {
      this.postOrientation = postOrientation;
    });
  }
  buildToggleView(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          onPressed:() =>setPostOrientation('grid'),
        ),
        IconButton(
          onPressed:() => setPostOrientation('list'),
          icon: Icon(Icons.list),
        )
      ],
    );
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header( titleText: 'profile'),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          buildProfileHeader(),
          buildToggleView(),
          Divider(height: 0.0,),
          showUserPost()
        ],
      ),
    );
  }
}
