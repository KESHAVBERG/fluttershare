import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
class User{
  final String id;
  final String displayname;
  final String email;
  final String photoUrl;
  final String username;
  final String bio;

  User({this.id, this.displayname, this.email, this.photoUrl, this.username, this.bio});

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      displayname: doc['displayname'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      username: doc['username'],
      bio: doc['bio']

    );
  }





}