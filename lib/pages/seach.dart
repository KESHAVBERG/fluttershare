import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/model/user.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/progess.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search>{
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResult ;
  // function to initate sigin
  handleSubmittion(String qurey){
    Future<QuerySnapshot> user = Firestore.instance
        .collection('users')
        .where('displayname' , isGreaterThanOrEqualTo:qurey )
        .getDocuments();
    setState(() {
      searchResult = user;
    });
  }
  onCleared(){
    searchController.clear();
  }
  //app bar
 AppBar BuildSearchField(){
    return AppBar(
      elevation: 0.0,
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'search',
          prefixIcon: Icon(Icons.account_box,color: Colors.grey,),
          suffix: IconButton(
            onPressed: onCleared,
            icon: Icon(Icons.clear,color: Colors.black,),
          )
        ),
        onFieldSubmitted: handleSubmittion,
      ),
    );
  }
  //body
Container  noContentScreen(){
   final Orientation orientation = MediaQuery.of(context).orientation;
   return Container(
     child: Center(
       child: ListView(
         shrinkWrap: true,
         children: <Widget>[
           Text('no result to show',style: TextStyle(
             color: Colors.black,
             fontSize:orientation == Orientation.portrait? 15:20,
             fontWeight: FontWeight.w600
           ),),
           Text('Enter  username',style: TextStyle(
               color: Colors.grey,
               fontSize: 10,
               fontWeight: FontWeight.w600
           ),),
         ],
       ),
     ),
   );
  }
  // when the user is found or searchresult has some word entered
  resultScreen(){
    return FutureBuilder(
      future: searchResult,
      builder: (context , snapshot){
        if(!snapshot.hasData){CircularProgressIndicator(
          valueColor:AlwaysStoppedAnimation(Colors.blue) ,
        );}
        List<UserResult> resultsofsearch = [];
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          UserResult userResult = UserResult(user: user,);
          resultsofsearch.add(userResult);
        });
        return ListView(
          children:resultsofsearch,
        );
      },
    );
  }
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: BuildSearchField(),
      body:searchResult == null? noContentScreen():resultScreen(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult({this.user});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=>Profile(
                  profileId: user.id,
                )
              ));
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(user.displayname , style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),),
              subtitle: Text(user.username , style: TextStyle(
                color: Colors.grey
              ),),
            ),
          ),
          Divider(height: 2,color: Colors.black,)
        ],
      ),
    );
  }
}
