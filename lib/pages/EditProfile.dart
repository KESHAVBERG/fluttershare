import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/model/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  const EditProfile({Key key, this.currentUserId}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  User user;
  TextEditingController displayNameEditController = TextEditingController();
  TextEditingController bioEditController = TextEditingController();
 bool _disNameValid = true;
 bool _bioNameValid = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }
  getUser() async{
    setState(() {
      isLoading = true;
    });
    final DocumentSnapshot doc =await userref
        .document(widget.currentUserId)
        .get();
    user = User.fromDocument(doc);
    displayNameEditController.text = user.displayname;
    bioEditController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }
  /// function for formfield
  Column buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Display Name',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20
          ),
        ),
        TextField(
          controller: displayNameEditController,
          decoration: InputDecoration(
            errorText: _disNameValid?null:'display must greater thsn 3 ',
            hintText: 'update display name'
          ),
        )
      ],
    );
  }
  Column buildBioField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'bio',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20
          ),
        ),
        TextField(
          controller: bioEditController,
          decoration: InputDecoration(
            errorText: _bioNameValid?null:'bio too long',
              hintText: 'update bio '
          ),
        )
      ],
    );
  }
  updateProfile(){
  setState(() {
    displayNameEditController.text.trim().length<3||
        displayNameEditController.text.trim().isEmpty?
        _disNameValid = false: _disNameValid = true;
    bioEditController.text.trim().length>100?
        _bioNameValid = false:_bioNameValid = true;
  });
  if(_disNameValid  && _bioNameValid){
    userref.document(widget.currentUserId).updateData({
     'displayname':displayNameEditController.text,
     'bio':bioEditController.text
    });
  SnackBar snackBar = SnackBar(content: Text('profile updated'),);
  _scaffoldKey.currentState.showSnackBar(snackBar);

  }
  }
  logout() async{
   await googleSignIn.signOut();
   Navigator.push(context, MaterialPageRoute(
     builder: (context) => Home()
   ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(' Edit Profile ',
        style: TextStyle(
          color: Colors.black,
          fontSize: 25
        ),),
        actions: <Widget>[
          IconButton(

            icon: Icon(Icons.check,color: Colors.blue,),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 40,
              backgroundImage:CachedNetworkImageProvider(currentUser.photoUrl),
            ),
          ),
          SizedBox(height: 10.0,),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child:buildDisplayNameField(),
          ),
          SizedBox(height: 10.0,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: buildBioField(),
          ),
          Container(
            alignment: Alignment.center,
            child: FlatButton(
              onPressed: updateProfile,
              color: Colors.grey,
              child: Text('update',style: TextStyle(
                color: Colors.black,
              ),),
            ),
          ),
          FlatButton.icon(
            onPressed: logout,
            icon: Icon(Icons.cancel , color: Colors.red,),
            label: Text('log out',style: TextStyle(
              color: Colors.red,
            ),),
          )
        ],
      ),
    );
  }
}
