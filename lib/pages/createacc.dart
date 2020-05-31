import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String userName;
  final _formkey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // for button
  sumitted(){
    SnackBar snackBar = SnackBar(content: Text('welcome $userName '),);
    _scaffoldKey.currentState.showSnackBar(snackBar);
    if(_formkey.currentState.validate()){
      _formkey.currentState.save();
      Timer(Duration(seconds: 2),(){
        Navigator.pop(context , userName);
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(titleText: 'create profile',remaoveBackbutton: true),
      body:ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(top: 10),
            child: Center(child: Text(('selcte your user name')),),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key:  _formkey,
              autovalidate: true,
              child: TextFormField(
                validator: (val){
                  if(val.trim().length<3|| val.isEmpty){
                    return 'too short';
                  }else if(val.length>12){
                    return 'too long';

                  }else{
                    return null;
                  }
                },
                onSaved: (val) =>userName =val  ,
                decoration: InputDecoration(
                  labelText: 'username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  hintText: 'atlest 5 chars'
                ),
              ),
            ),
          ),
          FlatButton(
            onPressed: sumitted,
            child: Text('submit'),
          )
        ],
      ),
    );
  }
}
