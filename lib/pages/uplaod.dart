import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/model/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  const Upload({Key key, this.currentUser}) : super(key: key);
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin<Upload>{
  /// note to noted
  /// first i created to screens one to upload image other when the image is selected
  /// then we created the the function  for upload image that shows the alert dialog
  /// then we created three functions one to take pic other to select on and one to cancel
  /// then we compress the image and there is function to to compress and upload it to firestorage

  File file;
 // to enable and disable button
 bool isUploading = false;
 // for post id
 String postId = Uuid().v4();
 // text edit controller
 TextEditingController captionController = TextEditingController();
 TextEditingController locationController = TextEditingController();


 // function to take a pic
 handleImageTaking() async{
   Navigator.pop(context);
   File file =await ImagePicker.pickImage(source: ImageSource.camera);
   setState(() {
     this.file = file;
   });
 }
// function to select a image
 handleImageSelecting() async{
   Navigator.pop(context);
   File file = await ImagePicker.pickImage(source: ImageSource.gallery);
   setState(() {
     this.file = file;
   });
 }
// altert dialog
 seleteImage(parentcontext){
    return showDialog(context: parentcontext,
    builder: (context){
      return SimpleDialog(
        title: Text('create post'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: handleImageTaking,
            child: Text('take a pic'),
          ),
          SimpleDialogOption(
            onPressed: handleImageSelecting,
            child: Text('select a pic'),
          ),
          SimpleDialogOption(
            child: Text('cancel'),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }
// this as the button and is shown when the image not selected
  Scaffold bulidSplashScreen(){
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('upload a image'),
          FlatButton(
            child: Text('upload'),
            color: Colors.red,
            onPressed: (){seleteImage(context);},
          )
        ],
      ),
    );
  }
  /// function to clear image
 clearImage(){
   setState(() {
     file = null;
   });
 }
 // in this function all we re doing is creating the file path and getting the downloadurl
 Future<String> uploadImage(imageFile)async{
  StorageUploadTask uploadTask =  storageRef
      .child('post_$postId.jpg')
      .putFile(imageFile);
  //
  StorageTaskSnapshot taskSnapshot = await
  uploadTask.onComplete;
  //******************
  String downloadUrl = await
  taskSnapshot.ref.getDownloadURL();
  //***************************
  return downloadUrl;
  }
  // function to upload image to firebase
  uploadImageToFirebase({String mediaUrl ,String location ,String caption }){
   postref.document(widget.currentUser.id)
    .collection('userpost').document(postId)
    .setData({
     'postId':postId,
     'ownerId':widget.currentUser.id,
     'username':widget.currentUser.username,
     'mediaUrl':mediaUrl,
     'description':caption,
     'loaction':location,
     'timestamp':timestamp,
     'liskes':{}
   });
  }
 // function to handle submit
  handleSubmit() async{
   setState(() {
     isUploading = true;
   });
   await compressImage();

   String mediaUrl = await uploadImage(file);
   uploadImageToFirebase(
     mediaUrl: mediaUrl,
     location: locationController.text,
     caption: captionController.text
   );
   captionController.clear();
   locationController.clear();
   setState(() {
     file = null;
     isUploading = false;
     postId = Uuid().v4();
   });

  }
  /// function to compress image
  compressImage() async{
   final tempdir = await getTemporaryDirectory();
   final path = tempdir.path;
   Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
   final compressedImage = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile));
    setState(() {
       file = compressedImage;
    });
  }
 // shows the image and has the text fields
Scaffold buldImageForm(){
   return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.white,
       leading: IconButton(/// button to clear image
         onPressed:clearImage,
         icon: Icon(Icons.arrow_back , color: Colors.black,),
       ),
       title: Text('Add image',style: TextStyle(
         color: Colors.black,
       ),),
       actions: <Widget>[
         FlatButton(
           onPressed:isUploading?null:() =>handleSubmit() ,
           child: Text('post' , style: TextStyle(
             color: Colors.blue,
           ),),
         )
       ],
     ),
     body: ListView(
       children: <Widget>[
         /// container to show the image
         Container(
           padding: EdgeInsets.symmetric(horizontal: 10),
           height: 250,
           width: MediaQuery.of(context).size.width,
           child: Center(
             child: Container(
               decoration: BoxDecoration(
                 image: DecorationImage(
                   fit: BoxFit.fill,
                   image: FileImage(file),
                 )
               ),
             ),
           ),
         ),
         /// form filed to enter the caption
         SizedBox(height: 5,),
         ListTile(
           leading: CircleAvatar(
             backgroundImage: CachedNetworkImageProvider(
               widget.currentUser.photoUrl
             ),
           ),
           title: Container(
             child: TextField(
               controller: captionController,
               decoration: InputDecoration(
                 hintText: ' enter the caption '
               ),
             ),
           ),
         ),
         ///
         Divider(height: 2,),
         ///to show the location
         ListTile(
           leading: Icon(Icons.location_on,color: Colors.black,),
           title: Container(
             child: TextField(
               controller: locationController,
               decoration: InputDecoration(
                 hintText: 'location'
               ),
             ),
           ),
         ),
         Container(
           alignment: Alignment.center,
           child: Center(
             child: RaisedButton.icon(
               icon: Icon(Icons.location_on),
               label: Text('select loaction'),
               onPressed:geoLocation,

             ),
           ),
         )
       ],
     )
   );
 }
  geoLocation() async {
   Position position = await Geolocator()
       .getCurrentPosition(
     desiredAccuracy: LocationAccuracy.best
   );
   List<Placemark> plackmer = await Geolocator()
       .placemarkFromCoordinates(position.latitude, position.longitude);

   Placemark placemark = plackmer[0];
   String completeAddress = '${placemark.locality} , ${placemark.country}';
   locationController.text = completeAddress;
  }
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return file == null ?bulidSplashScreen():buldImageForm();
  }
}
