
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/model/user.dart';
import 'package:fluttershare/pages/activityfeed.dart';
import 'package:fluttershare/pages/createacc.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/seach.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/uplaod.dart';
import 'package:google_sign_in/google_sign_in.dart';

//***********************************************

final GoogleSignIn googleSignIn = GoogleSignIn();
final userref = Firestore.instance.collection('users');
final postref = Firestore.instance.collection('posts');
final commentRef = Firestore.instance.collection('comments');
final activityRef = Firestore.instance.collection('feed');
final followerRef = Firestore.instance.collection('follower');
final followingRef = Firestore.instance.collection('following');
final timeLineRef = Firestore.instance.collection('timeline');
//****************************************************

final StorageReference storageRef = FirebaseStorage.instance.ref();
//**************************************************
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isAuth = false;
  PageController pageController;
  int pageindex = 0;
  //to set the firebase messing or to show push notify
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // =====================for auths
  ///logout
  logout(){
    googleSignIn.signOut();
  }
  login(){
    googleSignIn.signIn();
  }
  // for page view
onchanged(int pageindex){
    setState(() {
      this.pageindex = pageindex ;
    });
}
ontap(int pageindex){
      pageController.animateToPage(

        pageindex,
        duration: Duration(milliseconds: 200),
        curve: Curves.slowMiddle
      );
}
//***************************
 Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
      children: <Widget>[
          TimeLine(currentUser:currentUser),

        ActivityFeed(),
        Upload(currentUser: currentUser,),
        Search(),
        Profile(profileId: currentUser?.id,),
      ],
      controller:pageController ,
      onPageChanged: onchanged,
      physics: NeverScrollableScrollPhysics(),

    ),
bottomNavigationBar: CupertinoTabBar(
  activeColor: Colors.blue,
  currentIndex: pageindex,
  onTap: ontap,
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.access_time)),
    BottomNavigationBarItem(icon: Icon(Icons.favorite)),
    BottomNavigationBarItem(icon: Icon(Icons.file_upload)),
    BottomNavigationBarItem(icon: Icon(Icons.search)),
    BottomNavigationBarItem(icon: Icon(Icons.person)),
  ],
),
    );
  }
//************************************************************
  Scaffold bulidunAuthScreen() {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('FlutterShare', style: TextStyle(
              color: Colors.cyan,
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),),
            FlatButton(
              color: Colors.blue,
              onPressed: () {
                login();
              },
              child: Text('google sign'),
            )
          ],
        ),
      ),
    );
  }
  /// method to handlesigin
  /// this is made aysnc because we get the the error id = null' which can be resolved
  handleSignIn(GoogleSignInAccount account) async{
    if(account !=null){
     await createUser();
      setState(() {
        isAuth = true;
      });
      configurePushNotificaton();
    }else{
      setState(() {
        isAuth = false;
      });
    }
  }
  //******************************************
  configurePushNotificaton(){
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if(Platform.isIOS)getIOSPermission();
    _firebaseMessaging.getToken()
    .then((token){
      userref.document(user.id)//androidNotificationToken same as in the functions
          .updateData({'androidNotificationToken':token});
    });
    _firebaseMessaging.configure(
      //message as same in the functions
//    when the user is not using  onLaunch: (Map<String , dynamic>message) async{},
    onMessage:(Map<String, dynamic>message) async{
      final String recipientId = message['data']['recipient'];
      final String body = message['notification']['body'];
      if(recipientId == user.id){
        print(body);
        SnackBar snackBar = SnackBar(
          content: Text(body , overflow: TextOverflow.ellipsis,),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }


    );
  }
  //*****************************
  getIOSPermission(){
    _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(alert: true)
    );
    _firebaseMessaging
        .onIosSettingsRegistered
        .listen((setting){
      print("${setting}");
    });
  }
  /// function to create acc
  /// *********************************************
  createUser() async{
    final GoogleSignInAccount user  = googleSignIn.currentUser;
    DocumentSnapshot doc = await userref.document(user.id).get();
    if(!doc.exists){
    final username = await  Navigator.push(context, MaterialPageRoute(
        builder: (context) => CreateAccount()
      ));
    // document(user.id)=> create a document with secipic doc id for that user
    userref.document(user.id).setData({
      'id':user.id,
      'username':username,
      'photoUrl':user.photoUrl,
      'email':user.email,
      'displayname':user.displayName,
      'bio':'',
      'timestamp':timestamp,

    });
    // to show the user their own post in their time line
    // make new user as their follower
    await followerRef.document(user.id)
    .collection('userfollower')
    .document(user.id)
    .setData({});
    doc = await userref.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

 @override
  void initState() {
    pageController = PageController();
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account){
      if(account != null){
        setState(() {
          isAuth = true;
        });
      }else{
        setState(() {
          isAuth = false;
        });
      }
    });
    googleSignIn.signInSilently(suppressErrors: false).then((account) => handleSignIn(account));
  }
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : bulidunAuthScreen();
  }


}