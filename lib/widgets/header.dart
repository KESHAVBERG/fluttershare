import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar header({ titleText ,remaoveBackbutton = false}){
  return AppBar(

    automaticallyImplyLeading: remaoveBackbutton?false:true,
    title: Text(titleText,overflow: TextOverflow.ellipsis,),
    backgroundColor: Colors.green[500],
    centerTitle: true,
  );
}