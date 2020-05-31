import 'package:flutter/material.dart';

Container CircularProgress(){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue),
    ),
  );
}

Container LinearProgress(){
  return Container(
    padding: EdgeInsets.only(bottom: 20),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue),
    ),
  );
}