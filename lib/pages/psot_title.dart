import 'package:flutter/material.dart';
import 'package:fluttershare/pages/post.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/widgets/chached_image_widget.dart';

class PostTitle extends StatefulWidget {
  final Post post;

  const PostTitle({Key key, this.post}) : super(key: key);
  @override
  _PostTitleState createState() => _PostTitleState();
}

class _PostTitleState extends State<PostTitle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => PostScreen(
            postId: widget.post.postId,
            userId: widget.post.owenerId,
          )
        ));
      },
      child:cachedNetworkImage(widget.post.mediaUrl),
    );
  }
}
