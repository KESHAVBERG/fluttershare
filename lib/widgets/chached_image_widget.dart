
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

cachedNetworkImage(String mediaUrl){
  return CachedNetworkImage(
    imageUrl: mediaUrl,
placeholder: (context , url){
      return CircularProgressIndicator();
},
    errorWidget:( context, url , error){
      return Icon(Icons.error);
    },
  );
}